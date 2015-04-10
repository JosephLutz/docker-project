CWD=$(pwd)

{ # variables for OpenSSL
  NAME_OPENSSL_IMAGE="data_openssl"
  NAME_OPENSSL_DV="DV_openssl"
}

{ # variables for htpasswd
  NAME_HTPASSWD_IMAGE="data_htpasswd"
  NAME_HTPASSWD_DV="DV_htpasswd"
}

{ # Variables for WebSVN and SVN
  NAME_SVN_IMAGE="image_svn"
  NAME_SVN_CONTAINER="svn"
  NAME_SVN_REPO_DV="DV_svn_repo"
  SVN_IP=172.16.0.101
  HOST_SVN_BACKUP_DIR=${CWD}/BACKUP/SVN
  SVN_REPOS=("ddio" "novatech" "NCD_Release")
}

{ # variables for GIT
  NAME_GIT_IMAGE="image_git"
  NAME_GIT_CONTAINER="git"
  NAME_GIT_REPO_DV="DV_git_repo"
  GIT_IP=172.16.0.102
  HOST_GIT_BACKUP_DIR=${CWD}/BACKUP/GIT
}

{ # variables for MediaWIKI
  NAME_WIKI_CONTAINER="wiki"
  NAME_WIKI_MYSQL_CONTAINER="mysql_wiki"
  NAME_WIKI_MYSQL_DV="DV_mysql_wiki"
  MEDIAWIKI_IP=172.16.0.103
  HOST_MEDIAWIKI_BACKUP_DIR=${CWD}/BACKUP/WIKI
  MYSQL_PASSWORD=mediawiki-secret-pw
  MEDIAWIKI_USER=novatech
  MEDIAWIKI_PASSWORD=novatech
}

{ # variables for OpenLDAP
  NAME_LDAP_IMAGE="image_openldap"
  NAME_LDAP_CONTAINER="OpenLDAP"
  NAME_LDAP_DV="DV_openldap"
  OPENLDAP_IP=172.16.0.104
  HOST_OPENLDAP_BACKUP_DIR=${CWD}/BACKUP/LDAP
}

{ # variables for Django
  NAME_DJANGO_IMAGE="image_django"
  #NAME_DJANGO_CONTAINER="django"
  DJANGO_IP=172.16.0.105
  HOST_DJANGO_BACKUP_DIR=${CWD}/BACKUP/DJANGO
  HOST_DJANGO_SRC_DIR=${CWD}/BACKUP/DJANGO/code
}
