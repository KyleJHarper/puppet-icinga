#!/bin/bash

# Author       Kyle Harper
# Date         2014.10.19
# Description  A very simple script to read the memory use of a system and report on it.  Also provides perfdata.
#

function usage {
  echo "A very simple script to read the memory use of a system and report on it.  Also provides perfdata."
  echo "This script REQUIRES these tools:  awk, free"
  echo "  Usage:  ./check_memory.sh [-w ##] [-c ##]"
  echo "  Switches"
  echo "    -c  ##  Percentage before throwing a critical exit code.  No % sign!"
  echo "            No leading zeros!  Must be greater than warn (-w) value."
  echo "            Defaults to 90."
  echo "    -h      Show this help and quit."
  echo "    -w  ##  Percentage before throwing a warning exit code.  No % sign!"
  echo "            No leading zeros!  Must be less than critical (-c) value."
  echo "            Defaults to 80."
  echo ""
}


declare -i -r E_OK=0
declare -i -r E_WARNING=1
declare -i -r E_CRITICAL=2
declare -i -r E_UNKNOWN=3
declare -i    warning_threshold=80
declare -i    critical_threshold=90
declare       _opt=''

while getopts ':c:hw:' _opt ; do
  case "${_opt}" in
    'c' ) critical_threshold=${OPTARG} ;;
    'h' ) usage ; exit ${E_UNKNOWN}    ;;
    'w' ) warning_threshold=${OPTARG}  ;;
    *   ) echo "Unknown option '${_opt}', aborting." ; exit ${E_UNKNOWN} ;;
  esac
done

# Preflight Checks
if [ ${critical_threshold} -le ${warning_threshold} ] ; then echo "Warning threshold (-w) must be LESS than critical (-c)." ; exit ${E_UNKNOWN} ; fi
if [ ${critical_threshold} -lt 2 ]                    ; then echo "Critical threshold (-c) cannot be less than 2."          ; exit ${E_UNKNOWN} ; fi
if [ ${critical_threshold} -gt 99 ]                   ; then echo "Critical threshold (-c) cannot be greater than 99."      ; exit ${E_UNKNOWN} ; fi
if [ ${warning_threshold} -lt 1 ]                     ; then echo "Warning threshold (-w) cannot be less than 1."           ; exit ${E_UNKNOWN} ; fi
if [ ${warning_threshold} -gt 98 ]                    ; then echo "Warning threshold (-w) cannot be greater than 98."       ; exit ${E_UNKNOWN} ; fi


# Gather Raw Data
declare -r -i total_b=$(  free -b | awk '/^Mem/ {print $2 ;}')
declare -r -i total_mb=$( free -m | awk '/^Mem/ {print $2 ;}')
declare -r -i free_b=$(   free -b | awk '/^Mem/ {print $4 ;}')
declare -r -i free_mb=$(  free -m | awk '/^Mem/ {print $4 ;}')
declare -r -i buffer_b=$( free -b | awk '/^Mem/ {print $6 ;}')
declare -r -i buffer_mb=$(free -m | awk '/^Mem/ {print $6 ;}')
declare -r -i cache_b=$(  free -b | awk '/^Mem/ {print $7 ;}')
declare -r -i cache_mb=$( free -m | awk '/^Mem/ {print $7 ;}')

# Compute Differences and Percentages
declare -r -i used_b=$((  ${total_b}  - ${free_b}  - ${buffer_b} -  ${cache_b}  ))
declare -r -i used_mb=$(( ${total_mb} - ${free_mb} - ${buffer_mb} - ${cache_mb} ))
declare -r -i used_percentage=$(( ${used_b} * 100 / ${total_b} ))

# Create the perfdata string
declare -r    perfdata="Used=${used_mb}MB;;;0;${total_mb} Cache=${cache_mb}MB;;;0;${total_mb} Buffers=${buffer_mb}MB;;;0;${total_mb} Free=${free_mb}MB;;;0;${total_mb}"

if [ ${used_percentage} -gt ${critical_threshold} ] ; then
  echo "Memory consumption is critically high: ${used_percentage}%. | ${perfdata}"
  exit ${E_CRITICAL}
fi
if [ ${used_percentage} -gt ${warning_threshold} ] ; then
  echo "Memory consumption is getting high: ${used_percentage}%. | ${perfdata}"
  exit ${E_WARNING}
fi
echo "Memory OK at ${used_percentage}%. | ${perfdata}"
exit ${E_OK}
