#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from data_volume_git_gitrepo -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export    image_git git_backup
# Example restore commands
# sudo docker run -ti --rm --volumes-from data_volume_git_gitrepo -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export    image_git git_restore
# Example create new bare repositories
# sudo docker run -ti --rm --volumes-from data_volume_git_gitrepo image_git new_repository repos_name_1 repos_name_2 repos_name_3 repos_name_4

set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull debian:8
#sudo docker pull ubuntu:14.04

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="image_git" ${CWD}/docker-git

# ************************************************************
# create the data volumes

# A data volume for the git repositories - "GIT repositories"
FILES_TO_RESTORE=($(cd ${HOST_GIT_BACKUP_DIR};ls -1 *.backup.tar.gz))
sudo docker run -ti --name data_volume_git_gitrepo \
  -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export \
  image_git git_restore ${FILES_TO_RESTORE[*]}

# ************************************************************
# Start git for running on the linuxserver
sudo docker run -d --name git \
  --restart=always \
  -P -p ${GIT_IP}:443:443 -p ${GIT_IP}:80:80 \
  --volumes-from data_volume_htpasswd \
  --volumes-from data_volume_openssl \
  --volumes-from data_volume_git_gitrepo \
  image_git
