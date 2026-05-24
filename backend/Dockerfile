# ============================================================
# Galaxis POC v1.1 — Backend Laravel (image PHP-FPM)
# Multi-stage : composer install (vendor) → runtime PHP 8.3-FPM
# Pas de serveur web embarqué — c'est app-caddy qui fait reverse
# proxy via php_fastcgi sur le port 9000 (FPM)
# ============================================================

# ============================================================
# STAGE 1 — vendor build (composer install, sans dépendances dev en prod)
# ============================================================
FROM composer:2.7 AS vendor

WORKDIR /app

# Copie uniquement les fichiers nécessaires à composer install
# pour maximiser le cache layer
COPY composer.json composer.lock* ./

# Install dépendances prod uniquement (--no-dev), optimisé pour la prod
RUN composer install \
        --no-dev \
        --no-scripts \
        --no-autoloader \
        --no-interaction \
        --prefer-dist \
    || true

# Copie le reste du code et regenere l'autoload optimisé
COPY . .
RUN composer dump-autoload --optimize --classmap-authoritative --no-dev || true

# ============================================================
# STAGE 2 — runtime PHP 8.3-FPM Alpine
# ============================================================
FROM php:8.3-fpm-alpine AS runtime

# ---- Métadonnées
LABEL org.opencontainers.image.title="galaxis-app-php" \
      org.opencontainers.image.description="Laravel 11 API derrière reverse proxy app-caddy" \
      org.opencontainers.image.version="1.1" \
      org.opencontainers.image.source="https://github.com/AstroTechsRepo/Galaxis-POC"

# ---- Dépendances système + extensions PHP
RUN apk add --no-cache \
        bash curl git icu-dev libpq-dev libzip-dev oniguruma-dev \
        libpng-dev freetype-dev libjpeg-turbo-dev \
        postgresql-client fcgi \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS autoconf g++ make \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath intl mbstring opcache pcntl pdo pdo_pgsql zip gd \
    && pecl install redis \
    && docker-php-ext-enable redis opcache \
    && apk del .build-deps \
    && rm -rf /tmp/* /var/cache/apk/*

# ---- Configuration PHP-FPM
COPY docker/www.conf /usr/local/etc/php-fpm.d/zz-galaxis.conf
COPY docker/php.ini  /usr/local/etc/php/conf.d/zz-galaxis.ini
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY docker/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/healthcheck.sh

WORKDIR /var/www/html

# ---- Copie code + vendor depuis le stage 1
COPY --from=vendor --chown=www-data:www-data /app /var/www/html

# ---- Permissions Laravel
RUN mkdir -p storage/framework/{cache,sessions,views,testing} storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R ug+rwx storage bootstrap/cache

# ---- Cache de prod (sera regénéré au boot si .env change)
RUN php artisan config:clear || true \
    && php artisan route:clear || true \
    && php artisan view:clear || true

# Port FPM
EXPOSE 9000

# ---- Healthcheck : utilise cgi-fcgi pour pinger /ping côté FPM
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=5 \
    CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "-F"]
