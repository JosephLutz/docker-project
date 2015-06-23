#!/bin/bash
source config.sh
set -e

ALL_SERVICES=( \
    openssl \
    ldap \
    svn \
    gitlab \
    wiki \
    phpmyadmin \
    django \
    )
#    git \
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
                --volumes-from "${HTPASSWD_DV_NAME}" \
                -e USERNAME=novatech \
                -e PASSWORD=novatech \
                ${HTPASSWD_IMAGE_NAME}:${DOCKER_IMAGE_TAG} generate
            ;;

        openssl)
            sudo true
            cat ${HOST_OPENSSL_BACKUP_DIR}/openssl.tar | \
                sudo docker run -i --rm \
                    --volumes-from "${OPENSSL_DV_NAME}" \
                    ${OPENSSL_IMAGE_NAME}:${DOCKER_IMAGE_TAG} extract
            ;;

        ldap)
              # sudo docker run -ti --rm \
              #   --volumes-from "${OPENLDAP_DV_NAME}" \
              #   -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
              #   ${OPENLDAP_IMAGE_NAME}:${DOCKER_IMAGE_TAG} apply_ldif database.ldif
            #sudo docker run -ti --rm \
            #    --volumes-from "${OPENLDAP_DV_NAME}" \
            #    -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
            #    ${OPENLDAP_IMAGE_NAME}:${DOCKER_IMAGE_TAG} /bin/bash

            #      ${OPENLDAP_IMAGE_NAME}:${DOCKER_IMAGE_TAG} init_data_volumes
            sudo docker run -ti --rm \
                --volumes-from "${OPENLDAP_DV_NAME}" \
                -v ${HOST_OPENLDAP_BACKUP_DIR}:/tmp/import_export \
                ${OPENLDAP_IMAGE_NAME}:${DOCKER_IMAGE_TAG} /bin/tar \
                    --extract \
                    --preserve-permissions \
                    --preserve-order \
                    --same-owner \
                    --directory=/ \
                    -f /tmp/import_export/ldap.02.tar
            ;;

        svn)
            sudo docker run -ti --rm \
                --volumes-from "${SVN_DV_NAME}" \
                -v ${HOST_SVN_BACKUP_DIR}:/tmp/import_export \
                ${SVN_IMAGE_NAME}:${DOCKER_IMAGE_TAG} import ${SVN_REPOS[*]}
            ;;

        git)
            FILES_TO_RESTORE=($(cd ${HOST_GIT_BACKUP_DIR};ls -1 *.backup.tar.gz))
            sudo docker run -ti --rm \
                --volumes-from "${GIT_DV_NAME}" \
                -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export \
                ${GIT_IMAGE_NAME}:${DOCKER_IMAGE_TAG} restore ${FILES_TO_RESTORE[*]}
            ;;

        gitlab)
            # postgres database
            if sudo docker inspect "${GITLAB_DB_CONTAINER_NAME}_populate" &> /dev/null
            then
                if sudo docker inspect "${GITLAB_DB_CONTAINER_NAME}_populate" | grep -q '"Running": true,'
                then
                    printf "Stopping : "
                    sudo docker stop "${GITLAB_DB_CONTAINER_NAME}_populate"
                fi
                printf "Removing : "
                sudo docker rm -v "${GITLAB_DB_CONTAINER_NAME}_populate"
            fi
            sudo docker run -d --name "${GITLAB_DB_CONTAINER_NAME}_populate" \
                --volumes-from "${GITLAB_DB_DV_NAME}" \
                -v $(pwd)/$(get_docker_dir ${GITLAB_IMAGE_NAME})/postgres/:/docker-entrypoint-initdb.d/ \
                --env='POSTGRES_DB=gitlabhq_production' \
                -e POSTGRES_USER="${GITLAB_DB_USER}" \
                -e POSTGRES_PASSWORD="${GITLAB_DB_PASSWORD}" \
                postgres:${DOCKER_IMAGE_TAG}
            printf 'Waiting for postgresql database to finish starting up.  '
            while ! \
                sudo docker exec \
                    "${GITLAB_DB_CONTAINER_NAME}_populate" \
                        su postgres -c "psql -l" 2>&1 | \
                    grep -q '^ gitlabhq_production\b' &> /dev/null
            do
                sleep 1
                printf '.'
            done
            printf '\n'
            printf "Stopping : "
            sudo docker stop "${GITLAB_DB_CONTAINER_NAME}_populate"
            printf "Rremoving : "
            sudo docker rm -v "${GITLAB_DB_CONTAINER_NAME}_populate"
            ;;

        wiki)
            ./go.start.sh ldap
            ./go.start.sh ${service_name}
            ./docker-mediawiki/mediawiki.sh restore
            sudo docker stop "${WIKI_CONTAINER_NAME}" "${WIKI_DB_CONTAINER_NAME}"
            sudo docker rm -v "${WIKI_CONTAINER_NAME}" "${WIKI_DB_CONTAINER_NAME}"
            ;;

        phpmyadmin)
#            ./go.start.sh ${service_name}
#            ./
            ;;

        django)
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
