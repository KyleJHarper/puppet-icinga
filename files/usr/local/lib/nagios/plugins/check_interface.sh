#!/bin/bash

#@Author  Kyle Harper  <KyleJHarper @ gmail . com>
#@Date    2014.10.18
#@Description  This script will check the interface specified for errors and other monitorable values if desired.
#@Description  _
#@Description  This script uses StupidBashTard as an experiement.  A static copy of an alpha version is used.  Specifically just "core".
#@Usage  ./check_interfaces.sh -i 'eth0 eth1'

#@$opt_c  Specify the number of RX or TX errors before a critical is thrown.
#@$opt_h  Show usage and quit.
#@$opt_i  Interface to check.  Defaults to eth0.  Multiple should be space-separated.
#@$opt_r  Specify the maximum bytes per second received before throwing a warning.  There is no critical value for this.
#@$opt_t  Specify the maximum bytes per second transmitted before throwing a warning.  There is no critical value for this.
#@$opt_w  Specify the number of RX or TX errors before a warning is thrown.



function usage {
  echo "Checks interfaces for RX/TX errors and and excessive traffic.  Traffic checks will only give a warning."
  echo "Usage: check_interfaces.sh [-c #] [-h] [-i 'eth0 lo'] [-r #] [-t #] [-w #]"
  echo "  Switches"
  echo "    -c      #   Number of RX or TX errors acceptable between run intervals before throwing a critical."
  echo "                Defaults to 10."
  echo "    -h          Show this help and quit."
  echo "    -i 'ethX'   Space-separated list of interfaces to run checks on.  Make sure to quote them so they"
  echo "                arrive in the same positional e.g.:  'eth0 eth1 lo'"
  echo "                Defaults to eth0."
  echo "    -r      #   Number of RX bytes per second acceptable before throwing a warning.  There is no critical"
  echo "                counter-part to this check."
  echo "                Defaults to 5000000 (5 MB/s), ~half a 100Mbps link."
  echo "    -t      #   Number of TX bytes per second acceptable before throwing a warning.  There is no critical"
  echo "                counter-part to this check."
  echo "                Defaults to 5000000 (5 MB/s), ~half a 100Mbps link."
  echo "    -w      #   Number of RX or TX errors acceptable between run intervals before throwing a warning."
  echo "                Defaults to 1."
  echo ""
  exit ${E_UNKNOWN}
}

function fail {
  #@Description  Sends a message to stdout and returns unknown.  This is usually due to a bug or a trapped error.
  #@$1  Message to send to stdout.
  #@$2  Optional return value.  Default is E_UNKNOWN (3).
  local rv=${E_UNKNOWN}
  [ ! -z "${2}" ] && rv=${2}
  ${DO_ROTATE} && mv "${CURRENT_DATA_FILE}" "${PREVIOUS_DATA_FILE}"
  echo "${1}"
  exit ${rv}
}

function largest_of {
  #@Description  Returns the value of the position that is largest.  All positionals must be intgers.
  #@$@  Integers to compare one after another to determine which is largest.  The actual posistion is irrelevant.
  [[ ${1} =~ [0-9]+ ]] || fail "No values given to the largest_of function.  Aborting."
  local winner=${1}
  while [[ ${2} =~ [0-9]+ ]] ; do
    [ ${2} -gt ${winner} ] && winner=${2}
    shift 1
  done
  echo ${winner}
  return 0
}

# Variables
declare -r -i E_OK=0                           #@$ Return value to use when everything is ok.
declare -r -i E_WARNING=1                      #@$ Return value when a warning threshold is reached.
declare -r -i E_CRITICAL=2                     #@$ Return value if a critical threshold is reached.
declare -r -i E_UNKNOWN=3                      #@$ Return value when there's a problem.
declare -r    GETOPTS_SHORT=':c:hi:r:t:w:'     #@$ List of short options for the getopts loop.
declare       DO_ROTATE=false                  #@$ Flag to determine if we should swap the data files (should only happen if we can successfully write the new one).
declare -r    CURRENT_DATA_FILE='/tmp/check_interfaces.sh__current_data'    #@$ File for current data so we get ifconfig in 1 call.
declare -r    PREVIOUS_DATA_FILE='/tmp/check_interfaces.sh__previous_data'  #@$ File for previous data for comparison.
declare       perfdata=''                      #@$ Stores performance data on interfaces.
declare       msg=''                           #@$ Information messages when things go well.
declare       bad_msg='ERROR.'                 #@$ Messages when things don't go so well.
declare    -i rv=${E_OK}                       #@$ Return value for all checks.

