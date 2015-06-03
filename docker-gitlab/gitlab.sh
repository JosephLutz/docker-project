#!/bin/bash
source config.sh
set -e

[[ -f ./gitlab.env.list ]] || {
    echo "file dose not exist: ./gitlab.env.list"
    echo "  Are you running the script from the correct directory?"
    exit 1
}

#sudo mkdir -p ${HOST_GIT_BACKUP_DIR}/backups ${HOST_GIT_BACKUP_DIR}/repositories

case ${1} in
    backup)
        sudo docker inspect "${datavolume_name}" &> /dev/null || \
            docker stop "${NAME_GITLAB_CONTAINER}"
        sudo cp ./$(get_docker_dir ${NAME_GITLAB_DV_IMAGE})/backup_script.sh ${HOST_GIT_BACKUP_DIR}/backups/
        sudo docker run --name=gitlab_UTILITY --rm -t \
            --volumes-from "${NAME_GITLAB_REPO_DV}" \
            --link ${NAME_GITLAB_POSTGRES_CONTAINER}:gitlab-db \
            --link ${NAME_GITLAB_REDIS_CONTAINER}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_POSTGRES_USER}" \
            --env="DB_PASS=${GITLAB_POSTGRES_PASSWORD}" \
            -v ${HOST_GIT_BACKUP_DIR}/backups:/tmp/import_export \
            ${NAME_GITLAB_IMAGE}:${TAG} \
                /tmp/import_export/backup_script.sh
        sudo rm ${HOST_GIT_BACKUP_DIR}/backups/backup_script.sh
        sudo docker start "${NAME_GITLAB_CONTAINER}"
        ;;

    restore)
        timestamp="${2}"
        [[ ! -f "${HOST_GIT_BACKUP_DIR}/backups/${timestamp}_gitlab_backup.tar" ]] && {
            printf "Could not locate backup archive file: \n    ${HOST_GIT_BACKUP_DIR}/backups/${timestamp}_gitlab_backup.tar\n"
            exit 1
        }
        sudo docker inspect "${datavolume_name}" &> /dev/null || \
            docker stop "${NAME_GITLAB_CONTAINER}"
        sudo cp ./$(get_docker_dir ${NAME_GITLAB_DV_IMAGE})/backup_script.sh ${HOST_GIT_BACKUP_DIR}/backups/
        sudo docker run --name=gitlab_UTILITY -it --rm \
            -v ${HOST_GIT_BACKUP_DIR}/backups:/home/git/data/backups \
            --env="BACKUP_TIMESTAMP=${timestamp}"
            --volumes-from "${NAME_GITLAB_REPO_DV}" \
            --link ${NAME_GITLAB_POSTGRES_CONTAINER}:gitlab-db \
            --link ${NAME_GITLAB_REDIS_CONTAINER}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_POSTGRES_USER}" \
            --env="DB_PASS=${GITLAB_POSTGRES_PASSWORD}" \
            ${NAME_GITLAB_IMAGE}:${TAG} \
                /tmp/import_export/restore_script.sh
        sudo rm ${HOST_GIT_BACKUP_DIR}/backups/restore_script.sh
        sudo docker start "${NAME_GITLAB_CONTAINER}"
        ;;

    import)
        #     https://github.com/gitlabhq/gitlabhq/wiki/Import-existing-repositories-into-GitLab
        namespace="root"
        [[ ! -z "${2}" ]] && namespace=${2}
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
