#!/bin/bash

#################################################################
# General purpose shell functions
# Author: Brad Boyle (bboyle@email.arizona.edu)
# Date created: 27 June 2016
#################################################################

trim_ws() {
	##########################################
	# Trims leading and trailing whitespace
	# 
	# Usage:
	# str=$(trim ${str})
	##########################################

	local var="$*"
	var2="$(echo -e ${var} | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	echo -n "$var2"
}

checkemail()
{
	# Simple email validation function
	# Returns 0 if valid, 2 is missing, 1 if bad
	
	if [ -z "$1" ]; then
		# No email supplied
		#echo "No email supplied"
		return 2
	else 
		email=$1
	
		#if [[ "$email" == ?*@?*.?* ]]  ; then
		if is_email_valid "$email" ;then
			#echo $email": Valid email"
			return 0
		else
			#echo $email": Bad email"
			return 1
		fi
	fi

}

function is_email_valid() {
	regex="^([A-Za-z]+[A-Za-z0-9]*((\.|\-|\_)?[A-Za-z]+[A-Za-z0-9]*){1,})@(([A-Za-z]+[A-Za-z0-9]*)+((\.|\-|\_)?([A-Za-z]+[A-Za-z0-9]*)+){1,})+\.([A-Za-z]{2,})+"
	[[ "${1}" =~ $regex ]]
}

confirm()
{
	#################################################################
	# Echos optional message if supplied
	# Then prompts to continue
	# Stops execution if any reply other than Y or y
	#
	# Options:
	# 	-i	inline; echo entire message on same line
	#################################################################

	# Get parameters
	inline="f"
	msg=""
	while [ "$1" != "" ]; do
		# Get options, if any, and treat final token as message		
		case $1 in
			-i )			inline="t"	
							shift
							;;
			* )            	msg="$1"
							break
							;;
		esac
	done	
	
	if [ $inline == "f" ]; then
		if ! [ -z "$1" ]; then 
			echo "$msg"
			echo
			msg=""
		fi
	else
		msg=$msg" "
	fi
	 	
	read -p  "${msg}Continue? (Y/N): " -r

	if ! [[ $REPLY =~ ^[Yy]$ ]]; then
		echo "Operation cancelled"
		exit 0
	fi

}

confirm_ync()
{
	#################################################################
	# Request confirmation and return response, or cancel 
	# 
	# Echos optional message if supplied then prompts to continue
	# If response is yes, continues and returns standardized 
	#	response "y"
	# If response is no, continues and returns standardized response "n"
	# If any response other than [Yy] or [Nn] given, cancels execution
	#
	# Options:
	# 	-i	inline; echo entire message on same line
	#################################################################

	# Get parameters
	inline="f"
	msg=""
	while [ "$1" != "" ]; do
		# Get options, if any, and treat final token as message		
		case $1 in
			-i )			inline="t"	
							shift
							;;
			* )            	msg="$1"
							break
							;;
		esac
	done	
	
	msg=$(trim ${msg})
	
	if [[ "$msg" == "" ]]; then msg="Continue?"; fi
	
	if [ $inline == "f" ] && ! [ "$msg" == "Continue?" ]; then
		if ! [ -z "$1" ]; then 
			echo "$msg"
			echo
			msg=""
		fi
	else
		msg=$msg" "
	fi
	 	
	read -p  "${msg} (Y/N): " -r
	local response=$REPLY

	if [[ $response =~ ^[Yy]$ ]]; then
		echo "y"
	elif [[ $response =~ ^[Nn]$ ]]; then
		echo "n"
	else
			echo "Operation cancelled"
			exit 0
	fi
}


