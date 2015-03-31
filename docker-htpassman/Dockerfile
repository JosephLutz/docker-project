#
# htpassman (htpasswd manager) Docker container
#
# Version 0.1

FROM ubuntu:14.04
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

# install the required packages and cleanup the install
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install --yes \
    apache2 \
    ruby \
    curl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# install htpassman
RUN mkdir -p /usr/src/htpassman \
    && curl -SL http://sourceforge.net/projects/htpassman/files/latest/download?source=files \
    | tar -xzC /usr/src/htpassman \
    && chown www-data:www-data /usr/src/htpassman/*

# Set the configuration
COPY config/000-htpassman.conf config/000-htpassman-ssl.conf /etc/apache2/sites-available/
COPY config/params.rb /usr/src/htpassman/

# copy over scripts
COPY ./scripts/docker-entrypoint.sh \
	/scripts/configure.sh \
		/
RUN ["/bin/bash", "/configure.sh"]

# specify which network ports will be used
EXPOSE 80 443
#EXPOSE 443

# start apache running
WORKDIR /var/www/html
#ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["htpassman"]
