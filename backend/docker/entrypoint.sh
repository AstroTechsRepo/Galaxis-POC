#!/usr/bin/env bash
# Galaxis POC - entrypoint backend
set -euo pipefail

cd /var/www/html

# Génère APP_KEY si absent (dev/local seulement)
if [ -z "${APP_KEY:-}" ] && [ -f .env ]; then
  if ! grep -q "^APP_KEY=base64:" .env; then
    php artisan key:generate --force --no-interaction
  fi
fi

# Migrations idempotentes
if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
  echo "[entrypoint] Lancement des migrations…"
  php artisan migrate --force --no-interaction || true
fi

# Cache de config en prod
if [ "${APP_ENV:-production}" = "production" ]; then
  php artisan config:cache || true
  php artisan route:cache  || true
fi

exec "$@"
