#!/bin/bash
# Copyright (c) bfren - licensed under https://mit.bfren.dev/2020

# ======================================================================================================================
# BACKUP METHOD
# ======================================================================================================================

# 'rclone' (must be installed or it won't work!)
METHOD="rclone"
DEBUG=0


# ======================================================================================================================
# BACKUP DIRS
# ======================================================================================================================

# absolute path to the directory where you want your backups to be stored
BACKUP_DIR_ROOT="/path/to/backup/root"


# ======================================================================================================================
# RCLONE
# ======================================================================================================================

# the arguments used by rclone
RCLONE_ARGS="cvP"

# path to the rclone configuration file (must be readable by current user)
RCLONE_CONFIG=""

# (optional) TPS limit - default is 0 (unlimited)
RCLONE_TPS_LIMIT=0

# absolute path to rclone exclusions text file
# if this is not set, nothing will be excluded from the backup
RCLONE_EXCLUSIONS=""


# ======================================================================================================================
# LOGGING
# ======================================================================================================================

# the number of days to keep log files for
# if this is 0, no files will be deleted
KEEP_LOGS_FOR=28


# ======================================================================================================================
# COMPRESSION
# ======================================================================================================================

# absolute path to the directory where you want to stored compressed backup files
# compression is done in subfolders by day, and then files by time
# if this is not set, compression will not happen
COMPRESS_DIR=""

# the maximum size of compressed files
COMPRESS_MAX_FILE_SIZE=1024m

# the number of days to keep log files for
# if this is 0, no files will be deleted
KEEP_COMPRESSED_FOR=28


# ======================================================================================================================
# DIRECTORIES - use absolute paths
# ======================================================================================================================

# note - associative arrays are stored as hashes, so backups WILL NOT BE DONE IN THIS ORDER
declare -A D
D["/path/to/dir/0"]="" # empty string will use ${BACKUP_DIR_ROOT}/path/to/dir/0
D["/path/to/dir/1"]="/path/to/backup/dir"


# ======================================================================================================================
# FILES - use absolute paths
# ======================================================================================================================

# note - associative arrays are stored as hashes, so backups WILL NOT BE DONE IN THIS ORDER
declare -A F
F["/path/to/file/0"]="" # empty string will use ${BACKUP_DIR_ROOT}/path/to/file/0
F["/path/to/file/1"]="/path/to/backup/file"
