#!/bin/bash
set -e

SLAPD_PASSWORD=${1}
SLAPD_CONFIG_PASSWORD=${2}
SLAPD_DOMAIN=${3}
SLAPD_ORGANIZATION=${4}
SLAPD_ADDITIONAL_SCHEMAS=${5}
SLAPD_ADDITIONAL_MODULES=${6}


mv /etc/ldap /etc/ldap.dist
mkdir /etc/ldap

SLAPD_ORGANIZATION="${SLAPD_ORGANIZATION:-${SLAPD_DOMAIN}}"

cp -a /etc/ldap.dist/* /etc/ldap

cat <<-EOF | debconf-set-selections
slapd slapd/no_configuration boolean false
slapd slapd/password1 password $SLAPD_PASSWORD
slapd slapd/password2 password $SLAPD_PASSWORD
slapd shared/organization string $SLAPD_ORGANIZATION
slapd slapd/domain string $SLAPD_DOMAIN
slapd slapd/backend select HDB
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/purge_database boolean false
slapd slapd/move_old_database boolean true
EOF

dpkg-reconfigure -f noninteractive slapd >/dev/null 2>&1

dc_string=""

IFS="."; declare -a dc_parts=($SLAPD_DOMAIN)

for dc_part in "${dc_parts[@]}"; do
    dc_string="$dc_string,dc=$dc_part"
done

base_string="BASE ${dc_string:1}"

sed -i "s/^#BASE.*/${base_string}/g" /etc/ldap/ldap.conf

if [[ -n "$SLAPD_CONFIG_PASSWORD" ]]; then
    password_hash=`slappasswd -s "${SLAPD_CONFIG_PASSWORD}"`

    sed_safe_password_hash=${password_hash//\//\\\/}

    slapcat -n0 -F /etc/ldap/slapd.d -l /tmp/config.ldif
    sed -i "s/\(olcRootDN: cn=admin,cn=config\)/\1\nolcRootPW: ${sed_safe_password_hash}/g" /tmp/config.ldif
    rm -rf /etc/ldap/slapd.d/*
    slapadd -n0 -F /etc/ldap/slapd.d -l /tmp/config.ldif >/dev/null 2>&1
fi

if [[ -n "$SLAPD_ADDITIONAL_SCHEMAS" ]]; then
    IFS=","; declare -a schemas=($SLAPD_ADDITIONAL_SCHEMAS)

    for schema in "${schemas[@]}"; do
        slapadd -n0 -F /etc/ldap/slapd.d -l "/etc/ldap/schema/${schema}.ldif" >/dev/null 2>&1
    done
fi

if [[ -n "$SLAPD_ADDITIONAL_MODULES" ]]; then
    IFS=","; declare -a modules=($SLAPD_ADDITIONAL_MODULES)

    for module in "${modules[@]}"; do
         slapadd -n0 -F /etc/ldap/slapd.d -l "/etc/ldap/modules/${module}.ldif" >/dev/null 2>&1
    done
fi

chown -R openldap:openldap /var/lib/ldap/
