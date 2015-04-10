#!/bin/bash

set -e

source config.sh

# ************************************************************
# pull latest version of base image
sudo docker pull synctree/mediawiki
sudo docker pull mysql:latest

# ************************************************************
# pull latest version of base image

# ************************************************************
# create the data volumes
#     Create mysql data volume
sudo docker run -ti --name "${NAME_WIKI_MYSQL_DV}" \
  mysql:latest echo "MySQL data store"

# ************************************************************
# start mysql and populate the datavolume
sudo docker run -d --name "${NAME_WIKI_MYSQL_CONTAINER}" \
  --restart=always \
  -e MYSQL_ROOT_PASSWORD="${MYSQL_PASSWORD}" \
  -e MYSQL_DATABASE=mediawiki \
  -e MYSQL_USER="${MEDIAWIKI_USER}" \
  -e MYSQL_PASSWORD="${MEDIAWIKI_PASSWORD}" \
  --volumes-from "${NAME_WIKI_MYSQL_DV}" \
  mysql:latest

# ************************************************************
# start mysql and populate the datavolume
sudo docker run -d --name "${NAME_WIKI_CONTAINER}" \
  --restart=always \
  -P -p ${MEDIAWIKI_IP}:443:443 -p ${MEDIAWIKI_IP}:80:80 \
  -e MEDIAWIKI_DB_NAME=mediawiki \
  -e MEDIAWIKI_DB_USER="${MEDIAWIKI_USER}" \
  -e MEDIAWIKI_DB_PASSWORD="${MEDIAWIKI_PASSWORD}" \
  --link ${NAME_WIKI_MYSQL_CONTAINER}:mysql \
  synctree/mediawiki:latest
