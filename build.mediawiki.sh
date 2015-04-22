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
sudo docker inspect ${NAME_WIKI_PHPMYADMIN_CONTAINER} &> /dev/null && {
    # The container we are trying to create already exists
    echo "Container already exists : ${NAME_WIKI_PHPMYADMIN_CONTAINER}"
    exit 1
}
#   pull latest version of base image
###   sudo docker pull synctree/mediawiki
###   sudo docker inspect synctree/mediawiki > /dev/null
###   sudo docker pull mysql:latest
###   sudo docker inspect mysql:latest > /dev/null
###   #sudo docker pull corbinu/docker-phpmyadmin:latest
###   #sudo docker inspect corbinu/docker-phpmyadmin:latest > /dev/null

# remove any old versions of the tags
sudo docker inspect synctree/mediawiki:${TAG} &> /dev/null && \
    sudo docker rmi synctree/mediawiki:${TAG}
sudo docker inspect mysql:${TAG} &> /dev/null && \
    sudo docker rmi mysql:${TAG}
#sudo docker inspect corbinu/docker-phpmyadmin:${TAG} &> /dev/null && \
#    sudo docker rmi corbinu/docker-phpmyadmin:${TAG}

# create tag for images
sudo docker tag synctree/mediawiki:latest synctree/mediawiki:${TAG}
sudo docker tag mysql:latest mysql:${TAG}
#sudo docker tag corbinu/docker-phpmyadmin:latest corbinu/docker-phpmyadmin:${TAG}

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
  -e MYSQL_DATABASE=wikidb \
  -e MYSQL_USER="${MEDIAWIKI_USER}" \
  -e MYSQL_PASSWORD="${MEDIAWIKI_PASSWORD}" \
  --volumes-from "${NAME_WIKI_MYSQL_DV}" \
  mysql:${TAG}

# ************************************************************
# start mediawiki and populate the datavolume
sudo docker inspect ${NAME_WIKI_MYSQL_CONTAINER} > /dev/null
sudo docker run -d --name "${NAME_WIKI_CONTAINER}" \
  --restart=always \
  -P -p ${MEDIAWIKI}:443 -p ${MEDIAWIKI_OPEN}:80 \
  -e MEDIAWIKI_DB_NAME=wikidb \
  -e MEDIAWIKI_DB_USER="${MEDIAWIKI_USER}" \
  -e MEDIAWIKI_DB_PASSWORD="${MEDIAWIKI_PASSWORD}" \
  --link ${NAME_WIKI_MYSQL_CONTAINER}:mysql \
  -v ${BACKUP_DIR}:/tmp/import_export \
  synctree/mediawiki:${TAG}


# ************************************************************
# build phpmyadmin with changes made. then make tag
sudo docker build --rm=true --tag="docker-phpmyadmin" ./docker-phpmyadmin
sudo docker inspect docker-phpmyadmin:latest > /dev/null
sudo docker inspect docker-phpmyadmin:${TAG} &> /dev/null && \
    sudo docker rmi docker-phpmyadmin:${TAG}
sudo docker tag docker-phpmyadmin:latest docker-phpmyadmin:${TAG}

# ************************************************************
# start phpmyadmin and link it to the database
sudo docker inspect ${NAME_WIKI_MYSQL_CONTAINER} > /dev/null
sudo docker run -d --name ${NAME_WIKI_PHPMYADMIN_CONTAINER} \
  --link ${NAME_WIKI_MYSQL_CONTAINER}:mysql \
  -e MYSQL_USERNAME=root \
  -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
  -e PMA_SECRET="${PHPMYADMIN_PMA_SECRET}" \
  -e PMA_USERNAME="${PHPMYADMIN_PMA_USERNAME}" \
  -e PMA_PASSWORD="${PHPMYADMIN_PMA_PASSWD}" \
  -p ${PHPMYADMIN_OPEN}:80 \
  docker-phpmyadmin:${TAG}
#  corbinu/docker-phpmyadmin:${TAG}