echoi()
{
	#################################################################
	# Echos message only if first token=true, otherwise does nothing
	# If optionally pass most recent exit code, will abort if error
	# Provides a compact alternative to wrapping echo in if...fi
	# Options:
	# 	-n 	Standard echo -n switch, turns off newline
	# 	-r 	Carriage return without newline (replaces existing line)
	#	-e 	Exit status of last operation. If used, -e MUST be 
	#		followed by $? or $? saved as variable.
	# 	-l	No log. Suppresses default behavior of writing to logfile
	# Gotchas: 
	#	1. May behave unexpectedly if message = "true" or true
	#	2. Currenly only writes to logfile if screen echo on. Need to fix this.
	#	3. Logfile name ($glogfile) is global. Need to file this.
	#################################################################

	# first token MUST be 'true' to continue
	if [ "$1" = true ]; then
		
		shift
		log="true"
		msg=""
		n=" "
		o=""
		while [ "$1" != "" ]; do
			# Get remaining options, treating final 
			# token as message		
			case $1 in
				-n )			n=" -n "	
								shift
								;;
				-l )			log="false"	
								shift
								;;
				-r )			n=" -ne "	# Enable backslash (\) options
								o=" \r"		# The \ option to append 
								shift
								;;
				-e )			shift
								rc=$1
								#echo "rc="$rc
								if [[ $rc != 0 ]]; then 
   									kill -s TERM $TOP_PID
								fi
								shift
								;;
				* )            	msg="$1"
								break
								;;
			esac
		done	
		
		if [ "$log" == "false" ]; then
			echo $n "$msg"$o
		else
			echo $n "$msg"$o |& tee -a $glogfile
		fi
	fi
}

check_status_notify()
{
	# Check exit status & take one of the following actions:
	# 1. Fail: 
	#		a. Echos error
	#		b. Send failure notification email (email on only)
	#		c. Stop execution.
	# 2. Success: 
	#		a. Echo supplied success message (email on only)
	# Parameters: 
	#	-s $status	exit status code
	#	-i			echo on (interactive mode) [default: no echo]	 
	#	-n			standard echo -n switch, turns off newline [opt]
	#	-m	$msg	success message to echo [echo on only]
	#	-e $email	failure email address [default: no email]
	#	-h $header	failure email header
	#	-b $body	failure email body
	# Required functions:
	# 	echoi
	# Complete usage:
	# check_status_notify -s $status -r $rc -i -n -m $msg -e $email -h $header -b $body
	
	# Get parameters
	while [ "$1" != "" ]; do
		# Get options, treating final 
		# token as message		
		#send="false"
		case $1 in
			-s )			shift
							status=$1
							;;
			-r )			shift
							rc=$1
							;;
			-i )			shift
							i=$1	
							;;
			-e )			shift
							echomsg=$1	
							;;
			-t )			shift
							elapsed=$1	
							;;
			-n )			n=" -n "	
							;;
			-m )			send="true"
							shift
							email=$1
							;;
			-h )			shift
							header=$1
							;;
			-b )			shift
							body=$1
							;;
		esac
		shift
	done	

	if ! [[ $status = 0 ]]; then 
		if [[ "$m" = "true" ]]; then
			echo "$body"`date` | mail -s "$header" $email; 
		fi
		exit $rc
	else
		echoi $i "done ($elapsed seconds)"
	fi

}

etime()
{
	# Returns elapsed time in seconds
	# Accepts: $prev, previous time 
	# Returns: difference between now and $prev
	
	now=`date +%s%N`
	prev=$1
	elapsed=`echo "scale=2; ($now - $prev) / 1000000000" | bc`
	echo $elapsed
}

