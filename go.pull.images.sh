#!/bin/bash
source config.sh
set -e

printf '***************************************\n'
printf 'Pulling latest base images\n'
printf '***************************************\n'
sudo docker pull debian:8
sudo docker pull mysql:latest
sudo docker pull synctree/mediawiki
sudo docker pull corbinu/docker-phpmyadmin:latest

sudo docker pull osixia/phpldapadmin

printf '***************************************\n'
printf 'Images used as they are\n'

printf 'remove old tags\n'
sudo docker inspect mysql:${TAG} &> /dev/null && \
    sudo docker rmi mysql:${TAG}
sudo docker inspect corbinu/docker-phpmyadmin:${TAG} &> /dev/null && \
    sudo docker rmi corbinu/docker-phpmyadmin:${TAG}

printf 'add new tags\n'
sudo docker tag mysql:latest mysql:${TAG}
sudo docker tag corbinu/docker-phpmyadmin:latest corbinu/docker-phpmyadmin:${TAG}

printf '***************************************\n'
