# 06 — IAM Keycloak

> **Audience** : devops, admin IAM · **Source** : `infrastructure/scripts/configure-keycloak.sh`, `docker-compose.yml` service `keycloak`

---

## Vue d'ensemble

Keycloak 26 joue le rôle de **fournisseur d'identité** (IdP) unique du POC. Il :
- héberge la base utilisateurs et leurs credentials
- expose un endpoint OIDC standard (`/realms/galaxis/.well-known/openid-configuration`)
- émet des JWT (access_token / id_token) signés RS256
- publie les clés publiques JWKS sur `/realms/galaxis/protocol/openid-connect/certs`

---

## Variables d'environnement Keycloak (`docker-compose.yml`)

| Variable | Valeur | Raison |
|---|---|---|
| `KC_DB` | `postgres` | DB managée par notre Postgres dédié |
| `KC_DB_URL` | `jdbc:postgresql://keycloak-db:5432/keycloak` | nom du service dans le réseau iam-net |
| `KEYCLOAK_ADMIN` | `admin` (via `KC_ADMIN` dans `.env`) | utilisateur admin initial |
| `KEYCLOAK_ADMIN_PASSWORD` | depuis `.env` (`KC_ADMIN_PASSWORD`) | défini une fois au premier boot |
| `KC_HOSTNAME` | `http://localhost:8080` | URL complète exposée aux endpoints OIDC |
| `KC_HOSTNAME_STRICT` | `false` | tolère les variations (sinon casserait avec tunnel SSH) |
| `KC_HEALTH_ENABLED` | `true` | active `/health/ready` |
| `KC_HTTP_ENABLED` | `true` | écoute HTTP sur 8080 |

Lancement : `start-dev`

---

## Realm `galaxis`

Créé par `configure-keycloak.sh`. Options notables :

```json
{
  "realm": "galaxis",
  "enabled": true,
  "displayName": "Galaxis",
  "sslRequired": "none",
  "registrationAllowed": false,
  "loginWithEmailAllowed": true,
  "rememberMe": true,
  "resetPasswordAllowed": false,
  "bruteForceProtected": true,
  "accessTokenLifespan": 1800,
  "ssoSessionIdleTimeout": 3600,
  "ssoSessionMaxLifespan": 36000
}
```

| Option | Valeur | Raison |
|---|---|---|
| `registrationAllowed` | `false` | pas d'auto-inscription (admin gère) |
| `bruteForceProtected` | `true` | blocage temporaire après échecs |
| `resetPasswordAllowed` | `false` | dans le POC, l'admin gère les resets (à activer en prod) |
| `accessTokenLifespan` | 1800s (30 min) | bon compromis sécurité/UX |
| `ssoSessionIdleTimeout` | 3600s (1 h) | refresh token utilisable 1h après dernière activité |
| `ssoSessionMaxLifespan` | 36000s (10 h) | session max sur un jour de bureau |

---

## Client public `galaxis-portal`

Créé par `configure-keycloak.sh`. Configuration :

```json
{
  "clientId": "galaxis-portal",
  "publicClient": true,
  "standardFlowEnabled": true,
  "directAccessGrantsEnabled": false,
  "implicitFlowEnabled": false,
  "serviceAccountsEnabled": false,
  "redirectUris": [
    "http://localhost:9080/auth/callback",
    "http://localhost:9080/*"
  ],
  "webOrigins": ["http://localhost:9080"],
  "attributes": {
    "pkce.code.challenge.method": "S256",
    "post.logout.redirect.uris": "http://localhost:9080/##http://localhost:9080/*"
  }
}
```

| Choix | Pourquoi |
|---|---|
| `publicClient: true` | Le navigateur ne peut pas stocker un secret en sécurité → client public + PKCE |
| `standardFlowEnabled` | Authorization Code (le seul flow OIDC recommandé pour SPA) |
| `directAccessGrantsEnabled: false` | On bloque l'envoi de password depuis le client (anti-phishing) |
| `implicitFlowEnabled: false` | Déprécié OAuth2.1, jamais utilisé en SPA moderne |
| `pkce.code.challenge.method: S256` | PKCE obligatoire pour clients publics depuis OAuth 2.1 |
| `webOrigins: [...]` | CORS strict côté Keycloak |

---

## Users de démo

### Comptes "Atelier Marchand" (scénario principal)

