#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from data_volume_git_gitrepo    -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export image_git git_backup
# sudo docker run -ti --rm --volumes-from data_volume_git_ssl    -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export image_git ssl_backup
# sudo docker run -ti --rm --volumes-from data_volume_git_passwd -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export image_git passwd_backup
# Example import commands
# sudo docker run -ti --rm --volumes-from data_volume_git_gitrepo    -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export image_git git_import
# sudo docker run -ti --rm --volumes-from data_volume_git_ssl    -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export image_git ssl_import
# sudo docker run -ti --rm --volumes-from data_volume_git_passwd -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export image_git passwd_import
# Example initial create
# sudo docker run -ti --rm --volumes-from data_volume_git_gitrepo    image_git git_import repos_name_1 repos_name_2 repos_name_3 repos_name_4
# sudo docker run -ti --rm --volumes-from data_volume_git_ssl    image_git ssl_generate
# sudo docker run -ti --rm --volumes-from data_volume_git_ssl    image_git ssl_generate "/C=US/ST=Kansas/L=Lenexa/O=Novatech/CN=git.example.com"
# sudo docker run -ti --rm --volumes-from data_volume_git_passwd image_git passwd_generate

set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="image_git" ${CWD}/docker-git

# ************************************************************
# create the images for the data volumes
 # sudo docker build --rm=true --tag="data_git_ssl"    ${CWD}/git.data/data_git_ssl
 # sudo docker build --rm=true --tag="data_git_passwd" ${CWD}/git.data/data_git_passwd
sudo docker build --rm=true --tag="data_git_gitrepo"    ${CWD}/data_volumes/git/data_git_gitrepo

# ************************************************************
# create the data volumes
 # sudo docker run --name data_volume_git_ssl       data_git_ssl
 # sudo docker run --name data_volume_git_passwd    data_git_passwd
sudo docker run --name data_volume_git_gitrepo   data_git_gitrepo

# ************************************************************
# generate self signed certificate
 # sudo docker run -ti --rm \
 #   --volumes-from data_volume_git_ssl \
 #   image_git ssl_generate

# ************************************************************
# create the first user for access to git
 # sudo docker run -ti --rm \
 #   --volumes-from data_volume_git_passwd \
 #   image_git passwd_generate

# ************************************************************
# Import git repositories
 # sudo docker run -ti --rm \
 #   --volumes-from data_volume_git_gitrepo \
 #   -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export \
 #   image_git git_import ${GIT_REPOS[*]}

# ************************************************************
# Start git for running on the linuxserver
sudo docker run -d --name git -P -p ${GIT_IP}:443:443 -p ${GIT_IP}:80:80 \
  --volumes-from data_volume_git_gitrepo \
  image_git
 #   --volumes-from data_volume_git_ssl \
 #   --volumes-from data_volume_git_passwd \
