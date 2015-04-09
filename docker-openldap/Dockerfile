#
# GIT Docker container
#
# Version 0.1

FROM debian:8
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

ENV OPENLDAP_VERSION 2.4.31

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        ldap-utils=${OPENLDAP_VERSION}* \
        slapd=${OPENLDAP_VERSION}* \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
    config/modules/ \
    /etc/ldap.dist/modules
COPY ./docker-entrypoint.sh \
    ./configure.sh \
        /

# run the configuration script
RUN ["/bin/bash", "/configure.sh", \
    "openldap-admin-secret-pw", \
    "openldap-config-secret-pw", \
    "ldap.example.org", \
    "Example Inc.", \
    "collective,corba,duaconf,dyngroup,java,misc,openldap,pmi,ppolicy", \
    "memberof"]

# specify which network ports will be used
EXPOSE 389

# set any environment variables
#ENV SLAPD_PASSWORD openldap-admin-secret-pw
#ENV SLAPD_CONFIG_PASSWORD openldap-config-secret-pw
#ENV SLAPD_DOMAIN ldap.example.org
#ENV SLAPD_ORGANIZATION Example Inc.
#ENV SLAPD_ADDITIONAL_SCHEMAS collective, corba, duaconf, dyngroup, java, misc, openldap, pmi, ppolicy
#ENV SLAPD_ADDITIONAL_MODULES memberof

# specify the volumes directly related to this image
VOLUME ["/var/lib/ldap"]

# start the entrypoint script
WORKDIR /var/www/html
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["openldap"]
