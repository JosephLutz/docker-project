#!/bin/bash

# Example backup commands
#   sudo docker run -ti --rm --volumes-from "${NAME_LDAP_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_LDAP_IMAGE}:latest backup
# Example restore commands
#   sudo docker run -ti --rm --volumes-from "${NAME_LDAP_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_LDAP_IMAGE}:latest restore
# Example create new database
#   sudo docker run -ti --rm --volumes-from "${NAME_LDAP_DV}" ${NAME_LDAP_IMAGE}:latest

source config.sh
set -e

# ************************************************************
# verify prerequisites:
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null || \
    ./build.openssl.sh
#     pull latest version of base image
sudo docker pull debian:8
sudo docker inspect debian:8 > /dev/null

# ************************************************************
# create docker images:
sudo docker build --rm=true --tag="${NAME_LDAP_IMAGE}" ./docker-openldap
sudo docker inspect ${NAME_LDAP_IMAGE}:latest > /dev/null
# move the image to the tag
sudo docker tag ${NAME_LDAP_IMAGE}:latest ${NAME_LDAP_IMAGE}:${TAG}
sudo docker rmi ${NAME_LDAP_IMAGE}:latest

# ************************************************************
# create the data volumes:
#     create ldap data volume if it dose not already exist
sudo docker inspect ${NAME_LDAP_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_LDAP_DV}" \
      -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
      ${NAME_LDAP_IMAGE}:${TAG} restore

# ************************************************************
# Start openldap for running on the linuxserver
#sudo docker run -d --name "${NAME_LDAP_CONTAINER}" \
#  --restart=always \
#  --volumes-from "${NAME_OPENSSL_DV}" \
#  --volumes-from "${NAME_LDAP_DV}" \
#  ${NAME_LDAP_IMAGE}:${TAG}

sudo docker run -ti --rm \
  -P -p ${OPENLDAP}:389 -p ${OPENLDAP_SECURE}:636 \
  --volumes-from "${NAME_OPENSSL_DV}" \
  --volumes-from "${NAME_LDAP_DV}" \
  ${NAME_LDAP_IMAGE}:${TAG} /bin/bash
