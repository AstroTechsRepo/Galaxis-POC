#!/usr/bin/env bash
# ============================================================
# wait-for-keycloak.sh
# Attend que Keycloak réponde sur /iam/health/ready
# Utilisé par `make demo` avant configure-keycloak.sh
# ============================================================
set -euo pipefail

KC_HEALTH_URL="${KC_HEALTH_URL:-http://localhost:8080/iam/health/ready}"
MAX_WAIT="${MAX_WAIT:-180}"   # secondes

echo "[wait-for-keycloak] attente de ${KC_HEALTH_URL} (timeout ${MAX_WAIT}s)…"

start=$(date +%s)
while true; do
  if curl -fsS -o /dev/null --connect-timeout 2 "${KC_HEALTH_URL}" 2>/dev/null; then
    echo "[wait-for-keycloak] ✓ Keycloak READY"
    exit 0
  fi
  now=$(date +%s)
  elapsed=$((now - start))
  if [ "${elapsed}" -ge "${MAX_WAIT}" ]; then
    echo "[wait-for-keycloak] ✗ Timeout après ${MAX_WAIT}s" >&2
    exit 1
  fi
  printf "."
  sleep 3
done
