#
# SVN Docker container
#
# Version 0.0

FROM debian:8
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

# copy over files
COPY ./docker-entrypoint.sh /

# set any environment variables
ENV SSL_BASE_DIR /etc/apache2/ssl
ENV SSL_BASE_FILES svn git django wiki openldap
ENV IMPORT_EXPORT_PATH /tmp/import_export
ENV SUBJ /C=US/ST=Kansas/L=Lenexa/O=Novatech/CN=svn.novatech-llc.com
ENV BYTES 2048
ENV DAYS 365

# create the openssl directory volumes
VOLUME ["/etc/apache2/ssl"]

ENTRYPOINT ["/docker-entrypoint.sh"]
