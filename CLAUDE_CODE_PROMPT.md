# 🚀 Mission Claude Code — Construire le POC GALAXIS prêt à livrer

> Tu es **seul aux commandes**. Tu travailles en **mode autonome** : tu explores, tu décides, tu construis, tu testes, tu **documentes**, tu commits. Pas besoin de me demander à chaque étape — mais commit à chaque feature/phase pour la traçabilité.
>
> **Livraison attendue : un POC complet ET ses 3 documentations (technique, projet, utilisateur) prêtes à remettre au jury ESGI.**

---

## 🎯 Source de vérité absolue

**Tout ce que tu fais doit être aligné avec la présentation de soutenance.** C'est elle qui définit le scope, la DA, l'archi, le narratif, les contraintes.

### Slides à lire EN PREMIER, dans cet ordre

```
docs/soutenance/presentation/html/slides/01.html  → Couverture, DA générale
docs/soutenance/presentation/html/slides/02.html  → AstroTechs
docs/soutenance/presentation/html/slides/03.html  → Présentation projet
docs/soutenance/presentation/html/slides/04.html  → Enquête terrain (validation marché)
docs/soutenance/presentation/html/slides/05.html  → Persona Marc
docs/soutenance/presentation/html/slides/06.html  → Rôles utilisateurs
docs/soutenance/presentation/html/slides/07.html  → PÉRIMÈTRE IN/OUT (CRITIQUE)
docs/soutenance/presentation/html/slides/08.html  → Archi fonctionnelle POC + parcours
docs/soutenance/presentation/html/slides/09.html  → Archi fonctionnelle cible
docs/soutenance/presentation/html/slides/10.html  → Archi technique POC (CRITIQUE)
docs/soutenance/presentation/html/slides/11.html  → Archi AWS cible
docs/soutenance/presentation/html/slides/12.html  → Focus JWT / flow OIDC (CRITIQUE)
docs/soutenance/presentation/html/slides/13.html  → Démo (ce qui sera montré)
docs/soutenance/presentation/html/slides/14.html  → Tests & difficultés
docs/soutenance/presentation/html/slides/15.html  → Conclusion (sécurité)
docs/soutenance/presentation/html/slides/16.html à 18.html → Suite
docs/soutenance/presentation/html/slides/A01.html à A06.html → Annexes
```

### Méthode d'extraction

Les slides sont du HTML statique. Pour la DA, parse les `<style>` ou `<link>` pour récupérer les CSS variables (couleurs, gradients, typo). Pour le contenu, lis le texte des sections. Si des slides utilisent du SVG embarqué, inspecte-le pour comprendre les schémas d'archi.

---

## 🖥️ CONTRAINTE DE DÉMO — LA PLUS IMPORTANTE

**Lucas doit pouvoir faire la démo depuis le navigateur de son laptop, via un simple tunnel SSH vers la VM. Sans aucune friction.**

### Cahier des charges démo (non négociable)

