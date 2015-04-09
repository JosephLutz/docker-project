#!/bin/bash

: ${DB_USER:=db_user}
: ${DB_PASSWORD:=db_pass}
: ${DB_NAME:=db_name}
: ${DB_ENCODING:=UTF-8}
: ${DB_PG_DUMP_FILE:=/tmp/import_export/db.pgdump}

{
  gosu postgres postgres --single -jE <<-EOSQL
CREATE USER "$DB_USER" WITH PASSWORD '$DB_PASSWORD';
EOSQL
} && {
  gosu postgres postgres --single -jE <<-EOSQL
CREATE DATABASE "$DB_NAME" WITH OWNER="$DB_USER" TEMPLATE=template0 ENCODING='$DB_ENCODING';
EOSQL
} && {
  gosu postgres pg_ctl start -w && \
    gosu postgres pg_restore -d "$DB_NAME" "$DB_PG_DUMP_FILE" && \
    gosu postgres pg_ctl stop -w
} && \
  /bin/rm -f ${DB_PG_DUMP_FILE}

