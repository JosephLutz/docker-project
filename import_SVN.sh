#!/bin/bash
set -e

CWD=$(pwd)

source config.sh

sudo docker run -it --rm \
  -v ${HOST_SVN_DIR}:/var/lib/svn \
  -v ${HOST_BACKUP_DIR}:${SVN_EXPORT_PATH} \
  -e "SVN_EXPORT_PATH="${SVN_EXPORT_PATH} \
  websvn_image \
    /import_svn.sh ${SVN_EXPORT_PATH} ${SVN_REPOS[*]}

#sudo docker run -it --rm \
#  --volumes-from svn_data_volume \
#  -v ${HOST_BACKUP_DIR}:${SVN_EXPORT_PATH} \
#  -e "SVN_EXPORT_PATH="${SVN_EXPORT_PATH} \
#  websvn_image \
#    /import_svn.sh ${SVN_EXPORT_PATH} ${SVN_REPOS[*]}
