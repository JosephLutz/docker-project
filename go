#!/bin/bash
source config.sh
set -e

ALL_SERVICES=( \
    pull_images \
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
    services=( 'all' )

for service_name in ${services[*]}
do
    case ${service_name} in
        all)
#            ./go.pull.images.sh
            ./go.build.images.sh
            ./go.create.volumes.sh
            ./go.populate.volumes.sh
            ./go.start.sh
            ;;

        pull_images)
            ./go.pull.images.sh
            ;;

        htpasswd)
            ./go.build.images.sh ${HTPASSWD_IMAGE_NAME}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ;;

        openssl)
            ./go.build.images.sh ${OPENSSL_IMAGE_NAME}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ;;

        ldap)
            ./go.build.images.sh ${OPENLDAP_IMAGE_NAME}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        svn)
            ./go.build.images.sh ${SVN_IMAGE_NAME}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        git)
            ./go.build.images.sh ${GIT_IMAGE_NAME}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        gitlab)
            ./go.build.images.sh ${GITLAB_DV_IMAGE_NAME}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        wiki)
            ./go.build.images.sh ${WIKI_IMAGE_NAME}
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        phpmyadmin)
            ./go.create.volumes.sh "${service_name}"
            ./go.populate.volumes.sh "${service_name}"
            ./go.start.sh  "${service_name}"
            ;;

        django)
            ./go.build.images.sh ${DJANGO_IMAGE_NAME}
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
