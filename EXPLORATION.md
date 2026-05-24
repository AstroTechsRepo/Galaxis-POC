# EXPLORATION — Synthèse du brief et décisions de cadrage

> Document produit en Phase 0. Source de verite = slides de soutenance.

---

## 1. Le produit en 3 phrases

**GALAXIS** est l'orchestrateur souverain d'AstroTechs pour TPE françaises (1 à 20 personnes, secteur services, sans équipe IT). Il déploie un écosystème open source (IAM Keycloak, mots de passe Vaultwarden, drive Nextcloud) accessible derrière un portail unique avec SSO OIDC. Le POC est un déploiement mono-VM ; la cible est un déploiement AWS multi-VPC (slide 11).

Tagline : **« One core. Infinite orbits. »**

---

## 2. Personas et rôles (slides 5 et 6)

| Persona | Rôle | Spécificités |
|---|---|---|
| **Marc DUBREUIL** | Dirigeant-opérateur, 41 ans, Lyon, 12 personnes, 10 SaaS, 850€/mois | Décide de l'achat. Pas de DSI. Persona acheteur. |
| **Sarah LEMOINE** | Développeuse web, 28 ans | Utilisatrice quotidienne. SSO le matin, accès à tout. |
| **Karim BENALI** | Lead développeur, 35 ans | Constitue les équipes projet, gère les accès. |

Audience de la doc utilisateur = **Marc** (peu technique).

---

## 3. Validation marché (slide 4 — enquête de terrain)

- **500 répondants**, Avril 2026
- **Intérêt** : 4,02/5
- **Prêts à investir** : 36,8%
- **Satisfaction des outils actuels** : 3,58/5
- **Besoin n°1** : centralisation (79% le placent en tête, 393 votes)
- **Cible confirmée** : TPE & indépendants (268/500)

---

## 4. Périmètre POC (slide 7)

### IN scope — implémenté
- Portail GALAXIS (React)
- Login OIDC PKCE
- IAM Keycloak centralisé
- Vaultwarden (passwords)
- Nextcloud (drive)
- 3 réseaux Docker isolés
- Validation JWT serveur
- Déploiement Ansible scripté

### OUT of scope — conçu mais non implémenté
- SSO bout-en-bout vers les services métier
- MFA, RBAC fin
- Provisioning auto utilisateur
- Multi-tenant
- Monitoring (Prometheus/Loki)
- Migration cloud AWS effective
- IaC Terraform, CI/CD GitHub Actions
- TLS Let's Encrypt (prévu pour la prod cible)

### Hors-périmètre absolu
- Démarchage commercial, business plan détaillé, conformité DORA/NIS2, support 24/7

---

## 5. Direction artistique extraite des slides

### Couleurs (CSS variables — slide 01)
```css
--violet-dark:  #542669;
--violet-mid:   #7B3E97;
--violet-glow:  #A76EC8;
--blue-dark:    #127DC2;
--blue-light:   #07A9DD;
--blue-glow:    #60D5FF;
--space-black:  #07060D;
--space-deep:   #0D0B1A;
--space-card:   #14112A;
--space-hover:  #1A1638;
```

### Gradient signature
```css
background: linear-gradient(135deg,
  #07A9DD 0%, #60D5FF 25%, #A76EC8 60%, #7B3E97 100%);
```

### Typographie
- **Display / headings** : `Space Grotesk` (300 → 700)
- **Body** : `Inter` (300 → 700)
- **Mono** : `JetBrains Mono` (400, 500)

### Motifs visuels
- Fond `--space-deep` avec orbites circulaires en bordure subtile
- Étoiles SVG cross + dots blancs translucides
- Glassmorphism léger sur cartes (backdrop-blur)
- Sphères / orbes floutées en arrière-plan (effet espace)

### Identité texte
- Tagline : **One core. Infinite orbits.**
- Sous-titre : *L'orchestrateur souverain de votre écosystème open source*
- Signature : `Lucas PEREZ · ESGI 2 · Campus Éductive · 2025 / 2026`

---

## 6. Architecture technique POC (slide 10 — adaptée)

> **Attention :** La slide 10 originale parlait de « HTTPS TLS · CA locale · ports :443 :8443 :9443 :10443 ». Decision de cadrage : simplification pour la demo en **HTTP via tunnel SSH** (cf. section 7).

**Stack** :
- Backend : **Laravel 11** + PostgreSQL 16 + Redis 7
- Middleware custom **JWT RS256 contre JWKS Keycloak** (cache Redis 5 min)
- Frontend : **React 18 + Vite + TS + Tailwind + shadcn/ui**, client OIDC `oidc-client-ts`
- IAM : **Keycloak 25+** (realm `galaxis`, client public `galaxis-portal` PKCE)
- Briques : **Vaultwarden**, **Nextcloud** (login local autonome dans le POC)
- Infra : **Docker Compose** + **Caddy 2** en reverse proxy unique
- Déploiement : **Ansible** (4 playbooks idempotents)

