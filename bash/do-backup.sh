#!/bin/bash
# Copyright (c) bfren - licensed under https://mit.bfren.dev/2020

set -euo pipefail


# ======================================================================================================================
#
# DO NOT EDIT THIS FILE
# CONFIGURATION IS DONE USING backup-config.sh
#
# ======================================================================================================================

BACKUP_VERSION=0.4.220315.1146


# ======================================================================================================================
# UTILS
# ======================================================================================================================

SCRIPT_DIR=`dirname $(readlink -f $0)`
UTILS="${SCRIPT_DIR}/utils.sh"
if [ ! -f "${UTILS}" ]; then
  echo "Please create ${UTILS} before running this script" && exit 1
fi
source "${UTILS}"


# ======================================================================================================================
# VARIABLES
# ======================================================================================================================

STARTED=`date +%s`
TODAY="$(date +%Y%m%d)"
NOW="$(date +%H%M)"
LOG_DIR="${SCRIPT_DIR}/log"
LOG="${LOG_DIR}/backup-${TODAY}.log"
echo "== BACKUP | ${TODAY}${NOW} ==" >> ${LOG}


# ======================================================================================================================
# FUNCTIONS - END
# ======================================================================================================================

# Remove running file and exit with an error
#   1: text to print ('Unknown error' if empty)
end () {
  rm ${RUNNING}
  e_error "${1:-Unknown error}"
}

# ======================================================================================================================
# CONFIG
# ======================================================================================================================

echo "================================================="
echo "== CONFIG ======================================="
echo "================================================="

e "Script directory: ${SCRIPT_DIR}"
e "Log directory: ${LOG_DIR}"
e "Log file: ${LOG}"

CONFIG="${SCRIPT_DIR}/backup-config.sh"
if [ ! -f "${CONFIG}" ] ; then
  end "Please create ${CONFIG} before running this script"
fi

e "Configuration: ${CONFIG}"
source "${CONFIG}"

e "Backup method: ${METHOD}"

if [ "${METHOD}" = "rclone" ] ; then

  e "rclone arguments: ${RCLONE_ARGS}"
  e_cont "rclone config: ${RCLONE_CONFIG}"
  if [ ! -f "${RCLONE_CONFIG}" ] ; then
    end "not found"
  fi
  e_done "found"
  e "rclone TPS limit: ${RCLONE_TPS_LIMIT}"

  RCLONE_EXCLUSIONS=${RCLONE_EXCLUSIONS:-${SCRIPT_DIR}/exclusions.txt}
  e_cont "rclone exclusions: ${RCLONE_EXCLUSIONS}"
   if [ ! -f "${RCLONE_EXCLUSIONS}" ] ; then
    end "not found"
  fi
  e_done "found"

else

  end "Unknown backup method: ${METHOD}"

fi

e "Backup directory root: ${BACKUP_DIR_ROOT}"

e "Keep logs for: ${KEEP_LOGS_FOR} days"

e_cont "Compressed file directory: ${COMPRESS_DIR}"
if [ -n "${COMPRESS_DIR}" ] ; then
  if [ ! -d "${COMPRESS_DIR}" ] ; then
    end "not found"
  fi
  e_done "found"
else
  e_done "not enabled"
fi

e "Compressed file maximum size: ${COMPRESS_MAX_FILE_SIZE}"
e "Keep compressed files for: ${KEEP_COMPRESSED_FOR} days"


# ======================================================================================================================
# RUNNING
# ======================================================================================================================

RUNNING="${SCRIPT_DIR}/running"
if [ -f "${RUNNING}" ] ; then
  e_error "Backup already running"
fi
touch "${RUNNING}"


# ======================================================================================================================
# START
# ======================================================================================================================

echo "================================================="
echo "== BACKUP ======================================="
echo "================================================="
e "Starting new backup (backup script version ${BACKUP_VERSION})"


# ======================================================================================================================
# FUNCTIONS - BACKUP
# ======================================================================================================================

