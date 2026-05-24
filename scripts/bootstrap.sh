#!/usr/bin/env bash
# ============================================================
# Galaxis POC v1.1 — bootstrap.sh
# Idempotent. Lance la séquence complète post `docker compose up` :
#   1. Attente que Keycloak soit healthy
#   2. Configuration Keycloak (realm + client + rôles + 5 users)
#   3. Migrations Laravel (artisan migrate)
#   4. Seed démo Laravel (DemoSeeder : 5 users + ~24 audit_logs)
#
# Rejouable sans risque : chaque étape vérifie son état avant d'agir.
# ============================================================
set -euo pipefail

# ---- Couleurs
C="\033[36m"; G="\033[32m"; Y="\033[33m"; R="\033[31m"; X="\033[0m"
log() { printf "${C}[bootstrap]${X} %s\n" "$*"; }
ok()  { printf "${G}[bootstrap]${X} %s\n" "$*"; }
warn(){ printf "${Y}[bootstrap]${X} %s\n" "$*"; }
err() { printf "${R}[bootstrap]${X} %s\n" "$*" >&2; }

# ---- Variables (source .env si présent)
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ -f "${ROOT_DIR}/.env" ]; then
  # shellcheck disable=SC1090,SC1091
  set -a; . "${ROOT_DIR}/.env"; set +a
fi

# Endpoint de health Keycloak — exposé par caddy-iam en HTTPS sur 8443
KC_HEALTH_URL="${KC_HEALTH_URL:-https://localhost:8443/health/ready}"
MAX_WAIT="${MAX_WAIT:-240}"
DOCKER_COMPOSE="${DOCKER_COMPOSE:-docker compose}"

# ============================================================
# 1) Attente Keycloak
# ============================================================
log "Attente que Keycloak soit READY (timeout ${MAX_WAIT}s)…"
start=$(date +%s)
while true; do
  if curl -fsS --insecure -o /dev/null --connect-timeout 3 "${KC_HEALTH_URL}" 2>/dev/null; then
    ok "Keycloak READY"
    break
  fi
  now=$(date +%s)
  elapsed=$((now - start))
  if [ "${elapsed}" -ge "${MAX_WAIT}" ]; then
    err "Timeout après ${MAX_WAIT}s en attendant ${KC_HEALTH_URL}"
    err "Vérifie : docker compose logs keycloak caddy-iam"
    exit 2
  fi
  printf "."
  sleep 4
done

# ============================================================
# 2) Configuration Keycloak (realm + client + rôles + users)
# ============================================================
log "Lancement de configure-keycloak.sh (idempotent)…"

# Le script tourne en HOST mode (utilise les ports loopback) — on lui passe
# le KC_URL public via env. Il utilise déjà DEMO_PASSWORD pour le mot de passe.
KC_URL="https://localhost:8443" \
PUBLIC_ORIGIN="${PUBLIC_ORIGIN:-https://localhost:9443}" \
KC_BOOTSTRAP_ADMIN_USERNAME="${KC_ADMIN:-admin}" \
KC_BOOTSTRAP_ADMIN_PASSWORD="${KC_ADMIN_PASSWORD}" \
KC_REALM="${KC_REALM:-galaxis}" \
KC_CLIENT_ID="${KC_CLIENT_ID:-galaxis-portal}" \
DEMO_PASSWORD="${DEMO_PASSWORD:-Demo2026!}" \
CURL_INSECURE=1 \
  "${ROOT_DIR}/infrastructure/scripts/configure-keycloak.sh"

ok "Keycloak configuré (realm + client + rôles + 5 users démo)"

# ============================================================
# 3) Migrations Laravel
# ============================================================
log "Migrations Laravel (artisan migrate --force)…"
${DOCKER_COMPOSE} exec -T app-php php artisan migrate --force --no-interaction
ok "Migrations OK"

# ============================================================
# 4) Seed démo (5 users Atelier Marchand + ~24 audit_logs)
# ============================================================
# Le seeder est rejouable : upsert sur username + purge des audit_logs
# des 5 users avant régénération. Pas besoin de migrate:fresh ici
# pour préserver les comptes éventuels créés via le flow OIDC réel.
log "Seed Laravel (DemoSeeder : 5 users + ~24 audit_logs)…"
${DOCKER_COMPOSE} exec -T app-php php artisan db:seed --class=DemoSeeder --force --no-interaction
ok "Seed démo OK"

# ============================================================
# 5) Sentinel d'idempotence (info uniquement)
# ============================================================
${DOCKER_COMPOSE} exec -T app-php sh -c 'mkdir -p /var/www/html/storage/bootstrap && date -u +%FT%TZ > /var/www/html/storage/bootstrap/last-bootstrap.txt'

ok "Bootstrap terminé."
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Galaxis POC v1.1 est prêt — scénario Atelier Marchand       ║"
echo "║                                                              ║"
echo "║  Depuis le laptop :                                          ║"
echo "║    ssh -L 8443:127.0.0.1:8443  -L 9443:127.0.0.1:9443  \\    ║"
echo "║        -L 10443:127.0.0.1:10443 -L 11443:127.0.0.1:11443 \\  ║"
echo "║        user@<vm-ip>                                          ║"
echo "║                                                              ║"
echo "║  Puis ouvrir dans le navigateur :                            ║"
echo "║    https://localhost:9443   → Portail Galaxis                ║"
echo "║    https://localhost:8443   → Keycloak admin                 ║"
echo "║    https://localhost:10443  → Vaultwarden                    ║"
echo "║    https://localhost:11443  → Nextcloud                      ║"
echo "║                                                              ║"
echo "║  Comptes démo : marc · sophie · julien · chloe · admin       ║"
echo "║  Mot de passe partagé : Demo2026!                            ║"
echo "║                                                              ║"
echo "║  ⚠ Warning navigateur 'certificat non reconnu' attendu       ║"
echo "║    (CA Caddy locale) — cliquer 'avancer'. Voir demo-guide.   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
