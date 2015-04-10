#!/bin/bash
set -e

# When not limiting the open file descritors limit, the memory consumption of
# slapd is absurdly high. See https://github.com/docker/docker/issues/8231
ulimit -n 8192

case ${1} in
    openldap)
        exec slapd -d 32768 -u openldap -g openldap
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