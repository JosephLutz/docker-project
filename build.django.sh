#!/bin/bash
source config.sh
set -e

# ************************************************************
# verify prerequisites:
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null || \
    ./build.openssl.sh
#     pull latest version of base image
sudo docker pull debian:8

# ************************************************************
# create docker images:
sudo docker build --rm=true --tag="${NAME_DJANGO_IMAGE}" ./docker-django
sudo docker inspect ${NAME_DJANGO_IMAGE}:latest &> /dev/null
# move the image to the tag
sudo docker tag ${NAME_DJANGO_IMAGE}:latest ${NAME_DJANGO_IMAGE}:${TAG}
sudo docker rmi ${NAME_DJANGO_IMAGE}:latest

# ************************************************************
# create the data volumes:

# ************************************************************
# Start Django running
sudo docker inspect ${NAME_LDAP_CONTAINER} > /dev/null
sudo docker run -d --name "${NAME_DJANGO_CONTAINER}" \
  --restart=always \
  -P -p ${DJANGO_SECURE}:443 -p ${DJANGO}:80 \
  --volumes-from "${NAME_OPENSSL_DV}" \
  -v ${HOST_DJANGO_SRC_DIR}:/var/lib/django \
  -v ${HOST_DJANGO_BACKUP_DIR}:/tmp/import_export \
  --link ${NAME_LDAP_CONTAINER}:ldap \
  ${NAME_DJANGO_IMAGE}:${TAG}
