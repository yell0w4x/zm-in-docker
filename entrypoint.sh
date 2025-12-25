#!/usr/bin/env bash
set -eux

/usr/local/bin/wait-for-it.sh db:3306 -t 60

init_db() {
    if ! mysql -h"$ZM_DB_HOST" -u"$ZM_DB_USER" -p"$ZM_DB_PASS" -e "use $ZM_DB_NAME"; then
        echo "Database not found. Creating and initializing database..."
        mysql -h"$ZM_DB_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $ZM_DB_NAME;"
        mysql -h"$ZM_DB_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $ZM_DB_NAME.* TO '$ZM_DB_USER'@'%';"
        mysql -h"$ZM_DB_HOST" -u"$ZM_DB_USER" -p"$ZM_DB_PASS" "$ZM_DB_NAME" < /usr/share/zoneminder/db/zm_create.sql
    else
        echo "Database already exists."
    fi
}

init_zm_db_conf() {
    ZM_DB_CONF=/etc/zm/conf.d/db-user.conf

    if ! [ -f "${ZM_DB_CONF}" ]; then
        cat <<EOF > /etc/zm/conf.d/db-user.conf
ZM_DB_HOST=$ZM_DB_HOST
ZM_DB_NAME=$ZM_DB_NAME
ZM_DB_USER=$ZM_DB_USER
ZM_DB_PASS=$ZM_DB_PASS
EOF
    fi
}

enable_a2_mod() {
    local mod_name=$1
    if ! [ -f "/etc/apache2/mods-enabled/${mod_name}.load" ]; then
        a2enmod "${mod_name}"
    fi
}

enable_a2_conf() {
    local conf_name=$1
    if ! [ -f "/etc/apache2/conf-enabled/${conf_name}.conf" ]; then
        a2enconf "${conf_name}"
    fi
}

chown -R www-data:www-data \
    /var/cache/zoneminder/events \
    /var/cache/zoneminder/images \
    /var/log/zm

sed -i "s|;date.timezone =|date.timezone = ${TZ}|g" /etc/php/8.3/apache2/php.ini || true

init_db
init_zm_db_conf
enable_a2_conf zoneminder
enable_a2_mod rewrite
enable_a2_mod headers
enable_a2_mod expires
enable_a2_mod cgi

/usr/bin/zmpkg.pl start
apachectl -D FOREGROUND
