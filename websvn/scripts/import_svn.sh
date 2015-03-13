#!/bin/bash
set -e

SVN_BASE_DIR=/var/lib/svn
SVN_EXPORT_PATH=${1}
shift ; shift

# make certain the SVN directory exists
[[ ! -d ${SVN_BASE_DIR} ]] && mkdir -p ${SVN_BASE_DIR}

# reset DAV_SVN configuration
[[ -e ${SVN_BASE_DIR}/dav_svn.conf ]] && rm -f ${SVN_BASE_DIR}/dav_svn.conf
touch ${SVN_BASE_DIR}/dav_svn.conf

# if the passed in repository dose not already exist create it
for repo_name in ${*}
do
  [[ ! -f ${SVN_BASE_DIR}/${repo_name}/format ]] && \
    svnadmin create --fs-type=fsfs ${SVN_BASE_DIR}/${repo_name}
done

# import other SVN repositories from svndump files that have been gziped
for filename in ${SVN_EXPORT_PATH}/*.svndump.gz
do
  [[ ! -e ${filename} ]] && continue
  repo_name=$(basename ${filename} | sed -e 's/\.svndump\.gz//')
  [[ -d ${SVN_BASE_DIR}/${repo_name} ]] && \
    rm -rf ${SVN_BASE_DIR}/${repo_name}
  /usr/bin/svnadmin create ${SVN_BASE_DIR}/${repo_name}
  /bin/gunzip --stdout ${filename} | \
    /usr/bin/svnadmin load ${SVN_BASE_DIR}/${repo_name}
done

# examine each repository
for repo_path in ${SVN_BASE_DIR}/*
do
  if [[ -f ${repo_path}/format ]]
  then
    # Update DAV_SVN configuration
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
