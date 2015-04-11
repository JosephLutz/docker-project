#!/bin/bash

# Example backup commands
#   sudo docker run -ti --rm --volumes-from "${NAME_HTPASSWD_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_HTPASSWD_IMAGE}:latest backup
# Example restore commands
#   sudo docker run -ti --rm --volumes-from "${NAME_HTPASSWD_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_HTPASSWD_IMAGE}:latest restore
# Example initial create
#   sudo docker run -ti --rm --volumes-from "${NAME_HTPASSWD_DV}" ${NAME_HTPASSWD_IMAGE}:latest generate

source config.sh
set -e

# ************************************************************
# verify prerequisites:
#     pull latest version of base image
sudo docker pull debian:8
sudo docker inspect debian:8 > /dev/null

# ************************************************************
# create docker images:
sudo docker build --rm=true --tag="${NAME_HTPASSWD_IMAGE}" ./docker-htpasswd
sudo docker inspect ${NAME_HTPASSWD_IMAGE}:latest > /dev/null
# move the image to the tag
sudo docker tag ${NAME_HTPASSWD_IMAGE}:latest ${NAME_HTPASSWD_IMAGE}:${TAG}
sudo docker rmi ${NAME_HTPASSWD_IMAGE}:latest

# ************************************************************
# create the data volumes:
#     create openssl data volume if it dose not already exist
sudo docker inspect ${NAME_HTPASSWD_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_HTPASSWD_DV}" \
      ${NAME_HTPASSWD_IMAGE}:${TAG} true

# ************************************************************
# generating password database files for containers on the linuxserver
sudo docker run -ti --rm \
  --volumes-from "${NAME_HTPASSWD_DV}" \
  ${NAME_HTPASSWD_IMAGE}:${TAG} generate
