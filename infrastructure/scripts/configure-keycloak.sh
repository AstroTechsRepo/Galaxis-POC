#!/usr/bin/env bash
# ============================================================
# configure-keycloak.sh
# IDEMPOTENT — relançable sans casser
# ============================================================
# Crée :
#   - Realm `galaxis` (si absent)
#   - Client public `galaxis-portal` avec PKCE S256 (si absent)
#   - Users de démo : lucas-test, admin-test (si absents)
# Toutes les actions sont protégées par un check d'existence préalable.
# ============================================================
set -euo pipefail

# ---- Variables (overridables via env)
KC_URL="${KC_URL:-http://localhost:8080/iam}"
KC_BOOTSTRAP_ADMIN_USERNAME="${KC_BOOTSTRAP_ADMIN_USERNAME:-admin}"
KC_BOOTSTRAP_ADMIN_PASSWORD="${KC_BOOTSTRAP_ADMIN_PASSWORD:-}"
REALM="${KC_REALM:-galaxis}"
CLIENT_ID="${KC_CLIENT_ID:-galaxis-portal}"
PUBLIC_ORIGIN="${PUBLIC_ORIGIN:-http://localhost:8080}"

DEMO_USER_LUCAS_PASSWORD="${DEMO_USER_LUCAS_PASSWORD:-demo}"
DEMO_USER_ADMIN_PASSWORD="${DEMO_USER_ADMIN_PASSWORD:-demo}"

# Source .env si présent à la racine du projet
if [ -f "$(dirname "$0")/../../.env" ]; then
  # shellcheck disable=SC1090
  set -a; . "$(dirname "$0")/../../.env"; set +a
  KC_BOOTSTRAP_ADMIN_PASSWORD="${KC_BOOTSTRAP_ADMIN_PASSWORD:-}"
fi

if [ -z "${KC_BOOTSTRAP_ADMIN_PASSWORD}" ]; then
  echo "[configure-keycloak] ERREUR : KC_BOOTSTRAP_ADMIN_PASSWORD doit être défini (env ou .env)" >&2
  exit 1
fi

# ---- Helpers
log()  { printf "\033[36m[configure-keycloak]\033[0m %s\n" "$*"; }
warn() { printf "\033[33m[configure-keycloak]\033[0m %s\n" "$*"; }
err()  { printf "\033[31m[configure-keycloak]\033[0m %s\n" "$*" >&2; }
ok()   { printf "\033[32m[configure-keycloak]\033[0m %s\n" "$*"; }

# ---- 1) Récupère un token admin
log "Authentification admin sur ${KC_URL}…"
TOKEN_RESP=$(curl -fsS -X POST "${KC_URL}/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=admin-cli" \
  -d "username=${KC_BOOTSTRAP_ADMIN_USERNAME}" \
  -d "password=${KC_BOOTSTRAP_ADMIN_PASSWORD}")
