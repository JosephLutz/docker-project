FROM ubuntu:trusty

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $PATH:$HTTPD_PREFIX/bin
RUN mkdir -p "$HTTPD_PREFIX" && \
	chown www-data:www-data "$HTTPD_PREFIX"

#---------------------------
RUN apt-get update
RUN apt-get install -y gcc --no-install-recommends

RUN apt-get install -y apache2 --no-install-recommends
RUN apt-get install -y libapache2-mod-wsgi --no-install-recommends
RUN apt-get install -y libapache2-mod-xsendfile --no-install-recommends

RUN apt-get install -y mysql-client --no-install-recommends
RUN apt-get install -y libmysqlclient-dev --no-install-recommends

RUN apt-get install -y python-pip --no-install-recommends
RUN apt-get install -y python-setuptools --no-install-recommends
RUN apt-get install -y libpython-dev --no-install-recommends

RUN rm -rf /var/lib/apt/lists/*
#---------------------------
#---------------------------
RUN rm -rf /var/www/html && \
	mkdir -p /var/lock/apache2 \
		/var/run/apache2 \
		/var/log/apache2 \
		/var/www/html && \ 
	chown -R www-data:www-data \
		/var/lock/apache2 \
		/var/run/apache2 \
		/var/log/apache2 \
		/var/www/html
#---------------------------
#Setup and install of DJango version 1.7.5
ENV DJANGO_VERSION 1.7.5
RUN pip install django=="$DJANGO_VERSION"
RUN pip install mysqlclient 
RUN pip install pyserial
#---------------------------

COPY ./config_files/httpd.conf       /etc/apache2/conf-available/httpd.conf
COPY ./config_files/apache2.conf     /etc/apache2/apache2.conf
RUN /usr/sbin/a2enconf httpd
RUN /usr/sbin/a2disconf charset localized-error-pages other-vhosts-access-log security serve-cgi-bin

COPY httpd-foreground /usr/local/bin/
WORKDIR /var/www/html
EXPOSE 80

CMD ["httpd-foreground"]
