#!/bin/bash
source config.sh
set -e

printf '***************************************\n'
printf 'Pulling latest base images\n'
printf '***************************************\n'
sudo docker pull debian:8
sudo docker pull mysql:5
sudo docker pull postgres:9.4
sudo docker pull redis:3.0
sudo docker pull synctree/mediawiki
sudo docker pull corbinu/docker-phpmyadmin:latest
sudo docker pull osixia/phpldapadmin
sudo docker pull sameersbn/gitlab

printf '***************************************\n'
printf 'Images used as they are\n'

printf 'remove old tags\n'
sudo docker inspect mysql:${TAG} &> /dev/null && \
    sudo docker rmi mysql:${TAG}
sudo docker inspect postgres:${TAG} &> /dev/null && \
    sudo docker rmi postgres:${TAG}
sudo docker inspect redis:${TAG} &> /dev/null && \
    sudo docker rmi redis:${TAG}
sudo docker inspect corbinu/docker-phpmyadmin:${TAG} &> /dev/null && \
    sudo docker rmi corbinu/docker-phpmyadmin:${TAG}
sudo docker inspect sameersbn/gitlab:${TAG} &> /dev/null && \
    sudo docker rmi sameersbn/gitlab:${TAG}

printf 'add new tags\n'
sudo docker tag mysql:5 mysql:${TAG}
sudo docker tag postgres:9.4 postgres:${TAG}
sudo docker tag redis:3.0 redis:${TAG}
sudo docker tag corbinu/docker-phpmyadmin:latest corbinu/docker-phpmyadmin:${TAG}
sudo docker tag sameersbn/gitlab:latest sameersbn/gitlab:${TAG}

printf '***************************************\n'