TOKEN=$(printf '%s' "${TOKEN_RESP}" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')
if [ -z "${TOKEN}" ]; then
  err "Échec d'obtention du token admin. Vérifie KC_BOOTSTRAP_ADMIN_USERNAME/PASSWORD."
  exit 2
fi
ok "Token admin obtenu"

AUTH=(-H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json")

# ---- 2) Crée le realm s'il n'existe pas
log "Vérification du realm '${REALM}'…"
HTTP=$(curl -fso /dev/null -w "%{http_code}" "${KC_URL}/admin/realms/${REALM}" "${AUTH[@]}" || true)
if [ "${HTTP}" = "404" ]; then
  log "Création du realm '${REALM}'…"
  curl -fsS -X POST "${KC_URL}/admin/realms" "${AUTH[@]}" \
    -d "{
      \"realm\": \"${REALM}\",
      \"enabled\": true,
      \"displayName\": \"Galaxis\",
      \"sslRequired\": \"external\",
      \"registrationAllowed\": false,
      \"loginWithEmailAllowed\": true,
      \"rememberMe\": true,
      \"resetPasswordAllowed\": false,
      \"editUsernameAllowed\": false,
      \"bruteForceProtected\": true,
      \"accessTokenLifespan\": 1800,
      \"ssoSessionIdleTimeout\": 3600,
      \"ssoSessionMaxLifespan\": 36000
    }"
  ok "Realm '${REALM}' créé"
elif [ "${HTTP}" = "200" ]; then
  ok "Realm '${REALM}' existe déjà"
else
  err "Statut inattendu lors du check realm : ${HTTP}"; exit 3
fi

# ---- 3) Crée le client public PKCE s'il n'existe pas
log "Vérification du client '${CLIENT_ID}'…"
CLIENT_LIST=$(curl -fsS "${KC_URL}/admin/realms/${REALM}/clients?clientId=${CLIENT_ID}" "${AUTH[@]}")
if printf '%s' "${CLIENT_LIST}" | grep -q '"clientId":"'"${CLIENT_ID}"'"'; then
  ok "Client '${CLIENT_ID}' existe déjà"
else
  log "Création du client public '${CLIENT_ID}' (PKCE S256)…"
  curl -fsS -X POST "${KC_URL}/admin/realms/${REALM}/clients" "${AUTH[@]}" \
    -d "{
      \"clientId\": \"${CLIENT_ID}\",
      \"name\": \"Galaxis Portal\",
      \"enabled\": true,
      \"publicClient\": true,
      \"standardFlowEnabled\": true,
      \"directAccessGrantsEnabled\": false,
      \"implicitFlowEnabled\": false,
      \"serviceAccountsEnabled\": false,
      \"protocol\": \"openid-connect\",
      \"redirectUris\": [
        \"${PUBLIC_ORIGIN}/auth/callback\",
        \"${PUBLIC_ORIGIN}/*\"
      ],
      \"webOrigins\": [\"${PUBLIC_ORIGIN}\"],
      \"attributes\": {
        \"pkce.code.challenge.method\": \"S256\",
        \"post.logout.redirect.uris\": \"${PUBLIC_ORIGIN}/##${PUBLIC_ORIGIN}/*\"
      }
    }"
  ok "Client '${CLIENT_ID}' créé"
fi

# ---- 4) Helper : crée ou met à jour un user
upsert_user() {
  local username="$1"
  local email="$2"
  local first="$3"
  local last="$4"
  local password="$5"

  log "Vérification user '${username}'…"
  local list
  list=$(curl -fsS "${KC_URL}/admin/realms/${REALM}/users?username=${username}&exact=true" "${AUTH[@]}")
  local id
  id=$(printf '%s' "${list}" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -n1)

  if [ -z "${id}" ]; then
    log "Création user '${username}'…"
    curl -fsS -X POST "${KC_URL}/admin/realms/${REALM}/users" "${AUTH[@]}" \
      -d "{
        \"username\": \"${username}\",
        \"email\": \"${email}\",
        \"emailVerified\": true,
        \"firstName\": \"${first}\",
        \"lastName\": \"${last}\",
        \"enabled\": true,
        \"credentials\": [{ \"type\": \"password\", \"value\": \"${password}\", \"temporary\": false }]
      }"
    ok "User '${username}' créé"
  else
    log "User '${username}' existe (id=${id}) — reset password (idempotent)"
    curl -fsS -X PUT "${KC_URL}/admin/realms/${REALM}/users/${id}/reset-password" "${AUTH[@]}" \
      -d "{ \"type\": \"password\", \"value\": \"${password}\", \"temporary\": false }"
    ok "Password de '${username}' réinitialisé"
  fi
}

# ---- 5) Users de démo
upsert_user "lucas-test" "lucas-test@galaxis.local" "Lucas"  "Test"  "${DEMO_USER_LUCAS_PASSWORD}"
upsert_user "admin-test" "admin-test@galaxis.local" "Admin"  "Test"  "${DEMO_USER_ADMIN_PASSWORD}"

ok "Configuration Keycloak terminée — realm='${REALM}', client='${CLIENT_ID}', 2 users de démo"
