#
# mediawiki Docker container
#
# Version 0.1

FROM synctree/mediawiki:latest
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        git \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/www/html/{LocalSettings.php,images} && \
	ln -st /var/www/html/ \
		/var/www-shared/html/LocalSettings.php \
		/var/www-shared/html/images

# specify the volumes directly related to this image
VOLUME ["/var/www-shared/html"]
