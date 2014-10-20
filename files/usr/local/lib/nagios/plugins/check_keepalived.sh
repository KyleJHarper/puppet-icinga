#!/bin/bash

#@Author       Kyle Harper
#@Date         2014.10.19
#@Description  Check on ipvsadm output and provide perfdata.
#

function usage {
  echo "A very simple script to check on ipvsadm output (keepalived).  Also provides perfdata."
  echo "Perfdata will include: member connections, inactive connections, and inactive memory used."
  echo ""
  echo "This script REQUIRES these tools:  awk, grep, ipvsadm, touch"
  echo "  Usage:  ./check_keepalived.sh [-c #] [-i #,#] [-w #]"
  echo "  Switches"
  echo "    -c    #  Connction count for a VRRP instance in active state before throwing a critical"
  echo "             exit code.  No commas or decimals!  Must be greater than warn (-w) value."
  echo "             Defaults to ${active_critical_threshold}."
  echo "    -h       Show this help and quit."
  echo "    -i  #,#  Number of inactive connections before throwing warning/critical exit codes."
  echo "             InActConns use 128b RAM each."
  echo "             Defaults to '${inactive_warning_threshold},${inactive_critical_threshold}'."
  echo "    -w    #  Connction count for a VRRP instance in active state before throwing a warning"
  echo "             exit code.  No commas or decimals!  Must be less than critical (-c) value."
  echo "             Defaults to ${active_warning_threshold}."
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


declare -i -r    E_OK=0
declare -i -r    E_WARNING=1
declare -i -r    E_CRITICAL=2
declare -i -r    E_UNKNOWN=3
declare    -r    TMP_FILE='/tmp/ipvsadm_snapshot.tmp'
declare    -r    KEEPALIVED_PID_FILE='/var/run/keepalived.pid'
declare -i       active_warning_threshold=10000
declare -i       active_critical_threshold=16000
declare -i       inactive_warning_threshold=30000
declare -i       inactive_critical_threshold=48000
declare -i       RV=0
declare          perfdata=''
declare          msg=''
declare          _opt=''

while getopts ':c:hi:w:' _opt ; do
  case "${_opt}" in
    'c' ) active_critical_threshold=${OPTARG} ;;
    'h' ) usage ; exit ${E_UNKNOWN} ;;
    'i' ) if grep -Pqs '^[0-9]+,[0-9]+$' <<<"${OPTARG}" ; then
            inactive_warning_threshold="${OPTARG%,*}"
            inactive_critical_threshold="${OPTARG#*,}"
          else
            echo "Invalid value(s) for -i: '${OPTARG}'.  Showing help."
            usage ; exit ${E_UNKNOWN}
          fi
          ;;
    'w' ) active_warning_threshold=${OPTARG} ;;
    *   ) echo "Unknown option '${_opt}', aborting." ; exit ${E_UNKNOWN} ;;
  esac
done

# Preflight Checks
if [ ${EUID} -ne 0 ] ; then
  echo "Must be root to run this script (for ipvsadm mainly).  Aborting."
  exit ${E_UNKNOWN}
fi
if [ ${active_critical_threshold} -le ${active_warning_threshold} ] ; then
  echo "Warning threshold (-w) must be LESS than critical (-c)."
  exit ${E_UNKNOWN}
fi
if [ ${inactive_critical_threshold} -le ${inactive_warning_threshold} ] ; then
  echo "Inactive warning threshold (-i first number) must be LESS than critical (-i second number)."
  exit ${E_UNKNOWN}
fi
[ -f "${TMP_FILE}" ] && rm "${TMP_FILE}"
if ! touch "${TMP_FILE}" ; then
  echo "Unable to write to the temp snapshot file: ${TMP_FILE}  (aborting)."
  exit ${E_UNKNOWN}
fi


# Main logic
# -- Write data to snapshot file.  Prevents us from calling ipvsadm a bunch of times.
ipvsadm -L -n | grep -P -- '->[\s]+[0-9]+' >> "${TMP_FILE}"
if [ ${PIPESTATUS[0]} -ne 0 ] || ! grep -Pqs -- '->[\s]+[0-9]+' "${TMP_FILE}" ; then
  echo "IPVSADM failed or no members found.  Can't check anything else."
  exit ${E_CRITICAL}
fi
if [ ! -f "${KEEPALIVED_PID_FILE}" ] ; then
  echo "Keepalived doesn't appear to be running (missing pid file, doesn't support status check).  No further checks."
  exit ${E_CRITICAL}
fi
msg="IPVSADM/Keepalive appears to be running."

# -- Loop over VRRP Instances
while read -r VRRP ; do
  vip="${VRRP%:*}"
  port="${VRRP#*:}"
  active=0
  inactive=0
  inactive_mem=0
  # -- Loop over records and aggregate information
  while read -r ; do
    grep -Fqs '${VRRP}' <<<"${REPLY}" || continue 1
    member="$(awk '{print $2;}' <<<"${REPLY}")"
    let "active+=$(awk '{print $5;}' <<<"${REPLY}")"
    let "inactive+=$(awk '{print $6;}' <<<"${REPLY}")"
    let "inactive_mem+=$(( ${inactive} * 128 / 1024))"
  done <"${TMP_FILE}"
  [ ${active} -gt ${active_warning_threshold} ]  && msg+="  VRRP instance '${VRRP}' has too many active connections: ${active}."
  [ ${active} -gt ${active_warning_threshold} ]  && RV=$(greatest_of ${RV} ${E_WARNING})
  [ ${active} -gt ${active_critical_threshold} ] && RV=$(greatest_of ${RV} ${E_CRITICAL})

  [ ${inactive} -gt ${inactive_warning_threshold} ]  && msg+="  VRRP instance '${VRRP}' has too many inactive connections: ${inactive}."
  [ ${inactive} -gt ${inactive_warning_threshold} ]  && RV=$(greatest_of ${RV} ${E_WARNING})
  [ ${inactive} -gt ${inactive_critical_threshold} ] && RV=$(greatest_of ${RV} ${E_CRITICAL})

  perfdata+=" '${VRRP}_ActiveConn'=${active};${active_warning_threshold};${active_critical_threshold};0; "
  perfdata+=" '${VRRP}_InActiveConn'=${inactive};${inactive_warning_threshold};${inactive_critical_threshold};0; "
  perfdata+=" '${VRRP}_InActiveMem'=${inactive_mem}KB;;;; "
done < <(ipvsadm -L -n | awk '/^TCP / {print $2;}')
msg+="  Member checks finished."

# -- Clean up and leave
rm "${TMP_FILE}"
echo "${msg} | ${perfdata}"
exit ${RV}
