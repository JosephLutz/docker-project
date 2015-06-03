#!/bin/bash
# Restore gitlab files from /tmp/import_export/*_gitlab_backup.tar

set -e

rm -f /home/git/data/backups/*_gitlab_backup.tar

cp --verbose /tmp/import_export/${BACKUP_TIMESTAMP}_gitlab_backup.tar /home/git/data/backups/

sudo -u git -H bundle exec rake gitlab:backup:restore force=yes BACKUP=${BACKUP_TIMESTAMP} RAILS_ENV=production

rm -f /home/git/data/backups/*_gitlab_backup.tar
