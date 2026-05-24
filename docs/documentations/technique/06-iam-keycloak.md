# 06 — IAM Keycloak

> **Audience** : devops, admin IAM · **Source** : `infrastructure/scripts/configure-keycloak.sh`, `docker-compose.yml` service `keycloak`

---

## Vue d'ensemble

Keycloak 25 joue le rôle de **fournisseur d'identité** (IdP) unique du POC. Il :
- héberge la base utilisateurs et leurs credentials
- expose un endpoint OIDC standard (`/iam/realms/galaxis/.well-known/openid-configuration`)
- émet des JWT (access_token / id_token) signés RS256
- publie les clés publiques JWKS sur `/iam/realms/galaxis/protocol/openid-connect/certs`

---

## Variables d'environnement Keycloak (`docker-compose.yml`)

| Variable | Valeur | Raison |
|---|---|---|
| `KC_DB` | `postgres` | DB managée par notre Postgres dédié |
| `KC_DB_URL` | `jdbc:postgresql://iam-db:5432/keycloak` | nom du service dans le réseau iam-net |
| `KC_BOOTSTRAP_ADMIN_USERNAME` | `admin` (par défaut) | utilisateur admin initial |
| `KC_BOOTSTRAP_ADMIN_PASSWORD` | depuis `.env` | défini une fois au premier boot |
| `KC_HTTP_RELATIVE_PATH` | `/iam` | toutes les routes Keycloak sont préfixées `/iam` (cohérent avec le routing Caddy) |
| `KC_PROXY` | `edge` | Keycloak sait qu'il est derrière un reverse proxy |
| `KC_HOSTNAME` | `localhost` | hostname exposé aux URLs OIDC |
| `KC_HOSTNAME_STRICT` | `false` | tolère les variations (sinon casserait avec tunnel SSH) |
| `KC_HOSTNAME_STRICT_HTTPS` | `false` | on est en HTTP local |
| `KC_HEALTH_ENABLED` | `true` | active `/iam/health/ready` |
| `KC_HTTP_ENABLED` | `true` | écoute HTTP sur 8080 |

Lancement : `start --optimized --http-enabled=true`

---

## Realm `galaxis`

Créé par `configure-keycloak.sh`. Options notables :

```json
{
  "realm": "galaxis",
  "enabled": true,
  "displayName": "Galaxis",
  "sslRequired": "external",
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
    "http://localhost:8080/auth/callback",
    "http://localhost:8080/*"
  ],
  "webOrigins": ["http://localhost:8080"],
  "attributes": {
    "pkce.code.challenge.method": "S256",
    "post.logout.redirect.uris": "http://localhost:8080/##http://localhost:8080/*"
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

| Username | Email | Password | Rôles |
|---|---|---|---|
| `lucas-test` | lucas-test@galaxis.local | `demo` | (aucun rôle realm explicite — joue Sarah / utilisateur final) |
| `admin-test` | admin-test@galaxis.local | `demo` | (idem, pour démontrer un 2e user) |

> ⚠️ **Mot de passe `demo` réservé au POC.** Pour la prod, créez les users via la console admin et utilisez les politiques de password Keycloak (longueur min, complexité, …).

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
1. S'auth contre `master/admin-cli` avec `KC_BOOTSTRAP_ADMIN_USERNAME` + `KC_BOOTSTRAP_ADMIN_PASSWORD`
2. Crée le realm si absent (`404` sur GET /admin/realms/galaxis)
3. Crée le client si absent
4. Upsert les 2 users démo (create + set password si absent, sinon reset password)

---

## Configurer un nouveau user (admin)

### Via la console admin

1. Tunnel SSH : `ssh -L 8080:127.0.0.1:8080 user@vm`
2. Ouvrir `http://localhost:8080/iam/admin`
3. Login `admin / <KC_BOOTSTRAP_ADMIN_PASSWORD>`
4. Select realm `galaxis`
5. Menu **Users → Add user**
6. Renseigner username/email, **enabled=true**, **email verified=true**
7. Onglet **Credentials → Set password** (cocher temporary=false pour ne pas forcer le changement)

### Via l'API REST (scriptable)

```bash
TOKEN=$(curl -s -X POST \
  "http://localhost:8080/iam/realms/master/protocol/openid-connect/token" \
  -d "grant_type=password" -d "client_id=admin-cli" \
  -d "username=admin" -d "password=$KC_BOOTSTRAP_ADMIN_PASSWORD" | jq -r .access_token)

curl -X POST "http://localhost:8080/iam/admin/realms/galaxis/users" \
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
  "http://localhost:8080/iam/realms/galaxis/protocol/openid-connect/token" \
  -d "grant_type=password" -d "client_id=galaxis-portal" \
  -d "username=lucas-test" -d "password=demo" | jq -r .access_token)

# Décoder le payload (lecture seule, ne vérifie pas la signature)
echo $ACCESS | cut -d. -f2 | base64 -d 2>/dev/null | jq .

# Tester contre /api/me
curl -fsS http://localhost:8080/api/me -H "Authorization: Bearer $ACCESS" | jq .
```

> Le grant `password` est désactivé dans la config par défaut (`directAccessGrantsEnabled: false`). Pour le test ci-dessus, activez-le temporairement dans la console admin.

---

## Liens internes
- Flow OIDC complet : [07-flow-oidc-jwt.md](./07-flow-oidc-jwt.md)
- Sécurité : [09-securite.md](./09-securite.md)
- Architecture : [01-architecture-poc.md](./01-architecture-poc.md)