# Get options and update post-option values.
[ -f core.sh ] || fail "Cannot find core.sh (provided by the Stupid BashTard github project).  Aborting."
source core.sh
core_EasyGetOpts "${GETOPTS_SHORT}" '' "$@" || fail "Failed to get options.  Aborting."
declare -r -a interfaces=(${option_i:-eth0})            #@$ The interfaces to test.
declare -r -i ERROR_WARNING_THRESHOLD=${option_w:-1}    #@$ Number of errors between runs before throwing a warning.
declare -r -i ERROR_CRITICAL_THRESHOLD=${option_c:-10}  #@$ Number of errors between runs before throwing a critical.
declare -r -i RX_BPS_THRESHOLD=${option_r:-5000000}     #@$ Number of bytes per second received before throwing a warning.
declare -r -i TX_BPS_THRESHOLD=${option_t:-5000000}     #@$ Number of bytes per second transmitted before throwing a warning.

# Pre-flight checks
# -- Show usage if they just want help
[ "${option_h}" = 'true' ] && usage
# -- Make sure the tools we need exist.  Again, can't check ifconfig.
core_ToolExists 'awk' -v '-W version' || fail "This script requires 'awk'."
core_ToolExists 'grep'                || fail "This script requires 'grep'."
core_ToolExists 'stat'                || fail "This script requires 'stat'."
ifconfig 2>/dev/null 1>&2             || fail "This script requires 'ifconfig'."
# -- Generate and rotate interface data.  This will ensure at least a 2 second window for comparison at first run.
if [ ! -f "${PREVIOUS_DATA_FILE}" ] ; then
  ifconfig -a >"${PREVIOUS_DATA_FILE}" 2>/dev/null || fail "Can't write to previous data file: ${PREVIOUS_DATA_FILE}"
  sleep 2
fi
if [ ! -f "${CURRENT_DATA_FILE}" ] ; then
  >"${CURRENT_DATA_FILE}"  2>/dev/null || fail "Can't write to current data file: ${CURRENT_DATA_FILE}"
fi
ifconfig -a > "${CURRENT_DATA_FILE}" 2>/dev/null || fail "Can't write to current data file: ${CURRENT_DATA_FILE}"
DO_ROTATE=true


