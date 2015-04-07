#!/bin/bash
set -e

GIT_BASE_DIR=/var/lib/git
SSL_BASE_DIR=/etc/apache2/ssl
GIT_PASSWD_BASE_DIR=/etc/htpasswd/
GIT_PASSWD_FILENAME=git.passwd

# ************************************************************
# Options passed to the docker container to run scripts
# ************************************************************
# git               : Starts apache running. This is the containers default
# git_backup        : archives the git repositories into the IMPORT_EXPORT_PATH
# git_restore       : restore repository archive names (*.backup.tar.gz | *.mirror.tar.gz) from the remining arguments
# ssl_generate      : generates a self signed certificate authority
# passwd_generate   : creates an initial httpasswd file with the novatech user
# new_repository    : creates a new bare repository named from remaining arguments

case ${1} in
    'git')
        # Apache gets grumpy about PID files pre-existing
        rm -f /var/run/apache2/apache2.pid
        # if apache dose not shut down properly and release all locks
        rm -f /var/lock/apache2/DAVLock
        # Start apache
        exec apache2 -D FOREGROUND
        ;;

    git_backup)
        workdir=$(mktemp -d /tmp/git_backup.XXXXXXXXXX)
        # commands export the GIT repositories for backup
        for repo_path in ${GIT_BASE_DIR}/*
        do
            repo_name=$(basename ${repo_path})
            [[ ! -f ${repo_path}/config ]] && continue
            # make a backup of the working repository
            pushd ${repo_path}
            tar -czf ${IMPORT_EXPORT_PATH}/${repo_name}.backup.tar.gz *
            popd
            # (If there is a commit at the same time this is happening this can leave the repository in a bad state)
            # Therefore: mirror repository to working directory and archive the mirror repository
            git clone --mirror ${repo_path} ${workdir}/${repo_name}
            pushd ${workdir}/${repo_name}
            tar -czf ${IMPORT_EXPORT_PATH}/${repo_name}.mirror.tar.gz *
            popd
        done
        ;;

    git_restore)
        shift
        ARCHIVED_REPOSITORIES=(${*})
        for archive_file in ${ARCHIVED_REPOSITORIES[*]}
        do
            if [[ ! -e ${IMPORT_EXPORT_PATH}/${archive_file} ]] ; then
                echo "SKIPPING (Could not locate): ${IMPORT_EXPORT_PATH}/${archive_file}"
                continue
            fi
            repo_name=$(echo ${archive_file} | sed 's/\.backup\.tar\.gz$//' | sed 's/\.mirror\.tar\.gz$//')
            echo "[RESTORE REPOSITORY] : ${repo_name}"
            [[ ! -e ${GIT_BASE_DIR}/${repo_name} ]] && rm -rf ${GIT_BASE_DIR}/${repo_name}
            mkdir ${GIT_BASE_DIR}/${repo_name}
            tar -xzf ${IMPORT_EXPORT_PATH}/${archive_file} --directory=${GIT_BASE_DIR}/${repo_name}
            pushd ${GIT_BASE_DIR}/${repo_name}
            touch git-daemon-export-ok
            cp hooks/post-update.sample hooks/post-update
            git config http.receivepack true
            git update-server-info
            popd
        done
        # make certain repositories are part of the www-data group and readable by apache
        chgrp -R www-data ${GIT_BASE_DIR}
        chown www-data ${GIT_BASE_DIR}
        ;;

    ssl_generate)
        # commands to generate a self signed certifacate
        SUBJ="/C=US/ST=Kansas/L=Lenexa/O=Novatech/CN=git.novatech-llc.com"
        if [[ ! -z "${2}" ]] ; then
            SUBJ=${2}
        fi
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
            openssl
        openssl req -newkey rsa:2048 -x509 -days 365 -nodes \
            -keyout ${SSL_BASE_DIR}/git.key \
            -out ${SSL_BASE_DIR}/git.pem \
            -subj "${SUBJ}"
        chmod 600 \
            ${SSL_BASE_DIR}/git.key \
            ${SSL_BASE_DIR}/git.pem
        chown www-data:www-data \
            ${SSL_BASE_DIR}/git.key \
            ${SSL_BASE_DIR}/git.pem
        ;;

    passwd_generate)
        # commands to generate an initial user in the htpasswd file
        #     Username : novatech
        #     Password : novatech
        chown root:www-data ${GIT_PASSWD_BASE_DIR}
        chmod 770 ${GIT_PASSWD_BASE_DIR}
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
            apache2-utils
        /usr/bin/htpasswd -bcB \
            ${GIT_PASSWD_BASE_DIR}/${GIT_PASSWD_FILENAME} \
            novatech novatech
        chown www-data:www-data \
            ${GIT_PASSWD_BASE_DIR}/${GIT_PASSWD_FILENAME}
        ;;

    new_repository)
        # ignore first argument and get list of repositories to create
        shift
        NEW_GIT_REPOSITORIES=(${*})
        for repo_name in ${NEW_GIT_REPOSITORIES[*]}
        do
            if [[ -d ${GIT_BASE_DIR}/${repo_name} ]] ; then
                echo "Repository already exists: ${repo_name}"
            fi
            # create new bare repository
            mkdir ${GIT_BASE_DIR}/${repo_name}.git
            pushd ${GIT_BASE_DIR}/${repo_name}.git
            git init --bare --shared=group
            touch git-daemon-export-ok
            cp hooks/post-update.sample hooks/post-update
            git config http.receivepack true
            git update-server-info
            popd
        done
        # make certain repositories are part of the www-data group and readable by apache
        chgrp -R www-data ${GIT_BASE_DIR}
        chown www-data ${GIT_BASE_DIR}
        ;;

    *)
        # run some other command in the docker container
        exec "$@"
        ;;
esac