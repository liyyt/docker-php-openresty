FROM alpine:3.10
LABEL maintainer="Jethro Hicks <jethro@hicksinspace.com>"

ARG RESTY_IMAGE_BASE="alpine"
ARG RESTY_IMAGE_TAG="3.10"
ARG RESTY_VERSION="1.15.8.2"
ARG RESTY_OPENSSL_VERSION="1.1.1d"
ARG RESTY_PCRE_VERSION="8.43"
ARG RESTY_J="1"
ARG RESTY_CONFIG_OPTIONS="\
    --with-compat \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-mail \
    --with-mail_ssl_module \
    --with-pcre-jit \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    "
ARG RESTY_CONFIG_OPTIONS_MORE=""
ARG RESTY_LUAJIT_OPTIONS="--with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT'"


ARG RESTY_ADD_PACKAGE_BUILDDEPS=""
ARG RESTY_ADD_PACKAGE_RUNDEPS=""
ARG RESTY_EVAL_PRE_CONFIGURE=""
ARG RESTY_EVAL_POST_MAKE=""


# These are not intended to be user-specified
#ARG _RESTY_CONFIG_DEPS="--with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}"

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-pcre \
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/openresty/pcre/include -I/usr/local/openresty/openssl/include' \
    --with-ld-opt='-L/usr/local/openresty/pcre/lib -L/usr/local/openresty/openssl/lib -Wl,-rpath,/usr/local/openresty/pcre/lib:/usr/local/openresty/openssl/lib' \
    "

LABEL resty_image_base="${RESTY_IMAGE_BASE}"
LABEL resty_image_tag="${RESTY_IMAGE_TAG}"
LABEL resty_version="${RESTY_VERSION}"
LABEL resty_openssl_version="${RESTY_OPENSSL_VERSION}"
LABEL resty_pcre_version="${RESTY_PCRE_VERSION}"
LABEL resty_config_options="${RESTY_CONFIG_OPTIONS}"
LABEL resty_config_options_more="${RESTY_CONFIG_OPTIONS_MORE}"
LABEL resty_config_deps="${_RESTY_CONFIG_DEPS}"
LABEL resty_add_package_builddeps="${RESTY_ADD_PACKAGE_BUILDDEPS}"
LABEL resty_add_package_rundeps="${RESTY_ADD_PACKAGE_RUNDEPS}"
LABEL resty_eval_pre_configure="${RESTY_EVAL_PRE_CONFIGURE}"
LABEL resty_eval_post_make="${RESTY_EVAL_POST_MAKE}"

ENV PHP_INI_DIR /usr/local/etc/php

ENV PHP_EXTRA_CONFIGURE_ARGS \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --disable-cgi \
    --enable-opcache \
    # --enable-opcache-jit \
    --with-zlib \
    # --enable-zip \
    --enable-json \
    --enable-sockets

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# Adds GNU HASH segments to generated executables (this is used if present, and is much faster than sysv hash; in this configuration, sysv hash is also generated)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

ENV GPG_KEYS 42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312

ENV PHP_VERSION 7.4.0RC6
ENV PHP_URL="https://downloads.php.net/~derick/php-7.4.0RC6.tar.xz" PHP_ASC_URL="https://downloads.php.net/~derick/php-7.4.0RC6.tar.xz.asc"
ENV PHP_SHA256="" PHP_MD5=""



# dependencies required for running "phpize"
# these get automatically installed and removed by "docker-php-ext-*" (unless they're already installed)
# persistent / runtime deps
ENV BUILD_DEPS \
    argon2-dev \
    autoconf \
    build-base \
    coreutils \
    curl-dev \
    dpkg-dev dpkg \
    file \
    g++ \
    gcc \
    gd-dev \
    geoip-dev \
    libc-dev \
    libedit-dev \
    libsodium-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    make \
    oniguruma-dev \
    openssl-dev \
    perl-dev \
    pkgconf \
    re2c \
    readline-dev \
    sqlite-dev \
    zlib-dev	

