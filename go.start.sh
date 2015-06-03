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
            check_volumes "${NAME_OPENSSL_DV}" openssl
            stop_and_remove "${NAME_LDAP_CONTAINER}"
            echo 'Starting :'
            printf "    ${NAME_LDAP_CONTAINER} : "
            sudo docker run -d --name "${NAME_LDAP_CONTAINER}" \
                --restart=always \
                --volumes-from "${NAME_OPENSSL_DV}" \
                --volumes-from "${NAME_LDAP_DV}" \
                -e LDAP_HOSTNAME="${LDAP_HOSTNAME}" \
                -P -p ${OPENLDAP}:389 -p ${OPENLDAP_SECURE}:636 \
                ${NAME_LDAP_IMAGE}:${TAG}
            ;;

        svn)
            check_volumes "${NAME_OPENSSL_DV}" openssl
            check_volumes "${NAME_LDAP_CONTAINER}" ldap
            stop_and_remove "${NAME_SVN_CONTAINER}"
            echo 'Starting :'
            printf "    ${NAME_SVN_CONTAINER} : "
            sudo docker run -d --name "${NAME_SVN_CONTAINER}" \
                --restart=always \
                -P -p ${SVN}:443 -p ${SVN_OPEN}:80 \
                --volumes-from "${NAME_SVN_REPO_DV}" \
                --volumes-from "${NAME_OPENSSL_DV}" \
                -e SVN_HOSTNAME="${SVN_HOSTNAME}" \
                --link ${NAME_LDAP_CONTAINER}:ldap \
                ${NAME_SVN_IMAGE}:${TAG}
            ;;

        git)
            check_volumes "${NAME_OPENSSL_DV}" openssl
            check_volumes "${NAME_LDAP_CONTAINER}" ldap
            stop_and_remove "${NAME_GIT_CONTAINER}"
            echo 'Starting :'
            printf "    ${NAME_GIT_CONTAINER} : "
            sudo docker run -d --name "${NAME_GIT_CONTAINER}" \
                --restart=always \
                -P -p ${GIT}:443 -p ${GIT_OPEN}:80 \
                --volumes-from "${NAME_GIT_REPO_DV}" \
                --volumes-from "${NAME_OPENSSL_DV}" \
                -e GIT_HOSTNAME="${GIT_HOSTNAME}" \
                --link ${NAME_LDAP_CONTAINER}:ldap \
                ${NAME_GIT_IMAGE}:${TAG}
            ;;

        gitlab)
            check_volumes "${NAME_OPENSSL_DV}" openssl
            check_volumes "${NAME_LDAP_CONTAINER}" ldap
            stop_and_remove "${NAME_GITLAB_CONTAINER}"
            stop_and_remove "${NAME_GITLAB_POSTGRES_CONTAINER}"
            stop_and_remove "${NAME_GITLAB_REDIS_CONTAINER}"
            echo 'Starting :'
            printf "    ${NAME_GITLAB_REDIS_CONTAINER} : "
            # start redis directory
            sudo docker run -d --name "${NAME_GITLAB_REDIS_CONTAINER}" \
                --restart=always \
                redis:${TAG}
            # start postgres database
            printf "    ${NAME_GITLAB_POSTGRES_CONTAINER} : "
            sudo docker run -d --name "${NAME_GITLAB_POSTGRES_CONTAINER}" \
                --restart=always \
                --volumes-from "${NAME_GITLAB_POSTGRES_DV}" \
                postgres:${TAG}
            # start gitlab
            printf "    ${NAME_GITLAB_CONTAINER} : "
            sudo docker run -d --name "${NAME_GITLAB_CONTAINER}" \
                --restart=always \
                -P -p ${GITLAB}:443 -p ${GITLAB_OPEN}:80 -p ${GITLAB_SSH}:22 \
                --volumes-from "${NAME_OPENSSL_DV}" \
                --volumes-from "${NAME_GITLAB_REPO_DV}" \
                --env-file=./gitlab.env.list \
                --env="GITLAB_HOST=${GITLAB_HOSTNAME}" \
                --env="GITLAB_SSH_HOST=${GITLAB_HOSTNAME}" \
                --env="DB_USER=${GITLAB_POSTGRES_USER}" \
                --env="DB_PASS=${GITLAB_POSTGRES_PASSWORD}" \
                --link ${NAME_LDAP_CONTAINER}:gitlab-ldap \
                --link ${NAME_GITLAB_REDIS_CONTAINER}:gitlab-redis \
                --link ${NAME_GITLAB_POSTGRES_CONTAINER}:gitlab-db \
                ${NAME_GITLAB_IMAGE}:${TAG}
            ;;

        wiki)
            check_volumes "${NAME_OPENSSL_DV}" openssl
            check_volumes "${NAME_LDAP_CONTAINER}" ldap
            stop_and_remove "${NAME_WIKI_MYSQL_CONTAINER}"
            stop_and_remove "${NAME_WIKI_CONTAINER}"
            echo 'Starting :'
            printf "    ${NAME_WIKI_MYSQL_CONTAINER} : "
            sudo docker run -d --name "${NAME_WIKI_MYSQL_CONTAINER}" \
                --restart=always \
                -e MYSQL_ROOT_PASSWORD="${WIKI_MYSQL_PASSWORD}" \
                -e MYSQL_DATABASE=wikidb \
                -e MYSQL_USER="${MEDIAWIKI_USER}" \
                -e MYSQL_PASSWORD="${MEDIAWIKI_PASSWORD}" \
                --volumes-from "${NAME_WIKI_MYSQL_DV}" \
                mysql:${TAG}
            printf "    ${NAME_WIKI_CONTAINER} : "
            sudo docker run -d --name "${NAME_WIKI_CONTAINER}" \
                --restart=always \
                -P -p ${MEDIAWIKI}:443 -p ${MEDIAWIKI_OPEN}:80 \
                -e MEDIAWIKI_DB_NAME=wikidb \
                -e MEDIAWIKI_DB_USER="${MEDIAWIKI_USER}" \
                -e MEDIAWIKI_DB_PASSWORD="${MEDIAWIKI_PASSWORD}" \
                -e WIKI_HOSTNAME="${WIKI_HOSTNAME}" \
                --volumes-from "${NAME_WIKI_DV}" \
                --volumes-from "${NAME_OPENSSL_DV}" \
                --link ${NAME_WIKI_MYSQL_CONTAINER}:mysql \
                --link ${NAME_LDAP_CONTAINER}:ldap \
                ${NAME_WIKI_IMAGE}:${TAG}
