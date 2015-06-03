#!/bin/bash
# Backup gitlab files and move to /tmp/import_export/

set -e

rm -f /home/git/data/backups/*_gitlab_backup.tar

sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production

cp --verbose /home/git/data/backups/*_gitlab_backup.tar /tmp/import_export/

rm -f /home/git/data/backups/*_gitlab_backup.tar
