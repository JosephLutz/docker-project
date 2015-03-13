#!/bin/bash
CWD=$(pwd)

source config.sh

docker run -d --name websvn -P -p ${WEBSVN_IP}:443:443 --volumes-from svn_data_volume --volumes-from websvn_password_data_volume --volumes-from websvn_ssl_data_volume websvn_image websvn