exists_column_psql()
{
	#############################################################
	# Uses postgres psql command to check if column $c exists in  
	# table $t in schema $s of database $d
	#  
	# Returns 't' if column exists, else 'f'
	#  
	# Usage:
	# exists_column_psql [-h $host] -u $user -d $db -s $schema -t $table -c $column
	#############################################################
	
	# Set defaults
	local host="localhost"

	# Get parameters
	while [ "$1" != "" ]; do
		case $1 in
			-u )			shift
							local user=$1
							;;
			-h )			shift
							local host=$1
							;;
			-d )			shift
							local db=$1
							;;
			-s )			shift
							local schema=$1
							;;
			-t )			shift
							local table=$1	
							;;
			-c )			shift
							local column=$1	
							;;
		esac
		shift
	done	
	
	sql_column_exists="SELECT EXISTS ( SELECT * FROM information_schema.columns WHERE column_name='$column' AND table_name='$table' AND table_schema='$schema') AS exists"
	column_exists=`psql -h $host -U $user -d $db -qt -c "$sql_column_exists" | tr -d '[[:space:]]'`
	echo $column_exists
}

exists_table_psql()
{
	#############################################################
	# Uses postgres psql command to check if table $t exists in 
	# schema $s of database $d
	# Returns 't' if table exists, else 'f'
	#
	# Usage:
	# exists_table_psql [-h $host] -u $user -d $db -s $schema -t $table
	#############################################################
	
	# Set defaults
	local host="localhost"

	# Get parameters
	while [ "$1" != "" ]; do
		case $1 in
			-u )			shift
							local user=$1
							;;
			-h )			shift
							local host=$1
							;;
			-d )			shift
							local db=$1
							;;
			-s )			shift
							local schema=$1
							;;
			-t )			shift
							local table=$1	
							;;
		esac
		shift
	done	
	
	sql_table_exists="SELECT EXISTS ( SELECT table_name FROM information_schema.tables WHERE table_name='$table' AND table_schema='$schema') AS exists_table"
	table_exists=`psql -h $host -U $user -d $db -qt -c "$sql_table_exists" | tr -d '[[:space:]]'`
	echo $table_exists
}

exists_schema_psql()
{
	#############################################################
	# Uses postgres psql command to check if schema $s exists in 
	# database $d
	# Returns 't' if schema exists, else 'f'
	#
	# Usage:
	# exists_schema_psql [-h $host] -u $user -d $db -s $schema
	#############################################################
	
	# Set defaults
	local host="localhost"

	# Get parameters
	while [ "$1" != "" ]; do
		case $1 in
			-u )			shift
							local user=$1
							;;
			-h )			shift
							local host=$1
							;;
			-d )			shift
							local db=$1
							;;
			-s )			shift
							local schema=$1
							;;
		esac
		shift
	done	
	
	sql_schema_exists="SELECT EXISTS ( SELECT schema_name FROM information_schema.schemata WHERE schema_name='$schema' ) AS exists_schema"
	schema_exists=`psql -h $host -U $user -d $db -qt -c "$sql_schema_exists" | tr -d '[[:space:]]'`
	echo $schema_exists
}

exists_index_psql()
{
	#############################################################
	# Uses postgres psql command to check if index $i exists in 
	# schema $s of database $d
	# Returns 't' if schema exists, else 'f'
	#
	# Usage:
	# exists_schema_psql [-h $host] -u $user -d $db -s $schema -i $index_name
	#############################################################
	
	# Set defaults
	local host="localhost"

	# Get parameters
	while [ "$1" != "" ]; do
		case $1 in
			-u )			shift
							local user=$1
							;;
			-h )			shift
							local host=$1
							;;
			-d )			shift
							local db=$1
							;;
			-s )			shift
							local schema=$1
							;;
			-i )			shift
							local idx=$1
							;;
		esac
		shift
	done	
	
	sql_index_exists="SELECT EXISTS ( SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE c.relname = '$idx' AND n.nspname = '$schema' ) AS a"
	index_exists=`psql -h $host -U $user -d $db -qt -c "$sql_index_exists" | tr -d '[[:space:]]'`
	echo $index_exists
}

exists_db_psql()
{
	# Uses psql command to check if postgres database $db exists
	# Returns 't' if db exists, else 'f'
	# Usage:
	# exists_db_psql $db
	
	
	if ! psql -lqt | cut -d \| -f 1 | grep -qw $1; then
		echo 'f'
	else
		echo 't'
	fi
}

