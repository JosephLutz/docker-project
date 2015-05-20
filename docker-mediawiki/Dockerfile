#
# mediawiki Docker container
#
# Version 0.1

FROM synctree/mediawiki:latest
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        git \
        php5-ldap \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/www/html/{LocalSettings.php,images} && \
    ln -st /var/www/html/ \
        /var/www-shared/html/LocalSettings.php \
        /var/www-shared/html/images

# install the  LDAP Authentication Extension: http://www.mediawiki.org/wiki/Extension:LDAP_Authentication
RUN curl https://extdist.wmflabs.org/dist/extensions/LdapAuthentication-REL1_24-24a399e.tar.gz | \
    tar -xzC /var/www/html/extensions/
# install the UserMerge Extension: http://www.mediawiki.org/wiki/Extension:UserMerge
RUN curl https://extdist.wmflabs.org/dist/extensions/UserMerge-REL1_24-3a8651b.tar.gz | \
    tar -xzC /var/www/html/extensions/

# specify the volumes directly related to this image
VOLUME ["/var/www-shared/html"]
