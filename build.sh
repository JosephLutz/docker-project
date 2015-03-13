#!/bin/bash
CWD=$(pwd)

source config.sh

# ************************************************************
# create docker images
docker build --rm=true --tag="websvn_image" ${CWD}/websvn
docker build --rm=true --tag="websvn_ssl_data" --file="Dockerfile.ssl" ${CWD}/data_container
docker build --rm=true --tag="websvn_password_data" --file="Dockerfile.websvn_password" ${CWD}/data_container
docker build --rm=true --tag="websvn_svn_data" --file="Dockerfile.svndata" ${CWD}/data_container

# ************************************************************
# create the data volumes
docker run --name websvn_ssl_data_volume websvn_ssl_data
docker run --name websvn_password_data_volume websvn_password_data
docker run --name svn_data_volume websvn_svn_data

# ************************************************************
# populate the data volumes with their data

# generate self signed certificate
${CWD}/websvn_CertificateSigningRequest.sh gen_self_signed

# create the first user for access to WebSVN
docker run -ti --rm --volumes-from websvn_password_data_volume websvn_image \
  /bin/bash -c \
    "apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes apache2-utils && \
    /usr/bin/htpasswd -bcB /etc/apache2/websvn_password/dav_svn.passwd novatech novatech"

# Import SVN repositories
${CWD}/import_SVN.sh

# ************************************************************
# Start WebSVN for running on the linuxserver
${CWD}/start_websvn.sh
