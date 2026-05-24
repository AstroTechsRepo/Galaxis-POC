#!/usr/bin/env bash
# ============================================================
# configure-keycloak.sh
# IDEMPOTENT — relançable sans casser
# ============================================================
# Crée :
#   - Realm `galaxis` (si absent)
#   - Client public `galaxis-portal` avec PKCE S256 (si absent)
#   - Rôles realm : admin, user (si absents)
#   - Users de démo Atelier Marchand (5) + comptes hérités (2)
#   - Assignation du rôle admin/user à chaque user
# Toutes les actions sont protégées par un check d'existence préalable.
# ============================================================
set -euo pipefail

# ---- Variables (overridables via env)
# v1.1 : Keycloak est derrière caddy-iam en HTTPS (CA Caddy interne).
# Le portail React est sur app-caddy HTTPS également.
# CURL_INSECURE=1 (utilisé par scripts/bootstrap.sh) bypass la vérif TLS
# pour les certs émis par la CA Caddy locale.
KC_URL="${KC_URL:-https://localhost:8443}"
KC_BOOTSTRAP_ADMIN_USERNAME="${KC_BOOTSTRAP_ADMIN_USERNAME:-${KC_ADMIN:-admin}}"
KC_BOOTSTRAP_ADMIN_PASSWORD="${KC_BOOTSTRAP_ADMIN_PASSWORD:-${KC_ADMIN_PASSWORD:-}}"
REALM="${KC_REALM:-galaxis}"
CLIENT_ID="${KC_CLIENT_ID:-galaxis-portal}"
PUBLIC_ORIGIN="${PUBLIC_ORIGIN:-https://localhost:9443}"

# Mot de passe commun pour TOUS les comptes de démo Atelier Marchand
# (jamais commité dans .env — documenté dans LIVRAISON.md et demo-guide.md)
DEMO_PASSWORD="${DEMO_PASSWORD:-Demo2026!}"

# Hérités v1.0 — gardés en compatibilité, écraseront si DEMO_USER_*_PASSWORD défini
DEMO_USER_LUCAS_PASSWORD="${DEMO_USER_LUCAS_PASSWORD:-${DEMO_PASSWORD}}"
DEMO_USER_ADMIN_PASSWORD="${DEMO_USER_ADMIN_PASSWORD:-${DEMO_PASSWORD}}"

# Source .env si présent à la racine du projet
if [ -f "$(dirname "$0")/../../.env" ]; then
  # shellcheck disable=SC1090
  set -a; . "$(dirname "$0")/../../.env"; set +a
  # Compat env Phase A (KC_BOOTSTRAP_ADMIN_*) ↔ Phase C (KC_ADMIN_*)
  KC_BOOTSTRAP_ADMIN_USERNAME="${KC_BOOTSTRAP_ADMIN_USERNAME:-${KC_ADMIN:-admin}}"
  KC_BOOTSTRAP_ADMIN_PASSWORD="${KC_BOOTSTRAP_ADMIN_PASSWORD:-${KC_ADMIN_PASSWORD:-}}"
fi

if [ -z "${KC_BOOTSTRAP_ADMIN_PASSWORD}" ]; then
  echo "[configure-keycloak] ERREUR : KC_ADMIN_PASSWORD (ou KC_BOOTSTRAP_ADMIN_PASSWORD) doit être défini (env ou .env)" >&2
  exit 1
fi

# ---- Options curl (TLS strict par défaut, --insecure si CURL_INSECURE=1)
CURL_OPTS=(-fsS)
[ "${CURL_INSECURE:-0}" = "1" ] && CURL_OPTS+=(--insecure)

# ---- Helpers
log()  { printf "\033[36m[configure-keycloak]\033[0m %s\n" "$*"; }
warn() { printf "\033[33m[configure-keycloak]\033[0m %s\n" "$*"; }
err()  { printf "\033[31m[configure-keycloak]\033[0m %s\n" "$*" >&2; }
ok()   { printf "\033[32m[configure-keycloak]\033[0m %s\n" "$*"; }

