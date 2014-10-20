#!/bin/bash


function usage {
  echo "This script will check postgres for problems.  Currently it only checks service status and connection levels."
  echo "This script requires the following tools: awk, grep, psql"
  echo "  Usage: ./check_postgres.sh [-c ##] [-w ##]"
  echo "  Switches:"
  echo "    -c ##   Percentage before sending a CRITICAL response code.  (Default: 90%)"
  echo "    -d      Enable debug output."
  echo "    -w ##   Percentage before sending a WARNING response code.  (Default: 80%)"
  echo ""
}
function greatest_of {
  # Compares all positionals and returns the biggest one
  local -i biggest=$1
  while [ ! -z "${2}" ] ; do
    shift
    [ ${biggest} -lt ${1} ] && biggest=${1}
  done
  echo ${biggest}
  return 0
}


# -- Variable
declare    -i critical_threshold=90
declare    -i warning_threshold=80
declare       msg=''
declare       perfdata=''
declare    -i MAX_CONNECTIONS=1
declare -r -i DB_SIZE_WARNING=8000    # in MB
declare -r -i DB_SIZE_CRITICAL=10000  # in MB
declare       DEBUG=false
declare -r -i E_OK=0
declare -r -i E_WARNING=1
declare -r -i E_CRITICAL=2
declare -r -i E_UNKNOWN=3
declare    -i CONNECTIONS_RV=0
declare    -i DB_SIZE_RV=0

while getopts ':c:dw:' opt ; do
  case "${opt}" in
    'c' )  critical_threshold=${OPTARG} ;;
    'd' )  DEBUG=true                   ;;
    'w' )  warning_threshold=${OPTARG}  ;;
    *   )  echo "Invalid option '${opt}'.  Aborting." ; exit ${E_UNKNOWN} ;;
  esac
done

# -- Preflight checks
${DEBUG} && echo "Running preflight checks." >&2
if [ ${EUID} -ne 0 ] ; then echo "This script must run as root." ; exit ${E_UNKNOWN} ; fi
if [ ${critical_threshold} -le ${warning_threshold} ] ; then
  echo "Warning threshold (${warning_threshold}%) must be lower than the criical threshold (${critical_threshold}%).  Aborting."
  exit ${E_UNKNOWN}
fi
#Update Max Connections
MAX_CONNECTIONS=$(grep -oP 'max_connections[\s]+=[\s]+[0-9]+' /etc/postgresql/8.4/main/postgresql.conf | awk '{print $3;}')
if [ $? -ne 0 ] || [ ${MAX_CONNECTIONS} -le 1 ] ; then
  echo "Could not find max connections value.  Aborting."
  exit ${E_UNKNOWN}
fi


# -- Main
${DEBUG} && echo "Testing service status" >&2
if ! service postgresql-8.4 status >/dev/null 2>&1 ; then
  echo "Postgres isn't running.  That's probably a bad thing.  Can't check anything else."
  exit ${E_CRITICAL}
fi
msg+="Postgres service is running."


${DEBUG} && echo "Testing max connections threshold." >&2
declare -i connection_count=$(su postgres -c "psql -t <<<'select count(*) from pg_stat_activity;'")
if [ $? -ne 0 ] || ! grep -q -s -P '[0-9]+' <<<"${connection_count}" ; then
  msg+="  Error getting the connection count.  Can't discern value (${connection_count})."
  CONNECTIONS_RV=${E_UNKNOWN}
else
  declare -i connection_percent=$(( ${connection_count} * 100 / ${MAX_CONNECTIONS}))
  if [ ${connection_percent} -ge ${warning_threshold} ] ; then
    msg+="  Connection usage too high: ${connection_count}/${MAX_CONNECTIONS} (${connection_percent}%)."
    CONNECTIONS_RV=${E_WARNING}
    [ ${connection_percent} -ge ${critical_threshold} ] && CONNECTIONS_RV=${E_CRITICAL}
  else
    msg+="  Connection usage (${connection_count}/${MAX_CONNECTIONS}, ${connection_percent}%) is acceptable."
  fi
  perfdata+=" connections=${connection_count};;;0;${MAX_CONNECTIONS} "
fi


${DEBUG} && echo "Testing database sizes." >&2
declare -i dbsize
for db in $(su postgres -c "psql -tc \"SELECT datname FROM pg_database WHERE datistemplate = false;\"") ; do
  ${DEBUG} && echo "  Checking '${db}'..." >&2
  dbsize=0
  dbsize=$(su postgres -c "psql -tc \"SELECT pg_database_size('${db}');\"")
  if [ $? -ne 0 ] ; then msg+="  Error checking DB sizes (died checking '${db}')." ; DB_SIZE_RV=${E_UNKNOWN} ; break ; fi
  let "dbsize/=1048576"
  if [ ${dbsize} -gt ${DB_SIZE_WARNING} ] ; then msg+="  Database '${db}' too big." ; DB_SIZE_RV=$(greatest_of ${DB_SIZE_RV} ${E_WARNING}) ; fi
  [ ${dbsize} -gt ${DB_SIZE_CRITICAL} ] && DB_SIZE_RV=${E_CRITICAL}
  perfdata+=" ${db}_size=${dbsize}MB;${DB_SIZE_WARNING};${DB_SIZE_CRITICAL};; "
done
msg+="  Database size checks completed."

echo "${msg} | ${perfdata}"
exit $(greatest_of ${CONNECTIONS_RV} ${DB_SIZE_RV})
