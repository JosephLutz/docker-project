#
# WebSVN Docker container
#
# Version 0.1

FROM debian:8
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

ENV IMPORT_EXPORT_PATH /tmp/import_export

VOLUME ["/var/lib/svn", "/etc/apache2/ssl", "/etc/apache2/websvn_password"]

# install the required packages and cleanup the install
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
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
COPY ./docker-entrypoint.sh \
	./configure.sh \
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
