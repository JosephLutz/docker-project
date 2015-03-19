#!/bin/bash
set -e

SVN_BASE_DIR=/var/lib/svn
SSL_BASE_DIR=/etc/apache2/ssl
WEBSVN_PASSWD_BASE_DIR=/etc/apache2/websvn_password
WEBSVN_PASSWD_FILENAME=dav_svn.passwd

# ************************************************************
# Options passed to the docker container to run scripts
# ************************************************************
# websvn          : Starts apache running. This is the containers default
# svn_backup      : archives the svn repositories into the IMPORT_EXPORT_PATH
# ssl_backup      : archives the certificate authority into the IMPORT_EXPORT_PATH
# passwd_backup   : archives the httpasswd file into the IMPORT_EXPORT_PATH
# svn_import      : import and create svn repositories from arguments and the IMPORT_EXPORT_PATH
# ssl_import      : imports the certificate authority from the IMPORT_EXPORT_PATH
# passwd_import   : imports the httpasswd file from the IMPORT_EXPORT_PATH
# ssl_generate    : generates a self signed certificate authority
# passwd_generate : creates an initial httpasswd file with the novatech user

case ${1} in
    'websvn')
        # Apache gets grumpy about PID files pre-existing
        rm -f /var/run/apache2/apache2.pid
        # Start apache
        exec apache2 -D FOREGROUND
        ;;

    svn_backup)
        # commands export the SVN repositories for backup
        for repo_path in ${SVN_BASE_DIR}/*
        do
            repo_name=$(basename ${repo_path})
            if [[ ! -f ${repo_path}/format ]] ; then
                continue
            fi
            if [[ -f ${IMPORT_EXPORT_PATH}/${repo_name}.svndump.gz ]] ; then
                rm -f ${IMPORT_EXPORT_PATH}/${repo_name}.svndump.gz
            fi
            /usr/bin/svnadmin dump ${repo_path} | gzip -9 > \
                ${IMPORT_EXPORT_PATH}/${repo_name}.svndump.gz
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
            ${WEBSVN_PASSWD_BASE_DIR}/${WEBSVN_PASSWD_FILENAME} \
              ${IMPORT_EXPORT_PATH}/
        ;;

    svn_import)
        # ignore first argument and get list of repositories to create
        shift
        SVN_REPOSITORIES=(${*})
        # make certain the SVN directory exists
        [[ ! -d ${SVN_BASE_DIR} ]] && mkdir -p ${SVN_BASE_DIR}
        # reset DAV_SVN configuration
        [[ -e ${SVN_BASE_DIR}/dav_svn.conf ]] && rm -f ${SVN_BASE_DIR}/dav_svn.conf
        touch ${SVN_BASE_DIR}/dav_svn.conf
        # Create SVN repositories
        for repo_name in ${SVN_REPOSITORIES[*]} ; do
            [[ ! -f ${SVN_BASE_DIR}/${repo_name}/format ]] && \
                svnadmin create --fs-type=fsfs ${SVN_BASE_DIR}/${repo_name}
        done
        # Import svndump archived SVN repositories
        for filename in ${IMPORT_EXPORT_PATH}/*.svndump.gz
        do
            if [[ ! -e ${filename} ]] ; then
                continue
            fi
            repo_name=$(basename ${filename} | sed -e 's/\.svndump\.gz//')
            if [[ -d ${SVN_BASE_DIR}/${repo_name} ]] ; then
                rm -rf ${SVN_BASE_DIR}/${repo_name}
            fi
            /usr/bin/svnadmin create ${SVN_BASE_DIR}/${repo_name}
            /bin/gunzip --stdout ${filename} | \
                /usr/bin/svnadmin load ${SVN_BASE_DIR}/${repo_name}
        done
        # Examine repository and setup it's dav_svn config
        for repo_path in ${SVN_BASE_DIR}/* ; do
            if [[ -f ${repo_path}/format ]]
            then
                # Create DAV_SVN entry for the repository
                echo "<Location /"$(basename ${repo_path})">
  DAV svn
  SVNPath "${repo_path}"
  AuthName 'Subversion Repository'
  AuthType Basic
  AuthUserFile /etc/apache2/websvn_password/dav_svn.passwd
  Require valid-user
  SSLRequireSSL
</Location>
" >> ${SVN_BASE_DIR}/dav_svn.conf
                # change permissions on svn repositories
                chown -R www-data:www-data ${repo_path}
            fi
        done
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
        cp  ${IMPORT_EXPORT_PATH}/${WEBSVN_PASSWD_FILENAME} \
              ${WEBSVN_PASSWD_BASE_DIR}/
        chmod 600 \
            ${WEBSVN_PASSWD_BASE_DIR}/${WEBSVN_PASSWD_FILENAME}
        chown www-data:www-data \
            ${WEBSVN_PASSWD_BASE_DIR}/${WEBSVN_PASSWD_FILENAME}
        ;;

    ssl_generate)
        # commands to generate a self signed certifacate
        SUBJ="/C=US/ST=Kansas/L=Lenexa/O=Novatech/CN=websvn.novatech-llc.com"
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
            ${WEBSVN_PASSWD_BASE_DIR}/${WEBSVN_PASSWD_FILENAME} \
            novatech novatech
        chown www-data:www-data \
            ${WEBSVN_PASSWD_BASE_DIR}/${WEBSVN_PASSWD_FILENAME} \
        ;;

    *)
        # run some other command in the docker container
        exec "$@"
        ;;
esac