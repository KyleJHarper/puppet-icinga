#!/bin/bash

#@ Author       Kyle Harper
#@ Date         2014.10.19
#@ Description  Read the disk usage of the local filesystems and push out perfdata.


function usage {
  echo "Read the disk usage of the local filesystems and push out perfdata."
  echo "Reports warnings for disk usage and inode usage."
  echo "This script REQUIRES these tools:  awk, df"
  echo "  Usage:  ./check_disks.sh [-w ##] [-c ##]"
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


declare -i -r    E_OK=0
declare -i -r    E_WARNING=1
declare -i -r    E_CRITICAL=2
declare -i -r    E_UNKNOWN=3
declare -i       warning_threshold=80
declare -i       critical_threshold=90
declare -i       i=0
declare          critical=false
declare          warning=false
declare          perfdata=''
declare          msg=''
declare          _opt=''

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


for _mount in $(df | awk '/^\// {print $6;}') ; do
  # Gather Raw Data
  let i++
  device="$(   df    ${_mount} | awk '/^\// {print $1;}')"  # -- Device Info
  total="$(    df    ${_mount} | awk '/^\// {print $2;}')"  # -- Bytes Total
  used="$(     df    ${_mount} | awk '/^\// {print $3;}')"  # -- Bytes Used
  percent="$(  df    ${_mount} | awk '/^\// {print $5;}')"  # -- Bytes Percentage Used
  percent="${percent%\%}"
  i_total="$(  df -i ${_mount} | awk '/^\// {print $2;}')"  # -- Inodes Total
  i_used="$(   df -i ${_mount} | awk '/^\// {print $3;}')"  # -- Inodes Used
  i_percent="$(df -i ${_mount} | awk '/^\// {print $5;}')"  # -- Inodes Percentage Used
  i_percent="${i_percent%\%}"

  # Build Perfdata and Return Message
  perfdata+="${_mount}_used=${used}KB;;;0;${total} "
  msg+="Disk ${i} (${_mount}) on device ${device}: ${used}/${total} KB (${percent}%), inode: ${i_used}/${i_total} (${i_percent}%). "

  # Compare and Set Flags
  [ ${percent} -gt ${critical_threshold} ]   && critical=true
  [ ${i_percent} -gt ${critical_threshold} ] && critical=true
  [ ${percent} -gt ${warning_threshold} ]    && warning=true
  [ ${i_percent} -gt ${warning_threshold} ]  && warning=true
done

# Reporting
if ${critical} ; then echo "Critical!  At least one disk is nearly full! ${msg} | ${perfdata}" ; exit ${E_CRITICAL} ; fi
if ${warning}  ; then echo "Warning, at least one disk is nearly full. ${msg}   | ${perfdata}" ; exit ${E_WARNING}  ; fi
echo "Disks OK, ${i} checked. ${msg} | ${perfdata}"
exit ${E_OK}
