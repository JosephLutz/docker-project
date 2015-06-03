#!/bin/bash
# import existing git repositories script

set -e

# this function comes from /app/init
appSanitize () {
  echo "Checking repository directories permissions..."
  chmod -R ug+rwX,o-rwx ${GITLAB_DATA_DIR}/repositories/
  chmod -R ug-s ${GITLAB_DATA_DIR}/repositories/
  find ${GITLAB_DATA_DIR}/repositories/ -type d -print0 | xargs -0 chmod g+s
  chown -R git:git ${GITLAB_DATA_DIR}/repositories

  echo "Checking satellites directories permissions..."
  sudo -u git -H mkdir -p ${GITLAB_DATA_DIR}/gitlab-satellites/
  chmod u+rwx,g=rx,o-rwx ${GITLAB_DATA_DIR}/gitlab-satellites
  chown -R git:git ${GITLAB_DATA_DIR}/gitlab-satellites

  echo "Checking uploads directory permissions..."
  chmod -R u+rwX ${GITLAB_DATA_DIR}/uploads/
  chown git:git -R ${GITLAB_DATA_DIR}/uploads/

  echo "Checking tmp directory permissions..."
  chmod -R u+rwX ${GITLAB_DATA_DIR}/tmp/
  chown git:git -R ${GITLAB_DATA_DIR}/tmp/
}

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
