#
# Django Docker container
#
# Version 0.1

FROM debian:8
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

ENV DJANGO_VERSION 1.8

# install the required packages and cleanup the install
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        apache2 \
        libapache2-mod-wsgi \
        virtualenv \
        python2.7 \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# copy over files
COPY \
    config/000-default-ssl.conf \
    config/000-default.conf \
    config/000-django.conf \
        /etc/apache2/sites-available/
COPY ./docker-entrypoint.sh \
    ./configure.sh \
        /

# run the configuration script
RUN ["/bin/bash", "/configure.sh"]

# specify which network ports will be used
EXPOSE 80 443

# set any environment variables
ENV IMPORT_EXPORT_PATH /tmp/import_export

# specify the volumes directly related to this image
VOLUME ["/var/lib/django"]

# start the entrypoint script
WORKDIR /var/lib/django
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["django"]
