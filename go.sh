#!/bin/bash
BACKUP_DIR=${1}
[[ -x "${BACKUP_DIR}" ]] && ( \
	echo "A local directory  for svn backup is required as an argument" ;
	exit 1 )
SVN_EXPORT_PATH=/tmp/import_export
printf "\n\n\n"
printf "[ Building image \"php_ssh_test\"]\n" && \
sudo docker build -t php_ssh_test . && \
printf "\n\n\n\n" && \
printf "[Starting container \"sshd_test\"]\n" && \
sudo docker run -d -P --name sshd_test -v ${BACKUP_DIR}:${SVN_EXPORT_PATH} php_ssh_test && \
printf "\n\n\n\n" && \
printf "[ssh running on: " && \
sudo docker port sshd_test 22 && \
printf "]\n"
printf "\nssh root@localhost -p <PORT_NUM>\n\n"
