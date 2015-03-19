#!/bin/bash
set -e

CWD=$(pwd)

source config.sh

HOST_BACKUP_DIR=${CWD}/websvn.data/SVN

# ************************************************************
# create sudo docker images
sudo docker build --rm=true --tag="image_websvn" ${CWD}/websvn

# ************************************************************
# create the images for the data volumes
sudo docker build --rm=true --tag="data_websvn_ssl"    ${CWD}/websvn.data/data_websvn_ssl
sudo docker build --rm=true --tag="data_websvn_passwd" ${CWD}/websvn.data/data_websvn_passwd
sudo docker build --rm=true --tag="data_websvn_svn"    ${CWD}/websvn.data/data_websvn_svn

# ************************************************************
# create the data volumes
sudo docker run --name data_volume_websvn_ssl    data_websvn_ssl
sudo docker run --name data_volume_websvn_passwd data_websvn_passwd
sudo docker run --name data_volume_websvn_svn    data_websvn_svn

# ************************************************************
# generate self signed certificate
sudo docker run -ti --rm \
  --volumes-from data_volume_websvn_ssl \
  image_websvn ssl_generate

# ************************************************************
# create the first user for access to WebSVN
sudo docker run -ti --rm \
  --volumes-from data_volume_websvn_passwd \
  image_websvn passwd_generate

# ************************************************************
# Import SVN repositories
sudo docker run -ti --rm \
  --volumes-from data_volume_websvn_svn \
  -v ${HOST_BACKUP_DIR}:/tmp/import_export \
  image_websvn svn_import ${SVN_REPOS[*]}

# ************************************************************
# Start WebSVN for running on the linuxserver
sudo docker run -d --name websvn -P -p ${WEBSVN_IP}:443:443 \
  --volumes-from data_volume_websvn_ssl \
  --volumes-from data_volume_websvn_passwd \
  --volumes-from data_volume_websvn_svn \
  image_websvn
