#!/bin/bash
source config.sh
set -e

[[ -f ./gitlab.env.list ]] || {
    echo "file dose not exist: ./gitlab.env.list"
    echo "  Are you running the script from the correct directory?"
    exit 1
}

case ${1} in
    backup)
        sudo docker inspect "${datavolume_name}" &> /dev/null || \
            docker stop "${GITLAB_CONTAINER_NAME}"
        sudo cp ./$(get_docker_dir ${GITLAB_DV_IMAGE_NAME})/backup_script.sh ${HOST_GITLAB_BACKUP_DIR}/
        sudo docker run --name=gitlab_UTILITY --rm -t \
            --volumes-from "${GITLAB_DV_NAME}" \
            --link ${GITLAB_DB_CONTAINER_NAME}:gitlab-db \
            --link ${GITLAB_REDIS_CONTAINER_NAME}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_DB_USER}" \
            --env="DB_PASS=${GITLAB_DB_PASSWORD}" \
            -v ${HOST_GITLAB_BACKUP_DIR}/:/tmp/import_export \
            ${GITLAB_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
                /tmp/import_export/backup_script.sh
        sudo rm ${HOST_GITLAB_BACKUP_DIR}/backup_script.sh
        sudo docker start "${GITLAB_CONTAINER_NAME}"
        ;;

    restore)
        timestamp="${2}"
        [[ -z "${timestamp}" ]] && {
            echo "Please use the timestamp argument to specify which backup file to restore."
            echo "Available timestamps:"
            for i in $(ls -1 ${HOST_GITLAB_BACKUP_DIR}/*_gitlab_backup.tar | sed 's|^'${HOST_GITLAB_BACKUP_DIR}/'\(.*\)_gitlab_backup.tar$|\1|' | sort -r)
            do
                echo " - ${i}"
            done
            exit 1
        }
        [[ ! -f "${HOST_GITLAB_BACKUP_DIR}/${timestamp}_gitlab_backup.tar" ]] && {
            printf "Could not locate backup archive file: \n    ${HOST_GITLAB_BACKUP_DIR}/${timestamp}_gitlab_backup.tar\n"
            exit 1
        }
        sudo docker inspect "${datavolume_name}" &> /dev/null || \
            docker stop "${GITLAB_CONTAINER_NAME}"
        sudo cp ./$(get_docker_dir ${GITLAB_DV_IMAGE_NAME})/restore_script.sh ${HOST_GITLAB_BACKUP_DIR}/
        sudo docker run --name=gitlab_UTILITY -it --rm \
            -v ${HOST_GITLAB_BACKUP_DIR}:/tmp/import_export \
            --env="BACKUP_TIMESTAMP=${timestamp}" \
            --volumes-from "${GITLAB_DV_NAME}" \
            --link ${GITLAB_DB_CONTAINER_NAME}:gitlab-db \
            --link ${GITLAB_REDIS_CONTAINER_NAME}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_DB_USER}" \
            --env="DB_PASS=${GITLAB_DB_PASSWORD}" \
            ${GITLAB_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
                /tmp/import_export/restore_script.sh
        sudo rm ${HOST_GITLAB_BACKUP_DIR}/restore_script.sh
        sudo docker start "${GITLAB_CONTAINER_NAME}"
        ;;

    import)
        #     https://github.com/gitlabhq/gitlabhq/wiki/Import-existing-repositories-into-GitLab
        namespace="root"
        [[ ! -z "${2}" ]] && namespace=${2}
        [[ ! -d "${HOST_GITLAB_BACKUP_DIR}/repositories" ]] && {
            echo "Repository archives do not exist."
            exit 1
        }
        sudo docker inspect "${datavolume_name}" &> /dev/null || \
            docker stop "${GITLAB_CONTAINER_NAME}"
        sudo cp ./$(get_docker_dir ${GITLAB_DV_IMAGE_NAME})/import_script.sh ${HOST_GITLAB_BACKUP_DIR}/repositories/
        sudo docker run --name=gitlab_UTILITY -it --rm \
            -v ${HOST_GITLAB_BACKUP_DIR}/repositories:/tmp/import_export \
            --env="NAMESPACE=${namespace}" \
            --volumes-from "${GITLAB_DV_NAME}" \
            --link ${GITLAB_DB_CONTAINER_NAME}:gitlab-db \
            --link ${GITLAB_REDIS_CONTAINER_NAME}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_DB_USER}" \
            --env="DB_PASS=${GITLAB_DB_PASSWORD}" \
            ${GITLAB_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
                /tmp/import_export/import_script.sh
        sudo rm ${HOST_GITLAB_BACKUP_DIR}/repositories/import_script.sh
        sudo docker start "${GITLAB_CONTAINER_NAME}"
        ;;

    *)
        echo "Usage:"
        echo "  gitlab.sh <OPERATION>  [OPTIONS]"
        echo ""
        echo "  OPERATION:"
        echo "    backup        Backup data from the container"
        echo "    restore       Restore data to the container (Interactive)"
        echo "    import        Import git repositories into the container"
        echo ""
        echo "  OPTIONS:"
        echo "    timestamp     The timestamp of the backup file you wish to restore."
        echo "                  Ex: 1433176694  for file  1433176694_gitlab_backup.tar"
        echo "    namespace     The subdirectory the repositories will be placed durring importing."
        echo ""
        exit 0
        ;;
esac
