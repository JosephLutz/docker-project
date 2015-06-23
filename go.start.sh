#!/bin/bash
source config.sh
set -e

ALL_SERVICES=( \
    ldap \
    phpldapadmin \
    svn \
    gitlab \
    wiki \
    phpmyadmin \
    django \
    )
#    git \

check_volumes() {
    local container_name
    datavolume_name=${1}
    servicee_name=${2}
    sudo true
    if ! sudo docker inspect "${datavolume_name}" &> /dev/null
    then
        ./go ${servicee_name}
    fi
}

stop_and_remove() {
    local container_name
    container_name=${1}
    sudo true
    if sudo docker inspect "${container_name}" &> /dev/null
    then
        printf 'Container [%s] already exists  ' "${container_name}"
        sleep 1 ; printf '.'
        sleep 1 ; printf '.'
        sleep 1 ; printf '.'
        sleep 1 ; printf '\n'
        if sudo docker inspect "${container_name}" | grep -q '"Running": true,'
        then
            printf 'Stopping container : '
            sudo docker stop "${container_name}"
        fi
        printf 'Removing container : '
        sudo docker rm -v "${container_name}"
        printf '\n'
    fi
}

services=( ${@} )
[[ "${#services}" == "0" ]] && \
    services=${ALL_SERVICES[*]}

