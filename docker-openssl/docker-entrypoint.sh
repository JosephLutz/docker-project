#!/bin/bash
set -e

# ************************************************************
# Options passed to the docker container to run scripts
# ************************************************************
# backup   : archives the certificate authority into the IMPORT_EXPORT_PATH
# import   : imports the certificate authority from the IMPORT_EXPORT_PATH
# generate : generates a self signed certificate authority

case ${1} in
    backup)
        # command to export the certificate authority for backup
        for base_filename in ${SSL_BASE_FILES}
        do
            cp  ${SSL_BASE_DIR}/${base_filename}.key \
                ${SSL_BASE_DIR}/${base_filename}.pem \
                  ${IMPORT_EXPORT_PATH}/
        done
        ;;

    import)
        # commands to import the certificate authority
        for base_filename in ${SSL_BASE_FILES}
        do
            cp  ${IMPORT_EXPORT_PATH}/${base_filename}.key \
                ${IMPORT_EXPORT_PATH}/${base_filename}.pem \
                  ${SSL_BASE_DIR}/
        done
        chown root:www-data ${SSL_BASE_DIR}
        chmod 600 ${SSL_BASE_DIR}
        chown www-data:www-data ${SSL_BASE_DIR}/*
        ;;

    generate)
        # commands to generate a self signed certifacate
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
            openssl
        for base_filename in ${SSL_BASE_FILES}
        do
            openssl req -newkey rsa:${BYTES} -x509 -days ${DAYS} -nodes \
                -keyout ${SSL_BASE_DIR}/${base_filename}.key \
                -out ${SSL_BASE_DIR}/${base_filename}.pem \
                -subj ${SUBJ}
        done
        chown root:www-data ${SSL_BASE_DIR}
        chmod 600 ${SSL_BASE_DIR}
        chown www-data:www-data ${SSL_BASE_DIR}/*
        ;;

    *)
        # run some other command in the docker container
        exec "$@"
        ;;
esac
