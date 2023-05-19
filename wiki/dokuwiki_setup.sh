#!/bin/bash
set -euo pipefail

# Needed for https://www.dokuwiki.org/rewrite
a2enmod rewrite > /dev/null

# Set Apache2 ServerName
if [ -n "${DOKUWIKI_SERVER_NAME-}" ]; then
    echo "ServerName ${DOKUWIKI_SERVER_NAME}" \
        >> /etc/apache2/conf-enabled/dokuwiki-servername.conf
fi

# PHP Production mode
cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Get or create DOKUWIKI_GID group
if [ -n "${DOKUWIKI_GID-}" ]; then
    APACHE_RUN_GROUP=$( (getent group "$DOKUWIKI_GID" || true) | cut -d: -f1)
    if [ -z "$APACHE_RUN_GROUP" ]; then
        APACHE_RUN_GROUP="dokuwiki"
        groupadd --force --gid "$DOKUWIKI_GID" "$APACHE_RUN_GROUP"
    fi
fi

# Get or create DOKUWIKI_UID user
if [ -n "${DOKUWIKI_UID-}" ]; then
    APACHE_RUN_USER=$( (getent passwd "$DOKUWIKI_UID" || true) | cut -d: -f1)
    if [ -z "$APACHE_RUN_USER" ]; then
        APACHE_RUN_USER="dokuwiki"
        useradd --shell /sbin/nologin --home-dir /var/www/html \
            ${DOKUWIKI_GID:+ --gid "$DOKUWIKI_GID"} \
            --uid "$DOKUWIKI_UID" "$APACHE_RUN_USER"
    fi
fi

# Run Apache2
export APACHE_RUN_USER
export APACHE_RUN_GROUP
exec apache2-foreground