#!/bin/bash

# Example archive commands
#   sudo docker run -i --rm --volumes-from "${NAME_OPENSSL_DV}" ${NAME_OPENSSL_IMAGE}:latest archive > ${HOST_OPENSSL_BACKUP_DIR}/openssl.tar
# Example extract commands
#   cat ${HOST_OPENSSL_BACKUP_DIR}/openssl.tar | sudo docker run -i --rm --volumes-from "${NAME_OPENSSL_DV}" ${NAME_OPENSSL_IMAGE}:latest extract
# Example initial create
#   sudo docker run -ti --rm --volumes-from "${NAME_OPENSSL_DV}" -e SUBJ="/C=US/ST=Kansas/L=Lenexa/O=Novatech/CN=svn.novatech-llc.com" ${NAME_OPENSSL_IMAGE}:latest generate

source config.sh
set -e

# ************************************************************
# verify prerequisites:
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null && {
    # The container we are trying to create already exists
    echo "Container already exists : ${NAME_OPENSSL_DV}"
    exit 1
}
#     pull latest version of base image
sudo docker pull debian:8
sudo docker inspect debian:8 > /dev/null

# ************************************************************
# create docker images:
sudo docker inspect ${NAME_OPENSSL_IMAGE}:${TAG} &> /dev/null && {
	# an image already exists with the name and tag we are trying to create.
	# move it to the latest tag so it will be updated and then renamed
	sudo docker tag ${NAME_OPENSSL_IMAGE}:${TAG} ${NAME_OPENSSL_IMAGE}:latest
	sudo docker rmi ${NAME_OPENSSL_IMAGE}:${TAG}
}
sudo docker build --rm=true --tag="${NAME_OPENSSL_IMAGE}" ./docker-openssl
sudo docker inspect ${NAME_OPENSSL_IMAGE}:latest > /dev/null
# move the image to the tag
sudo docker tag ${NAME_OPENSSL_IMAGE}:latest ${NAME_OPENSSL_IMAGE}:${TAG}
sudo docker rmi ${NAME_OPENSSL_IMAGE}:latest

# ************************************************************
# create the data volumes:
#     create openssl data volume if it dose not already exist
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_OPENSSL_DV}" \
      ${NAME_OPENSSL_IMAGE}:${TAG} true

# ************************************************************
# extract data contained in openssl data volume
sudo true
cat ${HOST_OPENSSL_BACKUP_DIR}/openssl.tar | \
    sudo docker run -i --rm \
      --volumes-from "${NAME_OPENSSL_DV}" \
      ${NAME_OPENSSL_IMAGE}:${TAG} extract