for service_name in ${services[*]}
do
    printf '**************************************\n'
    printf ' - %s\n\n' "${service_name}"
    case ${service_name} in
        ldap)
            check_volumes "${OPENSSL_DV_NAME}" openssl
            stop_and_remove "${OPENLDAP_CONTAINER_NAME}"
            echo 'Starting :'
            printf "    ${OPENLDAP_CONTAINER_NAME} : "
            sudo docker run -d --name "${OPENLDAP_CONTAINER_NAME}" \
                --restart=always \
                --volumes-from "${OPENSSL_DV_NAME}" \
                --volumes-from "${OPENLDAP_DV_NAME}" \
                -e LDAP_HOSTNAME="${LDAP_HOSTNAME}" \
                -P -p ${OPENLDAP}:389 -p ${OPENLDAP_SECURE}:636 \
                ${OPENLDAP_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
            ;;

        svn)
            check_volumes "${OPENSSL_DV_NAME}" openssl
            check_volumes "${OPENLDAP_CONTAINER_NAME}" ldap
            stop_and_remove "${SVN_CONTAINER_NAME}"
            echo 'Starting :'
            printf "    ${SVN_CONTAINER_NAME} : "
            sudo docker run -d --name "${SVN_CONTAINER_NAME}" \
                --restart=always \
                -P -p ${SVN}:443 -p ${SVN_OPEN}:80 \
                --volumes-from "${SVN_DV_NAME}" \
                --volumes-from "${OPENSSL_DV_NAME}" \
                -e SVN_HOSTNAME="${SVN_HOSTNAME}" \
                --link ${OPENLDAP_CONTAINER_NAME}:ldap \
                ${SVN_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
            ;;

        git)
            check_volumes "${OPENSSL_DV_NAME}" openssl
            check_volumes "${OPENLDAP_CONTAINER_NAME}" ldap
            stop_and_remove "${GIT_CONTAINER_NAME}"
            echo 'Starting :'
            printf "    ${GIT_CONTAINER_NAME} : "
            sudo docker run -d --name "${GIT_CONTAINER_NAME}" \
                --restart=always \
                -P -p ${GIT}:443 -p ${GIT_OPEN}:80 \
                --volumes-from "${GIT_DV_NAME}" \
                --volumes-from "${OPENSSL_DV_NAME}" \
                -e GIT_HOSTNAME="${GIT_HOSTNAME}" \
                --link ${OPENLDAP_CONTAINER_NAME}:ldap \
                ${GIT_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
            ;;

        gitlab)
            check_volumes "${OPENSSL_DV_NAME}" openssl
            check_volumes "${OPENLDAP_CONTAINER_NAME}" ldap
            stop_and_remove "${GITLAB_CONTAINER_NAME}"
            stop_and_remove "${GITLAB_DB_CONTAINER_NAME}"
            stop_and_remove "${GITLAB_REDIS_CONTAINER_NAME}"
            echo 'Starting :'
            printf "    ${GITLAB_REDIS_CONTAINER_NAME} : "
            # start redis directory
            sudo docker run -d --name "${GITLAB_REDIS_CONTAINER_NAME}" \
                --restart=always \
                redis:${DOCKER_IMAGE_TAG}
            # start postgres database
            printf "    ${GITLAB_DB_CONTAINER_NAME} : "
            sudo docker run -d --name "${GITLAB_DB_CONTAINER_NAME}" \
                --restart=always \
                --volumes-from "${GITLAB_DB_DV_NAME}" \
                postgres:${DOCKER_IMAGE_TAG}
            # start gitlab
            printf "    ${GITLAB_CONTAINER_NAME} : "
            sudo docker run -d --name "${GITLAB_CONTAINER_NAME}" \
                --restart=always \
                -P -p ${GITLAB}:443 -p ${GITLAB_OPEN}:80 -p ${GITLAB_SSH}:22 \
                --volumes-from "${OPENSSL_DV_NAME}" \
                --volumes-from "${GITLAB_DV_NAME}" \
                --env-file=./gitlab.env.list \
                --env="GITLAB_HOST=${GITLAB_HOSTNAME}" \
                --env="GITLAB_SSH_HOST=${GITLAB_HOSTNAME}" \
                --env="DB_USER=${GITLAB_DB_USER}" \
                --env="DB_PASS=${GITLAB_DB_PASSWORD}" \
                --link ${OPENLDAP_CONTAINER_NAME}:gitlab-ldap \
                --link ${GITLAB_REDIS_CONTAINER_NAME}:gitlab-redis \
                --link ${GITLAB_DB_CONTAINER_NAME}:gitlab-db \
                ${GITLAB_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
            ;;

        wiki)
            check_volumes "${OPENSSL_DV_NAME}" openssl
            check_volumes "${OPENLDAP_CONTAINER_NAME}" ldap
            stop_and_remove "${WIKI_DB_CONTAINER_NAME}"
            stop_and_remove "${WIKI_CONTAINER_NAME}"
            echo 'Starting :'
            printf "    ${WIKI_DB_CONTAINER_NAME} : "
            sudo docker run -d --name "${WIKI_DB_CONTAINER_NAME}" \
                --restart=always \
                -e MYSQL_ROOT_PASSWORD="${WIKI_DB_ROOT_PASSWORD}" \
                -e MYSQL_DATABASE=wikidb \
                -e MYSQL_USER="${WIKI_DB_USER}" \
                -e MYSQL_PASSWORD="${WIKI_DB_PASSWORD}" \
                --volumes-from "${WIKI_DB_DV_NAME}" \
                mysql:${DOCKER_IMAGE_TAG}
            printf "    ${WIKI_CONTAINER_NAME} : "
            sudo docker run -d --name "${WIKI_CONTAINER_NAME}" \
                --restart=always \
                -P -p ${MEDIAWIKI}:443 -p ${MEDIAWIKI_OPEN}:80 \
                -e MEDIAWIKI_DB_NAME=wikidb \
                -e MEDIAWIKI_DB_USER="${WIKI_DB_USER}" \
                -e MEDIAWIKI_DB_PASSWORD="${WIKI_DB_PASSWORD}" \
                -e WIKI_HOSTNAME="${WIKI_HOSTNAME}" \
                --volumes-from "${WIKI_DV_NAME}" \
                --volumes-from "${OPENSSL_DV_NAME}" \
                --link ${WIKI_DB_CONTAINER_NAME}:mysql \
                --link ${OPENLDAP_CONTAINER_NAME}:ldap \
                ${WIKI_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
#-v ${HOST_WIKI_BACKUP_DIR}:/tmp/import_export \
            ;;

        phpmyadmin)
            stop_and_remove "${PHPMYADMIN_DB_CONTAINER_NAME}"
            stop_and_remove "${PHPMYADMIN_CONTAINER_NAME}"
            echo 'Starting :'
            printf "    ${PHPMYADMIN_DB_CONTAINER_NAME} : "
            sudo docker run -d --name "${PHPMYADMIN_DB_CONTAINER_NAME}" \
                --restart=always \
                -e MYSQL_ROOT_PASSWORD="${PHPMYADMIN_DB_ROOT_PASSWORD}" \
                --volumes-from "${PHPMYADMIN_DB_DV_NAME}" \
                mysql:${DOCKER_IMAGE_TAG}
            sudo docker inspect "${WIKI_DB_CONTAINER_NAME}" > /dev/null
            printf "    ${PHPMYADMIN_CONTAINER_NAME} : "
            sudo docker run -d --name "${PHPMYADMIN_CONTAINER_NAME}" \
                --link ${PHPMYADMIN_DB_CONTAINER_NAME}:mysql \
                --link ${WIKI_DB_CONTAINER_NAME}:wiki_mysql \
                --link ${OPENLDAP_CONTAINER_NAME}:ldap \
                -e MYSQL_USERNAME=root \
                -e MYSQL_PASSWORD="${PHPMYADMIN_DB_ROOT_PASSWORD}" \
                -e PMA_SECRET="${PHPMYADMIN_PMA_SECRET}" \
                -e PMA_USERNAME="${PHPMYADMIN_DB_USER}" \
                -e PMA_PASSWORD="${PHPMYADMIN_DB_PASSWD}" \
                -e PHPMYADMIN_HOSTNAME="${PHPMYADMIN_HOSTNAME}" \
                -p ${PHPMYADMIN_OPEN}:80 \
                corbinu/docker-phpmyadmin:${DOCKER_IMAGE_TAG}
            ;;

        django)
            check_volumes "${OPENSSL_DV_NAME}" openssl
            check_volumes "${OPENLDAP_CONTAINER_NAME}" ldap
            stop_and_remove "${DJANGO_CONTAINER_NAME}"
            echo 'Starting :'
            printf "    ${DJANGO_CONTAINER_NAME} : "
            sudo docker run -d --name "${DJANGO_CONTAINER_NAME}" \
                --restart=always \
                -P -p ${DJANGO_SECURE}:443 -p ${DJANGO}:80 \
                --volumes-from "${OPENSSL_DV_NAME}" \
                -e DJANGO_HOSTNAME="${DJANGO_HOSTNAME}" \
                -v ${HOST_DJANGO_SRC_DIR}:/var/lib/django \
                -v ${HOST_DJANGO_BACKUP_DIR}:/tmp/import_export \
                --link ${OPENLDAP_CONTAINER_NAME}:ldap \
                ${DJANGO_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
            ;;

        phpldapadmin)
            check_volumes "${OPENLDAP_CONTAINER_NAME}" ldap
            stop_and_remove "${PHPLDAPADMIN_CONTAINER_NAME}"
            echo 'Starting :'
            printf "    ${PHPLDAPADMIN_CONTAINER_NAME} : "
            sudo docker run -d --name "${PHPLDAPADMIN_CONTAINER_NAME}" \
                --restart=always \
                -P -p ${PHPLDAPADMIN_OPEN}:80 -p ${PHPLDAPADMIN}:443 \
                -e HTTPS=false \
                -e LDAP_HOSTS=ldap \
                --link ${OPENLDAP_CONTAINER_NAME}:ldap \
                osixia/phpldapadmin
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
