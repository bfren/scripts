#!/bin/bash
# Copyright (c) bfren - licensed under https://mit.bfren.dev/2021


UTILS_VERSION=0.3.220311.1715


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
  echo "done" >> "${LOG}"

}

# echo to stdout and log file, without newline terminator
#   1: string to echo
e () { 

  # get current date / time
  DATE=$(date '+%Y-%m-%d %H:%M')

  # echo with date / time
  echo -e "${DATE} ${1}...\c" 2>&1 | tee -a "${LOG}";

}

# indent and print a string to the log file
#   1: string to print
p () { [[ ! -z "${1}" ]] && printf "\n${1}\n" | sed 's/^/  /' >> "${LOG}"; }


# ======================================================================================================================
# FUNCTIONS - CLEANUP
# ======================================================================================================================

# delete files and directories older than a specified number of days
#  1: description of what is being deleted (e.g. log)
#  2: number of days
#  3: directory to search
delete_old () {

  # ensure the directory is not empty
  [[ -z "${3}" ]] && return

  # only delete if days is greater than zero
  if [ "${2}" -gt 0 ] ; then

    # calculate minutes from the number of days
    MIN=$((60*24*${2}))

    # use arguments to delete old files
    e "Deleting ${1} files older than ${2} days"
    DELETED=$(find "${3}" -type f -mmin +${MIN} -delete)
    p "${DELETED}"

    # use arguments to delete old directories
    e "Deleting ${1} directories older than ${2} days"
    DELETED=$(find "${3}" -type d -mmin +${MIN} | xargs rm -r)
    p "${DELETED}"

    # done
    echo_done

  fi

}
