#!/bin/bash

# Example backup commands
#   sudo docker run -ti --rm --volumes-from "${NAME_LDAP_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_LDAP_IMAGE}:latest backup
# Example restore commands
#   sudo docker run -ti --rm --volumes-from "${NAME_LDAP_DV}" -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export ${NAME_LDAP_IMAGE}:latest restore
# Example create new database
#   sudo docker run -ti --rm --volumes-from "${NAME_LDAP_DV}" ${NAME_LDAP_IMAGE}:latest

source config.sh
set -e

# ************************************************************
# verify prerequisites:
sudo docker inspect ${NAME_LDAP_CONTAINER} &> /dev/null && {
    # The container we are trying to create already exists
    echo "Container already exists : ${NAME_LDAP_CONTAINER}"
    exit 1
}
sudo docker inspect ${NAME_LDAP_IMAGE}:latest &> /dev/null && {
	echo "Image exists: ${NAME_LDAP_IMAGE}:latest"
	echo "  Can not build or update the image (${NAME_LDAP_IMAGE}:${TAG})"
	echo "  while ${NAME_LDAP_IMAGE}:latest exists."
	exit 1
}
sudo docker inspect ${NAME_OPENSSL_DV} &> /dev/null || \
    ./build.openssl.sh
#     pull latest version of base image
sudo docker pull debian:8
sudo docker inspect debian:8 > /dev/null

# ************************************************************
# create docker images:
sudo docker inspect ${NAME_LDAP_IMAGE}:${TAG} &> /dev/null && {
	# an image already exists with the name and tag we are trying to create.
	# move it to the latest tag so it will be updated and then renamed
	sudo docker tag ${NAME_LDAP_IMAGE}:${TAG} ${NAME_LDAP_IMAGE}:latest
	sudo docker rmi ${NAME_LDAP_IMAGE}:${TAG}
}
sudo docker build --rm=true --tag="${NAME_LDAP_IMAGE}" ./docker-openldap
sudo docker inspect ${NAME_LDAP_IMAGE}:latest > /dev/null
# move the image to the tag
sudo docker tag ${NAME_LDAP_IMAGE}:latest ${NAME_LDAP_IMAGE}:${TAG}
sudo docker rmi ${NAME_LDAP_IMAGE}:latest

# ************************************************************
# create the data volumes:
#     create ldap data volume if it dose not already exist
sudo docker inspect ${NAME_LDAP_DV} &> /dev/null || \
    sudo docker run -ti --name "${NAME_LDAP_DV}" \
      -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
      ${NAME_LDAP_IMAGE}:${TAG} init_data_volumes

# setup data volumes
  # sudo docker run -ti --rm \
  #   --volumes-from "${NAME_LDAP_DV}" \
  #   -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
  #   ${NAME_LDAP_IMAGE}:${TAG} apply_ldif database.ldif
sudo docker run -ti --rm \
  --volumes-from "${NAME_LDAP_DV}" \
  -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
  ${NAME_LDAP_IMAGE}:${TAG} /bin/bash

# ************************************************************
# Start openldap for running on the linuxserver
# start container running
sudo docker run -d --name "${NAME_LDAP_CONTAINER}" \
  --restart=always \
  --volumes-from "${NAME_OPENSSL_DV}" \
  --volumes-from "${NAME_LDAP_DV}" \
  ${NAME_LDAP_IMAGE}:${TAG}

#  -P -p ${OPENLDAP}:389 -p ${OPENLDAP_SECURE}:636 \



#SLAPADD=/usr/sbin/slapadd
#    init)
#        mkdir /tmp/config
#        cp /config/* /tmp/config/
#        DC='dc=novatech-llc,dc=com'
#        echo "Enter in password for olcRootPW :"
#        password=$(slappasswd)
#        sed -ie "s|dc=XXXXXXXXXXXX,dc=XXX|"${DC}"|" /tmp/config/config.ldif
#        #sed -ie "s|dc=XXXXXXXXXXXX,dc=XXX|"${DC}"|" /tmp/config/ldapuser.ldif
#        sed -ie "s|XXXXXXxxxxxxxxxxxxxxxxxxxxxxxx|"${password}"|" /tmp/config/config.ldif
#        #sed -ie "s|XXXXXXxxxxxxxxxxxxxxxxxxxxxxxx|"${password}"|" /tmp/config/ldapuser.ldif
#        # Set OpenLDAP admin password
#        #ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/config/config.ldif
#        #ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/config/ldapuser.ldif
#        #ldapadd -x -D cn=Manager,dc=server,dc=world -W -f ldapuser.ldif
#        nice ${SLAPADD} -F ${CONFIG_PATH} -n 0 -l /tmp/config/config.ldif
#        #nice ${SLAPADD} -F ${CONFIG_PATH} -n 0 -l /tmp/config/ldapuser.ldif
#        ;;
#    backup)
#        nice ${SLAPCAT} -n 0 > ${BACKUP_PATH}/config.ldif
#        nice ${SLAPCAT} -n 1 > ${BACKUP_PATH}/domain.ldif
#        nice ${SLAPCAT} -n 2 > ${BACKUP_PATH}/access.ldif
#        chmod 640 ${BACKUP_PATH}/*.ldif
#        ;;
#    restore)
#        rm -rf /etc/ldap/* ${DB_PATH}/*
#        cd /etc/ldap/
#        tar -xaf /config/ldap.tgz
#        nice ${SLAPADD} -F ${CONFIG_PATH} -n 0 -l ${BACKUP_PATH}/config.ldif
#        nice ${SLAPADD} -F ${CONFIG_PATH} -n 1 -l ${BACKUP_PATH}/domain.ldif
#        nice ${SLAPADD} -F ${CONFIG_PATH} -n 2 -l ${BACKUP_PATH}/access.ldif
#        chown -R openldap:openldap ${BACKUP_PATH}
#        chown -R openldap:openldap ${DB_PATH}
#        ;;