ENV PERSISTENT_DEPS \
    ca-certificates \
    # https://github.com/docker-library/php/issues/494
    # openssl \
    curl \
    tar \
    xz \
    freetype-dev \
    libmcrypt-dev \
    libjpeg-turbo-dev \
    libltdl \
    libpng-dev \
    icu-dev \
    gettext-dev \
    gd \
    geoip \
    libgcc \
    libxslt \
    zlib \
    supervisor

ENV PHP_EXT \
    gd \
    gettext \
    # iconv \
    # mbstring \
    # mcrypt \
    opcache \
    # pdo \
    pdo_mysql \
    mysqli \
    intl

# persistent / runtime deps
RUN apk upgrade --update; \
    apk add --no-cache \
        $PERSISTENT_DEPS 

# ensure www-data user exists
RUN set -eux; \
	addgroup -g 82 -S www-data; \
	adduser -u 82 -D -S -G www-data www-data
# 82 is the standard uid/gid for "www-data" in Alpine
# https://git.alpinelinux.org/aports/tree/main/apache2/apache2.pre-install?h=3.9-stable
# https://git.alpinelinux.org/aports/tree/main/lighttpd/lighttpd.pre-install?h=3.9-stable
# https://git.alpinelinux.org/aports/tree/main/nginx/nginx.pre-install?h=3.9-stable


RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
	[ ! -d /var/www/html ]; \
	mkdir -p /var/www/html; \
	chown www-data:www-data /var/www/html; \
	chmod 777 /var/www/html



RUN set -eux; \
	\
	apk add --no-cache --virtual .fetch-deps gnupg; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	curl -fsSL -o php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	if [ -n "$PHP_MD5" ]; then \
		echo "$PHP_MD5 *php.tar.xz" | md5sum -c -; \
	fi; \
	\
	if [ -n "$PHP_ASC_URL" ]; then \
		curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		done; \
		gpg --batch --verify php.tar.xz.asc php.tar.xz; \
		gpgconf --kill all; \
		rm -rf "$GNUPGHOME"; \
	fi; \
	\
	apk del --no-network .fetch-deps

COPY config/php/docker-php-ext-* \
    config/php/docker-php-entrypoint \ 
    config/php/docker-php-source \
    /usr/local/bin/

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$BUILD_DEPS \
	; \
	\
    cd /usr/src; \
    curl -fSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz ; \
    tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz; \
    cd openssl-${RESTY_OPENSSL_VERSION}; \
    if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.1" ] ; then \
        echo 'patching OpenSSL 1.1.1 for OpenResty'; \
        curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-1.1.1c-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi; \
    if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.0" ] ; then \
        echo 'patching OpenSSL 1.1.0 for OpenResty'; \
        curl -s https://raw.githubusercontent.com/openresty/openresty/ed328977028c3ec3033bc25873ee360056e247cd/patches/openssl-1.1.0j-parallel_build_fix.patch | patch -p1 ; \
        curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-1.1.0d-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi; \
    ./config \
      no-threads shared zlib -g \
      enable-ssl3 enable-ssl3-method \
      --prefix=/usr/local/openresty/openssl \
      --libdir=lib \
      -Wl,-rpath,/usr/local/openresty/openssl/lib \
    ; \
    make -j${RESTY_J}; \
    make -j${RESTY_J} install_sw; \
    cd /usr/src; \
    if [ -n "${RESTY_EVAL_PRE_CONFIGURE}" ]; then eval $(echo ${RESTY_EVAL_PRE_CONFIGURE}); fi ; \
    curl -fSL https://ftp.pcre.org/pub/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz ; \
    tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz ; \
    cd /usr/src/pcre-${RESTY_PCRE_VERSION}; \
    ./configure \
        --prefix=/usr/local/openresty/pcre \
        --disable-cpp \
        --enable-jit \
        --enable-utf \
        --enable-unicode-properties \
    ; \
    make -j${RESTY_J}; \
    make -j${RESTY_J} install; \
    cd /usr/src; \
    curl -fSL https://github.com/openresty/openresty/releases/download/v${RESTY_VERSION}/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz; \
    tar xzf openresty-${RESTY_VERSION}.tar.gz; \
    cd /usr/src/openresty-${RESTY_VERSION}; \
    eval ./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS_MORE} ${RESTY_LUAJIT_OPTIONS}; \
    make -j${RESTY_J}; \
    make -j${RESTY_J} install; \
    cd /usr/src; \
    if [ -n "${RESTY_EVAL_POST_MAKE}" ]; then eval $(echo ${RESTY_EVAL_POST_MAKE}); fi; \
	export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# make sure invalid --configure-flags are fatal errors intead of just warnings
		--enable-option-checking=fatal \
		\
