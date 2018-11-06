#!/bin/bash

#########################################################################
# Purpose: Loads parameters, functions & issues startup messages
#########################################################################

# Reset includes directory
#includes_dir="${BASH_SOURCE%/*}"

source "get_params.sh"	# Parameters, files and paths
source "$DIR/includes/get_functions.sh"	# Load functions file(s)
source "$DIR/includes/get_options.sh"	# Get & set command line options

