#!/bin/bash
set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# create docker images
docker build --rm=true --tag="htpassman_image" ${CWD}/htpassman

# ************************************************************
# create the data volumes
#docker run --name htpassman_password_data_volume htpassman_password_data

# ************************************************************
# populate the data volumes with their data

# generate self signed certificate
${CWD}/websvn_CertificateSigningRequest.sh gen_self_signed

# create the first user for access to WebSVN
docker run -ti --rm \
  -v ${HOST_WEBSVN_PASSWD_DIR}:/etc/apache2/websvn_password \
  htpassman_image \
    /bin/bash -c \
      "apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes apache2-utils && \
      /usr/bin/htpasswd -bcB /etc/apache2/htpassman_password/htpassman.passwd novatech novatech && \
      touch /etc/apache2/htpassman_password/htpassman.group && \
      chown www-data:www-data /etc/apache2/htpassman_password/htpassman.* && \
      chmod 600 /etc/apache2/htpassman_password/htpassman.*"

# ************************************************************
# Start WebSVN for running on the linuxserver

docker run -d --name htpassman --restart=always -P -p ${HTPASSMAN_IP}:443:443 -p ${HTPASSMAN_IP}:80:80 \
  -v ${HOST_HTPASSMAN_SSL_DIR}:/etc/apache2/ssl \
  -v ${HOST_HTPASSMAN_PASSWD_DIR}:/etc/apache2/htpassman_password \
  htpassman_image
