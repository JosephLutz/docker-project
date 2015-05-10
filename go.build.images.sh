#!/bin/bash
source config.sh
set -e

move_tag_to_latest() {
    local image_name
    image_name=${1}
    sudo true
    if sudo docker inspect "${image_name}:${TAG}" &> /dev/null
    then
        sudo docker tag "${image_name}:${TAG}" "${image_name}:latest"
        sudo docker rmi "${image_name}:${TAG}"
    fi
}

move_latest_to_tag() {
    local image_name
    image_name=${1}
    sudo true
    sudo docker inspect "${image_name}:latest" &> /dev/null
    sudo docker tag "${image_name}:latest" "${image_name}:${TAG}"
    sudo docker rmi "${image_name}:latest"
}

build_image() {
    local image_name
    image_name=${1}
    printf '***************************************\n'
    printf 'Building image : %s\n' "${image_name}"
    printf '***************************************\n'
    move_tag_to_latest "${image_name}"
    sudo docker build --rm=true --tag="${image_name}" ./$(get_docker_dir ${image_name})
    move_latest_to_tag "${image_name}"
}

images_to_build=( ${@} )
[[ "${#images_to_build}" == "0" ]] && \
    images_to_build=${ALL_IMAGES[*]}

for image_name in ${images_to_build[*]}
do
    case ${image_name} in
        ${NAME_OPENSSL_IMAGE})  build_image "${image_name}";;
        ${NAME_HTPASSWD_IMAGE}) build_image "${image_name}";;
        ${NAME_SVN_IMAGE})      build_image "${image_name}";;
        ${NAME_GIT_IMAGE})      build_image "${image_name}";;
        ${NAME_WIKI_IMAGE})     build_image "${image_name}";;
        ${NAME_LDAP_IMAGE})     build_image "${image_name}";;
        ${NAME_DJANGO_IMAGE})   build_image "${image_name}";;
        *)
            printf 'Available images:\n'
            for image_name in ${ALL_IMAGES[*]}
            do
                printf ' -  %s\n' "${image_name}"
            done
            ;;
    esac
done
