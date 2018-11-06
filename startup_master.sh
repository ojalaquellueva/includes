#!/bin/bash

#########################################################################
# Purpose: Loads parameters, functions & issues startup messages
#########################################################################

# Get this directory
thisdir="${BASH_SOURCE%/*}"

#source "$DIR/get_params.sh"	# Parameters, files and paths
#source "$DIR/includes/get_functions.sh"	# Load functions file(s)
#source "$DIR/includes/get_options.sh"	# Get & set command line options
source $thisdir"/get_params.sh"	# Parameters, files and paths
source $thisdir"/get_functions.sh"	# Load functions file(s)
source $thisdir"/get_options.sh"	# Get & set command line options

