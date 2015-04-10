#!/bin/bash
set -e

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull debian:8

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="${NAME_DJANGO_IMAGE}" ./docker-django

# ************************************************************
# create the data volumes

# ************************************************************
# Start Django running
sudo docker run -ti --rm \
  -P -p ${DJANGO_IP}:443:443 -p ${DJANGO_IP}:80:80 \
  -v ${HOST_DJANGO_SRC_DIR}:/var/lib/django \
  -v ${HOST_DJANGO_BACKUP_DIR}:/tmp/import_export \
  ${NAME_DJANGO_IMAGE}:latest /bin/bash
