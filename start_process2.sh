#!/bin/bash

######################################################
# Starts timer, sends confirmation email if requested
# and echoes operation start message
######################################################

# Get directory of this script
thisdir=$(dirname ${BASH_SOURCE[0]})

# Start timing & process ID
starttime="$(date)"
start=`date +%s%N`; prev=$start
pid=$$

if ! $quiet; then	
	echo "------ Process started at $starttime ------"
	echo ""

	# Send notification email if this option set
	if $notify; then 
		source "${thisdir}/mail_process_start.sh"	# Email notification
	fi
fi