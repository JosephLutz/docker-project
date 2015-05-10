#!/bin/bash
set -e

# ************************************************************
# Options passed to the docker container to run scripts
# ************************************************************
# backup   : archives the httpasswd file into the IMPORT_EXPORT_PATH
# import   : imports the httpasswd file from the IMPORT_EXPORT_PATH
# generate : creates an initial httpasswd file with the novatech user

IMPORT_EXPORT_PATH=/tmp/import_export
PASSWD_BASE_DIR=/etc/htpasswd
HTPASSWD_FILES=${HTPASSWD_FILES:=svn.passwd git.passwd}

case ${1} in
    backup)
        # command to export the httpasswd file for backup
        for filename in ${HTPASSWD_FILES}
        do
            cp  ${PASSWD_BASE_DIR}/${filename} \
                  ${IMPORT_EXPORT_PATH}/
        done
        ;;

    import)
        # commands to import the httpasswd file
        for filename in ${HTPASSWD_FILES}
        do
            cp  ${IMPORT_EXPORT_PATH}/${filename} \
                  ${PASSWD_BASE_DIR}/
        done
        chown root:www-data ${PASSWD_BASE_DIR}
        chmod 770 ${PASSWD_BASE_DIR}
        chown www-data:www-data ${PASSWD_BASE_DIR}/*
        ;;

    generate)
        USERNAME=${USERNAME:=novatech}
        PASSWORD=${PASSWORD:=novatech}
        # commands to generate an initial user in the htpasswd file
        for filename in ${HTPASSWD_FILES}
        do
            /usr/bin/htpasswd -bc \
                ${PASSWD_BASE_DIR}/${filename} \
                ${USERNAME} ${PASSWORD}
        done
        chown root:www-data ${PASSWD_BASE_DIR}
        chmod 770 ${PASSWD_BASE_DIR}
        chown www-data:www-data ${PASSWD_BASE_DIR}/*
        ;;

    *)
        # run some other command in the docker container
        exec "$@"
        ;;
esac
