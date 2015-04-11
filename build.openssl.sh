#!/bin/bash

# Example backup commands
#   sudo docker run -ti --rm --volumes-from "${NAME_OPENSSL_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_OPENSSL_IMAGE}:latest backup
# Example restore commands
#   sudo docker run -ti --rm --volumes-from "${NAME_OPENSSL_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_OPENSSL_IMAGE}:latest restore
# Example initial create
#   sudo docker run -ti --rm --volumes-from "${NAME_OPENSSL_DV}" ${NAME_OPENSSL_IMAGE}:latest generate

source config.sh
set -e

# ************************************************************
# verify prerequisites:
#     pull latest version of base image
sudo docker pull debian:8
sudo docker inspect debian:8 > /dev/null

# ************************************************************
# create docker images:
sudo docker build --rm=true --tag="${NAME_OPENSSL_IMAGE}" ./docker-openssl
sudo docker inspect ${NAME_OPENSSL_IMAGE}:latest > /dev/null
# move the image to the tag
sudo docker tag ${NAME_OPENSSL_IMAGE}:latest ${NAME_OPENSSL_IMAGE}:${TAG}
sudo docker rm ${NAME_OPENSSL_IMAGE}:latest

# ************************************************************
# create the data volumes:
#     create openssl data volume if it dose not already exist
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_OPENSSL_DV}" \
      ${NAME_OPENSSL_IMAGE}:${TAG} true

# ************************************************************
# generating self signed keys in the data volume
sudo docker run -ti --rm \
  --volumes-from "${NAME_OPENSSL_DV}" \
  ${NAME_OPENSSL_IMAGE}:${TAG} generate