**3 réseaux Docker isolés** :
- `galaxis-iam-net` : Keycloak + sa Postgres
- `galaxis-app-net` : Laravel + sa Postgres + Redis + frontend statique
- `galaxis-services-net` : Vaultwarden + Nextcloud + sa Postgres
- `app-php` est sur `app-net` **et** `iam-net` (pour valider les JWT contre JWKS)
- Caddy est sur les 3 réseaux (routeur unique)

---

## 7. Contrainte de démo (la plus importante)

**Lucas démontre depuis son laptop via un tunnel SSH.** Cahier des charges :

1. Un seul tunnel SSH (court, simple)
2. Aucun certificat à importer
3. Aucune modification `/etc/hosts`
4. Aucun warning navigateur
5. Toutes les fonctionnalités accessibles via un seul point d'entrée
6. Démarrage en une commande

**Implémentation décidée** :
- **Pas de TLS** côté navigateur. Le tunnel SSH chiffre laptop↔VM.
- **Un seul port** : `127.0.0.1:8080` sur la VM (loopback uniquement)
- **Caddy en reverse proxy unique** qui route par chemin :
  - `/` → Portail React
  - `/api/*` → Backend Laravel
  - `/iam/*` → Keycloak (avec `KC_HTTP_RELATIVE_PATH=/iam`)
  - `/vault/*` → Vaultwarden
  - `/cloud/*` → Nextcloud
- Tunnel SSH : `ssh -L 8080:127.0.0.1:8080 user@<vm-ip>`
- Laptop : `http://localhost:8080`

**Discours jury** : *« Le tunnel SSH chiffre le trafic laptop ↔ VM. En production cible AWS, Caddy + Let's Encrypt prennent le relais (voir slide 11). Ne pas confondre POC démo locale et déploiement prod. »*

---

## 8. Flow OIDC (slide 12 — Focus JWT)

1. User clique « Se connecter » sur le portail React
2. React (oidc-client-ts) génère `code_verifier` + `code_challenge` (PKCE S256) et redirige vers `/iam/realms/galaxis/protocol/openid-connect/auth`
3. Keycloak authentifie l'utilisateur, renvoie sur `/auth/callback?code=...`
4. React échange le `code` + `code_verifier` contre un `access_token` (JWT RS256) + `id_token` + `refresh_token`
5. React stocke les tokens en mémoire et appelle `/api/me` avec `Authorization: Bearer <access_token>`
6. Le middleware Laravel :
   - Récupère les JWKS via `http://keycloak:8080/iam/realms/galaxis/protocol/openid-connect/certs`
   - Cache la clé publique dans Redis (TTL 5 min, refresh on miss)
   - Vérifie signature RS256, `iss`, `aud`, `exp`, `nbf`
   - Insère/sync l'utilisateur en base au premier login
   - Log dans `audit_logs`
   - Renvoie les claims

---

## 9. Décisions prises (ambiguïtés du brief résolues)

| # | Ambiguïté | Décision |
|---|---|---|
| D1 | Slide 10 parle de TLS via CA Caddy mais le brief impose HTTP+SSH | **Brief gagne** : HTTP partout, SSH chiffre. Documenter dans la doc technique. |
| D2 | Le frontend React doit-il être servi par Vite (dev) ou nginx (prod) ? | **Build de prod servi par `caddy:file_server`** sur un container `app-front` (caddy alpine léger). Évite d'ajouter nginx. |
| D3 | Vaultwarden et Nextcloud doivent-ils avoir un vrai SSO ? | Non, **login local autonome** (cf. slide 7 : OUT scope POC). Les cartes du dashboard ouvrent juste les URLs. |
| D4 | Laravel : version exacte ? | **Laravel 11.x** (la plus récente LTS-style, PHP 8.3+) |
| D5 | Quel package PHP pour valider RS256 ? | `firebase/php-jwt` (le standard, mainteneur Google, supporte JWKS) |
| D6 | Stockage tokens côté front | **En mémoire** (variables React) — pas de localStorage pour limiter XSS. Refresh token dans cookie HttpOnly serait mieux mais hors scope POC. |
| D7 | Cache JWKS : Redis ou fichier ? | **Redis 7** (cohérent avec le reste, TTL 300s) |
| D8 | Nextcloud overwrite-* env | `OVERWRITEWEBROOT=/cloud`, `OVERWRITEPROTOCOL=http`, `OVERWRITEHOST=localhost:8080`, `TRUSTED_PROXIES=<caddy_ip_range>` |
| D9 | Test coverage | **≥ 60%** comme demandé (Pest + Vitest) |
| D10 | Quelle Debian | **Debian 13** (mais 12 reste supporté) — c'est l'OS du POC d'après le brief |

---

## 10. Plan d'exécution

J'enchaîne les phases 1 → 10 sans validation intermédiaire, **un commit par phase** (ou par sous-feature). Voir `CHANGELOG.md` à la fin.

Phase la plus critique : **Phase 8 — les 3 documentations**. Sans bâclage, elles sont remises au jury comme livrable formel.

---

## 11. Métriques de succès

- 15 critères de fini cochés (cf. brief)
- 3 documentations complètes (27 chapitres + index)
- `make demo && make test && make lint` passe
- 0 secret commité
- Tag `v1.0-soutenance` posé
