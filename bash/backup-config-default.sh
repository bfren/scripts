#!/bin/bash

# ======================================================================================================================
# BACKUP DIRS
# ======================================================================================================================

# the directory where you want your backups to be stored
BACKUP_DIR="/path/to/backup"

# the directory for storing files in your home directory (e.g. do-backup.sh)
BACKUP_DIR_HOME="$BACKUP_DIR/home"


# ======================================================================================================================
# RSYNC
# ======================================================================================================================

# the arguments used by rsync
RSYNC_ARGS="rptgoiDL"

# path to rsync exclusions text file
# if this is not set, nothing will be excluded from the backup
RSYNC_EXCLUSIONS="/path/to/exclusions.txt"


# ======================================================================================================================
# LOGGING
# ======================================================================================================================

# the directory where log files will be stored
LOG_DIR="/path/to/log"

# the number of days to keep log files for
# if this is 0, no files will be deleted
KEEP_LOGS_FOR=28


# ======================================================================================================================
# COMPRESSION
# ======================================================================================================================

# the directory where you want to stored compressed backup files
# compression is done in subfolders by day, and then files by time
# if this is not set, compression will not happen
COMPRESS_DIR="/path/to/compress"

# the maximum size of compressed files
COMPRESS_MAX_FILE_SIZE=1024m

# the number of days to keep log files for
# if this is 0, no files will be deleted
KEEP_COMPRESSED_FOR=28


# ======================================================================================================================
# DIRECTORIES
# ======================================================================================================================

declare -A D
D["/path/to/dir/0"]="" # empty string will use $BACKUP_DIR
D["/path/to/dir/1"]="/path/to/backup/dir"


# ======================================================================================================================
# FILES
# ======================================================================================================================

declare -A F
F["/path/to/file/0"]="" # empty string will use $BACKUP_DIR
F["/path/to/file/1"]="/path/to/backup/dir"
