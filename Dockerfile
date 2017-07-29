FROM php:7-fpm-alpine

# install php extensions as required in https://xenforo.com/help/installation/
# note: We use mysqlnd client library with mysqli extensions.
# see http://php.net/manual/en/mysqli.installation.php
RUN apk add --update freetype libpng libjpeg-turbo && \
  apk add --virtual .build-dep gcc make autoconf libc-dev freetype-dev libpng-dev libjpeg-turbo-dev pcre-dev && \
  pecl install apcu && \
  docker-php-ext-enable apcu opcache && \
  docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  docker-php-ext-configure mysqli --with-mysqli && \
  docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" gd mysqli && \
  apk del .build-dep && \
  rm -rf /var/cache/apk/*

COPY docker-php-entrypoint /usr/local/bin/

# ¶ separated list of lines will be added to /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini
ENV APC_CONFIGS='apc.shm_size=96M¶apc.entries_hint=26000' \
# ¶ separated list of string in format "X|Y" will be passed to: sed -i /usr/local/etc/php-fpm.d/www.conf -e "s|^[; ]*X|Y|"
    WWW_CONFIGS='pm.max_children = .*|pm.max_children = 200¶pm.start_servers = |;pm.start_servers = ¶pm.min_spare_servers = .*|pm.min_spare_servers = 5¶pm.max_spare_servers = .*|pm.max_spare_servers = 25¶;pm.status_path = .*|pm.status_path = /status¶;ping.path = .*|ping.path = /ping'
