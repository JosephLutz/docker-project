#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from "${NAME_SVN_REPO_DV}" -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export ${NAME_SVN_IMAGE}:latest backup
# Example import commands
# sudo docker run -ti --rm --volumes-from "${NAME_SVN_REPO_DV}" -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export ${NAME_SVN_IMAGE}:latest import
# Example initial create
# sudo docker run -ti --rm --volumes-from "${NAME_SVN_REPO_DV}" ${NAME_SVN_IMAGE}:latest import repos_name_1 repos_name_2 repos_name_3 repos_name_4

set -e

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull debian:8

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="${NAME_SVN_IMAGE}" ./docker-svn

# ************************************************************
# create the data volumes
#     import SVN repositories
sudo docker run -ti --name "${NAME_SVN_REPO_DV}" \
  -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export \
  ${NAME_SVN_IMAGE}:latest import ${SVN_REPOS[*]}

# ************************************************************
# Start SVN for running on the linuxserver
sudo docker run -d --name "${NAME_SVN_CONTAINER}" \
  --restart=always \
  -P -p ${SVN_IP}:443:443 -p ${SVN_IP}:80:80 \
  --volumes-from "${NAME_SVN_REPO_DV}" \
  --volumes-from "${NAME_OPENSSL_DV}" \
  --volumes-from "${NAME_HTPASSWD_DV}" \
  ${NAME_SVN_IMAGE}:latest