# https://github.com/docker-library/php/issues/439
		--with-mhash \
		\
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
		--enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
# https://wiki.php.net/rfc/argon2_password_hash (7.2+)
		--with-password-argon2 \
# https://wiki.php.net/rfc/libsodium
		--with-sodium=shared \
# always build against system sqlite3 (https://github.com/php/php-src/commit/6083a387a81dbbd66d6316a3a12a63f06d5f7109)
		--with-pdo-sqlite=/usr \
		--with-sqlite3=/usr \
		\
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
		\
# in PHP 7.4+, the pecl/pear installers are officially deprecated (requiring an explicit "--with-pear") and will be removed in PHP 8+; see also https://github.com/docker-library/php/issues/846#issuecomment-505638494
		--with-pear \
		\
# bundled pcre does not support JIT on s390x
# https://manpages.debian.org/stretch/libpcre3-dev/pcrejit.3.en.html#AVAILABILITY_OF_JIT_SUPPORT
		$(test "$gnuArch" = 's390x-linux-musl' && echo '--without-pcre-jit') \
		\
		${PHP_EXTRA_CONFIGURE_ARGS:-} \
	; \
	make -j "$(nproc)"; \
	find -type f -name '*.a' -delete; \
	make install; \
	find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; \
	make clean; \
	\
# https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
	cp -v php.ini-* "$PHP_INI_DIR/"; \
    cd /; \
    docker-php-ext-install $PHP_EXT; \
    pecl install redis; \
# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
    docker-php-ext-enable redis sodium; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache $runDeps; \
    cd /usr/src; \
    curl -fsSL "https://getcomposer.org/installer" -o /usr/src/installer; \
    php /usr/src/installer; \
    mv /usr/src/composer.phar /usr/local/bin/composer; \
    rm -rf \
        openssl-${RESTY_OPENSSL_VERSION}.tar.gz openssl-${RESTY_OPENSSL_VERSION} \
        openresty-${RESTY_VERSION}.tar.gz openresty-${RESTY_VERSION} \
        pcre-${RESTY_PCRE_VERSION}.tar.gz pcre-${RESTY_PCRE_VERSION} \
        /usr/src/installer \
    ; \
    apk del --no-network .build-deps; \
    ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log; \
    ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log; \
    mkdir -p /var/log/supervisor; \
    mkdir -p /var/cache/nginx/microcache; \
	\
# update pecl channel definitions https://github.com/docker-library/php/issues/443
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc; \
    docker-php-source delete; \
# smoke test
	php --version;
    # openresty -v;

ENTRYPOINT ["docker-php-entrypoint"]

WORKDIR /var/www/html

RUN set -eux; \
	cd /usr/local/etc; \
	if [ -d php-fpm.d ]; then \
		# for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	else \
		# PHP 5.x doesn't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
		mkdir php-fpm.d; \
		cp php-fpm.conf.default php-fpm.d/www.conf; \
		{ \
			echo '[global]'; \
			echo 'include=etc/php-fpm.d/*.conf'; \
		} | tee php-fpm.conf; \
	fi; \
	{ \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; echo '; https://github.com/docker-library/php/pull/725#issuecomment-443540114'; echo 'log_limit = 8192'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
		echo 'decorate_workers_output = no'; \
	} | tee php-fpm.d/docker.conf; \
	{ \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = 9000'; \
	} | tee php-fpm.d/zz-docker.conf


COPY config/php/php.development.ini /usr/local/etc/php/php.ini
COPY config/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY config/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY config/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

COPY config/nginx/includes /usr/local/openresty/nginx/conf/includes
COPY config/nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY config/nginx/nginx.vh.default.conf /etc/nginx/conf.d/default.conf
COPY config/supervisord.conf /etc/supervisord.conf

# Add additional binaries into PATH for convenience
ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE 9000
CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
# STOPSIGNAL SIGQUIT