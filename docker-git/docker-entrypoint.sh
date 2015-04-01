#!/bin/bash
set -e

GIT_BASE_DIR=/var/lib/git
SSL_BASE_DIR=/etc/apache2/ssl
GIT_PASSWD_BASE_DIR=/etc/apache2/git_password
GIT_PASSWD_FILENAME=dav_git.passwd

# ************************************************************
# Options passed to the docker container to run scripts
# ************************************************************
# git            : Starts apache running. This is the containers default
# git_backup      : archives the git repositories into the IMPORT_EXPORT_PATH
# ssl_backup      : archives the certificate authority into the IMPORT_EXPORT_PATH
# passwd_backup   : archives the httpasswd file into the IMPORT_EXPORT_PATH
# git_import      : import and create git repositories from arguments and the IMPORT_EXPORT_PATH
# ssl_import      : imports the certificate authority from the IMPORT_EXPORT_PATH
# passwd_import   : imports the httpasswd file from the IMPORT_EXPORT_PATH
# ssl_generate    : generates a self signed certificate authority
# passwd_generate : creates an initial httpasswd file with the novatech user

case ${1} in
    'git')
        # Apache gets grumpy about PID files pre-existing
        rm -f /var/run/apache2/apache2.pid
        # Start apache
        exec apache2 -D FOREGROUND
        ;;

    git_backup)
        # commands export the GIT repositories for backup
        for repo_path in ${GIT_BASE_DIR}/*
        do
            repo_name=$(basename ${repo_path})
            if [[ ! -f ${repo_path}/format ]] ; then
                continue
            fi
            if [[ -f ${IMPORT_EXPORT_PATH}/${repo_name}.gitdump.gz ]] ; then
                rm -f ${IMPORT_EXPORT_PATH}/${repo_name}.gitdump.gz
            fi
#            /usr/bin/gitadmin dump ${repo_path} | gzip -9 > \
#                ${IMPORT_EXPORT_PATH}/${repo_name}.gitdump.gz
        done
        ;;

    ssl_backup)
        # command to export the certificate authority for backup
        cp \
            ${SSL_BASE_DIR}/apache.key \
            ${SSL_BASE_DIR}/apache.pem \
              ${IMPORT_EXPORT_PATH}/
        ;;

    passwd_backup)
        # command to export the httpasswd file for backup
        cp \
            ${GIT_PASSWD_BASE_DIR}/${GIT_PASSWD_FILENAME} \
              ${IMPORT_EXPORT_PATH}/
        ;;

    git_import)
        # ignore first argument and get list of repositories to create
        shift
        GIT_REPOSITORIES=(${*})
        # make certain the GIT directory exists
        [[ ! -d ${GIT_BASE_DIR} ]] && mkdir -p ${GIT_BASE_DIR}
        # reset DAV_GIT configuration
        [[ -e ${GIT_BASE_DIR}/dav_git.conf ]] && rm -f ${GIT_BASE_DIR}/dav_git.conf
        touch ${GIT_BASE_DIR}/dav_git.conf
#        # Create GIT repositories
#        for repo_name in ${GIT_REPOSITORIES[*]} ; do
#            [[ ! -f ${GIT_BASE_DIR}/${repo_name}/format ]] && \
#                gitadmin create --fs-type=fsfs ${GIT_BASE_DIR}/${repo_name}
#        done
#         Import gitdump archived GIT repositories
#        for filename in ${IMPORT_EXPORT_PATH}/*.gitdump.gz
#        do
#            if [[ ! -e ${filename} ]] ; then
#                continue
#            fi
#            repo_name=$(basename ${filename} | sed -e 's/\.gitdump\.gz//')
#            if [[ -d ${GIT_BASE_DIR}/${repo_name} ]] ; then
#                rm -rf ${GIT_BASE_DIR}/${repo_name}
#            fi
#            /usr/bin/gitadmin create ${GIT_BASE_DIR}/${repo_name}
#            /bin/gunzip --stdout ${filename} | \
#                /usr/bin/gitadmin load ${GIT_BASE_DIR}/${repo_name}
#        done
#        # Examine repository and setup it's dav_git config
#        for repo_path in ${GIT_BASE_DIR}/* ; do
#            if [[ -f ${repo_path}/format ]]
#            then
#                # Create DAV_GIT entry for the repository
#                echo "<Location /"$(basename ${repo_path})">
#  DAV git
#  GITPath "${repo_path}"
#  AuthName 'Subversion Repository'
#  AuthType Basic
#  AuthUserFile /etc/apache2/git_password/dav_git.passwd
#  Require valid-user
#  SSLRequireSSL
#</Location>
#" >> ${GIT_BASE_DIR}/dav_git.conf
#                # change permissions on git repositories
#                chown -R www-data:www-data ${repo_path}
#            fi
#        done
        ;;

    ssl_import)
        # commands to import the certificate authority
        cp  ${IMPORT_EXPORT_PATH}/apache.key \
            ${IMPORT_EXPORT_PATH}/apache.pem \
              ${SSL_BASE_DIR}/
        chmod 600 \
            ${SSL_BASE_DIR}/apache.key \
            ${SSL_BASE_DIR}/apache.pem
        chown www-data:www-data \
            ${SSL_BASE_DIR}/apache.key \
            ${SSL_BASE_DIR}/apache.pem
        ;;

    passwd_import)
        # commands to import the httpasswd file
        cp  ${IMPORT_EXPORT_PATH}/${GIT_PASSWD_FILENAME} \
              ${GIT_PASSWD_BASE_DIR}/
        chmod 600 \
            ${GIT_PASSWD_BASE_DIR}/${GIT_PASSWD_FILENAME}
        chown www-data:www-data \
            ${GIT_PASSWD_BASE_DIR}/${GIT_PASSWD_FILENAME}
        ;;

    ssl_generate)
        # commands to generate a self signed certifacate
        SUBJ="/C=US/ST=Kansas/L=Lenexa/O=Novatech/CN=git.novatech-llc.com"
        if [[ ! -z "${2}" ]] ; then
            SUBJ=${2}
        fi
        openssl req -newkey rsa:2048 -x509 -days 365 -nodes \
            -keyout ${SSL_BASE_DIR}/apache.key \
            -out ${SSL_BASE_DIR}/apache.pem \
            -subj "${SUBJ}"
        chmod 600 \
            ${SSL_BASE_DIR}/apache.key \
            ${SSL_BASE_DIR}/apache.pem
        chown www-data:www-data \
            ${SSL_BASE_DIR}/apache.key \
            ${SSL_BASE_DIR}/apache.pem
        ;;

    passwd_generate)
        # commands to generate an initial user in the htpasswd file
        #     Username : novatech
        #     Password : novatech
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
            apache2-utils
        /usr/bin/htpasswd -bcB \
            ${GIT_PASSWD_BASE_DIR}/${GIT_PASSWD_FILENAME} \
            novatech novatech
        chown www-data:www-data \
            ${GIT_PASSWD_BASE_DIR}/${GIT_PASSWD_FILENAME} \
        ;;

    *)
        # run some other command in the docker container
        exec "$@"
        ;;
esac