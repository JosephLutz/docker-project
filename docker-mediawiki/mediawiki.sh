#!/bin/bash

source config.sh
set -e

STATIC_BACKUP_FILE="WIKI/mediawiki.tar"
DATABASE_BACKUP_FILE="WIKI/wikidb.sql"

# ************************************************************
# check state before performing
case ${1} in
    backup)
        if [[ -f ${BACKUP_DIR}/${STATIC_BACKUP_FILE} ]] ; then
            echo "Removing existing backup file: ${BACKUP_DIR}/${STATIC_BACKUP_FILE}"
            rm -f ${BACKUP_DIR}/${STATIC_BACKUP_FILE}
        fi
        if [[ -f ${BACKUP_DIR}/${DATABASE_BACKUP_FILE} ]] ; then
            echo "Removing existing backup file: ${BACKUP_DIR}/${DATABASE_BACKUP_FILE}"
            rm -f ${BACKUP_DIR}/${DATABASE_BACKUP_FILE}
        fi
        ;;

    restore)
        error="FALSE"
        if [[ ! -f ${BACKUP_DIR}/${STATIC_BACKUP_FILE} ]] ; then
            echo "[ERROR] File not found: ${BACKUP_DIR}/${STATIC_BACKUP_FILE}"
            error="TRUE"
        fi
        if [[ ! -f ${BACKUP_DIR}/${DATABASE_BACKUP_FILE} ]] ; then
            echo "[ERROR] File not found: ${BACKUP_DIR}/${DATABASE_BACKUP_FILE}"
            error="TRUE"
        fi
        if [[ "${error}" == "TRUE" ]] ; then
            echo "ERROR: The mediawiki files to restore was not found!"
            exit 1
        fi
        ;;

    *)
        echo "Usage:"
        echo "  mediawiki.sh <OPERATION> [DETAILS]"
        echo ""
        echo "  OPERATION:"
        echo "    backup    Backup stat from the container"
        echo "    restore   Restore state to the container"
        echo ""
        echo "  DETAILS:"
        echo "    FILES     Only perform the operation on the mediawiki files"
        echo "    DATABASE  Only performe the operation on the mediawiki database"
        echo "    CONVERT   Only perform the operation on the mediawiki database (durring backup)"
        echo ""
        echo "    If not DETAILS are provided then all operations are performed in order."
        echo ""
        exit 0
        ;;
esac

sudo docker inspect ${WIKI_CONTAINER_NAME} > /dev/null
sudo docker inspect ${WIKI_DB_CONTAINER_NAME} > /dev/null
sudo docker inspect ${WIKI_DV_NAME} > /dev/null
sudo docker inspect ${WIKI_DB_DV_NAME} > /dev/null

printf 'Waiting for MySQL database to finish starting up.  '
while ! \
    echo "SHOW GLOBAL STATUS;" | \
    sudo docker exec -i \
      "${WIKI_DB_CONTAINER_NAME}" \
      mysql \
        --host=localhost \
        --user="${WIKI_DB_USER}" \
        --password="${WIKI_DB_PASSWORD}" \
        wikidb &> /dev/null
do
  sleep 1
  printf '.'
done
printf '\n'
sudo true

echo 'MySQL database is running'

# ************************************************************
# set mediawiki to readonly database
sudo docker exec ${WIKI_CONTAINER_NAME} ls /var/www-shared/html/LocalSettings.php &> /dev/null && {
    echo "Lock mediawiki making the database read only"
    sudo docker exec \
      ${WIKI_CONTAINER_NAME} /bin/sed \
        -i \
        's|^#wgReadOnly$|$wgReadOnly = '"'Restoring Database from backup, Access will be restored shortly.'"';|' \
        /var/www-shared/html/LocalSettings.php
}

