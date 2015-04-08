#
# GIT Docker container
#
# Version 0.0

FROM debian:8
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

# copy over files
COPY ./docker-entrypoint.sh /

# set any environment variables
ENV IMPORT_EXPORT_PATH /tmp/import_export
ENV USERNAME novatech
ENV PASSWORD novatech
ENV PASSWD_BASE_DIR /etc/htpasswd
ENV HTPASSWD_FILES svn.passwd git.passwd

# create the htpasswd database directory volume
VOLUME ["/etc/htpasswd/"]

ENTRYPOINT ["/docker-entrypoint.sh"]
