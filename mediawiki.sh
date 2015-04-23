#!/bin/bash

source config.sh
set -e

STATIC_BACKUP_FILE="WIKI/mediawiki.tar.bz2"
DATABASE_BACKUP_FILE="WIKI/wikidb.sql.bz2"

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


sudo docker inspect ${NAME_WIKI_CONTAINER} > /dev/null
sudo docker inspect ${NAME_WIKI_MYSQL_CONTAINER} > /dev/null

printf 'Waiting for MySQL database to finish starting up.\n'
while ! \
    echo "SHOW GLOBAL STATUS;" | \
    docker exec -i "${NAME_WIKI_MYSQL_CONTAINER}" \
      mysql \
        --host=localhost \
        --user="${MEDIAWIKI_USER}" \
        --password="${MEDIAWIKI_PASSWORD}" \
        wikidb &> /dev/null
do
  sleep 1
done
sudo true

# ************************************************************
# set mediawiki to readonly database
sudo docker exec -i ${NAME_WIKI_CONTAINER} ls /var/www-shared/html/LocalSettings.php &> /dev/null && {
    echo "Lock mediawiki making the database read only"
    sudo docker exec -i \
      ${NAME_WIKI_CONTAINER} /bin/sed \
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
            sudo docker exec -i \
              ${NAME_WIKI_CONTAINER} /bin/tar \
                --create \
                --preserve-permissions \
                --same-owner \
                --directory=/ \
                --to-stdout \
                /var/www-shared/html \
            | bzip2 -zc > ${BACKUP_DIR}/${STATIC_BACKUP_FILE}
        fi

        # ************************************************************
        # Backup the database for the mediawiki
        if [[ "${database}" == "TRUE" ]]
        then
            echo "Backing up the mediawiki database"
            sudo docker exec -i \
              "${NAME_WIKI_MYSQL_CONTAINER}" \
              mysqldump \
                --host=localhost \
                --user="${MEDIAWIKI_USER}" \
                --password="${MEDIAWIKI_PASSWORD}" \
                --add-drop-table \
                --flush-privileges \
                --hex-blob \
                --tz-utc \
                wikidb \
            | bzip2 -zc > ${BACKUP_DIR}/${DATABASE_BACKUP_FILE}
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
            bzcat -dc ${BACKUP_DIR}/${STATIC_BACKUP_FILE} | \
            sudo docker exec -i \
              ${NAME_WIKI_CONTAINER} \
              /bin/tar \
                --extract \
                --preserve-permissions \
                --preserve-order \
                --same-owner \
                --directory=/ \
                -f -
        fi

        # ************************************************************
        # Restore the database for the mediawiki
        if [[ "${database}" == "TRUE" ]]
        then
            echo "Restoring the mediawiki database backup"
            sudo true
            bzcat -dc ${BACKUP_DIR}/${DATABASE_BACKUP_FILE} | \
            sudo docker exec -i \
              "${NAME_WIKI_MYSQL_CONTAINER}" \
              mysql \
                --host=localhost \
                --user="${MEDIAWIKI_USER}" \
                --password="${MEDIAWIKI_PASSWORD}" \
                wikidb
        fi

        # ************************************************************
        # convert database to latest version for mediawiki
        if [[ "${convert}" == "TRUE" ]]
        then
            echo "Converting the mediawiki database to latest"
            sudo docker exec -i \
              ${NAME_WIKI_CONTAINER} \
              /usr/local/bin/php \
                /var/www/html/maintenance/update.php \
                --quick
        fi
        ;;
esac

# ************************************************************
# set mediawiki to read/write database
echo "UnLock mediawiki making the database read/write"
sudo docker exec -i \
  ${NAME_WIKI_CONTAINER} /bin/sed \
    -i \
    's|^$wgReadOnly = .*;$|#wgReadOnly|' \
    /var/www-shared/html/LocalSettings.php
