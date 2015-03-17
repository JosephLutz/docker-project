#!/bin/bash
set -e

CWD=$(pwd)

source config.sh

sudo docker run -d --name django --restart=always -P -p ${DJANGO_IP}:443:443 -p ${DJANGO_IP}:80:80 \
  -v ${HOST_DJANGO_DIR}:/var/lib/django \
  django_image
