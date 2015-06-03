#!/bin/bash
# Restore gitlab files from /tmp/import_export/*_gitlab_backup.tar

set -e

rm -f /home/git/data/backups/*_gitlab_backup.tar

sudo -u git -H bundle exec rake gitlab:backup:restore force=yes BACKUP=${BACKUP_TIMESTAMP} RAILS_ENV=production

cp --verbose /home/git/data/backups/*_gitlab_backup.tar /tmp/import_export/

rm -f /home/git/data/backups/*_gitlab_backup.tar
