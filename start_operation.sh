#!/bin/bash

######################################################
# Starts timer, sends confirmation email if requested
# and echoes operation start message
######################################################
# Get this directory
thisdir="${BASH_SOURCE%/*}"

# Start timing & process ID
starttime="$(date)"
start=`date +%s%N`; prev=$start
pid=$$

# Send notification email if this option set
if [[ "$m" = "true" ]]; then 
	source "${thisdir}/mail_process_start.sh"	# Email notification
fi

echoi $e ""; echoi $e "------ Operation started at $starttime ------"
echoi $e ""