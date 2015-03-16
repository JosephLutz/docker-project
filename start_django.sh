#!/bin/bash
CWD=$(pwd)

source config.sh

docker run -d --name django --restart=always -P -p ${DJANGO_IP}:443:443 -p ${DJANGO_IP}:80:80 \
  -v ${HOST_DJANGO_DIR}:/var/lib/django \
  django_image
