#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from "${NAME_HTPASSWD_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_HTPASSWD_IMAGE}:latest backup
# Example restore commands
# sudo docker run -ti --rm --volumes-from "${NAME_HTPASSWD_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_HTPASSWD_IMAGE}:latest restore
# Example initial create
# sudo docker run -ti --rm --volumes-from "${NAME_HTPASSWD_DV}" ${NAME_HTPASSWD_IMAGE}:latest generate

set -e

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull debian:8

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="${NAME_HTPASSWD_IMAGE}" ./docker-htpasswd

# ************************************************************
# create data volume for containers on the linuxserver
sudo docker run -ti --name "${NAME_HTPASSWD_DV}" \
  ${NAME_HTPASSWD_IMAGE}:latest true

# ************************************************************
# generating password database files for containers on the linuxserver
sudo docker run -ti --rm \
  --volumes-from "${NAME_HTPASSWD_DV}" \
  ${NAME_HTPASSWD_IMAGE}:latest generate
