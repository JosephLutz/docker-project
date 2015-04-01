set -e

GIT_BASE_DIR=/var/lib/git

# comment out apache2 config file lines that refrence the environment variables
sed -ie 's/^Mutex file/#Mutex file/' /etc/apache2/apache2.conf
sed -ie 's/^PidFile /#PidFile /' /etc/apache2/apache2.conf
sed -ie 's/^User /#User /' /etc/apache2/apache2.conf
sed -ie 's/^Group /#Group /' /etc/apache2/apache2.conf
sed -ie 's/^ErrorLog /#ErrorLog /' /etc/apache2/apache2.conf

# set the SSLSessionCache directory
sed -ie 's/\$[{]APACHE_RUN_DIR[}]/\/var\/run\/apache2/' /etc/apache2/mods-available/ssl.conf
sed -ie 's/\$[{]APACHE_RUN_DIR[}]/\/var\/run\/apache2/' /etc/apache2/mods-available/cgid.conf

# Set the lock directory for dav_fs
mkdir -p /var/lock/apache2
chown www-data:www-data /var/lock/apache2
sed -ie 's/\$[{]APACHE_LOCK_DIR[}]/\/var\/lock\/apache2/' /etc/apache2/mods-available/dav_fs.conf

# create the cgit cache directory
mkdir -p /var/cache/cgit
chown www-data:www-data /var/cache/cgit

# change the cgit 'highlight' source filter to use version 3 with inline css
sed -ie 's/^exec highlight /#exec highlight /' /usr/lib/cgit/filters/syntax-highlighting.sh
echo 'exec highlight --force --inline-css -f -I -O xhtml -S "$EXTENSION" 2>/dev/null' >> /usr/lib/cgit/filters/syntax-highlighting.sh

# set the git base Directory in the config files
sed -ie 's|GIT_BASE_DIR|'${GIT_BASE_DIR}'|' /etc/cgitrc /etc/gitweb.conf /etc/apache2/sites-available/*.conf

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
a2enmod cgid
a2enmod dav_fs

# disable a config - Needed so redirect logs to /proc/self/fd/2 will work (may need to redirect the log it is trying to set)
a2disconf other-vhosts-access-log

# Enable the site
#a2ensite 000-git-ssl
a2ensite 000-git
a2ensite 001-cgit
#a2ensite 001-gitweb

# disable site
a2dissite 000-default
