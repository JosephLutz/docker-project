#
# WebSVN Docker container
#
# Version 0.1

FROM ubuntu:14.04
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

# install the required packages and cleanup the install
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install --yes \
    apache2 \
    libapache2-mod-fcgid \
    openssl \
    python2.7 \
    python-django && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# copy over scripts
COPY ./scripts/docker-entrypoint.sh \
        ./scripts/configure.sh" \
            /

# Set the configuration
COPY config/000-django.conf config/000-django-ssl.conf /etc/apache2/sites-available/
RUN ["/bin/bash", "/configure.sh"]

# specify which network ports will be used
EXPOSE 80 443
#EXPOSE 443

# start apache running
WORKDIR /var/lib/django
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["websvn"]
