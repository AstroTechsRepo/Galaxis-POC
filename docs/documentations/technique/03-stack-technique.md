# 03 — Stack technique

> **Audience** : développeurs, devops, équipe sécurité · **Source** : `backend/composer.json`, `frontend/package.json`, `docker-compose.yml`

---

## Vue synthétique

| Couche | Choix | Version | Pourquoi |
|---|---|---|---|
| OS hôte VM | Debian | 12 (Bookworm) ou 13 | LTS, stable, packages Docker officiels |
| Orchestration | Docker Compose | v2 plugin | Standard, mono-VM, idempotent |
| Reverse proxy | Caddy | 2.8 | Config déclarative, auto-HTTPS facile pour la cible, léger |
| IAM | Keycloak | 25.0 | OIDC OAuth2 complet, JWKS, PKCE natif, mature |
| Backend | PHP / Laravel | 8.3 / 11.x | Mature, écosystème, PHP-FPM perf OK pour TPE |
| JWT lib | firebase/php-jwt | ^6.10 | Standard PHP, supporte JWKS, RS256 |
| HTTP client backend | Guzzle | ^7.9 | Standard, timeouts gérables |
| Cache backend | Redis (predis) | 7 / ^2.2 | Cache JWKS + sessions |
| DB | PostgreSQL | 16-alpine | Fiable, JSONB pour `audit_logs.payload`, multi-instance facile |
| Frontend | React + Vite | 18.3 / 5.4 | Modernes, build rapide, TS-first |
| Language front | TypeScript | 5.6 | Type safety, contrats API explicites |
| CSS | Tailwind CSS | 3.4 | Utility-first, tokens centralisés, cohérence avec DA slides |
| Client OIDC | oidc-client-ts | 3.1 | Maintenu, PKCE S256 natif, type-safe |
| Routing | React Router | 6.28 | Standard SPA |
| Vaultwarden | vaultwarden/server | 1.32.4 | Compatible API Bitwarden, footprint faible (Rust) |
| Nextcloud | nextcloud:apache | 30 | Mature, drive collaboratif, large communauté |
| Tests backend | Pest | ^3.5 | Plus expressif que phpunit pur, syntaxe agréable |
| Tests frontend | Vitest + Testing Library | 2.1 / 16 | Compatibilité Vite, API stable |
| Lint | Pint + ESLint + Prettier | latest | Standards de chaque écosystème |
| IaC | Ansible | core 2.16+ | Idempotent, sans agent, courbe d'apprentissage faible |

---

## Détails par couche

### Backend Laravel

```json
{
  "php": "^8.3",
  "laravel/framework": "^11.31",
  "firebase/php-jwt": "^6.10",
  "guzzlehttp/guzzle": "^7.9",
  "predis/predis": "^2.2"
}
```

- **PHP 8.3** : assez récent pour profiter de Readonly properties, `array_find` n'est pas encore là (sera dans 8.4) — on s'en passe pour la portabilité.
- **Laravel 11** : structure simplifiée (`bootstrap/app.php`), middleware en config, idéal pour API-only.
- **firebase/php-jwt v6.10** : le `JWK::parseKeySet()` est exactement ce qu'on attend pour le cache JWKS.
- **predis/predis** : pure PHP, pas besoin d'installer l'extension `phpredis`. Idéal Docker.

> 💡 Si on migre vers AWS plus tard, on switchera `predis` → extension `phpredis` pour de meilleures perfs ElastiCache.

### Frontend React

Versions principales :
- `react@18.3.1`, `react-dom@18.3.1`
- `react-router-dom@6.28.0`
- `oidc-client-ts@3.1.0`
- `tailwindcss@3.4.14`
- `typescript@5.6.3`
- `vite@5.4.10`
- `vitest@2.1.4` + `@vitest/coverage-v8@2.1.4`

> 💡 `oidc-client-ts` est le successeur de `oidc-client` (déprécié). Il est maintenu activement par IdentityModel/justin-vh.

### Infrastructure

- `docker-ce` + `docker-compose-plugin` (depuis le repo officiel Docker)
- `ufw` : firewall simple
- `fail2ban` : protection SSH brute-force
- `unattended-upgrades` : sécurité OS automatique

---

## Justifications stratégiques

### Pourquoi Laravel et pas FastAPI / Spring / Express ?

| Critère | Laravel | FastAPI | Express |
|---|---|---|---|
| Maturité ORM | ✅ Eloquent | ⚠️ SQLAlchemy (verbeux) | ❌ aucun built-in |
| Courbe d'entrée TPE | ✅ Docs FR énormes | ⚠️ moyen | ⚠️ trop bas niveau |
| Migrations natives | ✅ artisan migrate | ⚠️ Alembic à part | ❌ Knex/typeorm à choisir |
| Auth/middleware | ✅ built-in | ⚠️ à coder | ⚠️ à coder |
| Job queue (v2) | ✅ Horizon natif | ⚠️ Celery | ⚠️ Bull |

Pour un POC qui doit évoluer vers une plateforme TPE, Laravel donne le **time-to-feature** le plus rapide sans sacrifier la maintenabilité.

### Pourquoi pas un seul stack (Next.js full-stack) ?

- Le client OIDC PKCE nécessite du JavaScript côté navigateur → on aurait React de toute façon.
- Le backend qui valide les JWT doit être **persistant** et **rapide à scale horizontalement** sans coupler le runtime du front. Le PHP-FPM scale bien sur ECS Fargate sans surprise.
- Découpler front/back force à écrire un **contrat API REST** propre dès le premier jour. Précieux pour la v2.

### Pourquoi Keycloak et pas Authelia / Ory Hydra / Auth0 ?

| Critère | Keycloak | Authelia | Ory Hydra | Auth0 |
|---|---|---|---|---|
| Souveraineté | ✅ self-hosted | ✅ self-hosted | ✅ self-hosted | ❌ SaaS US |
| OIDC complet | ✅ | ⚠️ partiel | ✅ | ✅ |
| Admin UI riche | ✅ | ⚠️ | ❌ | ✅ |
| Multi-realm | ✅ | ❌ | ⚠️ via projects | ⚠️ payant |
| Communauté FR | ✅ forte | ⚠️ | ⚠️ | n/a |

Pour Marc (notre persona), qui veut un truc « français et open source » (cf. citation slide 5), Keycloak coche les cases sans dépendance SaaS.

### Pourquoi PostgreSQL ×3 et pas une seule DB ?

- **Isolation** : si Keycloak corrompt sa DB ou doit être restaurée, la DB Laravel et la DB Nextcloud sont intactes.
- **Migration progressive** : on peut migrer une brique en RDS sans toucher aux autres.
- **Coût POC** : trois Postgres alpine en conteneur, c'est ~150 MB de RAM, négligeable.

---

## Compatibilité navigateurs (frontend)

Vite par défaut cible `ES2022`. Le portail Galaxis fonctionne sur :
- Chrome / Edge / Firefox / Safari **versions récentes** (2 dernières années).
- ❌ IE11 (non supporté, on assume — TPE 2026 ne devrait plus l'utiliser).

---

## Compatibilité PHP (backend)

- **PHP 8.3** strictement requis (`composer.json` : `"php": "^8.3"`).
- Extensions PECL nécessaires : `redis`, `pdo_pgsql`, `intl`, `mbstring`, `zip`, `bcmath`.
- Toutes installées dans le Dockerfile.

---

## Liens internes
- Installation : [04-installation.md](./04-installation.md)
- Architecture cible : [02-architecture-cible.md](./02-architecture-cible.md)
