#!/bin/bash

# Example backup commands
# sudo docker run -ti --rm --volumes-from data_volume_svn_repo -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export image_svn svn_backup
# sudo docker run -ti --rm --volumes-from data_volume_svn_data -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export image_svn ssl_backup
# sudo docker run -ti --rm --volumes-from data_volume_svn_data -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export image_svn passwd_backup
# Example import commands
# sudo docker run -ti --rm --volumes-from data_volume_svn_repo -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export image_svn svn_import
# sudo docker run -ti --rm --volumes-from data_volume_svn_data -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export image_svn ssl_import
# sudo docker run -ti --rm --volumes-from data_volume_svn_data -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export image_svn passwd_import
# Example initial create
# sudo docker run -ti --rm --volumes-from data_volume_svn_repo image_svn svn_import repos_name_1 repos_name_2 repos_name_3 repos_name_4
# sudo docker run -ti --rm --volumes-from data_volume_svn_data image_svn ssl_generate
# sudo docker run -ti --rm --volumes-from data_volume_svn_data image_svn ssl_generate "/C=US/ST=Kansas/L=Lenexa/O=Novatech/CN=svn.example.com"
# sudo docker run -ti --rm --volumes-from data_volume_svn_data image_svn passwd_generate

set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# create docker images
sudo docker build --rm=true --tag="image_svn" ${CWD}/docker-svn

# ************************************************************
# create the images for the other data volumes
sudo docker build --rm=true --tag="data_svn_data" ${CWD}/data_volumes/svn/data_svn_data

# ************************************************************
# create the data volumes

# A data volume to hold certificates and passwords
sudo docker run --name data_volume_svn_data --entrypoint=echo data_svn_data "other SVN data"

#     generate self signed certificate - "other SVN data"
sudo docker run -ti --rm \
  --volumes-from data_volume_svn_data \
  image_svn ssl_generate

#     create the first user for access to SVN - "other SVN data"
sudo docker run -ti --rm \
  --volumes-from data_volume_svn_data \
  image_svn passwd_generate

# Import SVN repositories
sudo docker run -ti --name data_volume_svn_repo \
  -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export \
  image_svn svn_import ${SVN_REPOS[*]}

# ************************************************************
# Start SVN for running on the linuxserver
sudo docker run -d --name svn -P -p ${SVN_IP}:443:443 -p ${SVN_IP}:80:80 \
  --volumes-from data_volume_svn_data \
  --volumes-from data_volume_svn_repo \
  image_svn