1. ✅ **Un seul tunnel SSH** à mémoriser, court et simple
2. ✅ **Aucun certificat à importer** dans le navigateur du laptop
3. ✅ **Aucune modification de `/etc/hosts`** sur le laptop
4. ✅ **Aucun warning navigateur** type "connexion non sécurisée"
5. ✅ **Toutes les fonctionnalités du POC accessibles** depuis ce seul point d'entrée :
   - Portail GALAXIS (landing + login + dashboard)
   - Keycloak (pour l'admin et les redirections OIDC)
   - Vaultwarden (lien depuis le dashboard)
   - Nextcloud (lien depuis le dashboard)
6. ✅ **Démarrage en une commande** : `make demo` ou équivalent

### Architecture imposée pour atteindre ce CDC

**TLS** :
- ❌ Pas de TLS côté navigateur. Le trafic est **déjà chiffré par SSH lui-même** entre le laptop et la VM, donc pas besoin d'ajouter une couche TLS pour la démo locale.
- 💬 Pour le jury, expliquer : *« Le tunnel SSH chiffre le trafic laptop ↔ VM. En production cible (AWS), Caddy + Let's Encrypt prennent le relais (voir slide 11). Ne pas confondre POC démo locale et déploiement prod. »*
- Tout tourne en **HTTP en interne sur la VM**. Caddy reste utilisé comme **reverse proxy uniquement** (pas pour TLS).

**Ports** :
- **Un seul port exposé** : `8080` sur la VM (loopback uniquement : `127.0.0.1:8080`, pas `0.0.0.0`)
- **Caddy en reverse proxy unique** qui route par chemin :
  - `http://localhost:8080/` → Portail GALAXIS (React + API Laravel)
  - `http://localhost:8080/iam/` → Keycloak (avec `KC_HTTP_RELATIVE_PATH=/iam`)
  - `http://localhost:8080/vault/` → Vaultwarden
  - `http://localhost:8080/cloud/` → Nextcloud
- Le tunnel SSH : `ssh -L 8080:127.0.0.1:8080 user@<vm-ip>`

**Sur le laptop** :
- Ouvrir `http://localhost:8080` dans le navigateur. C'est tout.

### Pourquoi cette architecture

- **Conforme au POC** : 3 réseaux Docker isolés, briques en backend, Caddy en reverse proxy → exactement ce que disent les slides 08 et 10
- **Simple pour la démo** : un port, un tunnel, un URL, zéro cert, zéro `/etc/hosts`
- **Robuste** : pas de wildcards DNS, pas de `*.localhost`, pas de redirections HTTPS → HTTP qui plantent
- **Honnête** : on documente que la prod cible AWS a du TLS Let's Encrypt (slide 11)

---

## 🎨 Direction artistique attendue

Reproduis **l'esprit** des slides (pas une réplique pixel-perfect) :

- **Fond sombre** (noir profond, type `#0a0a0f` ou similaire — confirme via le CSS des slides)
- **Gradient bleu → violet** sur les éléments d'accent (titres, CTA, bordures actives)
- **Sphères / orbes floutées** en arrière-plan (effet "espace / planètes" qui matche le nom Galaxis)
- **Typo moderne sans-serif** (extrais la famille exacte des slides)
- **Glassmorphism léger** sur les cartes (backdrop-blur, bordure subtile)
- **Tagline** "One core. Infinite orbits." présente dans le footer/header
- **Logo** : reprends l'esprit du wordmark "Galaxis" des slides

Tu as **liberté créative sur les composants** (boutons, formulaires, tableaux) tant que tu restes dans cet univers visuel.

Extrais les tokens (couleurs, typo, espacements, ombres) dans `frontend/src/styles/tokens.ts` ou équivalent.

---

## ⚙️ Stack technique (non négociable — décisions de cadrage validées)

### Backend
- **Laravel 11** (PHP 8.3+)
- Middleware custom JWT (validation RS256 contre JWKS Keycloak)
- **PostgreSQL 16** comme base de données
- **Redis 7** pour le cache JWKS et les sessions

### Frontend
- **React 18** + **TypeScript**
- **Vite** comme bundler
- **Tailwind CSS** + **shadcn/ui**
- **React Router** v6
- Client OIDC : **oidc-client-ts** (maintenu, type-safe, OAuth2 + PKCE natif)

### IAM & briques
- **Keycloak 25+** (realm `galaxis`, client `galaxis-portal` public + PKCE)
  - Configuration : `KC_HTTP_RELATIVE_PATH=/iam`, `KC_PROXY=edge`, `KC_HOSTNAME_STRICT=false`
- **Vaultwarden** (intégré comme brique, login local autonome dans le POC, sous-chemin `/vault/`)
- **Nextcloud** (intégré comme brique, login local autonome dans le POC, sous-chemin `/cloud/`)
  - Configurer `overwritewebroot` et `trusted_proxies`

### Infra
- **Docker Compose** pour orchestration locale (POC mono-VM)
- **Caddy 2** comme **reverse proxy unique** (PAS de TLS) sur `127.0.0.1:8080`
- **3 réseaux Docker isolés** : `galaxis-iam-net`, `galaxis-app-net`, `galaxis-services-net`
  - Seul `app-php` (Laravel) est branché sur `app-net` + `iam-net` (pour valider les JWT contre JWKS de Keycloak)
  - Caddy est sur les 3 réseaux (puisqu'il route vers chacune des briques)
- **Scripts Ansible** idempotents pour le déploiement (4 playbooks : prereqs, iam, app, services)

---

## 📐 Périmètre POC (extrait des slides 07 et 13 — confirmer en lisant)

### IN scope
1. **Portail web GALAXIS** (React) : landing → login OIDC → dashboard
2. **Backend API Laravel** : validation JWT RS256 contre JWKS Keycloak avec cache Redis
3. **SSO OIDC** Portail → Backend (Authorization Code + PKCE)
4. **Dashboard** : cartes des briques disponibles (Vaultwarden, Nextcloud), profil utilisateur, claims affichés depuis `/api/me`
5. **Vaultwarden + Nextcloud déployés** et accessibles via lien depuis le dashboard (login local autonome — pas de vrai SSO bout-en-bout vers eux, c'est OUT scope POC)
6. **Audit log basique** des authentifications côté Laravel (table `audit_logs`)
7. **Secrets jamais commités** (`.env`, Ansible Vault)
8. **Reverse proxy Caddy** unique sur port 8080 (HTTP en interne, SSH chiffre le tunnel)

### OUT scope POC (mentionner dans README mais ne pas implémenter)
- SSO bout-en-bout vers Vaultwarden et Nextcloud
- MFA (mentionné dans archi cible slide 09/11, mais hors POC)
- Multi-tenancy
- Migration cloud AWS
- TLS Let's Encrypt (prévu pour la prod cible — slide 11)

⚠️ **Si une slide contredit ce résumé, la slide gagne.** Lis-les avant d'écrire du code.

---

## 🏗️ Structure du repo à créer

```
Galaxis-POC/
├── README.md                          # Quickstart démo (3 commandes max)
├── CHANGELOG.md
├── Makefile                           # Targets : up, down, demo, install, test, lint, seed, logs
├── .gitignore
├── .env.example
├── docker-compose.yml                 # Orchestration globale POC (3 tiers en stack unifiée)
├── Caddyfile                          # Reverse proxy unique → tous les services
├── docs/
│   ├── soutenance/                    # NE PAS TOUCHER (déjà là)
│   └── documentations/                # NOUVEAU — Les 3 docs livrées au jury
│       ├── README.md                  # Index des 3 docs
│       ├── technique/                 # Doc technique (admin/devops)
│       ├── projet/                    # Doc projet (gestion/cadrage)
│       └── utilisateur/               # Doc utilisateur (TPE non-tech)
├── backend/                           # Laravel 11
│   ├── app/, config/, database/, routes/, tests/
│   ├── composer.json
│   ├── Dockerfile
│   └── .env.example
├── frontend/                          # React 18 + Vite + TS
│   ├── src/
│   │   ├── styles/tokens.ts           # DA extraite des slides
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/useAuth.ts
│   │   └── lib/oidc.ts
│   ├── public/
│   ├── tests/
│   ├── package.json
│   ├── vite.config.ts
│   ├── tailwind.config.ts
│   ├── Dockerfile
│   └── .env.example
├── deployments/
│   ├── iam/docker-compose.yml         # Keycloak + Postgres (réseau iam-net)
│   ├── app/docker-compose.yml         # Laravel + React build + Postgres + Redis (réseau app-net + iam-net)
│   ├── services/docker-compose.yml    # Vaultwarden + Nextcloud + Postgres (réseau services-net)
│   └── proxy/docker-compose.yml       # Caddy (branché sur les 3 réseaux)
└── infrastructure/
    ├── ansible/
    │   ├── inventory.example
    │   ├── playbooks/
    │   │   ├── 00-prereqs.yml
    │   │   ├── 01-iam.yml
    │   │   ├── 02-app.yml
    │   │   └── 03-services.yml
    │   └── roles/
    └── scripts/
        └── configure-keycloak.sh      # Idempotent : crée realm, client, users de démo
```

---

## ✅ Critères de "fini" — état "prêt à livrer"

### Critères techniques (POC)
1. `make demo` lance toute la stack et tout démarre healthy en < 3 min
2. Depuis le laptop : `ssh -L 8080:127.0.0.1:8080 user@<vm-ip>` puis `http://localhost:8080` → portail GALAXIS visible avec la DA
3. Clic "Se connecter" → redirection vers `/iam/realms/galaxis/...` → login `lucas-test`/`demo` → retour dashboard avec claims affichés
4. Dashboard affiche cartes Vaultwarden + Nextcloud avec liens vers `/vault/` et `/cloud/` fonctionnels
5. `make test` passe (Pest backend + Vitest frontend) avec couverture ≥ 60%
6. `make lint` passe (PHP CS Fixer + ESLint + Prettier)
7. `./infrastructure/scripts/configure-keycloak.sh` est idempotent (relançable sans casser)
8. Aucun secret commité (vérifier avec grep manuel sur `password`, `secret`, `key`)
9. Les 3 réseaux Docker sont bien isolés (vérifiable avec `docker network inspect`)
10. **Aucun warning de certificat dans le navigateur du laptop** ✅
11. **Aucune modification `/etc/hosts` requise** sur le laptop ✅

### Critères de livraison (documentation)
12. **Les 3 documentations sont complètes** dans `docs/documentations/` (voir Phase 8 bis)
13. Le `README.md` racine permet à quelqu'un d'installer et démarrer la démo from scratch en < 30 min
14. Un livrable PDF unifié de la doc est généré : `docs/documentations/Galaxis_Documentation_Complete.pdf` (si pandoc dispo, sinon HTML)
15. **`LIVRAISON.md`** à la racine, qui liste tout ce qui est livré au jury avec les chemins

---

## 🧪 Tests requis

### Backend (Pest)
- Test middleware validation JWT (token valide, expiré, signature invalide, JWKS cache hit/miss)
- Test endpoint `/api/me` (retourne les claims du JWT)
- Test endpoint `/api/health` (DB + Redis + JWKS reachable)
- Test endpoint `/api/audit` (lister les logs d'auth)

### Frontend (Vitest + Testing Library)
- Test composant `LoginButton` (déclenche flow PKCE, génère code_verifier)
- Test composant `Dashboard` (rendu cartes briques + profil)
- Test hook `useAuth` (états logged in/out, refresh token)
- Test page `Callback` (échange code → token, redirection dashboard)

---

## 🔐 Sécurité — non négociable

- **Aucun secret en clair** dans le repo. `.env.example` documente, jamais de vrai `.env` commité
- **PKCE obligatoire** pour le client React (public, pas de client secret)
- **JWT validés serveur** : signature RS256 contre JWKS, vérif `iss`, `aud`, `exp`, `nbf`
- **JWKS cachées dans Redis** (TTL 5 min, refresh on miss)
- **CORS strict** : seul `http://localhost:8080` autorisé pour le POC
- **Headers de sécurité** via Caddy : `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`
  - ⚠️ Pas de HSTS / CSP stricte en POC HTTP (ça casserait la démo) — documenter pour la prod
- **Logs d'auth centralisés** : table `audit_logs` côté Laravel
- **Réseaux Docker isolés** : voir slide 10
- **Ansible Vault** pour les secrets de déploiement

---

## 📋 Workflow attendu (mode autonome, commits par phase)

> **Règle commits** : un commit Conventional Commits par feature/phase complétée. Si une phase contient plusieurs sous-features, splitter en plusieurs commits.

### Phase 0 — Exploration (15 min)
- Lis toutes les slides principales (01 à 15) + annexes
- Extrais la DA (couleurs, typo, gradients) dans une note de travail
- Produis `EXPLORATION.md` à la racine : ce que tu as compris du périmètre, de la DA, des contraintes, et les décisions que tu prends en cas d'ambiguïté
- ✅ Commit : `docs: exploration des slides et synthèse périmètre`

### Phase 1 — Squelette repo (10 min)
- Crée toute l'arborescence ci-dessus avec stubs README dans chaque dossier
- Setup `.gitignore` (gros, propre, multi-stack), `Makefile` minimal, `.env.example` racine
- ✅ Commit : `chore: scaffold complet du repo`

### Phase 2 — Reverse proxy Caddy + Docker Compose racine (30 min)
- `docker-compose.yml` racine qui orchestre les 3 stacks (include) + Caddy
- `Caddyfile` qui route :
  - `/iam/*` → `keycloak:8080`
  - `/vault/*` → `vaultwarden:80`
  - `/cloud/*` → `nextcloud:80`
  - `/api/*` → `app-php:80` (Laravel)
  - `/*` → `app-front:80` (React build servi par nginx-alpine ou caddy:file_server)
- Caddy bindé sur `127.0.0.1:8080` (loopback uniquement)
- 3 réseaux Docker : `galaxis-iam-net`, `galaxis-app-net`, `galaxis-services-net`
- ✅ Commit : `feat(infra): caddy reverse-proxy unique + 3 réseaux docker`

### Phase 3 — Keycloak (20 min)
- Realm `galaxis`, client public `galaxis-portal` avec PKCE
  - Redirect URI : `http://localhost:8080/auth/callback`
  - Web origins : `http://localhost:8080`
- Script `configure-keycloak.sh` idempotent (vérifie existence avant create)
- Users de démo : `lucas-test/demo`, `admin-test/demo`
- ✅ Commit : `feat(iam): keycloak realm + config idempotente + users démo`

### Phase 4 — Backend Laravel (60 min)
- Skeleton Laravel 11 (`composer create-project`)
- Middleware JWT custom : récupération JWKS Keycloak (URL `http://keycloak:8080/iam/realms/galaxis/protocol/openid-connect/certs`), cache Redis, validation RS256
- Endpoints : `/api/health`, `/api/me`, `/api/audit`
- Migrations : `users` (sync depuis JWT au premier login), `audit_logs`
- Seeders : aucun obligatoire
- Tests Pest (couverture ≥ 60%)
- ✅ Commit 1 : `feat(backend): laravel skeleton + middleware JWT`
- ✅ Commit 2 : `feat(backend): endpoints API + migrations + audit log`
- ✅ Commit 3 : `test(backend): tests pest + couverture`

### Phase 5 — Frontend React (60 min)
- Vite + React 18 + TS + Tailwind + shadcn/ui
- DA appliquée : `tokens.ts`, `globals.css`, composants de base
- Pages : Landing, LoginRedirect, Callback, Dashboard, Profile, NotFound
- Hook `useAuth` avec `oidc-client-ts`
- Composants UI : `Header`, `OrbBackground` (sphères floutées CSS), `BrickCard`, `ClaimsTable`
- Build de prod servi par nginx-alpine derrière Caddy
- Tests Vitest (couverture ≥ 60%)
- ✅ Commit 1 : `feat(frontend): vite + react + tailwind + DA tokens`
- ✅ Commit 2 : `feat(frontend): pages + routing + flow OIDC PKCE`
- ✅ Commit 3 : `feat(frontend): composants dashboard + cartes briques`
- ✅ Commit 4 : `test(frontend): tests vitest + couverture`

### Phase 6 — Briques services (20 min)
- Vaultwarden : variables `DOMAIN=http://localhost:8080/vault`, désactiver signup public
- Nextcloud : Postgres dédiée, `overwritewebroot=/cloud`, `trusted_proxies` Caddy
- Cartes sur le dashboard avec liens vers `/vault/` et `/cloud/`
- ✅ Commit : `feat(services): vaultwarden + nextcloud + intégration dashboard`

### Phase 7 — Ansible (30 min)
- 4 playbooks idempotents :
  - `00-prereqs.yml` : Docker, Docker Compose, swap, fail2ban
  - `01-iam.yml` : déploie stack iam + lance configure-keycloak.sh
  - `02-app.yml` : déploie stack app + migrations
  - `03-services.yml` : déploie stack services
- Inventory exemple `inventory.example` (template à remplir)
- ✅ Commit : `feat(infra): ansible playbooks idempotents + inventory`

---

## 📚 Phase 8 — DOCUMENTATIONS LIVRABLES (CRITIQUE — 90 min)

> **Cette phase est aussi importante que le code.** Le jury reçoit ces 3 docs comme livrable formel. Elles doivent être complètes, propres, sans `TODO` ni placeholder.

Crée `docs/documentations/` avec **3 sous-dossiers** + un index. Chaque doc est en **Markdown propre**, avec des schémas en **Mermaid**, des tableaux pour les matrices, et un ton adapté à son audience.

### 8.A — Doc TECHNIQUE — `docs/documentations/technique/`

**Audience** : développeurs, admin sys, devops qui doivent installer, déployer, maintenir, faire évoluer GALAXIS.

**Fichiers à produire** :

```
docs/documentations/technique/
├── README.md                    # Index + comment lire cette doc
├── 01-architecture-poc.md       # Mono-VM Debian, 3 réseaux Docker, schéma Mermaid
├── 02-architecture-cible.md     # Cible AWS multi-VPC, mapping POC→prod
├── 03-stack-technique.md        # Versions exactes, dépendances, justifications
├── 04-installation.md           # Pas-à-pas from scratch sur Debian 12/13
├── 05-deploiement-ansible.md    # Les 4 playbooks, ordre, idempotence, rollback
├── 06-iam-keycloak.md           # Realm, client, claims, PKCE, configuration
├── 07-flow-oidc-jwt.md          # Auth Code + PKCE détaillé, validation RS256, cache JWKS
├── 08-reseaux-docker.md         # 3 réseaux, matrice de communication, isolation
├── 09-securite.md               # Threat model POC, secrets, durcissement, what's OUT scope
└── 10-exploitation.md           # Logs, monitoring, backup, restore, mise à jour
```

**Règles** :
- Citations de fichiers du repo avec chemins absolus (ex: `infrastructure/scripts/configure-keycloak.sh`)
- Tous les schémas en Mermaid (archi, flow OIDC, réseaux)
- Toutes les commandes copiables-collables, testées
- En tête de chaque fichier : titre H1, date de génération, audience cible

### 8.B — Doc PROJET — `docs/documentations/projet/`

**Audience** : jury ESGI, chef de projet, sponsor. Comprendre **pourquoi** et **comment** ce projet a été mené.

**Fichiers à produire** :

```
docs/documentations/projet/
├── README.md                    # Index
├── 01-contexte-marche.md        # Pourquoi GALAXIS, douleurs TPE, validation marché (slide 04)
├── 02-fiche-projet.md           # Identité projet, objectifs, KPIs, deadline soutenance
├── 03-persona-roles.md          # Persona Marc (slide 05), rôles utilisateurs (slide 06)
├── 04-proposition-valeur.md     # Value proposition canvas, différenciation, business model
├── 05-perimetre-decisions.md    # IN/OUT scope (slide 07), décisions de cadrage et justifications
├── 06-architecture-fonctionnelle.md  # Vue fonctionnelle POC + cible (slides 08, 09)
├── 07-gestion-projet.md         # Méthode, planning, kanban, courbe de charge, ajustements
├── 08-difficultes-apprentissages.md  # Slide 14 développée
└── 09-roadmap.md                # POC → MVP → V1 produit (slides 16-18)
```

**Règles** :
- Ton factuel mais narratif (raconter le projet)
- Extraire les éléments des slides correspondantes ET les enrichir
- Pas de jargon technique gratuit (le jury n'est pas que technique)
- Inclure les chiffres clés de l'enquête (500 réponses, satisfaction, intérêt, budget)

### 8.C — Doc UTILISATEUR — `docs/documentations/utilisateur/`

**Audience** : Marc, gérant de TPE de 6 personnes, peu de bagage technique. Doit pouvoir utiliser GALAXIS sans appeler son neveu informaticien.

**Fichiers à produire** :

```
docs/documentations/utilisateur/
├── README.md                    # Bienvenue + sommaire visuel
├── 01-premiere-connexion.md     # Tour guidé : ouvrir l'URL, se connecter, voir le dashboard
├── 02-gerer-mes-acces.md        # Comprendre les briques disponibles (Vaultwarden, Nextcloud)
├── 03-vaultwarden-bases.md      # Stocker un mot de passe, partager avec un collaborateur
├── 04-nextcloud-bases.md        # Uploader un fichier, le partager, créer un dossier
├── 05-onboarding-collaborateur.md  # Ajouter Sophie qui rejoint l'équipe (admin Keycloak)
├── 06-offboarding.md            # Quand Sophie part : couper ses accès proprement
├── 07-faq.md                    # Questions courantes (mot de passe oublié, accès refusé, etc.)
└── 08-glossaire.md              # SSO, IAM, JWT, etc. expliqués en français simple
```

**Règles** :
- Ton chaleureux, phrases courtes, pas de jargon (ou expliqué tout de suite)
- **Captures d'écran** : si pas possibles, descriptions textuelles précises ("bouton bleu en haut à droite avec une icône d'engrenage")
- Tutoriels pas-à-pas numérotés
- Encarts "💡 Astuce" et "⚠️ Attention"
- Adapté au persona Marc (slide 05) : il a 45 ans, pas geek, veut juste que ça marche

### 8.D — Index global

```
docs/documentations/README.md
```

Sommaire des 3 docs, qui s'adresse à qui, où aller selon son besoin.

### Commits Phase 8

- ✅ Commit 1 : `docs(technique): documentation technique complète (10 chapitres)`
- ✅ Commit 2 : `docs(projet): documentation projet complète (9 chapitres)`
- ✅ Commit 3 : `docs(utilisateur): guide utilisateur TPE complet (8 chapitres)`
- ✅ Commit 4 : `docs: index global documentations + livrables`

---

### Phase 9 — README racine + guide démo + livraison (30 min)

- `README.md` racine : quickstart démo en 3 commandes max + capture d'écran si possible
- `docs/documentations/demo-guide.md` : guide démo détaillé pour Lucas (commande SSH exacte, ordre de clic, points de vigilance, plan B)
- `CHANGELOG.md` : historique des versions, démarrant à `v1.0-soutenance`
- **`LIVRAISON.md` à la racine** :
  - Liste exhaustive de ce qui est livré
  - Chemins vers chaque livrable
  - Commande de démo
  - Lien GitHub
  - Versions des dépendances clés
- ✅ Commit : `docs: readme racine + guide démo + livraison`

### Phase 10 — Validation finale (15 min)
- `make demo && make test && make lint` doit passer
- Vérifier les **15 critères de fini**
- Vérifier qu'aucun secret n'est commité (grep `password=`, `secret=`, `eyJ...`, etc.)
- Vérifier que chaque doc dans `docs/documentations/` est complète (pas de "TODO" ni de "à compléter")
- Si `pandoc` est dispo : générer `docs/documentations/Galaxis_Documentation_Complete.pdf` en concaténant les 3 docs
- ✅ Commit : `chore: validation finale POC v1.0 prêt livraison`
- Tag : `git tag v1.0-soutenance && git push --tags`

---

## 🎬 Commande de démo finale (à inclure dans le README)

```bash
# 1. Sur la VM (déploiement initial, une seule fois)
make demo

# 2. Sur le laptop (à chaque démo)
ssh -L 8080:127.0.0.1:8080 user@<VM_IP>

# 3. Sur le laptop, ouvrir le navigateur
xdg-open http://localhost:8080
```

Et c'est tout. Pas de cert, pas de `/etc/hosts`, pas de warning.

---

## 📦 Rapport final attendu

À la toute fin, produis un rapport final (en chat, pas dans un fichier) qui contient :

1. **État de chaque critère de fini** (cochés ou non, avec explications si non)
2. **Inventaire des livrables** :
   - POC fonctionnel ✓
   - Doc technique (X chapitres)
   - Doc projet (X chapitres)
   - Doc utilisateur (X chapitres)
   - PDF unifié ✓/✗
   - LIVRAISON.md ✓
3. **Commandes exactes pour la démo**
4. **Points d'amélioration** identifiés mais non implémentés (pour la v2)
5. **Liste des commits** créés (sortie `git log --oneline`)

---

## 🚀 Démarre maintenant

Commence par la **Phase 0 — Exploration**. Lis les slides, extrais la DA, comprends le périmètre exact, produis `EXPLORATION.md`.

Ensuite, enchaîne les phases 1 à 10 sans me demander de validation intermédiaire, mais **commit à chaque feature/phase** comme indiqué.

Si tu rencontres une ambiguïté sérieuse, documente la décision que tu prends dans `EXPLORATION.md` ou en commentaire de commit, et continue.

**N'oublie pas : la Phase 8 (les 3 documentations) est aussi importante que le code. C'est ce qui sera remis au jury. Pas de bâclage.**

**Go.**
