#
# htpasswd Docker container
#
# Version 0.0

FROM debian:8
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
    apache2-utils && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# copy over files
COPY ./docker-entrypoint.sh /

# create the htpasswd database directory volume
VOLUME ["/etc/htpasswd/"]

ENTRYPOINT ["/docker-entrypoint.sh"]
