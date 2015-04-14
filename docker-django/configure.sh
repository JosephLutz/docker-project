set -e

DJANGO_BASE_DIR=/var/lib/django
VIRTUALENV_BASE_DIR=/var/lib/python

# comment out apache2 config file lines that refrence the environment variables
sed -ie 's/^Mutex file/#Mutex file/' /etc/apache2/apache2.conf
sed -ie 's/^PidFile /#PidFile /' /etc/apache2/apache2.conf
sed -ie 's/^User /#User /' /etc/apache2/apache2.conf
sed -ie 's/^Group /#Group /' /etc/apache2/apache2.conf
sed -ie 's/^ErrorLog /#ErrorLog /' /etc/apache2/apache2.conf
rm -f /etc/apache2/apache2.confe

# place the hard coded environment variables
cat << EOF >> /etc/apache2/apache2.conf

# hard code the environment variables
Mutex file:/var/lock/apache2 default
PidFile /var/run/apache2/apache2.pid
User www-data
Group www-data
ErrorLog /proc/self/fd/2
CustomLog /proc/self/fd/1 combined
EOF

# set the SSLSessionCache directory
sed -ie 's/\$[{]APACHE_RUN_DIR[}]/\/var\/run\/apache2/' \
  /etc/apache2/mods-available/ssl.conf
sed -ie 's/\$[{]APACHE_RUN_DIR[}]/\/var\/run\/apache2/' \
  /etc/apache2/mods-available/cgid.conf
rm -f \
  /etc/apache2/mods-available/cgid.confe \
  /etc/apache2/mods-available/ssl.confe

# set the git base Directory in the config files
sed -ie 's|DJANGO_BASE_DIR|'${DJANGO_BASE_DIR}'|' \
  /etc/apache2/sites-available/*.conf
rm -f \
  /etc/apache2/sites-available/*.confe

# create apache domainname config
echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf
a2enconf servername.conf

# disable a config - wants to use an environment variable
a2disconf other-vhosts-access-log

# enable modules
a2enmod ssl wsgi

# Enable the site
a2ensite \
  000-default-ssl.conf \
  000-default.conf \
  000-django

# setup python virtual environment
virtualenv --python=/usr/bin/python2.7 --system-site-packages ${VIRTUALENV_BASE_DIR}
source ${VIRTUALENV_BASE_DIR}/bin/activate
pip install Django==${DJANGO_VERSION}
#pip install python-ldap==${PYTHON_LDAP_VERSION}    # do not have tools and libraries to compile C source => installed older distribution version
pip install django-ldapdb==${DJANGO_LDAPDB_VERSION}