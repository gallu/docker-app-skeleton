FROM php:8.4-fpm

# ===== OSパッケージ =====
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

# ===== PHP拡張 =====
RUN docker-php-ext-install \
    mbstring bcmath pcntl exif calendar \
    sysvmsg sysvsem sysvshm intl gmp curl \
    pdo_mysql zip sodium

# ===== GD =====
RUN docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    --with-webp=/usr/include/ \
  && docker-php-ext-install gd

# ===== Redis =====
RUN pecl install redis && docker-php-ext-enable redis

# ===== Composer =====
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# ===== プロジェクト固有の拡張追加用ブロック =====
# ここに追加拡張を追記するだけで良いように余白を確保。


# ===== php.ini =====
COPY php.ini /usr/local/etc/php/php.ini
