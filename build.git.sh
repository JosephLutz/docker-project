#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from data_volume_git_gitrepo -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export    image_git git_backup
# Example restore commands
# sudo docker run -ti --rm --volumes-from data_volume_git_gitrepo -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export    image_git git_restore
# Example initial create
# sudo docker run -ti --rm --volumes-from data_volume_git_data    image_git ssl_generate
# sudo docker run -ti --rm --volumes-from data_volume_git_data    image_git ssl_generate "/C=US/ST=Kansas/L=Lenexa/O=Novatech/CN=git.example.com"
# sudo docker run -ti --rm --volumes-from data_volume_git_data    image_git passwd_generate
# Example create new bare repositories
# sudo docker run -ti --rm --volumes-from data_volume_git_gitrepo image_git new_repository repos_name_1 repos_name_2 repos_name_3 repos_name_4

set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="image_git" ${CWD}/docker-git

# ************************************************************
# create the images for the other data volumes
sudo docker build --rm=true --tag="data_git_data" ${CWD}/data_volumes/git/data_git_data

# ************************************************************
# create the data volumes

# A data volume to hold certificates and passwords
sudo docker run --name data_volume_git_data --entrypoint=echo data_git_data "other GIT data"

#     generate self signed certificate - "other GIT data"
sudo docker run -ti --rm \
  --volumes-from data_volume_git_data \
  image_git ssl_generate

#     create the first user for access to git - "other GIT data"
sudo docker run -ti --rm \
  --volumes-from data_volume_git_data \
  image_git passwd_generate

# A data volume for the git repositories - "GIT repositories"
FILES_TO_RESTORE=($(cd ${HOST_GIT_BACKUP_DIR};ls -1 *.backup.tar.gz))
sudo docker run -ti --name data_volume_git_gitrepo \
  -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export \
  image_git git_restore ${FILES_TO_RESTORE[*]}

# ************************************************************
# Start git for running on the linuxserver
sudo docker run -d --name git -P -p ${GIT_IP}:443:443 -p ${GIT_IP}:80:80 \
  --volumes-from data_volume_git_data \
  --volumes-from data_volume_git_gitrepo \
  image_git
