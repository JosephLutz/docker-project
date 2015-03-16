#!/bin/bash
set -e

CWD=$(pwd)

source config.sh

docker run -d --name websvn --restart=always -P -p ${WEBSVN_IP}:443:443 \
  -v ${HOST_SVN_DIR}:/var/lib/svn \
  -v ${HOST_WEBSVN_SSL_DIR}:/etc/apache2/ssl \
  -v ${HOST_WEBSVN_PASSWD_DIR}:/etc/apache2/websvn_password \
  websvn_image

#docker run -d --name websvn -P -p ${WEBSVN_IP}:443:443 \
#  --volumes-from svn_data_volume \
#  --volumes-from websvn_password_data_volume \
#  --volumes-from websvn_ssl_data_volume \
#  websvn_image
