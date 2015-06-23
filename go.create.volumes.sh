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

create_data_volume() {
    local datavolume_name
    local image_name
    datavolume_name=${1}
    image_name=${2}
    printf "Datavolume [%s] from image [%s]\n" "${datavolume_name}" "${image_name}:${DOCKER_IMAGE_TAG}"
    sudo docker inspect ${datavolume_name} &> /dev/null || \
        sudo docker run -ti --name "${datavolume_name}" \
            --entrypoint="/bin/true" \
            ${image_name}:${DOCKER_IMAGE_TAG}
}

services=( ${@} )
[[ "${#services}" == "0" ]] && \
    services=${ALL_SERVICES[*]}

for service_name in ${services[*]}
do
    case ${service_name} in
        htpasswd)   create_data_volume "${HTPASSWD_DV_NAME}" "${HTPASSWD_IMAGE_NAME}";;
        openssl)    create_data_volume "${OPENSSL_DV_NAME}" "${OPENSSL_IMAGE_NAME}";;
        ldap)       create_data_volume "${OPENLDAP_DV_NAME}" "${OPENLDAP_IMAGE_NAME}";;
        svn)        create_data_volume "${SVN_DV_NAME}" "${SVN_IMAGE_NAME}";;
        git)        create_data_volume "${GIT_DV_NAME}" "${GIT_IMAGE_NAME}";;
        gitlab)     create_data_volume "${GITLAB_DV_NAME}" "${GITLAB_DV_IMAGE_NAME}"
                    create_data_volume "${GITLAB_DB_DV_NAME}" "postgres"
                    ;;
        wiki)       create_data_volume "${WIKI_DB_DV_NAME}" "mysql"
                    create_data_volume "${WIKI_DV_NAME}" "${WIKI_IMAGE_NAME}"
                    ;;
        phpmyadmin) create_data_volume "${PHPMYADMIN_DB_DV_NAME}" "mysql";;
        django)     ;;
        *)
            printf 'Available services:\n'
            for service_name in ${ALL_SERVICES[*]}
            do
                printf ' -  %s\n' "${service_name}"
            done
            ;;
    esac
done
