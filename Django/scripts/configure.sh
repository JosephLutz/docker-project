set -e

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

# create apache domainname config
echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf

# enable configs
a2enconf servername

# enable modules
a2enmod ssl

# disable a config - Needed so redirect logs to /proc/self/fd/2 will work (may need to redirect the log it is trying to set)
a2disconf other-vhosts-access-log

# Enable the site
a2ensite 000-django-ssl
a2ensite 000-django

# disable site
a2dissite 000-default
