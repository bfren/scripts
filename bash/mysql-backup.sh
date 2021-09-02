#!/bin/bash
# Copyright (c) bfren - licensed under https://mit.bfren.dev/2020


VERSION=0.1.2106070845


# ======================================================================================================================
# SET VARIABLES
# ======================================================================================================================

BACKUP_PATH=/tmp/backup
DATE=$(date '+%Y%m%d%H%M')
THIS_BACKUP_PATH=${BACKUP_PATH}/${DATE}
BACKUP_COMPRESS_FILES=1
BACKUP_KEEP_FOR_DAYS=14


# ======================================================================================================================
# UTILS
# ======================================================================================================================

SCRIPT_DIR=$(dirname $0)
UTILS="$SCRIPT_DIR/utils.sh"
if [ ! -f "$UTILS" ] ; then
  echo "Please create $UTILS before running this script"
  exit
fi

source "$UTILS"


# ======================================================================================================================
# GET DATABASES
# ======================================================================================================================

DATABASES=$(mysql --password=${MARIADB_ROOT_PASSWORD} --user=root -e 'show databases;' | sed 1d | grep -v -E "(mysql|information_schema|performance_schema)")

if [ "${DATABASES}" == "" ] ; then
  exit
fi


# ======================================================================================================================
# GET BACKUP PATH
# ======================================================================================================================

if [ ! -d ${BACKUP_PATH} ] ; then
  mkdir -p ${BACKUP_PATH}
  chmod 740 ${BACKUP_PATH}
fi


# ======================================================================================================================
# PERFORM BACKUPS TO TEMP DIR
# ======================================================================================================================

cd /tmp

for DATABASE in ${DATABASES}
do
  if [ -f /tmp/${DATABASE}.sql ] ; then
    rm -f /tmp/${DATABASE}.sql
  fi

  mysqldump --add-locks --password=${MARIADB_ROOT_PASSWORD} --user=root ${DATABASE} > /tmp/${DATABASE}.sql
done


# ======================================================================================================================
# MOVE BACKUPS TO BACKUP FOLDER AND GZIP
# ======================================================================================================================

mkdir -p ${THIS_BACKUP_PATH}
chmod 740 ${THIS_BACKUP_PATH}
cd ${THIS_BACKUP_PATH}

for DATABASE in ${DATABASES}
do
  if [ -f /tmp/${DATABASE}.sql ] ; then
    mv /tmp/${DATABASE}.sql ${DATABASE}.sql

    if [ ${BACKUP_COMPRESS_FILES} -eq "1" ] ; then
      gzip ${DATABASE}.sql
      chmod 640 ${DATABASE}.sql.gz
    fi
  fi
done


# ======================================================================================================================
# REMOVE OLD BACKUPS
# ======================================================================================================================

delete_old_dirs "MySQL backup" ${BACKUP_KEEP_FOR_DAYS} ${BACKUP_PATH}
