#!/bin/bash
source config.sh
set -e

sudo docker inspect "${datavolume_name}" &> /dev/null || \
    docker stop "${NAME_GITLAB_CONTAINER}"

docker run --name=gitlabBACKUP -it --rm \
    --volumes-from "${NAME_GITLAB_REPO_DV}" \
    --link ${NAME_GITLAB_POSTGRES_CONTAINER}:gitlab-db \
    --link ${NAME_GITLAB_REDIS_CONTAINER}:gitlab-redis \
    --env-file=./gitlab.env.list \
    --env="DB_USER=${GITLAB_POSTGRES_USER}" \
    --env="DB_PASS=${GITLAB_POSTGRES_PASSWORD}" \
    ${NAME_GITLAB_IMAGE}:${TAG} \
        app:rake gitlab:backup:create

docker run --name=gitlabBACKUP -it --rm \
    --volumes-from "${NAME_GITLAB_REPO_DV}" \
    --entrypoint="/bin/bash" \
    -v ${HOST_GIT_BACKUP_DIR}:/tmp/import_export \
    ${NAME_GITLAB_IMAGE}:${TAG} \
        -c "cp /home/git/data/backups/* /tmp/import_export/ ; rm -rf /home/git/data/backups/*"

docker start "${NAME_GITLAB_CONTAINER}"

#docker stop gitlab ; \
#docker run --name=gitlabBACKUP -it --rm \
#    --volumes-from "DV_gitlab_repo" \
#    --link gitlab_postgres:gitlab-db \
#    --link gitlab_redis:gitlab-redis \
#    --env-file=./gitlab.env.list \
#    --env="DB_USER=novatech" \
#    --env="DB_PASS=novatech" \
#    sameersbn/gitlab:current \
#        app:rake gitlab:backup:create && \
#docker run --name=gitlabBACKUP -it --rm \
#    --volumes-from "DV_gitlab_repo" \
#    --entrypoint="/bin/bash" \
#    -v /home/josephl/WORKSPACE/Docker/docker-project/t:/tmp/import_export \
#    sameersbn/gitlab:current \
#        -c "cp /home/git/data/backups/* /tmp/import_export/ ; rm -rf /home/git/data/backups/*" && \
#docker start gitlab
