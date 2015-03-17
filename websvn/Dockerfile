#
# WebSVN Docker container
#
# Version 0.1

FROM ubuntu:14.04
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

ENV SVN_EXPORT_PATH "/tmp/import_export"

# install the required packages and cleanup the install
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install --yes \
    apache2 \
    enscript \
    libapache2-svn \
    openssl \
    php5-common \
    subversion \
    websvn && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# copy over scripts
COPY ./scripts/docker-entrypoint.sh \
	./scripts/configure.sh \
	./scripts/import_svn.sh \
	./scripts/export_svn.sh \
		/

# Set the configuration
COPY config/000-websvn.conf config/000-websvn-ssl.conf /etc/apache2/sites-available/
COPY config/config.php /etc/websvn/
RUN ["/bin/bash", "/configure.sh"]

# specify which network ports will be used
#EXPOSE 80 443
EXPOSE 443

# start apache running
WORKDIR /var/www/html
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["websvn"]
