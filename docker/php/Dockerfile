FROM php:8.5-fpm

# ===== OSパッケージ =====
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libzip-dev \
    libgmp-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libfreetype-dev \
    libicu-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# ===== PHP拡張 =====
# mbstring / curl / sodium / opcache は php:8.5-fpm に同梱済み
RUN docker-php-ext-install \
    bcmath pcntl exif calendar sockets \
    sysvmsg sysvsem sysvshm intl gmp \
    pdo_mysql zip

# ===== GD =====
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
  && docker-php-ext-install gd

# ===== Redis（PIE: PECL の後継） =====
COPY --from=ghcr.io/php/pie:bin /pie /usr/local/bin/pie
RUN pie install phpredis/phpredis:~6.3

# ===== Composer =====
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# ===== プロジェクト固有の拡張追加用ブロック =====
# ここに追加拡張を追記するだけで良いように余白を確保。


# ===== php.ini =====
COPY php.ini /usr/local/etc/php/php.ini
