#!/bin/bash

source config.sh
set -e

# ************************************************************
# verify prerequisites:
#   pull latest version of base image
sudo docker pull synctree/mediawiki
sudo docker inspect synctree/mediawiki > /dev/null
sudo docker pull mysql:latest
sudo docker inspect mysql:latest > /dev/null

# create tag for images
sudo docker tag synctree/mediawiki:latest synctree/mediawiki:${TAG}
sudo docker tag mysql:latest mysql:${TAG}

# ************************************************************
# create the data volumes:
#     create mysql data volume if it dose not already exist
sudo docker inspect ${NAME_WIKI_MYSQL_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_WIKI_MYSQL_DV}" \
      mysql:${TAG} echo "MySQL data store"

# ************************************************************
# start mysql and populate the datavolume
sudo docker run -d --name "${NAME_WIKI_MYSQL_CONTAINER}" \
  --restart=always \
  -e MYSQL_ROOT_PASSWORD="${MYSQL_PASSWORD}" \
  -e MYSQL_DATABASE=mediawiki \
  -e MYSQL_USER="${MEDIAWIKI_USER}" \
  -e MYSQL_PASSWORD="${MEDIAWIKI_PASSWORD}" \
  --volumes-from "${NAME_WIKI_MYSQL_DV}" \
  mysql:${TAG}

# ************************************************************
# start mysql and populate the datavolume
sudo docker inspect ${NAME_WIKI_MYSQL_CONTAINER} > /dev/null
sudo docker run -d --name "${NAME_WIKI_CONTAINER}" \
  --restart=always \
  -P -p ${MEDIAWIKI}:443 -p ${MEDIAWIKI_OPEN}:80 \
  -e MEDIAWIKI_DB_NAME=mediawiki \
  -e MEDIAWIKI_DB_USER="${MEDIAWIKI_USER}" \
  -e MEDIAWIKI_DB_PASSWORD="${MEDIAWIKI_PASSWORD}" \
  --link ${NAME_WIKI_MYSQL_CONTAINER}:mysql \
  synctree/mediawiki:${TAG}
