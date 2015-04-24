#!/bin/bash

source config.sh
set -e

# ************************************************************
# verify prerequisites:
sudo docker inspect ${NAME_WIKI_MYSQL_CONTAINER} &> /dev/null && {
    # The container we are trying to create already exists
    echo "Container already exists : ${NAME_WIKI_MYSQL_CONTAINER}"
    exit 1
}
sudo docker inspect ${NAME_WIKI_CONTAINER} &> /dev/null && {
    # The container we are trying to create already exists
    echo "Container already exists : ${NAME_WIKI_CONTAINER}"
    exit 1
}
#   pull latest version of base image
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null || \
    ./build.openssl.sh
sudo docker pull synctree/mediawiki
sudo docker inspect synctree/mediawiki > /dev/null
sudo docker pull mysql:latest
sudo docker inspect mysql:latest > /dev/null

# ************************************************************
# remove any old versions of the tags
sudo docker inspect mysql:${TAG} &> /dev/null && \
    sudo docker rmi mysql:${TAG}

# ************************************************************
# create docker images:
sudo docker inspect ${NAME_WIKI_IMAGE}:${TAG} &> /dev/null && {
  # an image already exists with the name and tag we are trying to create.
  # move it to the latest tag so it will be updated and then renamed
  sudo docker tag ${NAME_WIKI_IMAGE}:${TAG} ${NAME_WIKI_IMAGE}:latest
  sudo docker rmi ${NAME_WIKI_IMAGE}:${TAG}
}
sudo docker build --rm=true --tag="${NAME_WIKI_IMAGE}" ./docker-mediawiki
sudo docker inspect ${NAME_WIKI_IMAGE}:latest > /dev/null
# move the image to the tag
sudo docker tag ${NAME_WIKI_IMAGE}:latest ${NAME_WIKI_IMAGE}:${TAG}
sudo docker rmi ${NAME_WIKI_IMAGE}:latest

# create tag for images
sudo docker tag mysql:latest mysql:${TAG}

# ************************************************************
# create the data volumes:
#     create mysql data volume if it dose not already exist
sudo docker inspect ${NAME_WIKI_MYSQL_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_WIKI_MYSQL_DV}" \
      mysql:${TAG} echo "MySQL data store"
#     create data volume containing static data for the mediawiki
sudo docker inspect ${NAME_WIKI_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_WIKI_DV}" \
      --entrypoint="/bin/echo" \
      ${NAME_WIKI_IMAGE}:${TAG} "mediawiki data store"

# ************************************************************
# start mysql
sudo docker run -d --name "${NAME_WIKI_MYSQL_CONTAINER}" \
  --restart=always \
  -e MYSQL_ROOT_PASSWORD="${WIKI_MYSQL_PASSWORD}" \
  -e MYSQL_DATABASE=wikidb \
  -e MYSQL_USER="${MEDIAWIKI_USER}" \
  -e MYSQL_PASSWORD="${MEDIAWIKI_PASSWORD}" \
  --volumes-from "${NAME_WIKI_MYSQL_DV}" \
  mysql:${TAG}

# ************************************************************
# start mediawiki
sudo docker inspect ${NAME_WIKI_MYSQL_CONTAINER} > /dev/null
sudo docker run -d --name "${NAME_WIKI_CONTAINER}" \
  --restart=always \
  -P -p ${MEDIAWIKI}:443 -p ${MEDIAWIKI_OPEN}:80 \
  -e MEDIAWIKI_DB_NAME=wikidb \
  -e MEDIAWIKI_DB_USER="${MEDIAWIKI_USER}" \
  -e MEDIAWIKI_DB_PASSWORD="${MEDIAWIKI_PASSWORD}" \
  --volumes-from "${NAME_WIKI_DV}" \
  --volumes-from "${NAME_OPENSSL_DV}" \
  --link ${NAME_WIKI_MYSQL_CONTAINER}:mysql \
  ${NAME_WIKI_IMAGE}:${TAG}

# ************************************************************
# restore mediawiki settings
./mediawiki.sh restore
