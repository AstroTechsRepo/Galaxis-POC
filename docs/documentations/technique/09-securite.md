# 09 — Sécurité

> **Audience** : RSSI, devops, sécurité applicative · **Source slides** : 15, 17

---

## Posture sécurité du POC

Le POC est **un environnement de démonstration**, pas une production. La sécurité est **proportionnée** :
- on applique les bonnes pratiques de base (zéro secret commité, PKCE, JWT validé serveur, isolation réseau)
- on documente explicitement ce qui est **OUT scope** pour ne pas tromper le jury
- on précise **où le POC diffère de la prod cible AWS** (chapitre 02)

---

## Modèle de menace simplifié

| Menace | Impact si réalisée | Mitigation POC | Mitigation prod (AWS) |
|---|---|---|---|
| Vol de session navigateur (XSS) | accès complet | tokens en `sessionStorage` (pas `localStorage`), CSP minimale, on ne fait pas confiance au front | + CSP stricte, CSRF token, cookie httpOnly secure samesite |
| Brute-force login | compte compromis | `bruteForceProtected: true` côté Keycloak | + WAF rules + rate limit ALB |
| Vol de token en transit | impersonation | tunnel SSH chiffre laptop↔VM | TLS 1.3 partout (ACM) |
| Compromis d'un service métier (Nextcloud, Vaultwarden) | pivot vers IAM | isolation réseau Docker, app-php seul pont vers IAM | + VPC isolés + SG restrictifs |
| Vol secret `.env` | DB et token Vaultwarden compromis | `.env` mode 0600, exclu de git, Ansible Vault pour le déploiement | + AWS Secrets Manager + KMS |
| Cassage d'une migration | downtime | migrations Laravel idempotentes, dumps DB avant | + RDS snapshot avant deploy, blue/green |
| Logs contenant des claims sensibles | leak via centralisation logs | on filtre les claims affichés (`MeController` ne retourne pas tout) | + redaction règles CloudWatch |
| Rotation clés Keycloak qui casse les sessions | downtime court | cache JWKS auto-refresh on miss kid | identique |

---

## Inventaire des secrets

Tous dans `.env` racine (mode `0600`, **jamais commité**).

| Secret | Usage | Rotation conseillée |
|---|---|---|
| `KC_BOOTSTRAP_ADMIN_PASSWORD` | admin Keycloak initial | au premier login (créer un autre admin, désactiver bootstrap) |
| `KC_DB_PASSWORD` | DB Keycloak | annuelle |
| `APP_DB_PASSWORD` | DB Laravel | annuelle |
| `APP_KEY` | Laravel encryption | annuelle (re-chiffre les données) |
| `REDIS_PASSWORD` | accès Redis | annuelle |
| `VAULTWARDEN_ADMIN_TOKEN` | panel admin Vaultwarden | trimestrielle |
| `NEXTCLOUD_DB_PASSWORD` | DB Nextcloud | annuelle |
| `NEXTCLOUD_ADMIN_PASSWORD` | admin Nextcloud | trimestrielle |
| Mots de passe demo `lucas-test` / `admin-test` | démo seulement | à supprimer avant prod |

---

## Comment vérifier qu'aucun secret n'est commité

```bash
# Grep simple
git grep -i -n 'password\s*=\|secret\s*=\|token\s*=' \
  | grep -v 'change-me\|<.*>\|example\|EXAMPLE\|"\?password"\?'

# Ou via gitleaks (recommandé)
docker run --rm -v $(pwd):/repo zricethezav/gitleaks:latest detect --source=/repo -v
```

Critère d'acceptation : **0 secret trouvé.**

---

## Validation JWT — checklist sécurité

| Contrôle | Implémenté ? | Où ? |
|---|:---:|---|
| Algorithme RS256 obligatoire (refuser `none`, `HS256`) | ✅ | `JwtValidator::validate()` |
| Signature vérifiée contre JWKS Keycloak | ✅ | `firebase/php-jwt` `JWT::decode()` |
| Issuer vérifié (`iss`) | ✅ | `JwtValidator` |
| Audience vérifiée (`aud`) | ✅ | `JwtValidator` |
| Expiration vérifiée (`exp`) | ✅ | `JWT::decode` + leeway 30s |
| Not-before vérifié (`nbf`) | ✅ | `JWT::decode` |
| `kid` du header utilisé pour sélectionner la clé | ✅ | `JwksService::getKeyForKid()` |
| Rotation clés gérée (refresh on miss) | ✅ | `JwksService` |
| Pas de stockage du JWT côté serveur | ✅ | stateless |
| Audit log centralisé | ✅ | `audit_logs` table |

