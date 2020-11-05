#!/bin/bash

#########################################################################
# Purpose: Loads parameters, functions & issues startup messages
#########################################################################

# Get directory of this script
# See: https://unix.stackexchange.com/a/4658/392830
thisdir=($_)

source $thisdir"/get_params.sh"	# Parameters, files and paths
source $thisdir"/functions.sh"	# Load functions file(s)
source $thisdir"/get_options.sh"	# Get & set command line options