# ---- 1) Récupère un token admin
log "Authentification admin sur ${KC_URL}…"
TOKEN_RESP=$(curl "${CURL_OPTS[@]}" -X POST "${KC_URL}/realms/master/protocol/openid-connect/token" \
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
HTTP=$(curl "${CURL_OPTS[@]}" -o /dev/null -w "%{http_code}" "${KC_URL}/admin/realms/${REALM}" "${AUTH[@]}" || true)
if [ "${HTTP}" = "404" ]; then
  log "Création du realm '${REALM}'…"
  curl "${CURL_OPTS[@]}" -X POST "${KC_URL}/admin/realms" "${AUTH[@]}" \
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
CLIENT_LIST=$(curl "${CURL_OPTS[@]}" "${KC_URL}/admin/realms/${REALM}/clients?clientId=${CLIENT_ID}" "${AUTH[@]}")
if printf '%s' "${CLIENT_LIST}" | grep -q '"clientId":"'"${CLIENT_ID}"'"'; then
  ok "Client '${CLIENT_ID}' existe déjà"
else
  log "Création du client public '${CLIENT_ID}' (PKCE S256)…"
  curl "${CURL_OPTS[@]}" -X POST "${KC_URL}/admin/realms/${REALM}/clients" "${AUTH[@]}" \
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

# ---- 4) Rôles realm : admin, user (idempotent)
upsert_realm_role() {
  local role_name="$1"
  local description="$2"

  log "Vérification rôle realm '${role_name}'…"
  local http_code
  http_code=$(curl "${CURL_OPTS[@]}" -o /dev/null -w "%{http_code}" \
    "${KC_URL}/admin/realms/${REALM}/roles/${role_name}" "${AUTH[@]}" || true)

  if [ "${http_code}" = "404" ]; then
    log "Création rôle '${role_name}'…"
    curl "${CURL_OPTS[@]}" -X POST "${KC_URL}/admin/realms/${REALM}/roles" "${AUTH[@]}" \
      -d "{ \"name\": \"${role_name}\", \"description\": \"${description}\" }"
    ok "Rôle '${role_name}' créé"
  else
    ok "Rôle '${role_name}' existe déjà"
  fi
}

upsert_realm_role "admin" "Administrateur Galaxis — accès complet"
upsert_realm_role "user"  "Utilisateur Galaxis — accès standard"

# ---- 5) Helper : crée ou met à jour un user, puis assigne un rôle realm
upsert_user() {
  local username="$1"
  local email="$2"
  local first="$3"
  local last="$4"
  local password="$5"
  local role="${6:-user}"   # par défaut "user", peut être "admin"

  log "Vérification user '${username}' (rôle ${role})…"
  local list
  list=$(curl "${CURL_OPTS[@]}" "${KC_URL}/admin/realms/${REALM}/users?username=${username}&exact=true" "${AUTH[@]}")
  local id
  id=$(printf '%s' "${list}" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -n1)

  if [ -z "${id}" ]; then
    log "Création user '${username}'…"
    curl "${CURL_OPTS[@]}" -X POST "${KC_URL}/admin/realms/${REALM}/users" "${AUTH[@]}" \
      -d "{
        \"username\": \"${username}\",
        \"email\": \"${email}\",
        \"emailVerified\": true,
        \"firstName\": \"${first}\",
        \"lastName\": \"${last}\",
        \"enabled\": true,
        \"credentials\": [{ \"type\": \"password\", \"value\": \"${password}\", \"temporary\": false }]
      }"
    # Re-lookup pour récupérer l'id fraîchement créé
    list=$(curl "${CURL_OPTS[@]}" "${KC_URL}/admin/realms/${REALM}/users?username=${username}&exact=true" "${AUTH[@]}")
    id=$(printf '%s' "${list}" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -n1)
    ok "User '${username}' créé (id=${id})"
  else
    log "User '${username}' existe (id=${id}) — reset password (idempotent)"
    curl "${CURL_OPTS[@]}" -X PUT "${KC_URL}/admin/realms/${REALM}/users/${id}/reset-password" "${AUTH[@]}" \
      -d "{ \"type\": \"password\", \"value\": \"${password}\", \"temporary\": false }"
    ok "Password de '${username}' réinitialisé"
  fi

  # Assignation du rôle realm (idempotent : Keycloak ignore les ajouts redondants)
  log "Assignation rôle '${role}' à '${username}'…"
  local role_repr
  role_repr=$(curl "${CURL_OPTS[@]}" "${KC_URL}/admin/realms/${REALM}/roles/${role}" "${AUTH[@]}")
  curl "${CURL_OPTS[@]}" -X POST "${KC_URL}/admin/realms/${REALM}/users/${id}/role-mappings/realm" "${AUTH[@]}" \
    -d "[${role_repr}]" >/dev/null
  ok "Rôle '${role}' assigné à '${username}'"
}

# ---- 6) Users de démo « Atelier Marchand » (TPE menuiserie 5 personnes — slide 05)
upsert_user "marc"   "marc@atelier-marchand.demo"   "Marc"   "Marchand" "${DEMO_PASSWORD}" "admin"
upsert_user "sophie" "sophie@atelier-marchand.demo" "Sophie" "Lemoine"  "${DEMO_PASSWORD}" "user"
upsert_user "julien" "julien@atelier-marchand.demo" "Julien" "Petit"    "${DEMO_PASSWORD}" "user"
upsert_user "chloe"  "chloe@atelier-marchand.demo"  "Chloé"  "Dubois"   "${DEMO_PASSWORD}" "user"
upsert_user "admin"  "admin@galaxis.demo"           "Admin"  "Galaxis"  "${DEMO_PASSWORD}" "admin"

# ---- 7) Comptes historiques (compatibilité avec la doc v1.0 initiale)
upsert_user "lucas-test" "lucas-test@galaxis.local" "Lucas" "Test"  "${DEMO_USER_LUCAS_PASSWORD}" "user"
upsert_user "admin-test" "admin-test@galaxis.local" "Admin" "Test"  "${DEMO_USER_ADMIN_PASSWORD}" "admin"

ok "Configuration Keycloak terminée — realm='${REALM}', client='${CLIENT_ID}', 5 users démo + 2 hérités"
