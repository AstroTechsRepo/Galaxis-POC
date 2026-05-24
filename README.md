# 🌌 Galaxis POC

> **One core. Infinite orbits.**
> L'orchestrateur souverain de votre écosystème open source — POC réalisé par Lucas PEREZ (ESGI 2 · Campus Éductive · 2025/2026), édité par AstroTechs.

[![Version](https://img.shields.io/badge/version-v1.0--soutenance-7B3E97)](#) [![License](https://img.shields.io/badge/licence-proprietary-127DC2)](#) [![Stack](https://img.shields.io/badge/stack-Laravel%2011%20%2B%20React%2018%20%2B%20Keycloak%2025-07A9DD)](#)

---

## ✨ En une phrase

Galaxis déploie sur **une seule VM Debian**, en **une seule commande**, un **portail unifié** qui orchestre une IAM (Keycloak), un coffre-fort de mots de passe (Vaultwarden) et un drive collaboratif (Nextcloud) — le tout en **open source souverain**, accessible via un **seul tunnel SSH** pour la démo.

---

## 🚀 Démarrage express (3 commandes)

### Sur la VM (déploiement initial)

```bash
git clone <repo>.git Galaxis-POC && cd Galaxis-POC
cp .env.example .env && $EDITOR .env   # remplacez tous les change-me-*
make demo
```

### Sur le laptop (à chaque démo)

```bash
ssh -L 8080:127.0.0.1:8080 user@<VM_IP>
```

### Sur le laptop, ouvrir le navigateur

```
http://localhost:8080
```

C'est **tout**.

- ✅ Pas de certificat à importer
- ✅ Pas de modification `/etc/hosts`
- ✅ Pas de warning navigateur

Connectez-vous avec `lucas-test / demo` et explorez votre orbite.

---

## 🛰️ Ce que vous verrez

1. **Landing page Galaxis** : fond espace, gradient bleu→violet, tagline *One core. Infinite orbits.*
2. **Login OIDC PKCE** : redirection vers Keycloak, page login, retour authentifié
3. **Dashboard** : *Bienvenue, Lucas* + 3 cartes briques (Vaultwarden, Nextcloud, VPN à venir) + tableau des claims du JWT décodés
4. **Profile** : session OIDC + journal d'audit des connexions
5. **Vaultwarden** sur `/vault/` : coffre-fort de mots de passe
6. **Nextcloud** sur `/cloud/` : drive collaboratif
7. **Keycloak admin** sur `/iam/admin` : pour créer / désactiver des comptes

---

## 🏗️ Architecture POC en 30 secondes

```
                ┌─────────────────────────────────────────┐
  Laptop ─SSH→  │  VM Debian (127.0.0.1:8080 loopback)    │
                │  ┌─────────────────────────────────────┐│
                │  │  Caddy 2.8 (reverse proxy unique)   ││
                │  └──┬──────────┬─────────┬────────┬────┘│
                │     │/         │/api     │/iam    │/vault, /cloud
                │     │          │         │        │
                │  ┌──┴─────┐ ┌──┴─────┐ ┌─┴──┐ ┌──┴───────────┐
                │  │app-front│ │app-php │ │ KC │ │ Vault + Cloud│
                │  │(React) │ │(Laravel)│ │25  │ │              │
                │  └────────┘ └─┬──┬────┘ └─┬──┘ └──────────────┘
                │              │  │      JWKS
                │           Redis │       │
                │              app-db    iam-db, nextcloud-db
                └─────────────────────────────────────────┘
                galaxis-app-net | galaxis-iam-net | galaxis-services-net
```

**11 conteneurs · 3 réseaux Docker isolés · 1 reverse proxy unique.**

Détails : [doc technique 01](./docs/documentations/technique/01-architecture-poc.md)

---

## 📚 Documentation livrée au jury

3 documentations dédiées dans [`docs/documentations/`](./docs/documentations/) :

| Doc | Pour qui ? | Quoi ? |
|---|---|---|
| 🟦 [**Technique**](./docs/documentations/technique/README.md) | devs, devops, admin sys | 10 chapitres : archi POC + cible AWS, stack, install, déploiement, IAM, JWT, réseaux, sécurité, exploitation |
| 🟪 [**Projet**](./docs/documentations/projet/README.md) | jury, sponsor | 9 chapitres : contexte, persona, valeur, périmètre, archi fonctionnelle, gestion, difficultés, roadmap |
| 🟧 [**Utilisateur**](./docs/documentations/utilisateur/README.md) | Marc et son équipe TPE | 8 chapitres : première connexion, Vaultwarden, Nextcloud, on/offboarding, FAQ, glossaire |

Voir aussi : [LIVRAISON.md](./LIVRAISON.md) pour l'inventaire complet.

---

## 🧪 Tests et qualité

```bash
make test    # Pest (backend) + Vitest (frontend) avec couverture ≥ 60%
make lint    # Pint + ESLint + Prettier
```

- **Backend** : 11 tests Pest couvrant le middleware JWT (8 cas), `/api/health`, `/api/audit`, et le cache JWKS
- **Frontend** : 4 fichiers de tests Vitest couvrant `LoginButton`, `Dashboard`, `useAuth`, `Callback`

---

## 🎬 Commande utile

| Commande | Fait quoi ? |
|---|---|
| `make demo` | Premier démarrage complet, healthy en ~3 min |
| `make up` / `make down` / `make restart` | Cycle de vie sans rebuild |
| `make logs` | Suit les logs de toute la stack |
| `make test` | Pest + Vitest avec couverture |
| `make lint` | Pint + ESLint + Prettier |
| `make ps` | Statut des conteneurs |
| `make configure-keycloak` | Rejoue la config Keycloak (idempotent) |
| `make seed` | Migrations + seeders Laravel |
| `make clean` | ⚠️ Supprime volumes (destructif) |
| `make ansible-all` | Déploie via Ansible sur une VM distante |

---

## 🔐 Sécurité du POC

- **PKCE S256** obligatoire (client public React)
- **Validation JWT serveur** : signature RS256, `iss`, `aud`, `exp`, `nbf`
- **Cache JWKS Redis** TTL 5 min + refresh on miss kid
- **CORS strict** : seul `APP_URL` autorisé
- **Headers Caddy** : X-Content-Type-Options, X-Frame-Options, Referrer-Policy
- **0 secret commité** (vérifié par grep)
- **3 réseaux Docker isolés** (cf. matrice de communication doc 08)
- **Audit log centralisé** (table `audit_logs`)

Cf. [doc technique 09 — Sécurité](./docs/documentations/technique/09-securite.md) pour le threat model détaillé.

---

## 🗺️ Périmètre

**IN scope POC** : Portail React + Login OIDC PKCE + IAM Keycloak centralisé + Vaultwarden + Nextcloud + validation JWT serveur + 3 réseaux Docker isolés + déploiement Ansible.

**OUT scope POC** : SSO bout-en-bout vers Vaultwarden/Nextcloud, MFA, RBAC fin, multi-tenant, migration cloud effective, monitoring, TLS Let's Encrypt (prévu pour la prod cible AWS).

Détails : [doc projet 05 — Périmètre & décisions](./docs/documentations/projet/05-perimetre-decisions.md).

---

## 📂 Structure du repo

```
Galaxis-POC/
├── README.md                     ← vous êtes ici
├── LIVRAISON.md                  ← inventaire complet du livrable jury
├── CHANGELOG.md                  ← historique de versions
├── EXPLORATION.md                ← notes de cadrage Phase 0
├── CLAUDE_CODE_PROMPT.md         ← brief originel
├── Makefile                      ← targets demo, up, down, test, lint, ansible-*
├── .env.example                  ← variables d'environnement documentées
├── docker-compose.yml            ← orchestration unifiée
├── Caddyfile                     ← reverse proxy unique
├── backend/                      ← Laravel 11 (API + JWT middleware)
├── frontend/                     ← React 18 + Vite + TS + Tailwind + oidc-client-ts
├── deployments/                  ← split docker-compose par tier (iam, app, services, proxy)
├── infrastructure/
│   ├── ansible/                  ← 4 playbooks idempotents + inventory.example
│   └── scripts/                  ← configure-keycloak.sh, wait-for-keycloak.sh
└── docs/
    ├── soutenance/               ← présentation 18 slides + annexes (intouchable)
    └── documentations/           ← LES 3 DOCS LIVRABLES
        ├── technique/            ← 10 chapitres
        ├── projet/               ← 9 chapitres
        └── utilisateur/          ← 8 chapitres
```

---

## 🧠 Stack technique en bref

| Couche | Choix | Version |
|---|---|---|
| OS hôte | Debian | 12 / 13 |
| Orchestration | Docker Compose | v2 plugin |
| Reverse proxy | Caddy | 2.8 |
| IAM | Keycloak | 25.0 |
| Backend | Laravel | 11.x (PHP 8.3+) |
| Frontend | React + Vite + TS | 18.3 / 5.4 / 5.6 |
| Style | Tailwind CSS | 3.4 |
| OIDC client | oidc-client-ts | 3.1 |
| Cache | Redis | 7-alpine |
| DB | PostgreSQL | 16-alpine ×3 |
| Vaultwarden | vaultwarden/server | 1.32.4 |
| Nextcloud | nextcloud:apache | 30 |
| IaC | Ansible | core 2.16+ |
| Tests back | Pest | 3.5 |
| Tests front | Vitest | 2.1 |

---

## 🆘 Démo qui plante ? Plan B

Voir le [guide démo](./docs/documentations/demo-guide.md) — procédure de récupération si quelque chose foire en présentation jury.

---

## 👤 Contact

- **Auteur** : Lucas PEREZ — ESGI 2, Campus Éductive
- **Soutenance** : 26 juin 2026
- **Éditeur** : AstroTechs

---

## 📄 Licence

Code source POC sous licence propriétaire (cf. `composer.json` et `package.json`). Les briques tierces gardent leurs licences originales (Keycloak Apache 2.0, Vaultwarden GPLv3, Nextcloud AGPL, Laravel MIT, React MIT, etc.).

---

> *« Ajouter une brique = ajouter une carte dans le portail. C'est ce que veut dire orchestrateur. »* — slide 09
