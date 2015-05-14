#!/bin/bash

# Arguments
#   USER_ID    username
#   DC         value to use for DC
#   DOMAIN     Domain nale for email account
#   FIRST_NAME User's first name
#   LAST_NAME  User's last name
#   UID        uid & gid number
add_user () {
    USER_ID=${1}
    DC=${2}
    DOMAIN=${3}
    FIRST_NAME=${4}
    LAST_NAME=${5}
    FULL_NAME="${FIRST_NAME} ${LAST_NAME}"
    UID=${6}
    GID=${UID}
    cp /config/add-user.ldif /tmp/add_user_${USER_ID}.ldif
    sed -ie "s|XXXUSER_IDXXX|"${USER_ID}"|"       /tmp/add_user_${USER_ID}.ldif
    sed -ie "s|dc=XXXXXXXXXXXX,dc=XXX|"${DC}"|"   /tmp/add_user_${USER_ID}.ldif
    sed -ie "s|XXXGIDXXX|"${GID}"|"               /tmp/add_user_${USER_ID}.ldif
    sed -ie "s|XXXUIDXXX|"${UIG}"|"               /tmp/add_user_${USER_ID}.ldif
    sed -ie "s|XXXFULL_NAMEXXX|"${FULL_NAME}"|"   /tmp/add_user_${USER_ID}.ldif
    sed -ie "s|XXXFIRST_NAMEXXX|"${FIRST_NAME}"|" /tmp/add_user_${USER_ID}.ldif
    sed -ie "s|XXXLAST_NAMEXXX|"${LAST_NAME}"|"   /tmp/add_user_${USER_ID}.ldif
    sed -ie "s|XXXDOMAINXXX|"${DOMAIN}"|"         /tmp/add_user_${USER_ID}.ldif
    rm -f /tmp/add_user_${USER_ID}.ldife
    ldapadd -cxWD cn=admin,${DC} -f /tmp/add_user_${USER_ID}.ldif
}

add_user 'josephl' 'dc=novatech-llc,dc=com' 'novatech-llc.com' 'Joseph' 'Lutz' '1000'