#-v ${HOST_MEDIAWIKI_BACKUP_DIR}:/tmp/import_export \
            ;;

        phpmyadmin)
            stop_and_remove "${NAME_PHPMYADMIN_MYSQL_CONTAINER}"
            stop_and_remove "${NAME_PHPMYADMIN_CONTAINER}"
            echo 'Starting :'
            printf "    ${NAME_PHPMYADMIN_MYSQL_CONTAINER} : "
            sudo docker run -d --name "${NAME_PHPMYADMIN_MYSQL_CONTAINER}" \
                --restart=always \
                -e MYSQL_ROOT_PASSWORD="${PHPMYADMIN_MYSQL_PASSWORD}" \
                --volumes-from "${NAME_PHPMYADMIN_MYSQL_DV}" \
                mysql:${TAG}
            sudo docker inspect "${NAME_WIKI_MYSQL_CONTAINER}" > /dev/null
            printf "    ${NAME_PHPMYADMIN_CONTAINER} : "
            sudo docker run -d --name "${NAME_PHPMYADMIN_CONTAINER}" \
                --link ${NAME_PHPMYADMIN_MYSQL_CONTAINER}:mysql \
                --link ${NAME_WIKI_MYSQL_CONTAINER}:wiki_mysql \
                --link ${NAME_LDAP_CONTAINER}:ldap \
                -e MYSQL_USERNAME=root \
                -e MYSQL_PASSWORD="${PHPMYADMIN_MYSQL_PASSWORD}" \
                -e PMA_SECRET="${PHPMYADMIN_PMA_SECRET}" \
                -e PMA_USERNAME="${PHPMYADMIN_PMA_USERNAME}" \
                -e PMA_PASSWORD="${PHPMYADMIN_PMA_PASSWD}" \
                -e PHPMYADMIN_HOSTNAME="${PHPMYADMIN_HOSTNAME}" \
                -p ${PHPMYADMIN_OPEN}:80 \
                corbinu/docker-phpmyadmin:${TAG}
            ;;

        django)
            check_volumes "${NAME_OPENSSL_DV}" openssl
            check_volumes "${NAME_LDAP_CONTAINER}" ldap
            stop_and_remove "${NAME_DJANGO_CONTAINER}"
            echo 'Starting :'
            printf "    ${NAME_DJANGO_CONTAINER} : "
            sudo docker run -d --name "${NAME_DJANGO_CONTAINER}" \
                --restart=always \
                -P -p ${DJANGO_SECURE}:443 -p ${DJANGO}:80 \
                --volumes-from "${NAME_OPENSSL_DV}" \
                -e DJANGO_HOSTNAME="${DJANGO_HOSTNAME}" \
                -v ${HOST_DJANGO_SRC_DIR}:/var/lib/django \
                -v ${HOST_DJANGO_BACKUP_DIR}:/tmp/import_export \
                --link ${NAME_LDAP_CONTAINER}:ldap \
                ${NAME_DJANGO_IMAGE}:${TAG}
            ;;

        phpldapadmin)
            check_volumes "${NAME_LDAP_CONTAINER}" ldap
            stop_and_remove "${NAME_PHPLDAPADMIN}"
            echo 'Starting :'
            printf "    ${NAME_PHPLDAPADMIN} : "
            sudo docker run -d --name "${NAME_PHPLDAPADMIN}" \
                --restart=always \
                -P -p ${PHPLDAPADMIN_OPEN}:80 -p ${PHPLDAPADMIN}:443 \
                -e HTTPS=false \
                -e LDAP_HOSTS=ldap \
                --link ${NAME_LDAP_CONTAINER}:ldap \
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