| Username | Email | Password | Rôle |
|---|---|---|---|
| `marc` | marc@atelier-marchand.demo | `Demo2026!` | `admin` |
| `sophie` | sophie@atelier-marchand.demo | `Demo2026!` | `user` |
| `julien` | julien@atelier-marchand.demo | `Demo2026!` | `user` |
| `chloe` | chloe@atelier-marchand.demo | `Demo2026!` | `user` |
| `admin` | admin@galaxis.demo | `Demo2026!` | `admin` |

### Comptes historiques (rétro-compatibilité)

| Username | Email | Password |
|---|---|---|
| `lucas-test` | lucas-test@galaxis.local | `Demo2026!` |
| `admin-test` | admin-test@galaxis.local | `Demo2026!` |

> **Attention** : **mot de passe `Demo2026!` réservé au POC.** Pour la prod, créez les users via la console admin et utilisez les politiques de password Keycloak (longueur min, complexité, ...).

Le script `upsert_user()` est idempotent : à chaque relance il vérifie l'existence puis reset le password (utile si vous changez le mot de passe dans `.env`).

---

## Comment relancer la configuration ?

```bash
# Variante 1 : via make
make configure-keycloak

# Variante 2 : direct
./infrastructure/scripts/configure-keycloak.sh
```

Le script :
1. S'auth contre `master/admin-cli` avec `KEYCLOAK_ADMIN` + `KEYCLOAK_ADMIN_PASSWORD`
2. Crée le realm si absent (`404` sur GET /admin/realms/galaxis)
3. Crée le client si absent
4. Upsert les 7 users démo (5 Atelier Marchand + 2 historiques)

---

## Configurer un nouveau user (admin)

### Via la console admin

1. Tunnel SSH : `ssh -L 8080:127.0.0.1:8080 user@vm`
2. Ouvrir `http://localhost:8080/admin`
3. Login `admin / <KC_ADMIN_PASSWORD>`
4. Select realm `galaxis`
5. Menu **Users → Add user**
6. Renseigner username/email, **enabled=true**, **email verified=true**
7. Onglet **Credentials → Set password** (cocher temporary=false pour ne pas forcer le changement)

### Via l'API REST (scriptable)

```bash
TOKEN=$(curl -s -X POST \
  "http://localhost:8080/realms/master/protocol/openid-connect/token" \
  -d "grant_type=password" -d "client_id=admin-cli" \
  -d "username=admin" -d "password=$KC_ADMIN_PASSWORD" | jq -r .access_token)

curl -X POST "http://localhost:8080/admin/realms/galaxis/users" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"username":"sophie","email":"sophie@tpe.fr","enabled":true,
       "credentials":[{"type":"password","value":"<change-me>","temporary":false}]}'
```

---

## Customiser les claims dans le JWT

Par défaut, Keycloak met dans `access_token` :
- `sub`, `preferred_username`, `email`, `email_verified`, `given_name`, `family_name`
- `iss`, `aud`, `iat`, `exp`, `azp`, `session_state`
- `realm_access.roles`, `resource_access`

Pour ajouter un **claim custom** (ex : department), ajoutez un **mapper** :

1. Console admin → Clients → galaxis-portal → onglet **Client scopes**
2. Choisir `galaxis-portal-dedicated`
3. Onglet **Mappers → Add mapper → User attribute**
4. Remplir : `Name=department`, `User Attribute=department`, `Token Claim Name=department`, types cochés

Le claim apparaîtra dans tous les tokens émis ensuite.

---

## Vérifier qu'un token est valide

```bash
# Récupérer un token via le flow direct (DEV uniquement, désactivé en prod)
ACCESS=$(curl -s -X POST \
  "http://localhost:8080/realms/galaxis/protocol/openid-connect/token" \
  -d "grant_type=password" -d "client_id=galaxis-portal" \
  -d "username=marc" -d "password=Demo2026!" | jq -r .access_token)

# Décoder le payload (lecture seule, ne vérifie pas la signature)
echo $ACCESS | cut -d. -f2 | base64 -d 2>/dev/null | jq .

# Tester contre /api/me
curl -fsS http://localhost:9080/api/me -H "Authorization: Bearer $ACCESS" | jq .
```

> Le grant `password` est désactivé dans la config par défaut (`directAccessGrantsEnabled: false`). Pour le test ci-dessus, activez-le temporairement dans la console admin.

---

## Liens internes
- Flow OIDC complet : [07-flow-oidc-jwt.md](./07-flow-oidc-jwt.md)
- Sécurité : [09-securite.md](./09-securite.md)
- Architecture : [01-architecture-poc.md](./01-architecture-poc.md)
