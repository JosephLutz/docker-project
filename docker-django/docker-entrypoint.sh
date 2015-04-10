#!/bin/bash
set -e

DJANGO_BASE_DIR=/var/lib/django

# ************************************************************
# Options passed to the docker container to run scripts
# ************************************************************
# django   : Starts apache running. (default)
# backup   : archives into the IMPORT_EXPORT_PATH
# restore  : restore 

case ${1} in
    django)
        # Apache gets grumpy about PID files pre-existing
        rm -f /var/run/apache2/apache2.pid
        # Start apache
        exec apache2 -D FOREGROUND
        ;;

    backup)
        ;;

    restore)
        ;;

    *)
        # run some other command in the docker container
        exec "$@"
        ;;
esac
