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
            docker stop "${NAME_GITLAB_CONTAINER}"
        sudo cp ./$(get_docker_dir ${NAME_GITLAB_DV_IMAGE})/backup_script.sh ${HOST_GIT_BACKUP_DIR}/
        sudo docker run --name=gitlab_UTILITY --rm -t \
            --volumes-from "${NAME_GITLAB_REPO_DV}" \
            --link ${NAME_GITLAB_POSTGRES_CONTAINER}:gitlab-db \
            --link ${NAME_GITLAB_REDIS_CONTAINER}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_POSTGRES_USER}" \
            --env="DB_PASS=${GITLAB_POSTGRES_PASSWORD}" \
            -v ${HOST_GIT_BACKUP_DIR}/:/tmp/import_export \
            ${NAME_GITLAB_IMAGE}:${TAG} \
                /tmp/import_export/backup_script.sh
        sudo rm ${HOST_GIT_BACKUP_DIR}/backup_script.sh
        sudo docker start "${NAME_GITLAB_CONTAINER}"
        ;;

    restore)
        timestamp="${2}"
        [[ -z "${timestamp}" ]] && {
            echo "Please use the timestamp argument to specify which backup file to restore."
            echo "Available timestamps:"
            for i in $(ls -1 ${HOST_GIT_BACKUP_DIR}/*_gitlab_backup.tar | sed 's|^'${HOST_GIT_BACKUP_DIR}/'\(.*\)_gitlab_backup.tar$|\1|' | sort -r)
            do
                echo " - ${i}"
            done
            exit 1
        }
        [[ ! -f "${HOST_GIT_BACKUP_DIR}/${timestamp}_gitlab_backup.tar" ]] && {
            printf "Could not locate backup archive file: \n    ${HOST_GIT_BACKUP_DIR}/${timestamp}_gitlab_backup.tar\n"
            exit 1
        }
        sudo docker inspect "${datavolume_name}" &> /dev/null || \
            docker stop "${NAME_GITLAB_CONTAINER}"
        sudo cp ./$(get_docker_dir ${NAME_GITLAB_DV_IMAGE})/backup_script.sh ${HOST_GIT_BACKUP_DIR}/
        sudo docker run --name=gitlab_UTILITY -it --rm \
            -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export \
            --env="BACKUP_TIMESTAMP=${timestamp}" \
            --volumes-from "${NAME_GITLAB_REPO_DV}" \
            --link ${NAME_GITLAB_POSTGRES_CONTAINER}:gitlab-db \
            --link ${NAME_GITLAB_REDIS_CONTAINER}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_POSTGRES_USER}" \
            --env="DB_PASS=${GITLAB_POSTGRES_PASSWORD}" \
            ${NAME_GITLAB_IMAGE}:${TAG} \
                /tmp/import_export/restore_script.sh
        sudo rm ${HOST_GIT_BACKUP_DIR}/restore_script.sh
        sudo docker start "${NAME_GITLAB_CONTAINER}"
        ;;

    import)
        #     https://github.com/gitlabhq/gitlabhq/wiki/Import-existing-repositories-into-GitLab
        namespace="root"
        [[ ! -z "${2}" ]] && namespace=${2}
        [[ ! -d "${HOST_GIT_BACKUP_DIR}/repositories" ]] && {
            echo "Repository archives do not exist."
            exit 1
        }
        sudo docker inspect "${datavolume_name}" &> /dev/null || \
            docker stop "${NAME_GITLAB_CONTAINER}"
        sudo cp ./$(get_docker_dir ${NAME_GITLAB_DV_IMAGE})/import_script.sh ${HOST_GIT_BACKUP_DIR}/repositories/
        sudo docker run --name=gitlab_UTILITY -it --rm \
            -v ${HOST_GIT_BACKUP_DIR}/repositories:/tmp/import_export \
            --env="NAMESPACE=${namespace}" \
            --volumes-from "${NAME_GITLAB_REPO_DV}" \
            --link ${NAME_GITLAB_POSTGRES_CONTAINER}:gitlab-db \
            --link ${NAME_GITLAB_REDIS_CONTAINER}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_POSTGRES_USER}" \
            --env="DB_PASS=${GITLAB_POSTGRES_PASSWORD}" \
            ${NAME_GITLAB_IMAGE}:${TAG} \
                /tmp/import_export/import_script.sh
        sudo rm ${HOST_GIT_BACKUP_DIR}/repositories/import_script.sh
        sudo docker start "${NAME_GITLAB_CONTAINER}"
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
