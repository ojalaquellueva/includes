#!/bin/bash

#########################################################################
# Purpose: Loads parameters, functions & issues startup messages for  
# component scripts of pipeline. Detects whether script is running  
# indendently or has been called by master scripts as part of pipeline,
# and adjust parameters, settings and messages accordingly.
#########################################################################

# Get directory of this script
thisdir=$(dirname ${BASH_SOURCE[0]})

# Load shared parameters if master script variable has not been set. 
if [ -z ${master+x} ]; then
	# reset master directory to parent directory
	DIR=$DIR_LOCAL"/.."
	
	# Base logfile name on local module
	export glogfile="$DIR/log/logfile_"$local_basename".txt"
	
	# Load shared parameters & options files
	source $thisdir"/get_params.sh"	# Parameters, files and paths
	source $thisdir"/functions.sh"	# Load functions file(s)
	source $thisdir"/get_options.sh" # Get command line options
	
	if [ ! -z ${src_local+x} ]; then
		# If applicable, set (missing) global source parameter 
		# to local source parameter
		src=$src_local
	fi
fi

# Load local parameters, if any
# Will over-write shared parameters of same name
if [ -f "$DIR_LOCAL/params.sh" ]; then
	source "$DIR_LOCAL/params.sh"

	###########################################################
	# Set local data directory
	#
	# If absolute path was(optionally) defined in local params 
	# file, then use this value. If not defined, then set path 
	# here relative to main data directory, using same name 
	# as base name of local file for final subdirectory.
	# Make sure data directory exists if you intend to use it!
	###########################################################

	# Assume relative path to start
	data_dir_local=$data_dir"/"$local_basename

	# Change to absolute path if absolute path supplied
	if [ -n "$data_dir_local_abs" ]; then
		if [[ $data_dir_local_abs == /* ]]; then
			data_dir_local=$data_dir_local_abs
		fi
	fi

fi	

# Load shared parameters if master script variable has not been set. 
if [ -z ${master+x} ]; then	
	# Substitute local process name if running independently
	pname=$pname_local
	pname_header=$pname_local_header

	# Reset the message suppression variable
	suppress_main='false'
	
	start=`date +%s%N`; prev=$start		# Get start time
	pid=$$								# Set process ID
	if [[ "$m" = "true" ]]; then 
		source "$DIR/includes/mail_process_start.sh"	# Email notification
	fi
		
fi
