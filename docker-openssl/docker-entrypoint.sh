#!/bin/bash
set -e

# ************************************************************
# Options passed to the docker container to run scripts
# ************************************************************
# archive  : archives the certificate authority into the IMPORT_EXPORT_PATH
# import   : imports the certificate authority from the IMPORT_EXPORT_PATH
# generate : generates a self signed certificate authority

VOLUME_DIR_CONTENTS="/etc/ssl/* /usr/share/ca-certificates/* /usr/local/share/ca-certificates/* /etc/grid-security/*"
SSL_BASE_DIR="/etc/ssl"

case ${1} in
    archive)
        /bin/tar \
            --create \
            --preserve-permissions \
            --same-owner \
            --directory=/ \
            --to-stdout \
            ${VOLUME_DIR_CONTENTS}
            #--sort=name \
        ;;

    extract)
        rm -rf ${VOLUME_DIR_CONTENTS}
        /bin/tar \
            --extract \
            --preserve-permissions \
            --preserve-order \
            --same-owner \
            --directory=/ \
            -f -
        update-ca-certificates --fresh
        ;;

    generate)
        SSL_BASE_FILES=${SSL_BASE_FILES:=apache2}
        BYTES=${BYTES:=2048}
        DAYS=${DAYS:=365}
        SUBJ=${SUBJ:="/C=??/ST=ExampleState/L=ExampleState/O=ExampleOrginization/CN=example.com"}
        # commands to generate a self signed certifacate
        for base_filename in ${SSL_BASE_FILES}
        do
            openssl req -newkey rsa:${BYTES} -x509 -days ${DAYS} -nodes \
                -keyout ${SSL_BASE_DIR}/private/${base_filename}.key \
                -out ${SSL_BASE_DIR}/private/${base_filename}.crt \
                -subj ${SUBJ}
        done
        touch ${SSL_BASE_DIR}/private/${base_filename}_bundle.crt
        update-ca-certificates --fresh
        ;;

    *)
        # run some other command in the docker container
        exec "$@"
        ;;
esac
