FROM php:8.4-fpm

#
# ===== 1) OSパッケージ =====
#
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libzip-dev \
    libonig-dev \
    libgmp-dev \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*


#
# ===== 2) PHP標準拡張（docker-php-ext-install） =====
#
RUN docker-php-ext-install \
    mbstring \
    bcmath \
    pcntl \
    exif \
    calendar \
    sysvmsg \
    sysvsem \
    sysvshm \
    intl \
    gmp \
    curl \
    pdo_mysql \
    zip \
    sodium


#
# ===== 3) GD =====
#
RUN docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    --with-webp=/usr/include/ \
  && docker-php-ext-install gd


#
# ===== 4) Redis（PECL） =====
#
RUN pecl install redis \
  && docker-php-ext-enable redis


#
# ===== 5) プロジェクト固有の拡張追加用ブロック =====
# ここに追加拡張を追記するだけで良いように余白を確保。
#
# 例:
# RUN pecl install xdebug \
#   && docker-php-ext-enable xdebug
#
# RUN docker-php-ext-install sockets
# RUN docker-php-ext-install pcov
# RUN pecl install grpc
# RUN pecl install imagick


#
# ===== 6) php.ini =====
#
COPY php.ini /usr/local/etc/php/php.ini

