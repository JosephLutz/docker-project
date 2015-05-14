#!/bin/bash

CSV_FILE=users.csv
ADD_USER_FILE=add_user.ldif
ORGINIZATION_FILE=organization.ldif
DC='dc=novatech'
LDAP_HOST=ldap.novatech-llc.com
LDIF_FILE=/tmp/${LDAP_HOST}.ldif
AUTH='-w novatech'

# Arguments
#   FILE       file to modify
#   DC         domain component value
set_domain_component () {
    local file
    local dc
    dc=${1}
    file=${2}
    [ ! -f ${file} ] && { echo "${file} file not found"; exit 99; }
    sed -ie "s|dc=XXXXXXXXXXXX|"${DC}"|" ${file}
    rm -f ${file}e
}

# Arguments
#   DC         domain component value
add_orginization () {
    local dc
    dc=${1}
    cp "${ORGINIZATION_FILE}" /tmp/"${ORGINIZATION_FILE}"
    set_domain_component "${dc}" /tmp/"${ORGINIZATION_FILE}"
    cat /tmp/"${ORGINIZATION_FILE}" >> ${LDIF_FILE}
    rm -f /tmp/"${ORGINIZATION_FILE}"
}

# Arguments
#   USER_ID    username
#   DC         value to use for DC
#   EMAIL      email address
#   FIRST_NAME User's first name
#   LAST_NAME  User's last name
#   USER_UID   uid & gid number
add_user () {
    USER_ID=${1}
    DC=${2}
    EMAIL=${3}
    FIRST_NAME=${4}
    LAST_NAME=${5}
    FULL_NAME="${FIRST_NAME} ${LAST_NAME}"
    USER_UID=${6}
    USER_GID=${USER_UID}
    cp ${ADD_USER_FILE} /tmp/${USER_ID}.ldif
    set_domain_component "${DC}" /tmp/${USER_ID}.ldif
    sed -ie "s|XXXUSER_IDXXX|"${USER_ID}"|"       /tmp/${USER_ID}.ldif
    sed -ie "s|XXXGIDXXX|"${USER_GID}"|"          /tmp/${USER_ID}.ldif
    sed -ie "s|XXXUIDXXX|"${USER_UID}"|"          /tmp/${USER_ID}.ldif
    sed -ie "s|XXXFULL_NAMEXXX|"${FULL_NAME}"|"   /tmp/${USER_ID}.ldif
    sed -ie "s|XXXFIRST_NAMEXXX|"${FIRST_NAME}"|" /tmp/${USER_ID}.ldif
    sed -ie "s|XXXLAST_NAMEXXX|"${LAST_NAME}"|"   /tmp/${USER_ID}.ldif
    sed -ie "s|XXXEMAILXXX|"${EMAIL}"|"           /tmp/${USER_ID}.ldif
    printf '\n# %20s (%5s) - %20s - %s\n' "${USER_ID}" "${USER_UID}" "${FULL_NAME}" "${EMAIL}" >> ${LDIF_FILE}
    cat /tmp/${USER_ID}.ldif >> ${LDIF_FILE}
    rm -f /tmp/${USER_ID}.ldife
    rm -f /tmp/${USER_ID}.ldif
}

rm -f ${LDIF_FILE}
OLDIFS=$IFS
add_orginization "${DC}"
printf '\n\n# Add users and their primary group\n\n' >> ${LDIF_FILE}
[ ! -f ${CSV_FILE} ] && { echo "${CSV_FILE} file not found"; exit 99; }
IFS=,
while read user first last email id
do
    printf '%20s (%5s) - %20s - %s\n' "${user}" "${id}" "${first} ${last}" "${email}"
    add_user "${user}" "${DC}" "${email}" "${first}" "${last}" "${id}"
done < ./${CSV_FILE}
IFS=$OLDIFS

ldapadd -cxD cn=admin,${DC} -f ${LDIF_FILE} -h ${LDAP_HOST} ${AUTH}
