#!/bin/bash

# Example backup commands
#   sudo docker run -ti --rm --volumes-from "${NAME_SVN_REPO_DV}" -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export ${NAME_SVN_IMAGE}:latest backup
# Example import commands
#   sudo docker run -ti --rm --volumes-from "${NAME_SVN_REPO_DV}" -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export ${NAME_SVN_IMAGE}:latest import
# Example initial create
#   sudo docker run -ti --rm --volumes-from "${NAME_SVN_REPO_DV}" ${NAME_SVN_IMAGE}:latest import repos_name_1 repos_name_2 repos_name_3 repos_name_4

source config.sh
set -e

# ************************************************************
# verify prerequisites:
sudo docker inspect ${NAME_SVN_CONTAINER} &> /dev/null && {
    # The container we are trying to create already exists
    echo "Container already exists : ${NAME_SVN_CONTAINER}"
    exit 1
}
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null || \
    ./build.openssl.sh
sudo docker inspect ${NAME_HTPASSWD_DV} &> /dev/null || \
    ./build.htpasswd.sh
#     pull latest version of base image
sudo docker pull debian:8

# ************************************************************
# create docker images:
sudo docker inspect ${NAME_SVN_IMAGE}:${TAG} &> /dev/null && {
  # an image already exists with the name and tag we are trying to create.
  # move it to the latest tag so it will be updated and then renamed
  sudo docker tag ${NAME_SVN_IMAGE}:${TAG} ${NAME_SVN_IMAGE}:latest
  sudo docker rmi ${NAME_SVN_IMAGE}:${TAG}
}
sudo docker build --rm=true --tag="${NAME_SVN_IMAGE}" ./docker-svn
sudo docker inspect ${NAME_SVN_IMAGE}:latest &> /dev/null
# move the image to the tag
sudo docker tag ${NAME_SVN_IMAGE}:latest ${NAME_SVN_IMAGE}:${TAG}
sudo docker rmi ${NAME_SVN_IMAGE}:latest

# ************************************************************
# create the data volumes
#     create GIT Repo. data volume if it dose not already exist
sudo docker inspect ${NAME_SVN_REPO_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_SVN_REPO_DV}" \
      ${NAME_SVN_IMAGE}:${TAG} true

#     Populate data volume with backed up SVN repositories
#SVN_REPOS=${SVN_REPOS}
sudo docker run -ti --rm \
  --volumes-from "${NAME_SVN_REPO_DV}" \
  -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export \
  ${NAME_SVN_IMAGE}:${TAG} import ${SVN_REPOS[*]}

# ************************************************************
# Start SVN for running on the linuxserver
sudo docker run -d --name "${NAME_SVN_CONTAINER}" \
  --restart=always \
  -P -p ${SVN}:443 -p ${SVN_OPEN}:80 \
  --volumes-from "${NAME_SVN_REPO_DV}" \
  --volumes-from "${NAME_OPENSSL_DV}" \
  --volumes-from "${NAME_HTPASSWD_DV}" \
  ${NAME_SVN_IMAGE}:${TAG}
