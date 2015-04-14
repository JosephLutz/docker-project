BACKUP_DIR=$(pwd)/BACKUP

TAG="current"
{ # variables for OpenSSL
  NAME_OPENSSL_IMAGE="novatechweb/data_openssl"
  NAME_OPENSSL_DV="DV_openssl"
}

{ # variables for htpasswd
  NAME_HTPASSWD_IMAGE="novatechweb/data_htpasswd"
  NAME_HTPASSWD_DV="DV_htpasswd"
}

{ # Variables for WebSVN and SVN
  NAME_SVN_IMAGE="novatechweb/svn"
  NAME_SVN_CONTAINER="svn"
  NAME_SVN_REPO_DV="DV_svn_repo"
  SVN=172.16.0.101:443
  SVN_OPEN=172.16.0.101:80
  HOST_SVN_BACKUP_DIR=${BACKUP_DIR}/SVN
  SVN_REPOS=("ddio" "novatech" "NCD_Release")
}

{ # variables for GIT
  NAME_GIT_IMAGE="novatechweb/git"
  NAME_GIT_CONTAINER="git"
  NAME_GIT_REPO_DV="DV_git_repo"
  GIT=172.16.0.102:443
  GIT_OPEN=172.16.0.102:80
  HOST_GIT_BACKUP_DIR=${BACKUP_DIR}/GIT
}

{ # variables for MediaWIKI
  NAME_WIKI_CONTAINER="wiki"
  NAME_WIKI_MYSQL_CONTAINER="mysql_wiki"
  NAME_WIKI_MYSQL_DV="DV_mysql_wiki"
  MEDIAWIKI=172.16.0.103:443
  MEDIAWIKI_OPEN=172.16.0.103:80
  HOST_MEDIAWIKI_BACKUP_DIR=${BACKUP_DIR}/WIKI
  MYSQL_PASSWORD=mediawiki-secret-pw
  MEDIAWIKI_USER=novatech
  MEDIAWIKI_PASSWORD=novatech
}

{ # variables for OpenLDAP
  NAME_LDAP_IMAGE="novatechweb/ldap"
  NAME_LDAP_CONTAINER="OpenLDAP"
  NAME_LDAP_DV="DV_ldap"
  OPENLDAP=172.16.0.104:389
  OPENLDAP_SECURE=172.16.0.104:636
  HOST_OPENLDAP_BACKUP_DIR=${BACKUP_DIR}/LDAP
}

{ # variables for Django
  NAME_DJANGO_IMAGE="novatechweb/django"
  NAME_DJANGO_CONTAINER="django"
  DJANGO=172.16.0.105:80
  DJANGO_SECURE=172.16.0.105:443
  HOST_DJANGO_BACKUP_DIR=${BACKUP_DIR}/Django
  HOST_DJANGO_SRC_DIR=${BACKUP_DIR}/Django/code
}
