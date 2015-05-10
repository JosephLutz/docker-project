#!/bin/bash
source config.sh
set -e

# ************************************************************
# verify prerequisites:
sudo docker inspect ${NAME_DJANGO_CONTAINER} &> /dev/null && {
    # The container we are trying to create already exists
    echo "Container already exists : ${NAME_DJANGO_CONTAINER}"
    exit 1
}
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null || \
    ./build.openssl.sh
#     pull latest version of base image
sudo docker pull debian:8
#     Check for containers that will be needed by the final container
sudo docker inspect ${NAME_LDAP_CONTAINER} > /dev/null

# ************************************************************
# create docker images:
sudo docker inspect ${NAME_DJANGO_IMAGE}:${TAG} &> /dev/null && {
	# an image already exists with the name and tag we are trying to create.
	# move it to the latest tag so it will be updated and then renamed
	sudo docker tag ${NAME_DJANGO_IMAGE}:${TAG} ${NAME_DJANGO_IMAGE}:latest
	sudo docker rmi ${NAME_DJANGO_IMAGE}:${TAG}
}
sudo docker build --rm=true --tag="${NAME_DJANGO_IMAGE}" ./docker-django
sudo docker inspect ${NAME_DJANGO_IMAGE}:latest &> /dev/null
# move the image to the tag
sudo docker tag ${NAME_DJANGO_IMAGE}:latest ${NAME_DJANGO_IMAGE}:${TAG}
sudo docker rmi ${NAME_DJANGO_IMAGE}:latest

# ************************************************************
# create the data volumes:

# ************************************************************
# Start Django running
sudo docker run -d --name "${NAME_DJANGO_CONTAINER}" \
  --restart=always \
  -P -p ${DJANGO_SECURE}:443 -p ${DJANGO}:80 \
  --volumes-from "${NAME_OPENSSL_DV}" \
  -e DJANGO_HOSTNAME="${DJANGO_HOSTNAME}" \
  -v ${HOST_DJANGO_SRC_DIR}:/var/lib/django \
  -v ${HOST_DJANGO_BACKUP_DIR}:/tmp/import_export \
  --link ${NAME_LDAP_CONTAINER}:ldap \
  ${NAME_DJANGO_IMAGE}:${TAG}
