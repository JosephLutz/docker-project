#!/bin/bash
set -e

BACKUP_PATH=/tmp/import_export
CONFIG_PATH=/etc/ldap/slapd.d
DB_PATH=/var/lib/ldap
SLAPADD=/usr/sbin/slapadd
SLAPCAT=/usr/sbin/slapcat

# When not limiting the open file descritors limit, the memory consumption of
# slapd is absurdly high. See https://github.com/docker/docker/issues/8231
ulimit -n 8192

case ${1} in
    openldap)
        exec slapd -d 32768 -u openldap -g openldap -h "ldap:/// ldapi:/// ldaps:///"
        ;;

    init_data_volumes)
        rm -rf ${CONFIG_PATH}/../* ${DB_PATH}/*
        mkdir -p ${CONFIG_PATH}
        cd /etc
        tar -xavf /etc/ldap.tar.gz ldap/schema/
        nice ${SLAPADD} -F ${CONFIG_PATH} -n 0 -l /etc/config.ldif
        chown -R openldap.openldap ${DB_PATH} ${CONFIG_PATH}
        ;;

    apply_ldif)
        # ignore first argument and get list of repositories to create
        shift
        LDIF_FILES=(${*})
        [[ ! -d ${BACKUP_PATH} ]] && exit 1
        for ldif_file in ${LDIF_FILES[*]} ; do
            if [[ ! -e ${BACKUP_PATH}/${ldif_file} ]] ; then
                echo "LDIF file not found: ${ldif_file} "
                continue
            fi
            nice ${SLAPADD} -F ${CONFIG_PATH} -n 0 -l ${BACKUP_PATH}/${ldif_file}
        done
        chown -R openldap.openldap ${DB_PATH} ${CONFIG_PATH}
        ;;

    backup)
        databasenumber=${2}
        backup_filename=${3}
        nice ${SLAPCAT} -F ${CONFIG_PATH} -n ${databasenumber} > ${BACKUP_PATH}/${backup_filename}
        chmod 640 ${BACKUP_PATH}/*.ldif
        ;;

    *)
        # run some other command in the docker container
        exec "$@"
        ;;

esac