---

## CORS

Le backend autorise **uniquement `APP_URL`** (par défaut `http://localhost:9080`).

```php
'allowed_origins' => [env('APP_URL', 'http://localhost:9080')],
'supports_credentials' => false,
```

Pas de wildcard, pas de localhost générique.

---

## Headers de sécurité (Caddy)

```caddyfile
header {
    X-Content-Type-Options "nosniff"
    X-Frame-Options "SAMEORIGIN"
    Referrer-Policy "strict-origin-when-cross-origin"
    -Server
}
```

**Attention** : **volontairement absents en POC** :
- `Strict-Transport-Security` (HSTS) : on est en HTTP en interne, HSTS forcerait HTTPS et casserait l'accès
- `Content-Security-Policy` strict : on garde laxe pour permettre le hot reload Vite en dev — à durcir pour la prod

Pour la prod cible AWS, ajouter :

```caddyfile
header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' fonts.googleapis.com; font-src fonts.gstatic.com; connect-src 'self'; frame-ancestors 'none'"
    X-Permitted-Cross-Domain-Policies "none"
    Permissions-Policy "geolocation=(), microphone=(), camera=()"
}
```

---

## Sécurité des conteneurs

| Pratique | POC | Production cible |
|---|:---:|:---:|
| Images Alpine (surface réduite) | ✅ | ✅ |
| Pinning de version (`postgres:16-alpine`) | ✅ | ✅ + SHA digest |
| `read-only` filesystem | ❌ | ✅ recommandé pour app-php |
| `no-new-privileges` | ❌ | ✅ |
| User non-root dans le conteneur | Partiel (Vaultwarden, Nextcloud officielles) | ✅ obligatoire partout |
| `cap_drop: [ALL]` | ❌ | ✅ |
| Scan vulnérabilités images (Trivy) | ❌ | ✅ en CI/CD |

> **Astuce** : pour durcir le POC, ajouter `security_opt: [no-new-privileges:true]` à chaque service applicatif.

---

## Brute-force / DoS

- **Keycloak** : `bruteForceProtected: true` (paramétrable dans realm settings)
- **SSH VM** : fail2ban actif, ban 10 min après 5 échecs (config par défaut)
- **Caddy** : pas de rate limit native — pour la prod, ajouter `caddy-ratelimit` ou utiliser le rate limit ALB AWS

---

## Audit log

Table `audit_logs` (cf. migration `2026_01_01_000002_create_audit_logs_table.php`) :

| Colonne | Contenu |
|---|---|
| `id` | clé primaire |
| `user_id` | foreign key vers users (nullable si rejet pré-auth) |
| `event` | string indexé (`auth.success`, `auth.rejected`) |
| `ip` | IPv4 ou IPv6 |
| `user_agent` | tronqué à 255 chars |
| `payload` | JSON (raison du rejet, route ciblée, sub, email) |
| `created_at` / `updated_at` | timestamps |

Endpoint `/api/audit` (protégé par JWT) liste les derniers événements pour le panel Profile.

**Attention** : volontairement basique — pour la prod, brancher CloudWatch / Loki avec rétention 90+ jours et alarmes (ex : > 10 `auth.rejected` du même IP en 1 min).

---

## Backup / récupération

Cf. chapitre [10-exploitation](./10-exploitation.md).

---

## Tâches OUT scope sécurité (documentées pour suite)

- MFA Keycloak (TOTP / WebAuthn) — slide 09
- RBAC fin (groupes, rôles métier mappés en claim)
- Provisioning auto utilisateurs (SCIM)
- Monitoring sécurité (Prometheus + alarmes)
- WAF
- Tests pénétration externes
- Conformité DORA / NIS2 (cf. slide 7 : hors-périmètre absolu)

---

## Liens internes
- Flow OIDC : [07-flow-oidc-jwt.md](./07-flow-oidc-jwt.md)
- Réseaux : [08-reseaux-docker.md](./08-reseaux-docker.md)
- Architecture cible : [02-architecture-cible.md](./02-architecture-cible.md)
