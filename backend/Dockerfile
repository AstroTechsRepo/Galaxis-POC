# ============================================================
# Galaxis POC — Backend Laravel
# Image PHP-FPM + nginx fusionnés via supervisord (simple, POC)
# ============================================================
FROM php:8.3-cli-alpine AS base

# ---- Dépendances système
RUN apk add --no-cache \
        bash curl git icu-dev libpq-dev libzip-dev oniguruma-dev \
        nginx supervisor postgresql-client \
    && docker-php-ext-install \
        bcmath intl mbstring opcache pcntl pdo pdo_pgsql zip \
    && pecl install redis \
    && docker-php-ext-enable redis opcache \
    && rm -rf /tmp/* /var/cache/apk/*

# ---- Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# ---- Copie composer + install (cache layer)
COPY composer.json composer.lock* ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction || true

# ---- Code applicatif
COPY . /var/www/html
RUN composer dump-autoload --optimize --no-dev || true \
    && mkdir -p storage/framework/{cache,sessions,views,testing} storage/logs bootstrap/cache \
    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R ug+rwx /var/www/html/storage /var/www/html/bootstrap/cache

# ---- Configuration nginx + php-fpm + supervisord
COPY docker/nginx.conf      /etc/nginx/nginx.conf
COPY docker/php-fpm.conf    /usr/local/etc/php-fpm.d/zz-galaxis.conf
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/entrypoint.sh   /usr/local/bin/entrypoint.sh

# php-fpm extension
RUN apk add --no-cache php83-fpm 2>/dev/null || true \
    && chmod +x /usr/local/bin/entrypoint.sh

# Healthcheck endpoint exposé via /api/health
EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
