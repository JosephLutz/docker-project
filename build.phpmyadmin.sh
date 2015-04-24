#!/bin/bash

source config.sh
set -e

# ************************************************************
# verify prerequisites:
sudo docker inspect ${NAME_PHPMYADMIN_MYSQL_CONTAINER} &> /dev/null && {
    # The container we are trying to create already exists
    echo "Container already exists : ${NAME_PHPMYADMIN_MYSQL_CONTAINER}"
    exit 1
}
sudo docker inspect ${NAME_PHPMYADMIN_CONTAINER} &> /dev/null && {
    # The container we are trying to create already exists
    echo "Container already exists : ${NAME_PHPMYADMIN_CONTAINER}"
    exit 1
}
#   pull latest version of base image
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null || \
    ./build.openssl.sh
sudo docker pull mysql:latest
sudo docker inspect mysql:latest > /dev/null
sudo docker pull corbinu/docker-phpmyadmin:latest
sudo docker inspect corbinu/docker-phpmyadmin:latest > /dev/null

# ************************************************************
# remove any old versions of the tags
sudo docker inspect mysql:${TAG} &> /dev/null && \
    sudo docker rmi mysql:${TAG}
sudo docker inspect corbinu/docker-phpmyadmin:${TAG} &> /dev/null && \
    sudo docker rmi corbinu/docker-phpmyadmin:${TAG}

# create tag for images
sudo docker tag mysql:latest mysql:${TAG}
sudo docker tag corbinu/docker-phpmyadmin:latest corbinu/docker-phpmyadmin:${TAG}

# ************************************************************
# create the data volumes:
#     create mysql data volume if it dose not already exist
sudo docker inspect ${NAME_PHPMYADMIN_MYSQL_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_PHPMYADMIN_MYSQL_DV}" \
      mysql:${TAG} echo "MySQL data store"

# ************************************************************
# start mysql
sudo docker run -d --name "${NAME_PHPMYADMIN_MYSQL_CONTAINER}" \
  --restart=always \
  -e MYSQL_ROOT_PASSWORD="${PHPMYADMIN_MYSQL_PASSWORD}" \
  --volumes-from "${NAME_PHPMYADMIN_MYSQL_DV}" \
  mysql:${TAG}

# ************************************************************
# start phpmyadmin and link it to the database
sudo docker inspect ${NAME_PHPMYADMIN_MYSQL_CONTAINER} > /dev/null
sudo docker inspect ${NAME_WIKI_MYSQL_CONTAINER} > /dev/null
sudo docker run -d --name ${NAME_PHPMYADMIN_CONTAINER} \
  --link ${NAME_PHPMYADMIN_MYSQL_CONTAINER}:mysql \
  --link ${NAME_WIKI_MYSQL_CONTAINER}:wiki_mysql \
  -e MYSQL_USERNAME=root \
  -e MYSQL_PASSWORD="${PHPMYADMIN_MYSQL_PASSWORD}" \
  -e PMA_SECRET="${PHPMYADMIN_PMA_SECRET}" \
  -e PMA_USERNAME="${PHPMYADMIN_PMA_USERNAME}" \
  -e PMA_PASSWORD="${PHPMYADMIN_PMA_PASSWD}" \
  -p ${PHPMYADMIN_OPEN}:80 \
  corbinu/docker-phpmyadmin:${TAG}
