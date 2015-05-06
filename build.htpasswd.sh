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
sudo docker inspect ${NAME_HTPASSWD_DV} &> /dev/null && {
    # The container we are trying to create already exists
    echo "Container already exists : ${NAME_HTPASSWD_DV}"
    exit 1
}
#     pull latest version of base image
sudo docker pull debian:8
sudo docker inspect debian:8 > /dev/null

# ************************************************************
# create docker images:
sudo docker inspect ${NAME_HTPASSWD_IMAGE}:${TAG} &> /dev/null && {
	# an image already exists with the name and tag we are trying to create.
	# move it to the latest tag so it will be updated and then renamed
	sudo docker tag ${NAME_HTPASSWD_IMAGE}:${TAG} ${NAME_HTPASSWD_IMAGE}:latest
	sudo docker rmi ${NAME_HTPASSWD_IMAGE}:${TAG}
}
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
