#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from data_volume_openldap -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export    image_openldap backup
# Example restore commands
# sudo docker run -ti --rm --volumes-from data_volume_openldap -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export    image_openldap restore
# Example create new database
# sudo docker run -ti --rm --volumes-from data_volume_openldap image_openldap

set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull debian:8
#sudo docker pull ubuntu:14.04

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="image_openldap" ${CWD}/docker-openldap

# ************************************************************
# create the data volumes

# A data volume for the ldap data
sudo docker run -ti --name data_volume_openldap \
  -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
  image_openldap restore

# ************************************************************
# Start openldap for running on the linuxserver
sudo docker run -d --name git \
  --restart=always \
  -P -p ${OPENLDAP_IP}:389:389 \
  --volumes-from data_volume_openssl \
  --volumes-from data_volume_openldap \
  image_openldap
