#!/bin/bash

set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull synctree/mediawiki
sudo docker pull mysql:latest

# ************************************************************
# pull latest version of base image

# ************************************************************
# create the data volumes

# Create mysql data volume
sudo docker run -ti --name data_volume_mediawiki_mysql \
  mysql:latest echo "MySQL data store"

# ************************************************************
# start mysql and populate the datavolume
sudo docker run -d --name mediawiki_mysql \
  --restart=always \
  -e MYSQL_ROOT_PASSWORD=mediawiki-secret-pw \
  -e MYSQL_USER=novatech \
  -e MYSQL_PASSWORD=novatech \
  -e MYSQL_DATABASE=mediawiki \
  --volumes-from data_volume_mediawiki_mysql \
  mysql:latest

# ************************************************************
# start mysql and populate the datavolume
sudo docker run -d --name mediawiki \
  --restart=always \
  -P -p ${MEDIAWIKI_IP}:443:443 -p ${MEDIAWIKI_IP}:80:80 \
  -e MEDIAWIKI_DB_NAME=mediawiki \
  -e MEDIAWIKI_DB_USER=novatech \
  -e MEDIAWIKI_DB_PASSWORD=novatech \
  --link mediawiki_mysql:mysql \
  synctree/mediawiki:latest
