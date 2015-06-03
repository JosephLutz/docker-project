#!/bin/bash
# import existing git repositories script

set -e

for archive_file in $(ls -1 /tmp/import_export/*.git*tar.gz)
do
    repository=$(basename ${archive_file} | sed 's|\.git\..*|.git|')
    mkdir /home/git/data/repositories/${NAMESPACE}/${repository}/
    /bin/tar \
        --extract \
        --numeric-owner \
        --owner=${USERMAP_UID} \
        --group=${USERMAP_GID} \
        --directory=/home/git/data/repositories/${NAMESPACE}/${repository}/ \
        -f ${archive_file}
done

appSanitize
sudo -u git -H bundle exec rake gitlab:import:repos RAILS_ENV=production
