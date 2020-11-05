#!/bin/bash

#########################################################################
# Purpose: Loads parameters, functions & issues startup messages
#########################################################################

# Get directory of this script
thisdir=$(dirname ${BASH_SOURCE[0]})

source $thisdir"/get_params.sh"	# Parameters, files and paths
source $thisdir"/functions.sh"	# Load functions file(s)
source $thisdir"/get_options.sh"	# Get & set command line options

