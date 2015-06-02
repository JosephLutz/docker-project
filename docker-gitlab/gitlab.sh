#!/bin/bash
source config.sh
set -e

[[ -f ./gitlab.env.list ]] || {
    echo "file dose not exist: ./gitlab.env.list"
    echo "  Are you running the script from the correct directory?"
    exit 1
}

sudo mkdir -p ${HOST_GIT_BACKUP_DIR}/backups ${HOST_GIT_BACKUP_DIR}/repositories

# Stop gitlab container
sudo docker inspect "${datavolume_name}" &> /dev/null || \
    docker stop "${NAME_GITLAB_CONTAINER}"

case ${1} in
    backup)
        sudo docker run --name=gitlab_UTILITY -it --rm \
            --volumes-from "${NAME_GITLAB_REPO_DV}" \
            --link ${NAME_GITLAB_POSTGRES_CONTAINER}:gitlab-db \
            --link ${NAME_GITLAB_REDIS_CONTAINER}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_POSTGRES_USER}" \
            --env="DB_PASS=${GITLAB_POSTGRES_PASSWORD}" \
            -v ${HOST_GIT_BACKUP_DIR}/backups:/home/git/data/backups \
            ${NAME_GITLAB_IMAGE}:${TAG} \
                app:rake gitlab:backup:create
        ;;

    restore)
        BACKUP=""
        [[ ! -z "${2}" ]] && BACKUP="BACKUP=${2}"
        sudo docker run --name=gitlab_UTILITY -it --rm \
            --volumes-from "${NAME_GITLAB_REPO_DV}" \
            --link ${NAME_GITLAB_POSTGRES_CONTAINER}:gitlab-db \
            --link ${NAME_GITLAB_REDIS_CONTAINER}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_POSTGRES_USER}" \
            --env="DB_PASS=${GITLAB_POSTGRES_PASSWORD}" \
            -v ${HOST_GIT_BACKUP_DIR}/backups:/home/git/data/backups \
            ${NAME_GITLAB_IMAGE}:${TAG} \
                app:rake gitlab:backup:restore force=yes ${BACKUP}
        ;;

    import)
        #     https://github.com/gitlabhq/gitlabhq/wiki/Import-existing-repositories-into-GitLab
        NAMESPACE="root"
        [[ ! -z "${2}" ]] && NAMESPACE=${2}
        # copy repositoris into the data container
        sudo docker run --name=gitlab_UTILITY -it --rm \
            --volumes-from "${NAME_GITLAB_REPO_DV}" \
            -v ${HOST_GIT_BACKUP_DIR}/repositories:/home/git/repositories/ \
            --entrypoint="/bin/bash" \
            ${NAME_GITLAB_IMAGE}:${TAG} \
                -c "cp -r /home/git/data/backups/* /home/git/data/repositories/${NAMESPACE}/"
        # import the repositories into gitlab
        sudo docker run --name=gitlab_UTILITY -it --rm \
            --volumes-from "${NAME_GITLAB_REPO_DV}" \
            -v ${HOST_GIT_BACKUP_DIR}/repositories:/home/git/repositories \
            --link ${NAME_GITLAB_POSTGRES_CONTAINER}:gitlab-db \
            --link ${NAME_GITLAB_REDIS_CONTAINER}:gitlab-redis \
            --env-file=./gitlab.env.list \
            --env="DB_USER=${GITLAB_POSTGRES_USER}" \
            --env="DB_PASS=${GITLAB_POSTGRES_PASSWORD}" \
            ${NAME_GITLAB_IMAGE}:${TAG} \
                app:rake gitlab:import:repos RAILS_ENV=production
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

# Start gitlab container
sudo docker start "${NAME_GITLAB_CONTAINER}"
