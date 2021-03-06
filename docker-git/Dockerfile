#
# GIT Docker container
#
# Version 0.1

FROM debian:8
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

ENV CGIT_VERSION 0.11.2

# install the required packages and cleanup the install
#   required to compile git: libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip
#   required for cgit: highlight lua5.2 libssl-dev
#   required for apache2: libapache2-mod-uwsgi uwsgi-core
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        apache2 \
        gettext \
        highlight \
        lua5.2 \
        libapache2-mod-uwsgi \
        libcurl4-gnutls-dev \
        libexpat1-dev \
        libssl-dev \
        unzip \
        uwsgi-core \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# compile and install cgit along with the matching version of git
#   1. installs packages needed to compile cgit
#   2. downloads cgit
#   3. uses cgit's makefile to download the proper version of git to compile against
#   4. compiles cgit
#   5. installs cgit
#   6. manualy move executable and create symlink
#   7. compile the downloaded version of git
#   8. install the compiled version of git
#   9. removes the source directory
#  10. cleanup the installed packages used to build cgit
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        autoconf \
        build-essential \
        ca-certificates \
        curl \
    && \
    cd /tmp/ && \
    curl http://git.zx2c4.com/cgit/snapshot/cgit-${CGIT_VERSION}.tar.xz | tar xJ && \
    cd /tmp/cgit-${CGIT_VERSION}/ && \
    make get-git && \
    make CGIT_SCRIPT_PATH=/usr/share/cgit prefix=/usr all  && \
    make CGIT_SCRIPT_PATH=/usr/share/cgit prefix=/usr install && \
    curl http://git-scm.com/favicon.ico > /usr/share/cgit/favicon.ico && \
    mv "/usr/share/cgit/cgit.cgi" "/usr/lib/cgit" && \
    ln -sf ../../lib/cgit/cgit.cgi "/usr/share/cgit/cgit.cgi" && \
    cd /tmp/cgit-${CGIT_VERSION}/git/ && \
    make configure && \
    ./configure --prefix=/usr --without-tcltk --with-expat --with-curl --with-openssl && \
    make && \
    make install && \
    cd && \
    rm -rf /tmp/cgit-${CGIT_VERSION}/ && \
    DEBIAN_FRONTEND=noninteractive apt-get purge --yes \
        ca-certificates \
        curl \
        autoconf \
        build-essential \
    && \
    DEBIAN_FRONTEND=noninteractive apt-get autoremove --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# copy over files
COPY \
    config/000-default-ssl.conf \
    config/000-default.conf \
    config/001-git.conf \
    config/002-cgit.conf \
        /etc/apache2/sites-available/
COPY config/ldap.conf \
        /etc/apache2/mods-available/
COPY \
    config/about.html \
        /var/www/html/about.html
COPY \
    config/cgitrc \
        /etc/
COPY ./docker-entrypoint.sh \
    ./configure.sh \
        /

# run the configuration script
RUN ["/bin/bash", "/configure.sh"]

# specify which network ports will be used
EXPOSE 80 443

# specify the volumes directly related to this image
VOLUME ["/var/lib/git"]

# start the entrypoint script
WORKDIR /var/www/html
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["git"]
