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

create_data_volume() {
    local datavolume_name
    local image_name
    datavolume_name=${1}
    image_name=${2}
    printf "Datavolume [%s] from image [%s]\n" "${datavolume_name}" "${image_name}:${TAG}"
    sudo docker inspect ${datavolume_name} &> /dev/null || \
        sudo docker run -ti --name "${datavolume_name}" \
            --entrypoint="/bin/true" \
            ${image_name}:${TAG}
}

services=( ${@} )
[[ "${#services}" == "0" ]] && \
    services=${ALL_SERVICES[*]}

for service_name in ${services[*]}
do
    case ${service_name} in
        htpasswd)   create_data_volume "${NAME_HTPASSWD_DV}" "${NAME_HTPASSWD_IMAGE}";;
        openssl)    create_data_volume "${NAME_OPENSSL_DV}" "${NAME_OPENSSL_IMAGE}";;
        ldap)       create_data_volume "${NAME_LDAP_DV}" "${NAME_LDAP_IMAGE}";;
        svn)        create_data_volume "${NAME_SVN_REPO_DV}" "${NAME_SVN_IMAGE}";;
        git)        create_data_volume "${NAME_GIT_REPO_DV}" "${NAME_GIT_IMAGE}";;
        wiki)       create_data_volume "${NAME_WIKI_MYSQL_DV}" "mysql"
                    create_data_volume "${NAME_WIKI_DV}" "${NAME_WIKI_IMAGE}"
                    ;;
        phpmyadmin) create_data_volume "${NAME_PHPMYADMIN_MYSQL_DV}" "mysql";;
        djangp)     ;;
        *)
            printf 'Available services:\n'
            for service_name in ${ALL_SERVICES[*]}
            do
                printf ' -  %s\n' "${service_name}"
            done
            ;;
    esac
done
