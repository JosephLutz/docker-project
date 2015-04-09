#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from data_volume_htpasswd -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export data_htpasswd backup
# Example restore commands
# sudo docker run -ti --rm --volumes-from data_volume_htpasswd -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export data_htpasswd restore
# Example initial create
# sudo docker run -ti --rm --volumes-from data_volume_htpasswd data_htpasswd generate

set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull debian:8
#sudo docker pull ubuntu:14.04

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="data_htpasswd" ${CWD}/docker-htpasswd

# ************************************************************
# create data volume for containers on the linuxserver
sudo docker run -ti --name data_volume_htpasswd \
  data_htpasswd true

# ************************************************************
# generating password database files for containers on the linuxserver
sudo docker run -ti --rm \
  --volumes-from data_volume_htpasswd \
  data_htpasswd generate
