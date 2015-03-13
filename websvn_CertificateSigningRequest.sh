#!/bin/bash
CWD=$(pwd)

source config.sh

COMMAND=${1}
FILE_PATH=${2}

case ${COMMAND} in
backup)
  [[ -z "${FILE_PATH}" ]] && exit -1
  # Copy certificate from inplace to the import/export path
  docker run -it --rm --volumes-from websvn_ssl_data_volume -v ${FILE_PATH}:${SVN_EXPORT_PATH} \
    websvn_image \
      cp /etc/apache2/ssl/apache.key /etc/apache2/ssl/apache.pem ${FILE_PATH}/
  ;;
import)
  [[ -z "${FILE_PATH}" ]] && exit -1
  # Copy certificate from import/export path into place
  docker run -it --rm --volumes-from websvn_ssl_data_volume -v ${FILE_PATH}:${SVN_EXPORT_PATH} \
    websvn_image \
      cp ${FILE_PATH}/apache.key ${FILE_PATH}/apache.pem /etc/apache2/ssl/
  # change permissions on generated self signed certificate
  docker run -ti --rm --volumes-from websvn_ssl_data_volume \
    websvn_image \
      chmod 600 /etc/apache2/ssl/apache.pem /etc/apache2/ssl/apache.key
  ;;
gen_self_signed)
  # generate self signed certificate
  docker run -ti --rm --volumes-from websvn_ssl_data_volume \
    websvn_image \
      openssl req -newkey rsa:2048 -x509 -days 365 -nodes \
        -keyout /etc/apache2/ssl/apache.key \
        -out /etc/apache2/ssl/apache.pem \
        -subj "/C=US/ST=Kansas/L=Lenexa/O=Novatech/CN=websvn.novatech-llc.com"
  # change permissions on generated self signed certificate
  docker run -ti --rm --volumes-from websvn_ssl_data_volume \
    websvn_image \
      chmod 600 /etc/apache2/ssl/apache.pem /etc/apache2/ssl/apache.key
  ;;
*)
  echo ${0}" COMMAND [FILE_PATH]"
  echo ""
  echo "  COMMANDS:"
  echo "    backup           Copies certificite signing request files out of the volume into the backup dir"
  echo "    import           Copies certificite signing request files into the volume from the specified dir"
  echo "    gen_self_signed  Generates a self signed (2048 bit RSA certificate) in the volume"
  echo ""
  echo "  FILE_PATH:"
  echo "    The directory path where the certificate files (apache.key and apache.pem) will be coppied to/from."
  echo ""
  ;;
esac