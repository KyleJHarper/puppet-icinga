#!/bin/bash

# Author       Kyle Harper
# Date         2014.05.20
# Description  A very simple script to check the number of procs running.  Also provides perfdata.
#

function usage {
  echo "A very simple script to check the number of procs running.  Also provides perfdata."
  echo "This script REQUIRES these tools:  awk, ps, wc"
  echo "  Usage:  ./check_procs.sh [-w #] [-c #] [-z #]"
  echo "  Switches"
  echo "    -c  #  Number of processes before throwing a critical exit code."
  echo "           No leading zeros!  Must be greater than warn (-w) value."
  echo "           Defaults to 100."
  echo "    -h     Show this help and quit."
  echo "    -w  #  Number of processes before throwing a warning exit code."
  echo "           No leading zeros!  Must be less than critical (-c) value."
  echo "           Defaults to 150."
  echo "    -z  #  Number of zombie processes before throwing a warning."
  echo "           Defaults to 5."
  echo ""
}


declare -i -r E_OK=0
declare -i -r E_WARNING=1
declare -i -r E_CRITICAL=2
declare -i -r E_UNKNOWN=3
declare -i    warning_threshold=100
declare -i    critical_threshold=150
declare -i    zombie_threshold=5
declare       _opt=''

while getopts ':c:hw:z:' _opt ; do
  case "${_opt}" in
    'c' ) critical_threshold=${OPTARG} ;;
    'h' ) usage ; exit ${E_UNKNOWN}    ;;
    'w' ) warning_threshold=${OPTARG}  ;;
    'z' ) zombie_threshold=${OPTARG}   ;;
    *   ) echo "Unknown option '${_opt}', aborting." ; exit ${E_UNKNOWN} ;;
  esac
done

# Preflight Checks
if [ ${critical_threshold} -le ${warning_threshold} ] ; then echo "Warning threshold (-w) must be LESS than critical (-c)." ; exit ${E_UNKNOWN} ; fi
if [ ${critical_threshold} -lt 2 ]                    ; then echo "Critical threshold (-c) cannot be less than 2."          ; exit ${E_UNKNOWN} ; fi
if [ ${warning_threshold} -lt 1 ]                     ; then echo "Warning threshold (-w) cannot be less than 1."           ; exit ${E_UNKNOWN} ; fi
if [ ${zombie_threshold} -lt 1 ]                      ; then echo "Zombie threshold (-z) cannot be less than 1."            ; exit ${E_UNKNOWN} ; fi


# Gather Raw Data
declare -r -i total=$(ps aux | wc -l)
declare -r -i zombies=$(ps aux | awk '{if($8 == "Z"){print $0}; }' | wc -l)

# Create the perfdata string
declare -r    perfdata="Procs=${total};;;; Zombies=${zombies};;;;"

if [ ${total} -gt ${critical_threshold} ] ; then
  echo "Process count is critically high: ${total} procs (warn/crit at ${warning_threshold}/${critical_threshold}). | ${perfdata}"
  exit ${E_CRITICAL}
fi
if [ ${total} -gt ${warning_threshold} ] ; then
  echo "Process count is getting high: ${total} procs (warn/crit at ${warning_threshold}/${critical_threshold}). | ${perfdata}"
  exit ${E_WARNING}
fi
echo "Process count is OK at ${total} processes. | ${perfdata}"
exit ${E_OK}
