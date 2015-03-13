BACKUP_DIR=/home/josephl/SVN
SVN_EXPORT_PATH=/tmp/import_export
SVN_REPOS="ddio novatech NCD_Release"
WEBSVN_IP=172.16.71.110

HOST_SVN_DIR=$(pwd)/svn
HOST_SSL_DIR=$(pwd)/ssl
HOST_WEBSVN_PASSWD_DIR=$(pwd)/websvn_password
mkdir -p ${HOST_SVN_DIR} ${HOST_SSL_DIR} ${HOST_WEBSVN_PASSWD_DIR}
