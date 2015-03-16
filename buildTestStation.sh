#!/bin/bash
set -e

CWD=$(pwd)

source config.sh

# ************************************************************
# make certain the host directories exist
#mkdir -p ${HOST_BACKUP_DIR}
#mkdir -p ${HOST_SVN_DIR} ${HOST_WEBSVN_SSL_DIR} ${HOST_WEBSVN_PASSWD_DIR}
#mkdir -p ${HOST_HTPASSMAN_SSL_DIR} ${HOST_HTPASSMAN_PASSWD_DIR}

# ************************************************************
# create docker images
docker build --rm=true --tag="my_sqld" ${CWD}/teststation_mysql
docker build --rm=true --tag="httpd_2" ${CWD}/httpd_django

# ************************************************************
# create the data volumes
#docker run --name name_data_volume name_data

# ************************************************************
# populate the data volumes with their data

# generate self signed certificate
#${CWD}/websvn_CertificateSigningRequest.sh gen_self_signed

# create the first user for access to WebSVN
#docker run -ti --rm \
#  -v ${HOST_WEBSVN_PASSWD_DIR}:/etc/apache2/websvn_password \
#  websvn_image \
#    /bin/bash -c \
#      "apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes apache2-utils && \
#      /usr/bin/htpasswd -bcB /etc/apache2/websvn_password/dav_svn.passwd novatech novatech"

# Import SVN repositories
#${CWD}/import_SVN.sh

# ************************************************************
# Start WebSVN for running on the linuxserver
${CWD}/start_TestStation.sh
