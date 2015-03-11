#!/bin/bash
mkdir -p ${SVN_BASE_DIR} && \
for filename in ${SVN_EXPORT_PATH}/*.svndump.gz
do
  repo_name=$(basename ${filename} | sed -e 's/\.svndump\.gz//')
  if [[ ! -d ${SVN_BASE_DIR}/${repo_name} ]]
  then
    svnadmin create ${SVN_BASE_DIR}/${repo_name} && \
    /usr/bin/svnadmin load ${SVN_BASE_DIR}/${repo_name} \
      < gunzip ${filename}
  else
    /usr/bin/svnadmin load ${SVN_BASE_DIR}/${repo_name} \
      < gunzip ${filename}
  fi
done
