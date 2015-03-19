# Variables for WebSVN and SVN
WEBSVN_IP=172.16.0.101
HOST_SVN_DIR=$(pwd)/data/websvn_svn
HOST_WEBSVN_SSL_DIR=$(pwd)/data/websvn_ssl
HOST_WEBSVN_PASSWD_DIR=$(pwd)/data/websvn_password
SVN_REPOS=("ddio" "novatech" "NCD_Release")

HTPASSMAN_IP=172.16.0.102
HOST_HTPASSMAN_SSL_DIR=$(pwd)/data/htpassman_ssl
HOST_HTPASSMAN_PASSWD_DIR=$(pwd)/data/htpassman_password

DJANGO_IP=172.16.0.103
HOST_DJANGO_DIR=$(pwd)/code

TESTSTATION_IP=172.16.0.104
HOST_TESTSTATION_MYSQL_DATA_DIR=$(pwd)/teststation_mysql/data
HOST_TESTSTATION_DJANGO_CODE_DIR=$(pwd)/httpd_django/Build_System_Code
