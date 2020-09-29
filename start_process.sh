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

if [ -z ${master+x} ]; then
	# Echo startup messages if running as master
	
	# Send notification email if this option set
	if [[ "$m" = "true" ]]; then 
		source "${thisdir}/mail_process_start.sh"	# Email notification
	fi

	echoi $e ""; echoi $e "------ Process started at $starttime ------"
	echoi $e ""
fi