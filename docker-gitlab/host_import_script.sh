#!/bin/bash
# import existing git repositories script

set -e

ls -al --color=auto /tmp/import_export/

rm -f /home/git/data/repositories/*.git*tar.gz
cp -v /tmp/import_export/*.git*tar.gz /home/git/data/repositories/
for archive_file in $(ls -1 /home/git/data/repositories/*.git*tar.gz)
do
	echo "archive_file := ${archive_file}"
    repository=$(basename ${archive_file} | sed 's|\.git\..*|.git|')
    echo "repository := ${repository}"
    mkdir /home/git/data/repositories/${NAMESPACE}/${repository}/
    /bin/tar \
        --extract \
        --numeric-owner \
        --owner=${USERMAP_UID} \
        --group=${USERMAP_GID} \
        --directory=/home/git/data/repositories/${NAMESPACE}/${repository}/ \
        -f ${archive_file}
    /bin/rm -f ${archive_file}
done