has_records_psql()
{
	#############################################################
	# Uses postgres psql command to check if table $t has one or  
	# more records.
	# Returns 't' if table exists, else 'f'
	#
	# Usage:
	# exists_table_psql -u [user] -d [db] -t [table]
	# 
	# Note: table name can be schema qualified 
	#############################################################
	
	# Get parameters
	while [ "$1" != "" ]; do
		case $1 in
			-u )			shift
							user=$1
							;;
			-d )			shift
							db=$1
							;;
			-t )			shift
							table=$1	
							;;
		esac
		shift
	done	
	
	sql_has_records="SELECT EXISTS ( SELECT * FROM $table ) AS a"
	has_records=`psql -U $user -d $db -qt -c "$sql_has_records" | tr -d '[[:space:]]'`
	echo $has_records
}


trim() {
	##########################################
	# Trims leading and trailing whitespace
	# This is the best solution
	# See: https://stackoverflow.com/a/3352015/2757825
	#
	# Usage: myvar_trimmed=$(trim ${myvar})
	##########################################

    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}

is_unique_psql()
{
	#############################################################
	# Uses postgres psql command to check if all values of 
	# column $c are unique. Use to test for PK violations when
	# PK contraint not present.
	#  
	# Returns 't' if column values unique, else 'f'
	#  
	# Usage:
	# is_unique_psql -u [user] -d [db] -s [schema] -t [table] -c [column]
	#############################################################
	
	# Get parameters
	while [ "$1" != "" ]; do
		case $1 in
			-u )			shift
							user=$1
							;;
			-d )			shift
							db=$1
							;;
			-s )			shift
							schema=$1
							;;
			-t )			shift
							table=$1	
							;;
			-c )			shift
							column=$1	
							;;
		esac
		shift
	done	
		
	sql_is_unique="SELECT NOT EXISTS ( SELECT $column, COUNT(*) FROM $schema.$table GROUP BY $column HAVING COUNT(*)>1 ) AS a"
	is_unique=`psql -U $user -d $db -qt -c "$sql_is_unique" | tr -d '[[:space:]]'`
	echo $is_unique
}

count_rows_psql()
{
	#############################################################
	# Counts rows in table tbl in database $db & returns count
	#
	# Usage:
	# count_rows_psql -u [user] -d [db] -t [table]
	# 
	# Note: table name can be schema qualified 
	#############################################################
	
	# Get parameters
	while [ "$1" != "" ]; do
		case $1 in
			-u )			shift
							user=$1
							;;
			-d )			shift
							db=$1
							;;
			-t )			shift
							table=$1	
							;;
		esac
		shift
	done	
	
	sql_rows="SELECT COUNT(*) FROM $table"
	result=`psql -U $user -d $db -qt -c "$sql_rows" | tr -d '[[:space:]]'` 
	
	echo $result
}

