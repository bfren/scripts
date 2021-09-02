#!/bin/bash
# Copyright (c) bfren - licensed under https://mit.bfren.dev/2021


UTILS_VERSION=0.1.2102171400


# ======================================================================================================================
# FUNCTIONS - ECHO & PRINT
# ======================================================================================================================

# echo 'done' - in green to stdout, and to log file
echo_done () {

  # colour commands
  GREEN='\033[1;32m'
  NC='\033[0m'

  # echo
  echo -e "${GREEN}done${NC}"
  echo "done" >> "$LOG"

}

# echo to stdout and log file, without newline terminator
#   1: string to echo
e () { 

  # get current date / time
  DATE=$(date '+%Y-%m-%d %H:%M')

  # echo with date / time
  echo -e "$DATE $1...\c" 2>&1 | tee -a "$LOG";

}

# indent and print a string to the log file
#   1: string to print
p () { [[ ! -z "$1" ]] && SANITISED="$1" | printf "\n$SANITISED\n" | sed 's/^/  /' >> "$LOG"; }


# ======================================================================================================================
# FUNCTIONS - CLEANUP
# ======================================================================================================================

# delete files older than a specified number of days
#  1: description of files to delete (e.g. log)
#  2: number of days
#  3: directory to search
delete_old_files () {

  # only delete if days is greater than zero
  if [ "$2" -gt 0 ] ; then

    # use arguments to delete old files
    e "Deleting $1 files older than $2 days"
    MIN=$((60*24*$2))
    DELETED=$(find "$3" -type f -mmin +$MIN -delete)
    p "$DELETED"

    # done
    echo_done

  fi

}

# delete sub-directories (and contents) older than a specified number of days
#  1: description of directories to delete (e.g. backup)
#  2: number of days
#  3: root directory to search - DO NOT end with trailing slash ("/*" will be added automatically)
delete_old_dirs () {

  # only delete if days is greater than zero
  if [ "$2" -gt 0 ] ; then

    # use arguments to delete old directories
    e "Deleting $1 directories older than $2 days"
    MIN=$((60*24*$2))
    DELETED=$(find $3/* -type d -mmin +$MIN | xargs rm -rf)
    p "$DELETED"

    # done
    echo_done

  fi

}