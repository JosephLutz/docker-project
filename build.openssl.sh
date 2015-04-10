#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from "${NAME_OPENSSL_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_OPENSSL_IMAGE}:latest backup
# Example restore commands
# sudo docker run -ti --rm --volumes-from "${NAME_OPENSSL_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_OPENSSL_IMAGE}:latest restore
# Example initial create
# sudo docker run -ti --rm --volumes-from "${NAME_OPENSSL_DV}" ${NAME_OPENSSL_IMAGE}:latest generate

set -e

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull debian:8

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="${NAME_OPENSSL_IMAGE}" ./docker-openssl

# ************************************************************
# create data volume for containers on the linuxserver
sudo docker run -ti --name "${NAME_OPENSSL_DV}" \
  ${NAME_OPENSSL_IMAGE}:latest true

# ************************************************************
# generating self signed keys for containers on the linuxserver
sudo docker run -ti --rm \
  --volumes-from "${NAME_OPENSSL_DV}" \
  ${NAME_OPENSSL_IMAGE}:latest generate