case ${1} in
    backup)
        static_files="FALSE"
        database="FALSE"
        convert="FALSE"
        case ${2} in
            FILES)
                static_files="TRUE"
                ;;

            DATABASE)
                database="TRUE"
                ;;

            CONVERT)
                ;;

            *)
                static_files="TRUE"
                database="TRUE"
                convert="TRUE"
                ;;
        esac

        # ************************************************************
        # Backup the static files for mediawiki
        if [[ "${static_files}" == "TRUE" ]]
        then
            echo "Backing up mediawiki static files"
            sudo true
            sudo docker exec \
              ${WIKI_CONTAINER_NAME} /bin/tar \
                --create \
                --preserve-permissions \
                --same-owner \
                --directory=/ \
                --to-stdout \
                /var/www-shared/html \
            > ${BACKUP_DIR}/${STATIC_BACKUP_FILE}
                #--sort=name \
        fi

        # ************************************************************
        # Backup the database for the mediawiki
        if [[ "${database}" == "TRUE" ]]
        then
            echo "Backing up the mediawiki database"
            sudo docker exec \
              "${WIKI_DB_CONTAINER_NAME}" \
              mysqldump \
                --host=localhost \
                --user="${WIKI_DB_USER}" \
                --password="${WIKI_DB_PASSWORD}" \
                --add-drop-table \
                --flush-privileges \
                --hex-blob \
                --tz-utc \
                wikidb \
            > ${BACKUP_DIR}/${DATABASE_BACKUP_FILE}
        fi
        ;;

    restore)
        static_files="FALSE"
        database="FALSE"
        convert="FALSE"
        case ${2} in
            FILES)
                static_files="TRUE"
                ;;

            DATABASE)
                database="TRUE"
                ;;

            CONVERT)
                convert="TRUE"
                ;;

            *)
                static_files="TRUE"
                database="TRUE"
                convert="TRUE"
                ;;
        esac

        # ************************************************************
        # restore the static files for mediawiki
        if [[ "${static_files}" == "TRUE" ]]
        then
            echo "Restoring the mediawiki static files backup"
            sudo true
            cat ${BACKUP_DIR}/${STATIC_BACKUP_FILE} | \
            sudo docker exec -i \
              ${WIKI_CONTAINER_NAME} \
              /bin/tar \
                --extract \
                --preserve-permissions \
                --preserve-order \
                --same-owner \
                --directory=/ \
                -f -
            echo "Set hostname/wgServer for mediawiki"
            sudo docker exec \
              ${WIKI_CONTAINER_NAME} \
              /bin/sed -ie \
                's|$wgServer = "http://.*|$wgServer = "http://'${WIKI_HOSTNAME}'";|' \
                /var/www-shared/html/LocalSettings.php
        fi

        # ************************************************************
        # Restore the database for the mediawiki
        if [[ "${database}" == "TRUE" ]]
        then
            echo "Restoring the mediawiki database backup"
            sudo true
            cat ${BACKUP_DIR}/${DATABASE_BACKUP_FILE} | \
            sudo docker exec -i \
              "${WIKI_DB_CONTAINER_NAME}" \
              mysql \
                --host=localhost \
                --user="${WIKI_DB_USER}" \
                --password="${WIKI_DB_PASSWORD}" \
                wikidb
        fi

        # ************************************************************
        # convert database to latest version for mediawiki
        if [[ "${convert}" == "TRUE" ]]
        then
            printf 'Waiting for mediwiki to finish starting up.  '
            while ! \
                sudo docker exec \
                  "${WIKI_CONTAINER_NAME}" \
                  ls /var/www/html/maintenance/update.php &> /dev/null
            do
              sleep 1
              printf '.'
            done
            printf '\n'
            echo "Converting the mediawiki database to latest"
            sudo docker exec \
              "${WIKI_CONTAINER_NAME}" \
              /usr/local/bin/php \
                /var/www/html/maintenance/update.php \
                --quick
        fi
        ;;
esac

# ************************************************************
# set mediawiki to read/write database
echo "UnLock mediawiki making the database read/write"
sudo docker exec \
  ${WIKI_CONTAINER_NAME} /bin/sed \
    -i \
    's|^$wgReadOnly = .*;$|#wgReadOnly|' \
    /var/www-shared/html/LocalSettings.php
