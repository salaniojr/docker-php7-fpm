#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM debian:jessie

# persistent / runtime deps
ENV PHPIZE_DEPS \
		autoconf \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkg-config \
		re2c
RUN apt-get update && apt-get install -y \
		$PHPIZE_DEPS \
		ca-certificates \
		curl \
		libedit2 \
		libsqlite3-0 \
		libxml2 \
		xz-utils \
		libdb5.3-dev \
		libbz2-dev \
		libpng12-dev \
		libldap2-dev \
		libexpat1-dev \
		libssl-dev \
		libxml2-dev \
		libyaml-dev \
		libdb-dev \
		libmysqlclient-dev \
		openssl \
		libcurl4-openssl-dev \
		libreadline6-dev \
		librecode-dev \
		librecode0 \
		libxml2 \
		bzip2 \
		libxslt1-dev \
		libxslt1.1 \
		expat \
		gettext \
		cvs \
		libjpeg-dev \
		libfreetype6 \
		libfreetype6-dev \
		libpam0g-dev \
		libkrb5-dev \
		libmemcached-dev \
		libmhash-dev \
		build-essential \
		pkg-config \
		libpcre3 \
		libpcre3-dev \
	--no-install-recommends && rm -r /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d

##<autogenerated>##
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data
##</autogenerated>##

ENV GPG_KEYS 1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763

#ICU
WORKDIR /opt
RUN curl -SL "http://downloads.sourceforge.net/project/icu/ICU4C/52.1/icu4c-52_1-src.tgz?r=http%3A%2F%2Fapps.icu-project.org%2Ficu-jsp%2FdownloadSection.jsp%3Fver%3D52.1%26base%3Dcs%26svn%3Drelease-52-1&ts=1471401810&use_mirror=ufpr" -o icu.tar.gz
RUN tar -xvf icu.tar.gz
RUN rm icu.tar.gz
WORKDIR /opt/icu/source
RUN ./configure --prefix=/opt/icu && make && make install

WORKDIR /opt

RUN mkdir /usr/include/freetype2/freetype
RUN ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h

ENV PHP_VERSION 7.0.10
ENV PHP_FILENAME php-7.0.10.tar.xz
ENV PHP_SHA256 348476ff7ba8d95a1e28e1059430c10470c5f8110f6d9133d30153dda4cdf56a

RUN set -xe \
	&& cd /usr/src \
	&& curl -fSL "https://secure.php.net/get/$PHP_FILENAME/from/this/mirror" -o php.tar.xz \
	&& echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c - \
	&& curl -fSL "https://secure.php.net/get/$PHP_FILENAME.asc/from/this/mirror" -o php.tar.xz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& for key in $GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done \
	&& gpg --batch --verify php.tar.xz.asc php.tar.xz \
	&& rm -r "$GNUPGHOME"

COPY docker-php-source /usr/local/bin/

RUN set -xe \
	&& buildDeps=" \
		$PHP_EXTRA_BUILD_DEPS \
		libcurl4-openssl-dev \
		libedit-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
	" \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& docker-php-source extract \
	&& cd /usr/src/php \
	&& ./configure \
	    --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        $PHP_EXTRA_CONFIGURE_ARGS \
        --disable-cgi \
        --enable-mysqlnd \
        --enable-sysvmsg \
        --enable-wddx \
        --enable-zip \
        --enable-bcmath \
        --enable-calendar \
        --enable-dba=shared \
        --enable-exif \
        --enable-ftp \
        --enable-gd-native-ttf \
        --enable-intl \
        --with-icu-dir=/opt/icu \
        --with-curl \
        --with-openssl=/usr/ \
        --with-readline \
        --with-libdir=/lib/x86_64-linux-gnu \
        --with-zlib \
        --with-bz2 \
        --with-yaml \
        --with-xsl \
        --with-libexpat-dir=lib/x86_64-linux-gnu \
        --with-cdb \
        --with-flatfile \
        --with-inifile \
        --with-db4 \
        --with-gettext \
        --with-gd \
        --with-jpeg \
        --with-png \
        --with-freetype-dir=/lib/x86_64-linux-gnu \
        --enable-gd-native-ttf \
        --with-ldap \
        --enable-mbstring \
        --with-mhash \
        --with-mysql \
        --with-mysqli \
        --with-pdo-mysql \
        --with-libedit \
        --enable-shmop \
        --enable-soap \
        --enable-sockets \
	&& make -j"$(nproc)" \
	&& make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
	&& make clean \
	&& docker-php-source delete \
	\
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

COPY docker-php-ext-* /usr/local/bin/

##<autogenerated>##
WORKDIR /var/www/html

RUN set -ex \
	&& cd /usr/local/etc \
	&& if [ -d php-fpm.d ]; then \
		# for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	else \
		# PHP 5.x don't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
		mkdir php-fpm.d; \
		cp php-fpm.conf.default php-fpm.d/www.conf; \
		{ \
			echo '[global]'; \
			echo 'include=etc/php-fpm.d/*.conf'; \
		} | tee php-fpm.conf; \
	fi \
	&& { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = [::]:9000'; \
	} | tee php-fpm.d/zz-docker.conf


COPY php-fpm.conf /usr/local/etc/php-fpm.conf
#COPY php.ini /usr/local/php/php.ini
COPY run.sh /usr/bin/docker-startup.sh
RUN chmod +x /usr/bin/docker-startup.sh

WORKDIR /opt
RUN mkdir nginx
WORKDIR nginx
RUN curl -SL "http://nginx.org/download/nginx-1.11.3.tar.gz" -o nginx.tar.gz
RUN tar xvzf nginx.tar.gz
WORKDIR nginx-1.11.3
RUN ./configure
RUN make
RUN make install

COPY nginx.conf /usr/local/nginx/conf/nginx.conf

WORKDIR /

RUN apt-get update && apt-get install -y git

RUN curl -SL "https://getcomposer.org/composer.phar" -o composer.phar
RUN chmod +x composer.phar
RUN mv composer.phar /usr/bin/composer

RUN rm /usr/local/nginx/html/index.html
RUN echo "<?php phpinfo(); ?>" >> /usr/local/nginx/html/index.php

RUN mkdir /www
RUN ln -s /usr/local/nginx/html/ www/public

EXPOSE 80

ENTRYPOINT ["/usr/bin/docker-startup.sh"]