#!/bin/bash
set -e

CWD=$(pwd)

source config.sh

sudo docker run -d --name ts_mysql1 --restart=always -P \
  -v ${HOST_TESTSTATION_MYSQL_DATA_DIR}:/var/lib/mysql \
  my_sqld

sudo docker run -d --name my_httpd_server2 --restart=always -P -p ${TESTSTATION_IP}:80:80 \
  -v ${HOST_TESTSTATION_DJANGO_CODE_DIR}:/opt/protocol \
  --link ts_mysql1:test_station_mysql_server \
  httpd_2
