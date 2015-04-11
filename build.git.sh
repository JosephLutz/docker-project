#!/bin/bash

# Example backup commands
#   sudo docker run -ti --rm --volumes-from "${NAME_GIT_REPO_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_GIT_IMAGE}:latest backup
# Example restore commands
#   sudo docker run -ti --rm --volumes-from "${NAME_GIT_REPO_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_GIT_IMAGE}:latest restore
# Example create new bare repositories
#   sudo docker run -ti --rm --volumes-from "${NAME_GIT_REPO_DV}" ${NAME_GIT_IMAGE}:latest new_repository repos_name_1 repos_name_2 repos_name_3 repos_name_4

source config.sh
set -e

# ************************************************************
# verify prerequisites:
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null || \
    ./build.openssl.sh
sudo docker inspect ${NAME_HTPASSWD_DV} &> /dev/null || \
    ./build.htpasswd.sh
#     pull latest version of base image
sudo docker pull debian:8

# ************************************************************
# create docker images:
sudo docker build --rm=true --tag="${NAME_GIT_IMAGE}" ./docker-git
sudo docker inspect ${NAME_GIT_IMAGE}:latest &> /dev/null
# move the image to the tag
sudo docker tag ${NAME_GIT_IMAGE}:latest ${NAME_GIT_IMAGE}:${TAG}
sudo docker rm ${NAME_GIT_IMAGE}:latest

# ************************************************************
# create the data volumes
#     create GIT Repo. data volume if it dose not already exist
sudo docker inspect ${NAME_GIT_REPO_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_GIT_REPO_DV}" \
      ${NAME_GIT_IMAGE}:${TAG} true

#     Populate data volume with backed up GIT repositories
FILES_TO_RESTORE=($(cd ${HOST_GIT_BACKUP_DIR};ls -1 *.backup.tar.gz))
sudo docker run -ti --rm \
  --volumes-from "${NAME_GIT_REPO_DV}" \
  -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export \
  ${NAME_GIT_IMAGE}:${TAG} restore ${FILES_TO_RESTORE[*]}

# ************************************************************
# Start git for running on the linuxserver
sudo docker run -d --name "${NAME_GIT_CONTAINER}" \
  --restart=always \
  -P -p ${GIT_IP}:443:443 -p ${GIT_IP}:80:80 \
  --volumes-from "${NAME_GIT_REPO_DV}" \
  --volumes-from "${NAME_OPENSSL_DV}" \
  --volumes-from "${NAME_HTPASSWD_DV}" \
  ${NAME_GIT_IMAGE}:${TAG}
