# Changelog

Toutes les évolutions notables du projet Galaxis POC. Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) et le versioning [SemVer](https://semver.org/lang/fr/).

---

## [v1.1-conteneurise] — 2026-05-24

### 🐳 Phase C — Architecture 100% conteneurisée alignée slides

Refactor majeur de la couche infra pour se conformer strictement aux slides de soutenance (10, 12, 13, 15, A01).

#### Changed (breaking)

- **docker-compose.yml** : réécriture complète → **11 conteneurs running** + 1 conteneur one-shot `frontend-builder`. Remplace l'ancien compose avec Caddy unique + HTTP.
- **3 Caddy frontaux** (un par tier) avec `tls internal` (CA Caddy locale, certs auto-générés persistés dans volumes nommés) : `caddy-iam`, `app-caddy`, `caddy-services`
- **HTTPS partout** via CA Caddy locale (ports loopback `127.0.0.1:8443/9443/10443/11443`)
- **Keycloak v26** (upgrade depuis 25.0), exposé derrière `caddy-iam` avec `KC_PROXY=edge`, `KC_HOSTNAME_PORT=8443`
- **React = build statique** dans le volume `galaxis-frontend-build`, servi par `app-caddy` (plus de conteneur React running)
- **backend/Dockerfile** : multi-stage composer + php:8.3-fpm-alpine (plus de nginx/supervisord embarqués)
- **frontend/Dockerfile** : multi-stage node build → alpine rsync → volume nommé
- **scripts/bootstrap.sh** : orchestre wait-keycloak + configure-keycloak + migrate + seed (idempotent)
- **Makefile** : refait pour Phase C avec targets `up`, `demo`, `bootstrap`, `nuke`, `ca`, etc.
- **configure-keycloak.sh** : URLs par défaut `https://localhost:8443` et `https://localhost:9443`, support `CURL_INSECURE=1` pour CA locale
- **Frontend oidc.ts** : authority = `VITE_KC_URL/realms/galaxis` (URL absolue, plus de sous-chemin `/iam`)
- **Laravel config** : `oidc.base_internal` = `http://keycloak:8080` (sans `/iam`), `cors` = `https://localhost:9443`

#### Removed

- Ancien `Caddyfile` racine unique + `frontend/Caddyfile`
- Anciens compose split `deployments/{iam,app,services,proxy}/docker-compose.yml`
- nginx.conf + supervisord.conf embarqués dans le backend Dockerfile

#### Unchanged (réutilisé tel quel)

- Code applicatif Laravel (middleware JWT, services, contrôleurs, modèles, migrations, seeders)
- Code applicatif React (composants, pages, hooks, styles, DA tokens)
- Playbooks Ansible (`00-prereqs` reste utile pour préparer une VM)
- 3 documentations livrables (technique, projet, utilisateur) — mises à jour pour refléter la nouvelle archi
- Factories, DemoSeeder, tests Pest, tests Vitest

---

## [v1.0-soutenance] — 2026-05-24

### 🚀 Version POC livrable au jury ESGI

#### Phase B (24 mai 2026) — Seeding données de démo

- **Scénario démo « Atelier Marchand »** : TPE de menuiserie 5 personnes, aligné avec le persona Marc (slide 05)
- **5 comptes alignés Keycloak ↔ Laravel** : `marc` (admin), `sophie` (user), `julien` (user), `chloe` (user), `admin` (admin) — mot de passe partagé `Demo2026!`, jamais commité
- **2 rôles realm Keycloak** créés : `admin`, `user` (idempotents)
- **Migration** `add_role_to_users` : colonne `role` (string 32 indexée nullable)
- **Middleware ValidateJwt** : extraction automatique du rôle depuis `realm_access.roles` au login (admin prime sur user)
- **Factories** : `UserFactory`, `AuditLogFactory` (5 states : loginSuccess, loginFailure, logout, tokenRefresh, accessDenied)
- **DemoSeeder** : 5 users explicites (upsert sur username pour idempotence) + ~24 audit_logs distribués sur 7 jours, biais jours ouvrés / 9h-19h
- **Make targets** : `make seed` (Keycloak + Laravel), `make demo` refactoré en `up + seed`
- **9 tests Pest** `DemoSeederTest` : 5 users, rôles, fenêtre 8j, idempotence, payloads JSON
- **Docs mises à jour** : `LIVRAISON.md`, `demo-guide.md`, `technique/04-installation.md`, `README.md`

C'est la version livrée pour la soutenance du 26 juin 2026.

#### Added

- **Architecture POC** : mono-VM Debian, 11 conteneurs Docker, 3 réseaux isolés (galaxis-iam-net, app-net, services-net)
- **Reverse proxy unique** Caddy 2.8 sur `127.0.0.1:8080` (loopback only)
- **Backend Laravel 11** :
  - Middleware JWT custom : validation RS256 contre JWKS Keycloak
  - Service JwksService avec cache Redis (TTL 5 min, refresh on miss kid)
  - Endpoints : `/api/health` (public), `/api/me`, `/api/audit` (JWT protégés)
  - Modèles User (sync depuis JWT) et AuditLog (event/ip/UA/payload JSON)
  - Migrations idempotentes
  - 11 tests Pest couvrant tous les cas de validation JWT
- **Frontend React 18 + Vite + TS + Tailwind** :
  - DA Galaxis (palette violet/blue/space, gradient bleu→violet)
  - Client OIDC `oidc-client-ts` avec PKCE S256
  - Hook `useAuth` avec gestion des events
  - Pages : Landing, LoginRedirect, Callback, Dashboard, Profile, NotFound
  - Composants : OrbBackground, Logo, Header, Footer, LoginButton, BrickCard, ClaimsTable
  - 4 fichiers de tests Vitest avec coverage v8
  - Build statique servi par Caddy alpine
- **IAM Keycloak 25** :
  - Realm `galaxis` avec brute force protection
  - Client public `galaxis-portal` avec PKCE S256
  - Users de démo `lucas-test` et `admin-test`
  - Script `configure-keycloak.sh` 100% idempotent
- **Briques services** :
  - Vaultwarden 1.32.4 (`SIGNUPS_ALLOWED=false`)
  - Nextcloud 30 (`OVERWRITEWEBROOT=/cloud`, trusted_proxies)
  - Postgres dédié pour chaque brique
- **Déploiement Ansible** : 4 playbooks idempotents
  - `00-prereqs.yml` : OS, Docker, swap, UFW, fail2ban, code clone
  - `01-iam.yml` : stack IAM + script Keycloak
  - `02-app.yml` : stack APP + migrations
  - `03-services.yml` : stack services + proxy + smoke test
- **Documentations livrables** : 3 docs complètes pour le jury ESGI
  - Technique : 10 chapitres (~ 5 000 lignes Markdown)
  - Projet : 9 chapitres (~ 3 000 lignes)
  - Utilisateur : 8 chapitres adaptés au persona Marc TPE non-tech
- **Outillage** : Makefile avec 12 targets, EXPLORATION.md, LIVRAISON.md
- **Sécurité** :
  - 0 secret commité
  - CORS strict sur `APP_URL`
  - Headers Caddy (X-Content-Type-Options, X-Frame-Options, Referrer-Policy)
  - Audit log centralisé table `audit_logs`

#### Decisions

- **HTTP en interne + tunnel SSH pour la démo** (vs TLS local) : cf. EXPLORATION.md D1
- **Login local pour Vaultwarden/Nextcloud** (SSO bout-en-bout = OUT scope POC)
- **Tokens en sessionStorage** (vs localStorage) pour limiter exposition XSS

#### Out of scope (documenté pour v2.0)

- SSO bout-en-bout vers Vaultwarden et Nextcloud
- MFA Keycloak
- RBAC fin par groupe (Karim peut gérer son équipe)
- Multi-tenant
- Page admin Galaxis maison
- Migration cloud AWS effective
- IaC Terraform, CI/CD GitHub Actions
- TLS Let's Encrypt en POC
- Monitoring (Prometheus/Loki)

---

## Historique des commits Phase 0 → 10

(extrait `git log --oneline`)

```
chore: validation finale POC v1.0 prêt livraison
docs: readme racine + guide démo + livraison
docs(utilisateur): guide utilisateur TPE complet (8 chapitres)
docs(projet): documentation projet complète (9 chapitres)
docs(technique): documentation technique complète (10 chapitres)
feat(infra): ansible playbooks idempotents + inventory
feat(services): vaultwarden + nextcloud + intégration dashboard
feat(frontend): vite + react + tailwind + DA tokens
feat(backend): endpoints API + migrations + audit log
feat(backend): laravel skeleton + middleware JWT
feat(iam): keycloak realm + config idempotente + users démo
feat(infra): caddy reverse-proxy unique + 3 réseaux docker
chore: scaffold complet du repo
docs: exploration des slides et synthèse périmètre
chore: initial state - slides and brief
```

---

## Jalons à venir (cf. roadmap projet 09)

- **v1.1-cloud** (T3 2026) — Migration AWS multi-VPC, ECS Fargate, RDS Multi-AZ
- **v2.0-sso** (T4 2026) — SSO bout-en-bout Vaultwarden + Nextcloud, page admin Galaxis
- **v2.5-bricks** (S1 2027) — VPN souverain, messagerie Matrix, IA interne
- **v3.0-suite** (S2 2027) — Multi-tenant, SCIM, marketplace de briques
