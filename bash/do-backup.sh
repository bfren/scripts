#!/bin/bash
# Copyright (c) bfren - licensed under https://mit.bfren.dev/2020

set -u


# ======================================================================================================================
#
# DO NOT EDIT THIS FILE
# CONFIGURATION IS DONE USING backup-config.sh
#
# ======================================================================================================================

BACKUP_VERSION=0.3.2203010845


# ======================================================================================================================
# UTILS
# ======================================================================================================================

SCRIPT_DIR=$(dirname ${0})
UTILS="${SCRIPT_DIR}/utils.sh"
if [ ! -f "${UTILS}" ]; then
  echo "Please create ${UTILS} before running this script"
  exit
fi

source "${UTILS}"


# ======================================================================================================================
# VARIABLES
# ======================================================================================================================

START=`date +%s`
TODAY="$(date +%Y%m%d)"
NOW="$(date +%H%M)"
LOG_DIR="${SCRIPT_DIR}/log"
LOG="${LOG_DIR}/backup-${TODAY}.log"


# ======================================================================================================================
# RUNNING
# ======================================================================================================================

RUNNING="${SCRIPT_DIR}/running"
if [ -f "${RUNNING}" ] ; then
  e "Backup already running" && echo ""
  exit
fi

touch "${RUNNING}"


# ======================================================================================================================
# CONFIG
# ======================================================================================================================

CONFIG="${SCRIPT_DIR}/backup-config.sh"
if [ ! -f "${CONFIG}" ]; then
  e "Please create ${CONFIG} before running this script" && echo ""
  exit
fi

source "${CONFIG}"


# ======================================================================================================================
# START
# ======================================================================================================================

p "Starting new backup (backup script version ${BACKUP_VERSION})"


# ======================================================================================================================
# FUNCTIONS - BACKUP
# ======================================================================================================================

# perform backup using rsync
#   1: file or directory to backup
#   2: directory to backup into
backup_rsync() {

  FROM="${1}"
  TO="${2}"
  EXC=${RSYNC_EXCLUSIONS:-${SCRIPT_DIR}/exclusions.txt}

  if [ -z "${EXC}" ] || [ ! -f "${EXC}" ]; then
    RESULTS=$(rsync -${RSYNC_ARGS} --delete --force "${FROM}" "${TO}")
  else
    RESULTS=$(rsync -${RSYNC_ARGS} --exclude-from="${EXC}" --delete "${FROM}" "${TO}}")
  fi

}

# perform backup using rclone
# progress will be sent to stdout, everything else logged to the log file directly
#   1: file or directory to backup
#   2: directory to backup into
backup_rclone() {

  printf "\n" 2>&1 | tee -a "${LOG}";

  RCLONE_BACKUP_VERSION=$(rclone version | grep -Po -m1 "(\d+\.)+\d+")
  RCLONE_USER_AGENT="ISV|rclone.org|rclone/v${RCLONE_BACKUP_VERSION}"

  EXC=${RCLONE_EXCLUSIONS:-${SCRIPT_DIR}/exclusions.txt}
  ARG=${RCLONE_ARGS}
  CFG=${RCLONE_CONFIG}
  UAG=${RCLONE_USER_AGENT}
  TPS=${RCLONE_TPS_LIMIT}

  export GODEBUG=asyncpreemptoff=1 # https://forum.rclone.org/t/interrupted-system-call-errors-when-sync-solved/20025

  FROM="${1}"
  TO="${2}"

  if [ -z "${EXC}" ] || [ ! -f "${EXC}" ]; then
    rclone sync -${ARG} --config="${CFG}" --log-file="${LOG}" --user-agent "${UAG}" --tpslimit ${TPS} --delete-during "${FROM}" "${TO}"
  else
    # if this is the first rclone with exclusions, dump the filters
    if [ "${RCLONE_COUNT}" -eq "0" ]; then
      rclone sync -${ARG} --config="${CFG}" --log-file="${LOG}" --user-agent "${UAG}" --tpslimit ${TPS} --exclude-from "${EXC}" --delete-excluded --delete-during --dump filters "${FROM}" "${TO}"
      ((RCLONE_COUNT=RCLONE_COUNT+1))
    else
      rclone sync -${ARG} --config="${CFG}" --log-file="${LOG}" --user-agent "${UAG}" --tpslimit ${TPS} --exclude-from "${EXC}" --delete-excluded --delete-during "${FROM}" "${TO}"
    fi
  fi

  RESULTS="Syncing ${FROM} -> ${TO} finished."

}

