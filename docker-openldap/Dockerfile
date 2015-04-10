#
# GIT Docker container
#
# Version 0.1

FROM debian:8
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

ENV OPENLDAP_VERSION 2.4

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        ldap-utils=${OPENLDAP_VERSION}* \
        slapd=${OPENLDAP_VERSION}* \
    && \
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
