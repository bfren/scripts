#!/bin/bash

# ======================================================================================================================
# CONFIG
# ======================================================================================================================

source backup-config.sh


# ======================================================================================================================
# VARIABLES
# ======================================================================================================================

START=`date +%s`
COMPRESS_FILE_NOW="$(date +%H%M)"
LOG="$LOG_DIR/backup-$(date +%Y%m%d).log"


# ======================================================================================================================
# START
# ======================================================================================================================

printf "\nStarting new backup\n" >> "$LOG"
mkdir -p "$LOG_DIR"


# ======================================================================================================================
# FUNCTIONS
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
  printf -v date '%(%Y-%m-%d %H:%M)T' -1

  # echo with date / time
  echo -e "$date $1...\c" 2>&1 | tee -a "$LOG";

}

# indent and print a string to the log file
#   1: string to print
p () { [[ ! -z "$1" ]] && printf "\n$1\n" | sed 's/^/  /' >> "$LOG"; }

# perform backup
#   1: file or directory to backup
#   2: (optional) directory to backup into - default is $BACKUP_DIR
backup () {

  # first argument is required
  if [[ -z "$1" ]]; then
    echo "You must pass a file or directory to backup"
    exit
  fi

  # use default backup dir if not set
  BACKUP_DIR_TMP="$BACKUP_DIR"
  [[ -n "$2" ]] && BACKUP_DIR_TMP="$2"

  # ensure backup directory exists
  mkdir -p "$BACKUP_DIR_TMP"

  # do rsync
  e "Backing up $1 to $BACKUP_DIR_TMP"

  if [ -z "$EXCLUSIONS_TXT" ]; then
    RESULTS=$(rsync -$RSYNC_ARGS --delete "$1" "$BACKUP_DIR_TMP")
  else
    RESULTS=$(rsync -$RSYNC_ARGS --exclude-from="$RSYNC_EXCLUSIONS" --delete "$1" "$BACKUP_DIR_TMP")
  fi

  # output changes with two-space indent
  p "$RESULTS"

  # done
  echo_done

}

# loop through backup array
#   1: associative array of directories / files to backup
backup_loop () {

  # get array
  local -n A=$1

  # loop
  for key in "${!A[@]}"; do
    backup "$key" "${A[$key]}"
  done

}

# compress backup files
compress () {

  if [ ! -z "$COMPRESS_DIR" ]; then

    e "Compressing $BACKUP_DIR to $COMPRESS_DIR"

    # create subdirectory for today
    COMPRESS_DIR_TODAY="$COMPRESS_DIR/$(date +%Y%m%d)"
    mkdir -p "$COMPRESS_DIR_TODAY"

    # do backup
    RESULTS=$(tar cfz - "$BACKUP_DIR" | split -b $COMPRESS_MAX_FILE_SIZE - "$COMPRESS_DIR_TODAY/$COMPRESS_FILE_NOW.tar.gz")
    p "$RESULTS"

    # done
    echo_done

  fi

}

# delete files older than a specified number of days
#  1: description of files to delete (e.g. log)
#  2: number of days
#  3: directory to search
delete_old () {

  # only delete if days is greater than zero
  if [ "$2" -gt 0 ] ; then

    # use arguments to delete old files
    e "Deleting $1 older than $2 days"
    DELETED=$(find "$3" -mtime +$2 -type f -delete)
    p "$DELETED"

    # done
    echo_done

  fi

}


# ======================================================================================================================
# Do Backup
# ======================================================================================================================

backup_loop D
backup_loop F


# ======================================================================================================================
# COMPRESS 
# ======================================================================================================================

compress


# ======================================================================================================================
# DELETE OLD FILES
# ======================================================================================================================

delete_old "logs" $KEEP_LOGS_FOR "$LOG_DIR"

if [ ! -z "$COMPRESS_DIR" ]; then
  delete_old "compressed backups" $KEEP_COMPRESSED_FOR "$COMPRESS_DIR"
fi


# ======================================================================================================================
# COMPLETE
# ======================================================================================================================

END=`date +%s`

((H=($END - $START) / 3600))
((M=(($END - $START) % 3600) / 60))
((S=($END - $START) % 60))
printf "Backup completed in %02dh %02dm %02ds\n" $H $M $S 2>&1 | tee -a "$LOG"