RCLONE_COUNT=0

# perform backup
#   1: file or directory to backup
#   2: (optional) directory to backup into - default is ${BACKUP_DIR_ROOT}/${1}
backup () {

  # first argument is required
  if [[ -z "$1" ]]; then
    echo "You must pass a file or directory to backup"
    exit
  fi
  FROM="${1}"

  # use default backup dir if not set
  if [ -d ${FROM} ] ; then
    BACKUP_PATH=${FROM}
  else
    BACKUP_PATH=`dirname ${FROM}`
  fi
  TO="${2:-${BACKUP_DIR_ROOT}${BACKUP_PATH}}"

  # do backup
  e "Backing up ${FROM} to ${TO}"

  # use specified method
  case ${METHOD} in
    "rsync") backup_rsync "${FROM}" "${TO}";;
    "rclone") backup_rclone "${FROM}" "${TO}";;
    *) p "Unknown backup method '${METHOD}'.";;
  esac

  # output changes with two-space indent
  p "${RESULTS}"

  # done
  echo_done

}

# loop through backup array
#   1: associative array of directories / files to backup
backup_loop () {

  # get array
  local -n A=${1}

  # loop
  for KEY in "${!A[@]}"; do
    backup "${KEY}" "${A[$KEY]}"
  done

}


# ======================================================================================================================
# FUNCTIONS - COMPRESS
# ======================================================================================================================

# compress backup files
compress () {

  if [ ! -z "${COMPRESS_DIR}" ]; then

    e "Compressing ${BACKUP_DIR_ROOT} to ${COMPRESS_DIR}"

    # create subdirectory for today
    COMPRESS_DIR_TODAY="${COMPRESS_DIR}/${TODAY}"
    mkdir -p "${COMPRESS_DIR_TODAY}"

    # compress file path
    COMPRESS_FILE="${COMPRESS_DIR_TODAY}/${TODAY}-${NOW}.tar.gz"

    # do compression
    # need to remove '/'' prefix from BACKUP_DIR to avoid tar warning 'Removing leading `/' from member names'
    RESULTS=$(tar cfz - -C / "${BACKUP_DIR_ROOT#*/}" | split -b ${COMPRESS_MAX_FILE_SIZE} - "${COMPRESS_FILE}")
    p "${RESULTS}"

    # done
    echo_done

  fi

}


# ======================================================================================================================
# BACKUP DIRECTORIES & FILES
# ======================================================================================================================

backup_loop D
backup_loop F


# ======================================================================================================================
# COMPRESS
# ======================================================================================================================

compress


# ======================================================================================================================
# DELETE OLD FILES AND DIRECTORIES
# ======================================================================================================================

delete_old_files "log" ${KEEP_LOGS_FOR} "${LOG_DIR}"
delete_old_dirs "log" ${KEEP_LOGS_FOR} "${LOG_DIR}"

if [ ! -z "${COMPRESS_DIR}" ]; then
  delete_old_files "compressed backup" ${KEEP_COMPRESSED_FOR} "${COMPRESS_DIR}"
  delete_old_dirs "compressed backup" ${KEEP_COMPRESSED_FOR} "${COMPRESS_DIR}"
fi


# ======================================================================================================================
# COMPLETE
# ======================================================================================================================

END=`date +%s`

((H=(${END} - ${START}) / 3600))
((M=((${END} - ${START}) % 3600) / 60))
((S=(${END} - ${START}) % 60))
printf "Backup completed in %02dh %02dm %02ds\n" ${H} ${M} ${S} 2>&1 | tee -a "${LOG}"

rm "${RUNNING}"
