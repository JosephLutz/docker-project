#!/bin/bash
CWD=$(pwd)

source config.sh

docker run -it --rm \
  -v ${HOST_SVN_DIR}:/var/lib/svn \
  -v ${BACKUP_DIR}:${SVN_EXPORT_PATH} \
  -e "SVN_EXPORT_PATH="${SVN_EXPORT_PATH} \
  websvn_image \
    /export_svn.sh ${SVN_EXPORT_PATH}

#docker run -it --rm \
#  --volumes-from svn_data_volume \
#  -v ${BACKUP_DIR}:${SVN_EXPORT_PATH} \
#  -e "SVN_EXPORT_PATH="${SVN_EXPORT_PATH} \
#  websvn_image \
#    /export_svn.sh ${SVN_EXPORT_PATH}
