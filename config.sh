BACKUP_DIR=/opt/BACKUP

TAG="current"
CONTAINER_ENDING=""
#CONTAINER_ENDING="_${TAG}"
{ # variables for OpenSSL
  NAME_OPENSSL_IMAGE="novatechweb/openssl"
  NAME_OPENSSL_DV="DV_openssl${CONTAINER_ENDING}"
  HOST_OPENSSL_BACKUP_DIR=${BACKUP_DIR}/openssl
}

{ # variables for htpasswd
  NAME_HTPASSWD_IMAGE="novatechweb/htpasswd"
  NAME_HTPASSWD_DV="DV_htpasswd${CONTAINER_ENDING}"
}

{ # Variables for WebSVN and SVN
  NAME_SVN_IMAGE="novatechweb/svn"
  NAME_SVN_CONTAINER="svn${CONTAINER_ENDING}"
  NAME_SVN_REPO_DV="DV_svn_repo${CONTAINER_ENDING}"
  SVN_HOSTNAME=svn.novatech-llc.com
  SVN=172.16.0.108:443
  SVN_OPEN=172.16.0.108:80
  HOST_SVN_BACKUP_DIR=${BACKUP_DIR}/SVN
  SVN_REPOS=("ddio" "novatech" "NCD_Release")
}

{ # variables for GIT
  NAME_GIT_IMAGE="novatechweb/git"
  NAME_GIT_CONTAINER="git${CONTAINER_ENDING}"
  NAME_GIT_REPO_DV="DV_git_repo${CONTAINER_ENDING}"
  GIT_HOSTNAME=git.novatech-llc.com
  GIT=172.16.0.102:443
  GIT_OPEN=172.16.0.102:80
  HOST_GIT_BACKUP_DIR=${BACKUP_DIR}/GIT
}

{ # variables for gitLab
  NAME_GITLAB_IMAGE="sameersbn/gitlab"
  NAME_GITLAB_DV_IMAGE="novatechweb/gitlab"
  NAME_GITLAB_CONTAINER="gitlab${CONTAINER_ENDING}"
  NAME_GITLAB_POSTGRES_CONTAINER="gitlab_postgres${CONTAINER_ENDING}"
  NAME_GITLAB_REDIS_CONTAINER="gitlab_redis${CONTAINER_ENDING}"
  NAME_GITLAB_REPO_DV="DV_gitlab_repo${CONTAINER_ENDING}"
  NAME_GITLAB_POSTGRES_DV="DV_gitlab_postgres${CONTAINER_ENDING}"
  GITLAB_HOSTNAME=git.novatech-llc.com
  GITLAB=172.16.0.102:443
  GITLAB_OPEN=172.16.0.102:80
  GITLAB_SSH=172.16.0.102:22
  HOST_GIT_BACKUP_DIR=${BACKUP_DIR}/GIT

  GITLAB_POSTGRES_USER=novatech
  GITLAB_POSTGRES_PASSWORD=novatech
}

{ # variables for MediaWIKI
  NAME_WIKI_IMAGE="novatechweb/wiki"
  NAME_WIKI_CONTAINER="wiki${CONTAINER_ENDING}"
  NAME_WIKI_MYSQL_CONTAINER="wiki_mysql${CONTAINER_ENDING}"
  NAME_WIKI_DV="DV_wiki${CONTAINER_ENDING}"
  NAME_WIKI_MYSQL_DV="DV_wiki_mysql${CONTAINER_ENDING}"
  WIKI_HOSTNAME=wiki.novatech-llc.com
  MEDIAWIKI=172.16.0.103:443
  MEDIAWIKI_OPEN=172.16.0.103:80
  HOST_MEDIAWIKI_BACKUP_DIR=${BACKUP_DIR}/WIKI
  WIKI_MYSQL_PASSWORD=database-root-user-secret-pw
  MEDIAWIKI_USER=novatech
  MEDIAWIKI_PASSWORD=novatech
}

{ # variables for PHPMyAdmin
  NAME_PHPMYADMIN_CONTAINER="phpmyadmin${CONTAINER_ENDING}"
  NAME_PHPMYADMIN_MYSQL_CONTAINER="phpmyadmin_mysql${CONTAINER_ENDING}"
  NAME_PHPMYADMIN_MYSQL_DV="DV_phpmyadmin_mysql${CONTAINER_ENDING}"
  #PHPMYADMIN_HOSTNAME=phpmyadmin.novatech-llc.com
  PHPMYADMIN=172.16.0.109:443
  PHPMYADMIN_OPEN=172.16.0.109:80
  PHPMYADMIN_PMA_SECRET="opGKy8P*FXJKZVqWuom6Bi8c8fgK1yaRDnq4loQ95g"
  PHPMYADMIN_MYSQL_PASSWORD=database-root-user-secret-pw
  PHPMYADMIN_PMA_USERNAME=novatech
  PHPMYADMIN_PMA_PASSWD=novatech
}

{ # variables for OpenLDAP
  NAME_LDAP_IMAGE="novatechweb/ldap"
  NAME_LDAP_CONTAINER="ldap${CONTAINER_ENDING}"
  NAME_LDAP_DV="DV_ldap${CONTAINER_ENDING}"
  #OPENLDAP_HOSTNAME=ldap.novatech-llc.com
  OPENLDAP=172.16.0.110:389
  OPENLDAP_SECURE=172.16.0.110:636
  HOST_OPENLDAP_BACKUP_DIR=${BACKUP_DIR}/LDAP
}

{ # variables for phpldapadmin
  NAME_PHPLDAPADMIN="phpldapadmin${CONTAINER_ENDING}"
  PHPLDAPADMIN=172.16.0.110:443
  PHPLDAPADMIN_OPEN=172.16.0.110:80
}

{ # variables for Django
  NAME_DJANGO_IMAGE="novatechweb/django"
  NAME_DJANGO_CONTAINER="django${CONTAINER_ENDING}"
  DJANGO_HOSTNAME=django.novatech-llc.com
  DJANGO=172.16.0.110:80
  DJANGO_SECURE=172.16.0.110:443
  HOST_DJANGO_BACKUP_DIR=${BACKUP_DIR}/Django
  HOST_DJANGO_SRC_DIR=${BACKUP_DIR}/Django/code
}

ALL_IMAGES=( \
    ${NAME_OPENSSL_IMAGE} \
    ${NAME_LDAP_IMAGE} \
    ${NAME_WIKI_IMAGE} \
    ${NAME_SVN_IMAGE} \
    ${NAME_GIT_IMAGE} \
    ${NAME_GITLAB_IMAGE} \
    ${NAME_GITLAB_DV_IMAGE} \
    )
#    ${NAME_DJANGO_IMAGE} \
#    ${NAME_HTPASSWD_IMAGE} \

get_docker_dir() {
    case $1 in
        ${NAME_OPENSSL_IMAGE}) echo 'docker-openssl';;
        ${NAME_HTPASSWD_IMAGE}) echo 'docker-htpasswd';;
        ${NAME_LDAP_IMAGE}) echo 'docker-openldap';;
        ${NAME_WIKI_IMAGE}) echo 'docker-mediawiki';;
        ${NAME_SVN_IMAGE}) echo 'docker-svn';;
        ${NAME_GIT_IMAGE}) echo 'docker-git';;
        ${NAME_GITLAB_IMAGE}) echo '';;
        ${NAME_GITLAB_DV_IMAGE}) echo 'docker-gitlab';;
        ${NAME_DJANGO_IMAGE}) echo 'docker-django';;
    esac
}
