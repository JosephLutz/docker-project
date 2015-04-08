#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from data_volume_openssl -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export data_openssl backup
# Example restore commands
# sudo docker run -ti --rm --volumes-from data_volume_openssl -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export data_openssl restore
# Example initial create
# sudo docker run -ti --rm --volumes-from data_volume_openssl data_openssl generate

set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="data_openssl" ${CWD}/docker-openssl

# ************************************************************
# create data volume for containers on the linuxserver
sudo docker run -ti --name data_volume_openssl \
  data_openssl true

# ************************************************************
# generating self signed keys for containers on the linuxserver
sudo docker run -ti --rm --volumes-from data_volume_openssl data_openssl generate
