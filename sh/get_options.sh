#!/bin/bash

#########################################################################
# Purpose: Gets command line switches and sets options accordingly
#
# Keeping this in separate script allows it to be used by individual
# pipeline scripts run on their own
#########################################################################


###########################################################
# Get options
#   -n  No confirm. All interactive warnings suppressed
#   -s  Silent mode. Suppresses screen echo.
#   -m	Send email notification. Must supply valid email 
#		in params file.
# 	-d 	Database to connect to (no default)
#	-c	Schema to connect to (no default)
###########################################################

i="true"						# Interactive mode on by default
e="true"						# Echo on by default

while [ "$1" != "" ]; do
    case $1 in
        -n | --nowarnings )		i="false"
        						;;
        -s | --silent )			e="false"
        						;;
        -m | --mail )         	m="true"
                                ;;
        -d | --database )       db="$2"
        						shift
                                ;;
        -c | --schema )         sch="$2"
        						shift
                                ;;
        * )                     echo "invalid option!"; exit 1
    esac
    shift
done
