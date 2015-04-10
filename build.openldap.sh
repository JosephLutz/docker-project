#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from "${NAME_LDAP_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_LDAP_IMAGE} backup
# Example restore commands
# sudo docker run -ti --rm --volumes-from "${NAME_LDAP_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_LDAP_IMAGE} restore
# Example create new database
# sudo docker run -ti --rm --volumes-from "${NAME_LDAP_DV}" ${NAME_LDAP_IMAGE}

set -e

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull debian:8

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="${NAME_LDAP_IMAGE}" ./docker-openldap

# ************************************************************
# create the data volumes
#     A data volume for the ldap data
sudo docker run -ti --name "${NAME_LDAP_DV}" \
  -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
  ${NAME_LDAP_IMAGE}:latest restore

# ************************************************************
# Start openldap for running on the linuxserver
sudo docker run -d --name "${NAME_LDAP_CONTAINER}" \
  --restart=always \
  -P -p ${OPENLDAP_IP}:389:389 \
  --volumes-from "${NAME_OPENSSL_DV}" \
  --volumes-from "${NAME_LDAP_DV}" \
  ${NAME_LDAP_IMAGE}:latest
