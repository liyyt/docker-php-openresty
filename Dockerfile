FROM php:5.6-fpm-alpine
MAINTAINER Jethro Hicks <jethro@liyyt.com>

ARG RESTY_VERSION="1.13.6.1"
ARG RESTY_OPENSSL_VERSION="1.0.2k"
ARG RESTY_PCRE_VERSION="8.41"
ARG RESTY_J="1"
ARG RESTY_CONFIG_OPTIONS="\
    --with-file-aio \
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
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-pcre-jit \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    "
ARG RESTY_CONFIG_OPTIONS_MORE=""

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}"

# persistent / runtime deps
ENV BUILD_DEPS \
    autoconf \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkgconf \
    re2c \
    build-base \
    curl \
    gd-dev \
    geoip-dev \
    libxslt-dev \
    linux-headers \
    perl-dev \
    readline-dev \
    zlib-dev

ENV PERSISTENT_DEPS \
    libmcrypt-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libltdl \
    libpng-dev \
    icu-dev \
    gettext-dev \
    gd \
    geoip \
    libgcc \
    libxslt \
    zlib

ENV PHP_EXT \
    gd \
    gettext \
    iconv \
    mbstring \
    mcrypt \
    opcache \
    pdo \
    pdo_mysql \
    mysqli

RUN set -xe \
    && apk upgrade --update \
	&& apk add --no-cache --virtual .build-deps $BUILD_DEPS \
    && apk add --no-cache --virtual .persistent-deps $PERSISTENT_DEPS \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install $PHP_EXT

RUN pecl install redis intl \
    && docker-php-ext-enable redis intl \
    && cd /tmp \
    && curl -fSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && curl -fSL https://ftp.pcre.org/pub/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz \
    && tar xzf openresty-${RESTY_VERSION}.tar.gz \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && ./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS_MORE} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && cd /tmp \
    && curl -fsSL "https://getcomposer.org/installer" -o /tmp/installer \
    && php /tmp/installer \
    && mv /tmp/composer.phar /usr/local/bin/composer \
    && rm -rf \
        openssl-${RESTY_OPENSSL_VERSION} \
        openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
        openresty-${RESTY_VERSION}.tar.gz openresty-${RESTY_VERSION} \
        pcre-${RESTY_PCRE_VERSION}.tar.gz pcre-${RESTY_PCRE_VERSION} \
        /tmp/installer \

    && apk del .build-deps \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

COPY config/php/php.development.ini /usr/local/etc/php/php.ini
COPY config/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY config/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY config/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

COPY config/nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY config/nginx/nginx.vh.default.conf /etc/nginx/conf.d/default.conf

# Add additional binaries into PATH for convenience
ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin


EXPOSE 9000

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
