#!/bin/bash
CWD=$(pwd)

source config.sh

docker run -it --rm --volumes-from svn_data_volume  -e "SVN_EXPORT_PATH="${SVN_EXPORT_PATH} -v ${BACKUP_DIR}:${SVN_EXPORT_PATH} websvn_image /export_svn.sh ${SVN_EXPORT_PATH}