# perform backup
#   1: file or directory to backup
#   2: (optional) directory to backup into - default is ${BACKUP_DIR_ROOT}/${1}
backup () {

  # first argument is required
  if [ -z "${1}" ]; then
    e_error "You must pass a file or directory to backup"
  fi
  FROM="${1}"
  e_dbg "From: ${FROM}"

  # use from path as the backup path, so the backup mirrors the filesystem
  if [ -d ${FROM} ] ; then
    BACKUP_PATH=${FROM}
  else
    BACKUP_PATH=`dirname ${FROM}`
  fi
  e_dbg "Backup path: ${BACKUP_PATH}"
  TO="${2:-${BACKUP_DIR_ROOT}${BACKUP_PATH}}"
  e_dbg "To: ${TO}"

  # if this is the first rclone with exclusions, echo the user agent and dump the filters
  if [ -z "${RCLONE_ALREADY_RUN-}" ]; then
    DUMP="--dump filters"
    export RCLONE_ALREADY_RUN=true
  fi
  e_dbg "Dump: ${DUMP:-not set}"

  # get variables
  EXC=${RCLONE_EXCLUSIONS}
  ARG=${RCLONE_ARGS}
  CFG=${RCLONE_CONFIG}
  TPS=${RCLONE_TPS_LIMIT}

  # do backup
  e "Backing up ${FROM} -> ${TO} (rclone)"
  rclone sync -${ARG} ${DUMP-} \
    --config="${CFG}" \
    --delete-excluded \
    --delete-during \
    --exclude-from="${EXC}" \
    --log-file="${LOG}" \
    --tpslimit=${TPS} \
    "${FROM}" \
    "${TO}" \
    || true

  e_done

}

# loop through backup array
#   1: associative array of directories / files to backup
backup_loop () {

  # get array
  local -n A=${1}
  e_dbg "Backup loop: ${1}"

  # loop
  for KEY in "${!A[@]}"; do
    e_dbg "Backup ${KEY} -> ${A[$KEY]:-not set}"
    backup "${KEY}" "${A[$KEY]}"
  done

}


# ======================================================================================================================
# FUNCTIONS - COMPRESS
# ======================================================================================================================

# compress backup files
compress () {

  if [ ! -z "${COMPRESS_DIR}" ]; then

    e "Compressing ${BACKUP_DIR_ROOT} -> ${COMPRESS_DIR}"

    # create subdirectory for today
    COMPRESS_DIR_TODAY="${COMPRESS_DIR}/${TODAY}"
    e_dbg "Compress directory: ${COMPRESS_DIR_TODAY}"
    mkdir -p "${COMPRESS_DIR_TODAY}"

    # compress file path
    COMPRESS_FILE="${COMPRESS_DIR_TODAY}/${TODAY}-${NOW}.tar.gz"
    e_dbg "Compress file: ${COMPRESS_FILE}"

    # do compression
    # need to remove '/'' prefix from BACKUP_DIR to avoid tar warning 'Removing leading `/' from member names'
    RESULTS=$(tar cfz - -C / "${BACKUP_DIR_ROOT#*/}" | split -b ${COMPRESS_MAX_FILE_SIZE} - "${COMPRESS_FILE}")
    e "${RESULTS}"

    # done
    e_done

  fi

}


# ======================================================================================================================
# BACKUP DIRECTORIES & FILES
# ======================================================================================================================

e_dbg "Backup: directories"
backup_loop D

e_dbg "Backup: files"
backup_loop F


# ======================================================================================================================
# COMPRESS
# ======================================================================================================================

e_dbg "Compress backup"
compress


# ======================================================================================================================
# DELETE OLD FILES AND DIRECTORIES
# ======================================================================================================================

e_dbg "Delete old logs"
delete_old "log" ${KEEP_LOGS_FOR} "${LOG_DIR}"

if [ ! -z "${COMPRESS_DIR}" ]; then
  e_dbg "Delete old compressed backups"
  delete_old "compressed backup" ${KEEP_COMPRESSED_FOR} "${COMPRESS_DIR}"
fi


# ======================================================================================================================
# COMPLETE
# ======================================================================================================================

e_cont "Removing ${RUNNING}"
rm ${RUNNING}
e_done

ENDED=`date +%s`
H=$(((ENDED - STARTED) / 3600))
M=$((((ENDED - STARTED) % 3600) / 60))
S=$(((ENDED - STARTED) % 60))
e_dbg "Ended: ${ENDED}, H: ${H}, M: ${M}, S:${S}"
printf "Backup completed in %02dh %02dm %02ds\n" ${H} ${M} ${S} 2>&1 | tee -a "${LOG}"
