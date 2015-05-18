#!/bin/bash
source config.sh
set -e

ALL_SERVICES=( \
    openssl \
    ldap \
    svn \
    git \
    wiki \
    phpmyadmin \
    djangp \
    )
#    htpasswd \

services=( ${@} )
[[ "${#services}" == "0" ]] && \
    services=${ALL_SERVICES[*]}

for service_name in ${services[*]}
do
    printf '**************************************\n'
    printf ' - %s\n\n' "${service_name}"
    case ${service_name} in
        htpasswd)
            sudo docker run -ti --rm \
                --volumes-from "${NAME_HTPASSWD_DV}" \
                -e USERNAME=novatech \
                -e PASSWORD=novatech \
                ${NAME_HTPASSWD_IMAGE}:${TAG} generate
            ;;

        openssl)
            sudo true
            cat ${HOST_OPENSSL_BACKUP_DIR}/openssl.tar | \
                sudo docker run -i --rm \
                    --volumes-from "${NAME_OPENSSL_DV}" \
                    ${NAME_OPENSSL_IMAGE}:${TAG} extract
            ;;

        ldap)
              # sudo docker run -ti --rm \
              #   --volumes-from "${NAME_LDAP_DV}" \
              #   -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
              #   ${NAME_LDAP_IMAGE}:${TAG} apply_ldif database.ldif
            #sudo docker run -ti --rm \
            #    --volumes-from "${NAME_LDAP_DV}" \
            #    -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
            #    ${NAME_LDAP_IMAGE}:${TAG} /bin/bash

            #      ${NAME_LDAP_IMAGE}:${TAG} init_data_volumes
            sudo docker run -ti --rm \
                --volumes-from "${NAME_LDAP_DV}" \
                -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
                ${NAME_LDAP_IMAGE}:${TAG} /bin/tar \
                    --extract \
                    --preserve-permissions \
                    --preserve-order \
                    --same-owner \
                    --directory=/ \
                    -f /tmp/import_export/ldap.02.tar
            ;;

        svn)
            sudo docker run -ti --rm \
                --volumes-from "${NAME_SVN_REPO_DV}" \
                -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export \
                ${NAME_SVN_IMAGE}:${TAG} import ${SVN_REPOS[*]}
            ;;

        git)
            FILES_TO_RESTORE=($(cd ${HOST_GIT_BACKUP_DIR};ls -1 *.backup.tar.gz))
            sudo docker run -ti --rm \
                --volumes-from "${NAME_GIT_REPO_DV}" \
                -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export \
                ${NAME_GIT_IMAGE}:${TAG} restore ${FILES_TO_RESTORE[*]}
            ;;

        wiki)
            ./go.start.sh ldap
            ./go.start.sh ${service_name}
            ./docker-mediawiki/mediawiki.sh restore
            sudo docker stop "${NAME_WIKI_CONTAINER}" "${NAME_WIKI_MYSQL_CONTAINER}" "${NAME_LDAP_CONTAINER}"
            sudo docker rm -v "${NAME_WIKI_CONTAINER}" "${NAME_WIKI_MYSQL_CONTAINER}" "${NAME_LDAP_CONTAINER}"
            ;;

        phpmyadmin)
#            ./go.start.sh ${service_name}
#            ./
            ;;

        djangp)
            ;;

        *)
            printf 'Available services:\n'
            for service_name in ${ALL_SERVICES[*]}
            do
                printf ' -  %s\n' "${service_name}"
            done
            ;;
    esac
    printf '\n\n\n'
done