drop_indexes() {
	##################################################
	# Drops all indexes on table $table in schema $sch
	# of database $db
	#
	# Notes:
	#	1. User must have all relevant permissions
	#	2. Primary key constraint must be named *_pkey* for -p option to work
	#
	# Requires custom functions:
	#  echoi()
	#  exists_db_psql()
	#  exists_schema_psql()
	#  exists_table_psql()
	#
	# Parameters:
	#	h	host (default: localhost)
	#	u	user name
	#	d	database name
	#	s	schema name
	#	t	table name
	#	p	drop primary key as well (default: false)
	#	c	drop foreign key constraints as well (default: false)
	#	a	cascade pk constraint: drops dependent table fk constraints
	#	q	quiet, no confirmation or progress echoes (default: false)
	#	
	# Usage:
	#	drop_all_indexes [-q] [-p] [-i] [-h $host] -u $user -d $db -s $schema -t $table
	##################################################

	local host='localhost'
	local quiet='f'
	local e='true'
	local drop_pk='f'
	local drop_con='f'
	local cascade=''
	local what='all indexes'

	# Dummy values double as automatic error messages 
	# and prevent dangerous parameter skipping
	local user='no-user-defined'
	local db='no-db-defined'
	local sch='no-schema-defined'
	local tbl='no-table-defined'

	# Get parameters
	while [ "$1" != "" ]; do
		# Get options, treating final 
		# token as message		
		#send="false"
		case $1 in
			-h )			shift
							host=$1
							;;
			-u )			shift
							user=$1
							;;
			-d )			shift
							db=$1
							;;
			-s )			shift
							sch=$1
							;;
			-t )			shift
							tbl=$1
							;;
			-q )			quiet='t'
							e=''
							;;
			-p )			drop_pk='t'
							;;
			-c )			drop_con='t'
							;;
			-a )			cascade=' CASCADE '
							;;
		esac
		shift
	done	
	
	if [ "$drop_pk" == "t" ]; then
		what="primary key and $what"
	fi 
	
	if [ "$drop_con" == "t" ]; then
		what=" $what and all constraints"
	fi 

	if [ "$quiet" == "f" ]; then
		read -p  "Drop ${what} on table ${tbl} in schema ${sch} of db ${db}? (Y/N): " -r

		if ! [[ $REPLY =~ ^[Yy]$ ]]; then
			echo "Operation cancelled"
			exit 0
		fi
	fi
	
	# Validate parameters
	if [[ $(exists_db_psql $db) == "f" ]]; then
		echo "$db: no such database (func drop_all_indexes)"; exit 1
	fi
	if [[ $(exists_schema_psql -h $host -u $user -d $db -s $sch) == "f" ]]; then
		echo "$sch: no such schema in db $db (func drop_all_indexes)"; exit 1
	fi
	if [[ $(exists_table_psql -h $host -u $user -d $db -s $sch -t $tbl) == "f" ]]; then
		echo "$tbl: no such table in schema $sch (func drop_all_indexes)"; exit 1
	fi

	if [ "$drop_con" == "t" ]; then
		echoi $e "Dropping unique and foreign key constraints:"
#		local sql_cons="SELECT conname, pg_catalog.pg_get_constraintdef(r.oid, true) as condef FROM pg_catalog.pg_constraint r WHERE r.conrelid='${tbl}'::regclass AND r.contype = 'f' ORDER BY 1"
		local sql_cons="SELECT conname as con, pg_catalog.pg_get_constraintdef(r.oid, true) as condef FROM pg_catalog.pg_constraint r WHERE r.conrelid='${tbl}'::regclass ORDER BY 1"
			for con in $(psql -h localhost -U $user -d $db -qt  -c "$sql_cons"); do
			echoi $e -n "  "$con"..."
			local sql_drop_con="ALTER TABLE ${tbl} DROP CONSTRAINT IF EXISTS ${con} ${cascade}"
			PGOPTIONS='--client-min-messages=warning' psql -h $host -U $user -d $db -q << EOF
			\set ON_ERROR_STOP on
			SET search_path TO $sch;
			$sql_drop_con
EOF
			echoi $e "done"
		done
	fi

	echoi $e "Dropping indexes:"
	local sql_indexes="select indexname from pg_indexes where schemaname='${sch}' and tablename='${tbl}' and indexname not like '%_pkey%' order by indexname"
	for idx in $(psql -h localhost -U $user -d $db -qt  -c "$sql_indexes"); do
		echoi $e -n "  "$idx"..."
		local sql_drop_idx="DROP INDEX IF EXISTS ${idx} ${cascade} "
		PGOPTIONS='--client-min-messages=warning' psql -h $host -U $user -d $db -q << EOF
		\set ON_ERROR_STOP on
		SET search_path TO $sch;
		$sql_drop_idx
