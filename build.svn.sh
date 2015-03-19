#!/bin/bash
set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# create sudo docker images
sudo docker build --rm=true --tag="websvn_image" ${CWD}/websvn

# ************************************************************
# create the images for the data volumes
sudo docker build --rm=true --tag="websvn_ssl_data" ${CWD}/data_container/websvn_ssl_data
sudo docker build --rm=true --tag="websvn_password_data" ${CWD}/data_container/websvn_password_data
sudo docker build --rm=true --tag="websvn_svn_data" ${CWD}/data_container/websvn_svn_data

# ************************************************************
# create the data volumes
sudo docker run --name websvn_ssl_data_volume websvn_ssl_data
sudo docker run --name websvn_password_data_volume websvn_password_data
sudo docker run --name svn_data_volume websvn_svn_data

# ************************************************************
# generate self signed certificate
sudo docker run -ti --rm \
  --volumes-from websvn_ssl_data_volume \
  websvn_image ssl_generate

# ************************************************************
# create the first user for access to WebSVN
sudo docker run -ti --rm \
  --volumes-from websvn_password_data_volume \
  websvn_image passwd_generate

# ************************************************************
# Import SVN repositories
sudo docker run -ti --rm \
  --volumes-from svn_data_volume \
  websvn_image svn_import ${SVN_REPOS[*]}

# ************************************************************
# Start WebSVN for running on the linuxserver
sudo docker run -d --name websvn -P -p ${WEBSVN_IP}:443:443 \
  --volumes-from websvn_ssl_data_volume \
  --volumes-from websvn_password_data_volume \
  --volumes-from svn_data_volume \
  websvn_image
