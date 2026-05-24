#!/usr/bin/env bash
# Galaxis POC v1.1 — entrypoint php-fpm
set -euo pipefail

cd /var/www/html

# ---- Permissions storage/cache (mount du repo en bind monte avec UID hôte)
chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true

# ---- APP_KEY auto-gen si absent (dev only)
if [ -z "${APP_KEY:-}" ]; then
  if [ "${APP_ENV:-production}" != "production" ] && [ -w .env ] 2>/dev/null; then
    php artisan key:generate --force --no-interaction || true
  fi
fi

# ---- Migrations idempotentes au boot (désactivable via RUN_MIGRATIONS=false)
if [ "${RUN_MIGRATIONS:-false}" = "true" ]; then
  echo "[entrypoint] Lancement des migrations…"
  php artisan migrate --force --no-interaction || true
fi

# ---- Caches de prod
if [ "${APP_ENV:-production}" = "production" ]; then
  php artisan config:cache || true
  php artisan route:cache  || true
  php artisan view:cache   || true
fi

exec "$@"