EOF
		echoi $e "done"
	done
	
	if [ "$drop_pk" == "t" ]; then
		echoi $e "Dropping primary key:"
		local sql_pk_cons="select indexname as pk_con from pg_indexes where schemaname='${sch}' and tablename='${tbl}' and indexname like '%_pkey%' order by indexname"
		for pk_con in $(psql -h localhost -U $user -d $db -qt  -c "$sql_pk_cons"); do
			echoi $e -n "  "$idx"..."
			local sql_drop_pk="ALTER TABLE ${tbl} DROP CONSTRAINT IF EXISTS ${pk_con} ${cascade} "
			PGOPTIONS='--client-min-messages=warning' psql -h $host -U $user -d $db -q << EOF
			\set ON_ERROR_STOP on
			SET search_path TO $sch;
			$sql_drop_pk
EOF
			echoi $e "done"
		done
	fi
	
}

check_pk() {
	##################################################
	# Check if candidate primary key column is unique
	#
	# Requires functions:
	#  exists_db_psql()
	#  exists_schema_psql()
	#  exists_table_psql()
	#  exists_column_psql()
	#
	# Parameters:
	#	n	No quit: don't exit on error (default: false)
	#	q	Quiet: no progress echo unless error (default: false)
	#	h	Host (default: localhost)
	#	u	User 
	#	d	Database 
	#	s	Schema 
	#	t	Table 
	#	c	Column to check
	#	
	# Usage:
	#	check_pk [-q] [-n] [-h $host] -u $user -d $db -s $sch -t $tbl -c $col
	##################################################

	local host='localhost'
	local e='f'
	local fncname="check_pk"

	# Dummy values double as automatic error messages 
	# Also prevent dangerous parameter skipping
	local user='no-user-defined'
	local db='no-db-defined'
	local sch='no-schema-defined'
	local tbl='no-table-defined'
	local col='no-column-defined'
	local exit_on_error='t'
	local quiet='f'

	# Get parameters
	while [ "$1" != "" ]; do
		# Get options, treating final 
		# token as message		
		#send="false"
		case $1 in
			-h )			shift
							host=$1
							;;
			-u )			shift
							user=$1
							;;
			-d )			shift
							db=$1
							;;
			-s )			shift
							sch=$1
							;;
			-t )			shift
							tbl=$1
							;;
			-c )			shift
							col=$1
							;;
			-n )			exit_on_error='f'
							;;
			-q )			quiet='t'
							;;
		esac
		shift
	done	
	
	# Validate parameters
	if [[ $(exists_db_psql $db) == "f" ]]; then
		echo "$db: no such database (func ${fncname})"; exit 1
	fi
	if [[ $(exists_schema_psql -h $host -u $user -d $db -s $sch) == "f" ]]; then
		echo "$sch: no such schema in db $db (func ${fncname})"; exit 1
	fi
	if [[ $(exists_table_psql -h $host -u $user -d $db -s $sch -t $tbl) == "f" ]]; then
		echo "$tbl: no such table in schema $sch (func ${fncname})"; exit 1
	fi
	if [[ $(exists_column_psql -h $host -u $user -d $db -s $sch -t $tbl -c $col) == "f" ]]; then
		echo "$col: no such column in table ${sch}.${tbl} (func ${fncname})"; exit 1
	fi

	if [ "$quiet" == "f" ]; then
		echo -n "- Checking candidate pkey ${col} in table ${tbl}..."
	fi
	
	sql_is_unique="SELECT NOT EXISTS ( SELECT ${col}, COUNT(*) FROM ${sch}.${tbl} GROUP BY ${col} HAVING COUNT(*)>1 ) AS a"
	is_unique=`psql -h $host -U $user -d $db -qt -c "$sql_is_unique" | tr -d '[[:space:]]'`
	if [[ "$is_unique" == "f" ]]; then
		echo "ERROR: Column \"$col\" NOT UNIQUE!"
		if [ "$exit_on_error" == "t" ]; then
			exit 1
		fi
	else
		if [ "$quiet" == "f" ]; then
			echo "OK"
		fi
	fi

}
