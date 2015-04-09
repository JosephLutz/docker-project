#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from data_volume_svn_repo -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export image_svn svn_backup
# Example import commands
# sudo docker run -ti --rm --volumes-from data_volume_svn_repo -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export image_svn svn_import
# Example initial create
# sudo docker run -ti --rm --volumes-from data_volume_svn_repo image_svn svn_import repos_name_1 repos_name_2 repos_name_3 repos_name_4

set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull debian:8
#sudo docker pull ubuntu:14.04

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="image_svn" ${CWD}/docker-svn

# ************************************************************
# create the data volumes

# Import SVN repositories
sudo docker run -ti --name data_volume_svn_repo \
  -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export \
  image_svn svn_import ${SVN_REPOS[*]}

# ************************************************************
# Start SVN for running on the linuxserver
sudo docker run -d --name svn \
  --restart=always \
  -P -p ${SVN_IP}:443:443 -p ${SVN_IP}:80:80 \
  --volumes-from data_volume_htpasswd \
  --volumes-from data_volume_openssl \
  --volumes-from data_volume_svn_repo \
  image_svn
