set -e

SVN_BASE_DIR=/var/lib/svn

# Create a directory for a dead symlink
mkdir /var/cache/websvn/tmp

# comment out apache2 config file lines that refrence the environment variables
sed -ie 's/^Mutex file/#Mutex file/' /etc/apache2/apache2.conf
sed -ie 's/^PidFile /#PidFile /' /etc/apache2/apache2.conf
sed -ie 's/^User /#User /' /etc/apache2/apache2.conf
sed -ie 's/^Group /#Group /' /etc/apache2/apache2.conf
sed -ie 's/^ErrorLog /#ErrorLog /' /etc/apache2/apache2.conf

# set the SSLSessionCache directory
sed -ie 's/\$[{]APACHE_RUN_DIR[}]/\/var\/run\/apache2/' /etc/apache2/mods-available/ssl.conf

# place the hard coded environment variables
echo "
# hard code the environment variables
Mutex file:/var/lock/apache2 default
PidFile /var/run/apache2/apache2.pid
User www-data
Group www-data
ErrorLog /proc/self/fd/2
CustomLog /proc/self/fd/1 combined
" >> /etc/apache2/apache2.conf

# configure SVN_BASE_DIR for the WebSVN configuration
sed -ie 's|SVN_BASE_DIR|'${SVN_BASE_DIR}'|' /etc/websvn/config.php

# relocate dav_svn.conf to the svn repo directory
mv /etc/apache2/mods-available/dav_svn.conf /var/lib/svn/dav_svn.conf
ln -s /var/lib/svn/dav_svn.conf /etc/apache2/mods-available/dav_svn.conf

# enable modules
a2enmod ssl
a2enmod dav
a2enmod dav_svn

# disable a config - Needed so redirect logs to /proc/self/fd/2 will work (may need to redirect the log it is trying to set)
a2disconf other-vhosts-access-log

# Enable the site
a2ensite 000-websvn-ssl
#a2ensite 000-websvn

# disable site
a2dissite 000-default
