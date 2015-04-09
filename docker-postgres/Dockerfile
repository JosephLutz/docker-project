#
# GIT Docker container
#
# Version 0.1

FROM postgres:9.4
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

ENV PGDATA /var/lib/pgsql/data

VOLUME ["/docker-entrypoint-initdb.d/", "${PGDATA}"]
