#!/bin/bash
source config.sh
set -e

ALL_SERVICES=( \
    pull_images \
    htpasswd \
    openssl \
    ldap \
    svn \
    git \
    wiki \
    phpmyadmin \
    djangp \
    )

services=( ${@} )
[[ "${#services}" == "0" ]] && \
    services=( 'all' )

for service_name in ${services[*]}
do
    case ${service_name} in
        all)
            ./go.pull.images.sh
            ./go.build.images.sh
            ./go.create.volumes.sh
            ./go.populate.volumes.sh
            ./go.start.sh
            ;;

        pull_images)
            ./go.pull.images.sh
            ;;

        htpasswd)
            ./go.build.images.sh ${NAME_HTPASSWD_IMAGE}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ;;

        openssl)
            ./go.build.images.sh ${NAME_OPENSSL_IMAGE}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ;;

        ldap)
            ./go.build.images.sh ${NAME_LDAP_IMAGE}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        svn)
            ./go.build.images.sh ${NAME_SVN_IMAGE}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        git)
            ./go.build.images.sh ${NAME_GIT_IMAGE}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        wiki)
            ./go.build.images.sh ${NAME_WIKI_IMAGE}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        phpmyadmin)
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        djangp)
            ./go.build.images.sh ${NAME_DJANGO_IMAGE}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
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
