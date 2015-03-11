#
# WebSVN (sshd DEBUG) Docker container
#
# Version 0.0

FROM php:apache
#FROM ubuntu:14.04
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

# These commands are here for debugging purposes only. They should be removed in the final version
ADD ./sshd_debug.sh /tmp/sshd_debug.sh
RUN ["/bin/bash", "/tmp/sshd_debug.sh"]
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# set the apache environment variables
#   this is needed due to running apache interactivly
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV LANG=C

# set variables used in init_svn.sh, import_svn.sh, and export_svn.sh scripts
ENV SVN_EXPORT_PATH /tmp/import_export
ENV SVN_BASE_DIR /var/lib/svn/

# create the volumes that will be needed
VOLUME ["/var/www", "${APACHE_LOG_DIR}", "/etc/apache2"]

# add and run the script that installs the packages that are needed
ADD ./install.sh /tmp/install.sh
RUN ["/bin/bash", "/tmp/install.sh"]

# add and run the script which changes the default configuration to our custom configuration
ADD ./configure.sh /tmp/configure.sh
RUN ["/bin/bash", "/tmp/configure.sh"]

# add and run the script which initilized the SVN repositories
ADD ./init_svn.sh /tmp/init_svn.sh
RUN ["/bin/bash", "/tmp/init_svn.sh"]

# add the import and export scripts, then run the import script
ADD ./import_svn.sh /tmp/import_svn.sh
ADD ./export_svn.sh /tmp/export_svn.sh
RUN ["/bin/bash", "/tmp/import_svn.sh"]

# specify which network ports will be used
EXPOSE 80 443

# start apache running
# CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
# ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]