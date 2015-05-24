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
    djangp \
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

        gitlab)
            # postgres database
            if sudo docker inspect "${NAME_GITLAB_POSTGRES_CONTAINER}_populate" &> /dev/null
            then
                if sudo docker inspect "${NAME_GITLAB_POSTGRES_CONTAINER}_populate" | grep -q '"Running": true,'
                then
                    printf "Stopping : "
                    sudo docker stop "${NAME_GITLAB_POSTGRES_CONTAINER}_populate"
                fi
                printf "Rremoving : "
                sudo docker rm -v "${NAME_GITLAB_POSTGRES_CONTAINER}_populate"
            fi
            sudo docker run -d --name "${NAME_GITLAB_POSTGRES_CONTAINER}_populate" \
                --volumes-from "${NAME_GITLAB_POSTGRES_DV}" \
                -v $(pwd)/$(get_docker_dir ${NAME_GITLAB_IMAGE})/postgres/:/docker-entrypoint-initdb.d/ \
                --env='POSTGRES_DB=gitlabhq_production' \
                -e POSTGRES_USER="${GITLAB_POSTGRES_USER}" \
                -e POSTGRES_PASSWORD="${GITLAB_POSTGRES_PASSWORD}" \
                postgres:${TAG}
            printf 'Waiting for postgresql database to finish starting up.\n'
            while ! \
                sudo docker exec -i \
                    "${NAME_GITLAB_POSTGRES_CONTAINER}_populate" \
                        su postgres -c "psql -l" 2>&1 | \
                    grep -q '^ gitlabhq_production\b' &> /dev/null
            do
                sleep 1
            done
            printf "Stopping : "
            sudo docker stop "${NAME_GITLAB_POSTGRES_CONTAINER}_populate"
            printf "Rremoving : "
            sudo docker rm -v "${NAME_GITLAB_POSTGRES_CONTAINER}_populate"
            # gitlab repositories
#            sudo docker run -ti --rm \
#                --volumes-from "${NAME_GITLAB_REPO_DV}" \
#                -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export \
#                ${NAME_GIT_IMAGE}:${TAG} true
            ;;

        wiki)
            ./go.start.sh ldap
            ./go.start.sh ${service_name}
            ./docker-mediawiki/mediawiki.sh restore
            sudo docker stop "${NAME_WIKI_CONTAINER}" "${NAME_WIKI_MYSQL_CONTAINER}"
            sudo docker rm -v "${NAME_WIKI_CONTAINER}" "${NAME_WIKI_MYSQL_CONTAINER}"
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
