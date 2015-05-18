#!/bin/bash
source config.sh
set -e

move_latest_to_tag() {
    local image_name
    image_name=${1}
    sudo true
    sudo docker inspect "${image_name}:latest" &> /dev/null
    if sudo docker inspect "docker.io/${image_name}:${TAG}" &> /dev/null
    then
        # This is to get around the Issue with the CentOS changes to the Docker package
        sudo docker rmi "docker.io/${image_name}:${TAG}"
    fi
    if sudo docker inspect "${image_name}:${TAG}" &> /dev/null
    then
        sudo docker rmi "${image_name}:${TAG}"
    fi
    sudo docker tag "${image_name}:latest" "${image_name}:${TAG}"
    sudo docker rmi "${image_name}:latest"
}

build_image() {
    local image_name
    image_name=${1}
    printf '***************************************\n'
    printf 'Building image : %s\n' "${image_name}"
    printf '***************************************\n'
    sudo docker build --rm=true --tag="${image_name}" ./$(get_docker_dir ${image_name})
    move_latest_to_tag "${image_name}"
}

images_to_build=( ${@} )
[[ "${#images_to_build}" == "0" ]] && \
    images_to_build=${ALL_IMAGES[*]}

for image_name in ${images_to_build[*]}
do
    case ${image_name} in
        "${NAME_HTPASSWD_IMAGE}" | \
        "${NAME_OPENSSL_IMAGE}" | \
        "${NAME_LDAP_IMAGE}" | \
        "${NAME_SVN_IMAGE}" | \
        "${NAME_GIT_IMAGE}" | \
        "${NAME_WIKI_IMAGE}" | \
        "${NAME_DJANGO_IMAGE}")   build_image "${image_name}";;
        *)
            printf 'Available images:\n'
            for image_name in ${ALL_IMAGES[*]}
            do
                printf ' -  %s\n' "${image_name}"
            done
            ;;
    esac
done
