#!/bin/bash
set -e

GIT_BASE_DIR=/var/lib/git

# place the hard coded environment variables
cat << EOF > /etc/apache2/apache2.conf

# hard code the environment variables
Mutex file:/var/lock/apache2 default
PidFile /var/run/apache2/apache2.pid
User www-data
Group www-data
ErrorLog /proc/self/fd/2
CustomLog /proc/self/fd/1 combined
EOF

# comment out apache2 config file lines that refrence the environment variables
sed -ie 's/^Mutex file/#Mutex file/' /etc/apache2/apache2.conf
sed -ie 's/^PidFile /#PidFile /' /etc/apache2/apache2.conf
sed -ie 's/^User /#User /' /etc/apache2/apache2.conf
sed -ie 's/^Group /#Group /' /etc/apache2/apache2.conf
sed -ie 's/^ErrorLog /#ErrorLog /' /etc/apache2/apache2.conf
rm -f /etc/apache2/apache2.confe

# set the SSLSessionCache directory
sed -ie 's/\$[{]APACHE_RUN_DIR[}]/\/var\/run\/apache2/' /etc/apache2/mods-available/ssl.conf
sed -ie 's/\$[{]APACHE_RUN_DIR[}]/\/var\/run\/apache2/' /etc/apache2/mods-available/cgid.conf
rm -f \
  /etc/apache2/mods-available/cgid.confe \
  /etc/apache2/mods-available/ssl.confe

# create the cgit cache directory
mkdir -p /var/cache/cgit
chown www-data:www-data /var/cache/cgit

# change the cgit 'highlight' source filter to use version 3 with inline css
sed -ie 's/^exec highlight /#exec highlight /' /usr/lib/cgit/filters/syntax-highlighting.sh
rm -f /usr/lib/cgit/filters/syntax-highlighting.she
echo 'exec highlight --force --inline-css -f -I -O xhtml -S "$EXTENSION" 2>/dev/null' >> /usr/lib/cgit/filters/syntax-highlighting.sh

# set the git base Directory in the config files
sed -ie 's|GIT_BASE_DIR|'${GIT_BASE_DIR}'|' /etc/cgitrc /etc/apache2/sites-available/*.conf
rm -f \
  /etc/apache2/sites-available/*.confe \
  /etc/cgitrce

# create apache domainname config
echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf
a2enconf servername.conf

# disable a config - wants to use an environment variable
a2disconf other-vhosts-access-log

# enable modules
a2enmod ssl cgi

# Enable the site
a2ensite \
  000-default-ssl.conf \
  000-default.conf \
  001-git.conf \
  002-cgit.conf
