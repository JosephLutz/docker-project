#!/bin/bash
set -e

SVN_BASE_DIR=/var/lib/svn
SVN_EXPORT_PATH=${1}

if [[ -d ${SVN_EXPORT_PATH} ]]
then
  for repo_path in ${SVN_BASE_DIR}/*
  do
    repo_name=$(basename ${repo_path})
    [[ ! -f ${repo_path}/format ]] && continue
    [[ -f ${SVN_EXPORT_PATH}/${repo_name}.svndump.gz ]] && \
      rm -f ${SVN_EXPORT_PATH}/${repo_name}.svndump.gz
    /usr/bin/svnadmin dump ${repo_path} | gzip -9 > \
      ${SVN_EXPORT_PATH}/${repo_name}.svndump.gz
  done
else
  echo "Export path dose not exist: "${SVN_EXPORT_PATH}
  exit 1
fi