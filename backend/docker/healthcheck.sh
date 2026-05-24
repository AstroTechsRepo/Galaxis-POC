#!/usr/bin/env bash
# Galaxis POC v1.1 — healthcheck php-fpm
# Utilise cgi-fcgi (paquet fcgi) pour pinger /ping côté FPM
set -e
SCRIPT_NAME=/ping \
SCRIPT_FILENAME=/ping \
REQUEST_METHOD=GET \
cgi-fcgi -bind -connect 127.0.0.1:9000 \
  | grep -q 'pong'
