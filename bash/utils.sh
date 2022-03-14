#!/bin/bash
# Copyright (c) bfren - licensed under https://mit.bfren.dev/2021


UTILS_VERSION=0.4.220314.1740


# ======================================================================================================================
# FUNCTIONS - ECHO & PRINT
# ======================================================================================================================

# echo to stdout and log file
#   1: string to echo
e () {

  # get current date / time
  DATE=$(date '+%Y-%m-%d %H:%M')

  # echo with date / time
  echo -e "${DATE} ${1}" 2>&1 | tee -a "${LOG}";

}

# echo to stdout and log file, without newline terminator
#   1: string to echo
e_cont () {

  # get current date / time
  DATE=$(date '+%Y-%m-%d %H:%M')

  # echo with date / time
  echo -e "${DATE} ${1}...\c" 2>&1 | tee -a "${LOG}";

}

# echo text or 'done' - in green to stdout, and to log file
#   1: string to echo (or 'done' if null)
e_done () {

  # done or text
  TEXT="${1:-done}"

  # colour commands
  GREEN='\033[1;32m'
  NC='\033[0m'

  # echo
  echo -e "${GREEN}${TEXT}${NC}"
  echo "${TEXT}" >> "${LOG}"

}

# echo an error message - in red to stdout, and to log file
e_error () {

  # get current date / time
  DATE=$(date '+%Y-%m-%d %H:%M')

  # colour commands
  RED='\033[1;91m'
  NC='\033[0m'

  # echo
  echo -e "${DATE} ${RED}${1}${NC}"
  echo "${DATE} ${1}" >> "${LOG}"

  # exit with error
  exit 1

}


# ======================================================================================================================
# FUNCTIONS - CLEANUP
# ======================================================================================================================

# delete files and directories older than a specified number of days
#  1: description of what is being deleted (e_cont.g. log)
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
    e_cont "Deleting ${1} files older than ${2} days"
    find "${3}" -type f -mmin +${MIN} -delete
    e_done

    # use arguments to delete old directories
    e_cont "Deleting ${1} directories older than ${2} days"
    find "${3}" -type d -mmin +${MIN} | xargs rm -r
    e_done

  fi

}
