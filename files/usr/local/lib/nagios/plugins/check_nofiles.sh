#!/bin/bash

function usage {
  echo 'This will scan all running process via lsof and find which, if any, are nearing their'
  echo 'hard limit for the ulimit nofiles setting.'
  echo '  Usage   : ./check_nofiles.sh [-c ##] [-w ##]'
  echo '  Switches: -c ##   Critical if percentage of soft-limit is over ##%  (default: 70%)'
  echo '            -d      Enable debug messages.'
  echo '            -s      Calculate based on soft limits instead of hard limits.'
  echo '            -w ##   Warn if percentage of soft-limit is over ##%  (default: 85%)'
  echo ''
}

function check_lsof {

  return 0
}

function is_a_valid_number {
  [ "${1:0:1}" = '0' ]     && return 1
  [[ "${1}" =~ ^[0-9]+$ ]] || return 1
  [ ${1} -gt 99 ]          && return 1
  return 0
}


################
#  Main Logic  #
################
declare       opt=''
declare       use_soft=false
declare    -i warning_level=70
declare    -i critical_level=85
declare       send_warning=false
declare       send_critical=false
declare    -i user_count=0
declare    -i process_count=0
declare    -i procs_nearly_full=0
declare       DEBUG=false
declare -r    TMP_FILE='/tmp/check_nofiles.sh.tmp'
declare -r -i OK=0
declare -r -i WARNING=1
declare -r -i CRITICAL=2
declare -r -i UNKNOWN=3
while getopts ':c:dsw:' opt ; do
  case "${opt}" in
    'c' ) if ! is_a_valid_number "${OPTARG}" ; then
            echo "Invalid value for critical level (must be a positive whole number under 100 without leading zeros).  Quitting."
            exit ${UNKNOWN}
          fi
          critical_level=${OPTARG}
          ;;
    'd' ) DEBUG=true
          ;;
    's' ) use_soft=true
          ;;
    'w' ) if ! is_a_valid_number "${OPTARG}" ; then
            echo "Invalid value for warning level (must be a positive whole number under 100 without leading zeros).  Quitting."
            exit ${UNKNOWN}
          fi
          warning_level=${OPTARG}
          ;;
    *   ) echo "Invalid syntax.  Showing usage and quitting."
          usage
          exit ${UNKNOWN}
          ;;
  esac
done

# -- Preflight Checks
${DEBUG} && echo "Testing preflight checks." >&2
if ! [ -r /etc/passwd ]                       ; then echo "Cannot read /etc/passwd.  Quitting."                                 ; exit ${UNKNOWN} ; fi
if ! [ ${EUID} -eq 0 ]                        ; then echo "Must execute this as root.  Quitting."                               ; exit ${UNKNOWN} ; fi
if [ ${warning_level} -ge ${critical_level} ] ; then echo "Warn level meets or exceeds critical level, that's silly.  Quitting" ; exit ${UNKNOWN} ; fi


# -- Loop through and check file limits for PROCESSES
eval declare -A lsof_table=( $(lsof | awk '{print $2 " " $3}' | uniq -c | awk '{printf "%s ", "[" $2 "]=" $1 ""}')  )
${DEBUG} && echo "Michael Poag made me do it!" >&2
for this_process in $(ps -A -o pid) ; do
  # Find the proc file and get a file count
  proc_file="/proc/${this_process}/limits"
  [ -r "${proc_file}" ] || continue
  let process_count++
  open_files=${lsof_table[${this_process}]}
  [ "${open_files}" = '' ] && open_files=$(lsof | awk -v pid="${this_process}" 'BEGIN{sum=0} {if ($2 == pid){sum++}} END{print sum}')

  # Scan the proc file for limits
  limit=0
  limit=$(grep -F 'Max open files' "${proc_file}" | awk '{print $5;}')
  ${use_soft} && limit=$(grep -F 'Max open files' "${proc_file}" | awk '{print $4;}')
  if [ ${limit} -lt 1 ] ; then echo "Error finding nofiles limit for process ${this_process}.  Quitting." ; exit ${UNKNOWN} ; fi

  # Calculate the percentage and report / set flags as needed
  percent=$(( ${open_files} * 100 / ${limit} ))
  if [ ${percent} -ge ${critical_level} ] ; then
    critical_msg+="Process ${this_process} owned by $(ps -p ${this_process} -o user --no-heading) is CRITICALLY CLOSE to depletion of file descriptors at ${percent}% (${open_files} / ${limit}).  "
    # The procs_nearly_full counter will get incremented in the warn block right below this.
    send_critical=true
  fi
  if [ ${percent} -ge ${warning_level} ] ; then
    warning_msg+="Process ${this_process} owned by $(ps -p ${this_process} -o user --no-heading) is nearing depletion of file descriptors at ${percent}% (${open_files} / ${limit}).  "
    let procs_nearly_full++
    send_warning=true
  fi

  # Debug output
  ${DEBUG} && echo "Process '${this_process}' is ${percent}% full (${open_files}/${limit})"
done


# -- Send notices and exit accordingly
declare perfdata="procs_nearly_full=${procs_nearly_full};"
if ${send_critical} ; then echo -e "${critical_msg} | ${perfdata}" ; exit ${CRITICAL} ; fi
if ${send_warning}  ; then echo -e "${warning_msg} | ${perfdata}"  ; exit ${WARNING}  ; fi
echo "File descriptor levels ok for all processes (${process_count} checked). | ${perfdata}"
exit ${OK}