# Main Logic:  Process checks for each interface
for interface in "${interfaces[@]}" ; do
  # Quick reset of all the vars, just to be safe (and optimistic).
  link_status=1
  rx_errors=0 ; previous_rx_errors=0 ; rx_errors_delta=0
  tx_errors=0 ; previous_tx_errors=0 ; tx_errors_delta=0
  rx_bytes=0  ; previous_rx_bytes=0  ; rx_bps=0
  tx_bytes=0  ; previous_tx_bytes=0  ; tx_bps=0

  # If the interface doesn't exist, store warning text and continue.
  if ! ifconfig -a | grep -oE '^[^ ]+' | grep -qE "^${interface}\$" ; then
    bad_msg+="  Cannot find interface ${interface} to run checks on, skipping."
    rv=${E_UNKNOWN}
    continue
  fi

  # Check 1:  Link Status
  perl -e "\$/=''; while(<>) {print if /^${interface}/}" <"${CURRENT_DATA_FILE}" | grep -qE '^[ ]*UP'  || link_status=0

  # Check 2:  RX Errors
  rx_errors=$(         perl -e "\$/=''; while(<>){print if /^${interface}/}" <"${CURRENT_DATA_FILE}"  | grep -oE 'RX.*errors:[0-9]+' | awk -F: '{print $3}')
  previous_rx_errors=$(perl -e "\$/=''; while(<>){print if /^${interface}/}" <"${PREVIOUS_DATA_FILE}" | grep -oE 'RX.*errors:[0-9]+' | awk -F: '{print $3}')
  rx_errors_delta=$((${rx_errors} - ${previous_rx_errors}))
  [ ${rx_errors_delta} -gt ${ERROR_WARNING_THRESHOLD} ]  && rv=$(largest_of ${rv} ${E_WARNING}) && bad_msg+="  Excessive RX errors on ${interface}."
  [ ${rx_errors_delta} -gt ${ERROR_CRITICAL_THRESHOLD} ] && rv=$(largest_of ${rv} ${E_CRITICAL})

  # Check 3:  TX Errors
  tx_errors=$(         perl -e "\$/=''; while(<>){print if /^${interface}/}" <"${CURRENT_DATA_FILE}"  | grep -oE 'TX.*errors:[0-9]+' | awk -F: '{print $3}')
  previous_tx_errors=$(perl -e "\$/=''; while(<>){print if /^${interface}/}" <"${PREVIOUS_DATA_FILE}" | grep -oE 'TX.*errors:[0-9]+' | awk -F: '{print $3}')
  tx_errors_delta=$((${tx_errors} - ${previous_tx_errors}))
  [ ${tx_errors_delta} -gt ${ERROR_WARNING_THRESHOLD} ]  && rv=$(largest_of ${rv} ${E_WARNING}) && bad_msg+="  Excessive TX errors on ${interface}."
  [ ${tx_errors_delta} -gt ${ERROR_CRITICAL_THRESHOLD} ] && rv=$(largest_of ${rv} ${E_CRITICAL})

  # Check 4:  RX Bytes
  rx_bytes=$(         perl -e "\$/=''; while(<>){print if /^${interface}/}" <"${CURRENT_DATA_FILE}"  | grep -oE 'RX[ ]bytes:[0-9]+' | awk -F: '{print $2}')
  previous_rx_bytes=$(perl -e "\$/=''; while(<>){print if /^${interface}/}" <"${PREVIOUS_DATA_FILE}" | grep -oE 'RX[ ]bytes:[0-9]+' | awk -F: '{print $2}')
  rx_bps=$(( (${rx_bytes} - ${previous_rx_bytes}) / ($(stat -c%Y "${CURRENT_DATA_FILE}") - $(stat -c%Y "${PREVIOUS_DATA_FILE}") ) ))
  [ ${rx_bps} -gt ${RX_BPS_THRESHOLD} ] && rv=$(largest_of ${rv} ${E_WARNING}) && bad_msg+="  Heavy RX traffic on ${interface}."

  # Check 5:  TX Bytes
  tx_bytes=$(         perl -e "\$/=''; while(<>){print if /^${interface}/}" <"${CURRENT_DATA_FILE}"  | grep -oE 'TX[ ]bytes:[0-9]+' | awk -F: '{print $2}')
  previous_tx_bytes=$(perl -e "\$/=''; while(<>){print if /^${interface}/}" <"${PREVIOUS_DATA_FILE}" | grep -oE 'TX[ ]bytes:[0-9]+' | awk -F: '{print $2}')
  tx_bps=$(( (${tx_bytes} - ${previous_tx_bytes}) / ($(stat -c%Y "${CURRENT_DATA_FILE}") - $(stat -c%Y "${PREVIOUS_DATA_FILE}") ) ))
  [ ${tx_bps} -gt ${TX_BPS_THRESHOLD} ] && rv=$(largest_of ${rv} ${E_WARNING}) && bad_msg+="  Heavy TX traffic on ${interface}."

  # Append performance data
  msg+="Checks finished on ${interface}.  "
  perfdata+="${interface}_RX_errors=${rx_errors_delta};;;; "
  perfdata+="${interface}_TX_errors=${tx_errors_delta};;;; "
  perfdata+="${interface}_RX_bps=${rx_bps}b;;;; "
  perfdata+="${interface}_TX_bps=${tx_bps}b;;;; "
done

# -- Rotate files
mv "${CURRENT_DATA_FILE}" "${PREVIOUS_DATA_FILE}"

# -- Report data and bounce.
[ "${bad_msg}" = 'ERROR.' ] || msg="${bad_msg}  ${msg}"
echo "${msg} | ${perfdata}"
exit ${rv}
