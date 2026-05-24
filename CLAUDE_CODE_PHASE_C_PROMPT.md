# 🐳 Mission Claude Code — Phase C : Conteneurisation complète & alignement architecture slides

> Tu viens de finir les Phases A (rebuild POC) et B (seeding). Tu enchaînes maintenant sur la **Phase C** : refactor de l'architecture pour qu'elle soit **100% conteneurisée**, **alignée avec les slides de soutenance** (11 conteneurs exacts, 3 Caddy frontaux, 3 réseaux Docker isolés, HTTPS via CA local Caddy), et **transportable** (un `git clone` + `docker compose up` n'importe où doit suffire).
>
> ⚠️ **Cette phase corrige des erreurs de cadrage de la Phase A**. Le brief initial parlait à tort d'un Caddy unique et de HTTP. La vérité, c'est ce que disent les slides : 3 Caddy frontaux + HTTPS + 11 conteneurs. On corrige maintenant.

---

## 🎯 Source de vérité — RELIRE OBLIGATOIREMENT

Tu DOIS relire ces fichiers AVANT d'écrire la moindre ligne :

```
docs/soutenance/presentation/html/slides/10.html    → Archi technique POC (les 11 conteneurs)
docs/soutenance/presentation/html/slides/12.html    → Focus JWT (le pont app-php multi-réseau)
docs/soutenance/presentation/html/slides/13.html    → Séquence de démo (les sondes curl, docker ps, docker network)
docs/soutenance/presentation/html/slides/15.html    → Conclusion (les chiffres-clés : 11 · 3 · HTTPS · OIDC · 0 secret · 4 scripts)
docs/soutenance/presentation/html/slides/A01.html   → Annexe slide 16 : tableau des 15 flux
```

**Si une slide contredit ce qui est écrit ci-dessous, la slide gagne.**

---

## 📦 Architecture cible — LES 11 CONTENEURS EXACTS

| # | Conteneur | Image | Ports | Réseau Docker |
|---|---|---|---|---|
| 1 | **caddy-iam** | `caddy:2-alpine` | `8443→443` (loopback VM) | `galaxis-iam-net` |
| 2 | **keycloak** | `quay.io/keycloak/keycloak:26.0` | `8080`, `8443`, `9000` (interne) | `galaxis-iam-net` |
| 3 | **keycloak-db** | `postgres:16-alpine` | `5432` (interne) | `galaxis-iam-net` |
| 4 | **app-caddy** | `caddy:2-alpine` | `9443→443` (loopback VM) | `galaxis-app-net` |
| 5 | **app-php** | image custom Laravel (PHP 8.3-FPM) | `9000` (interne) | **`galaxis-app-net` + `galaxis-iam-net`** (PASSERELLE) |
| 6 | **app-db** | `postgres:16-alpine` | `5432` (interne) | `galaxis-app-net` |
| 7 | **app-redis** | `redis:7-alpine` | `6379` (interne) | `galaxis-app-net` |
| 8 | **caddy-services** | `caddy:2-alpine` | `10443→443`, `11443→444` (loopback VM) | `galaxis-services-net` |
| 9 | **vaultwarden** | `vaultwarden/server:latest` | `80`, `3012` (interne, WebSocket) | `galaxis-services-net` |
| 10 | **nextcloud** | `nextcloud:apache` | `80` (interne) | `galaxis-services-net` |
| 11 | **nextcloud-db** | `postgres:16-alpine` | `5432` (interne) | `galaxis-services-net` |

### ⚠️ Points critiques (à respecter sans dévier)

1. **`app-php` est le seul conteneur multi-réseau** : il est branché sur `galaxis-app-net` (pour parler à app-db, app-redis, app-caddy) ET sur `galaxis-iam-net` (pour valider les JWT contre JWKS de Keycloak). C'est le **pont JWT** — la slide 12 et la slide A01 (annexe flux) le détaillent.

2. **React n'est PAS un conteneur**. C'est un **build statique** servi par `app-caddy` depuis `/srv/frontend` avec fallback SPA `/index.html`. La build se fait dans une étape multi-stage du Dockerfile ou dans un volume nommé.

3. **3 Caddy frontaux distincts**, un par tier. Pas un Caddy unique. Chacun :
   - Termine HTTPS avec un **certificat émis par son CA Caddy interne** (`tls internal`)
   - Reverse-proxy les briques de son tier
   - Expose un port loopback unique sur la VM

4. **Tous les ports VM sont bindés sur `127.0.0.1`** (loopback), JAMAIS sur `0.0.0.0`. L'accès se fait exclusivement via tunnel SSH depuis le laptop.

---

## 🌐 Mapping des ports & accès démo

### Bindings sur la VM (loopback uniquement)

```
127.0.0.1:8443  → caddy-iam:443      (Keycloak)
127.0.0.1:9443  → app-caddy:443      (Portail Galaxis : React + API Laravel)
127.0.0.1:10443 → caddy-services:443 (Vaultwarden)
127.0.0.1:11443 → caddy-services:444 (Nextcloud)
```

### Hostnames internes Docker (réseau)

```
galaxis-iam       → caddy-iam        (vu depuis caddy)
galaxis-app       → app-caddy
galaxis-vault     → caddy-services:443
galaxis-cloud     → caddy-services:444
```

### Commande SSH unique pour le laptop

```bash
ssh -L 8443:127.0.0.1:8443 \
    -L 9443:127.0.0.1:9443 \
    -L 10443:127.0.0.1:10443 \
    -L 11443:127.0.0.1:11443 \
    user@<vm-ip>
```

### URLs accessibles depuis le navigateur du laptop

```
https://localhost:9443       → Portail Galaxis (entry point principal de la démo)
https://localhost:8443       → Keycloak admin console
https://localhost:10443      → Vaultwarden
https://localhost:11443      → Nextcloud
```

### Note TLS pour la démo

Les certificats sont émis par les **CA Caddy internes** (un par Caddy frontal). Le navigateur affichera un warning **« certificat non reconnu »** au premier accès à chaque URL — c'est **normal et attendu** pour un POC. Cliquer « avancer » est acceptable. Documenter cela explicitement dans `docs/documentations/demo-guide.md`.

> 💡 Option avancée optionnelle : exposer les CA Caddy via un endpoint `/_ca.crt` pour que Lucas puisse les importer dans son trust navigateur en pré-démo (zéro warning). À documenter mais pas à imposer.

---

## 🏗️ Travail à faire

### 1. Refactor `docker-compose.yml` racine

Un seul `docker-compose.yml` à la racine qui **orchestre tout**, sans dépendre de fichiers includes externes (transportabilité maximale). Trois networks déclarés, onze services déclarés.

```yaml
networks:
  galaxis-iam-net:
    name: galaxis-iam-net
    driver: bridge
  galaxis-app-net:
    name: galaxis-app-net
    driver: bridge
  galaxis-services-net:
    name: galaxis-services-net
    driver: bridge

services:
  # Tier IAM
  caddy-iam: ...
  keycloak: ...
  keycloak-db: ...

  # Tier APP
  app-caddy: ...
  app-php: ...
  app-db: ...
  app-redis: ...

  # Tier SERVICES
  caddy-services: ...
  vaultwarden: ...
  nextcloud: ...
  nextcloud-db: ...
```

Chaque service a :
- Un `container_name` explicite (le nom officiel du tableau ci-dessus)
- Des `networks:` strictement comme indiqué
- Des `depends_on:` avec conditions `service_healthy` quand pertinent
- Un `healthcheck:` pour les services critiques (postgres, keycloak, vaultwarden, nextcloud, app-php)
- Des `volumes:` nommés et persistants pour les données
- Des variables d'env tirées de `.env` (jamais en dur)
- `restart: unless-stopped`

Les anciens `deployments/iam/`, `deployments/app/`, `deployments/services/`, `deployments/proxy/` :
- Soit tu les supprimes (préférable, pour la simplicité)
- Soit tu les conserves comme variants alternatifs documentés dans `docs/documentations/technique/`, mais **le compose racine est la source de vérité**

### 2. Dockerfiles applicatifs

#### `backend/Dockerfile`
- Multi-stage : `composer install` dans une étape, runtime PHP 8.3-FPM dans l'autre
- Inclut les extensions PHP nécessaires (pdo_pgsql, redis, mbstring, openssl, bcmath, gd)
- Copie le code, lance `php artisan optimize`
- Healthcheck via `php-fpm-healthcheck` ou un script `curl` interne

#### `frontend/Dockerfile`
- Multi-stage : `node:20-alpine` pour le build (`npm ci && npm run build`), puis sortie statique
- Pas de runtime serveur dans ce Dockerfile : le build est copié dans un **volume nommé** (`galaxis-frontend-build`) que `app-caddy` monte en lecture seule sur `/srv/frontend`
- Permet de rebuilder le front sans toucher à Caddy

Alternative acceptable : étape build dans `frontend/Dockerfile`, image finale = `nginx:alpine` qui sert le statique, mais Caddy fait déjà le job → préférer le volume.

### 3. Caddyfiles (un par tier)

#### `deployments/caddy/Caddyfile.iam`
```caddyfile
{
    auto_https disable_redirects
    local_certs
}

galaxis-iam:443, localhost:443 {
    tls internal
    reverse_proxy keycloak:8080
    encode gzip
    log
}
```

#### `deployments/caddy/Caddyfile.app`
```caddyfile
{
    auto_https disable_redirects
    local_certs
}

galaxis-app:443, localhost:443 {
    tls internal
    encode gzip
    log

    handle /api/* {
        root * /srv/api/public
        php_fastcgi app-php:9000
    }

    handle {
        root * /srv/frontend
        try_files {path} /index.html
        file_server
    }
}
```

#### `deployments/caddy/Caddyfile.services`
```caddyfile
{
    auto_https disable_redirects
    local_certs
}

galaxis-vault:443, localhost:443 {
    tls internal
    reverse_proxy vaultwarden:80
    reverse_proxy /notifications/hub vaultwarden:3012
    encode gzip
    log
}

galaxis-cloud:444, localhost:444 {
    tls internal
    reverse_proxy nextcloud:80
    redir /.well-known/carddav /remote.php/dav/ 301
    redir /.well-known/caldav /remote.php/dav/ 301
    encode gzip
    log
}
```

Volumes nommés pour les CA Caddy générés (un par Caddy) pour qu'ils persistent entre les redémarrages :
- `caddy-iam-data`, `caddy-iam-config`
- `caddy-app-data`, `caddy-app-config`
- `caddy-services-data`, `caddy-services-config`

### 4. Configuration Keycloak

Le conteneur `keycloak` doit être configuré pour fonctionner **derrière le reverse proxy `caddy-iam`** :

```yaml
keycloak:
  image: quay.io/keycloak/keycloak:26.0
  command: start --optimized
  environment:
    KC_HOSTNAME: localhost
    KC_HOSTNAME_PORT: 8443
    KC_HOSTNAME_STRICT: false
    KC_HOSTNAME_STRICT_HTTPS: false
    KC_HTTP_ENABLED: true
    KC_PROXY: edge
    KC_DB: postgres
    KC_DB_URL: jdbc:postgresql://keycloak-db:5432/keycloak
    KC_DB_USERNAME: ${KC_DB_USERNAME}
    KC_DB_PASSWORD: ${KC_DB_PASSWORD}
    KEYCLOAK_ADMIN: ${KC_ADMIN}
    KEYCLOAK_ADMIN_PASSWORD: ${KC_ADMIN_PASSWORD}
```

Le redirect URI du client `galaxis-portal` doit être : `https://localhost:9443/auth/callback`.
Web origin : `https://localhost:9443`.

### 5. Configuration Vaultwarden / Nextcloud

#### Vaultwarden
```yaml
vaultwarden:
  image: vaultwarden/server:latest
  environment:
    DOMAIN: https://localhost:10443
    SIGNUPS_ALLOWED: false
    ADMIN_TOKEN: ${VW_ADMIN_TOKEN}
    WEBSOCKET_ENABLED: true
    LOG_LEVEL: info
  volumes:
    - vaultwarden-data:/data
```

#### Nextcloud
```yaml
nextcloud:
  image: nextcloud:apache
  environment:
    POSTGRES_HOST: nextcloud-db
    POSTGRES_DB: nextcloud
    POSTGRES_USER: ${NC_DB_USER}
    POSTGRES_PASSWORD: ${NC_DB_PASSWORD}
    NEXTCLOUD_ADMIN_USER: ${NC_ADMIN_USER}
    NEXTCLOUD_ADMIN_PASSWORD: ${NC_ADMIN_PASSWORD}
    NEXTCLOUD_TRUSTED_DOMAINS: localhost
    OVERWRITEPROTOCOL: https
    OVERWRITEHOST: localhost:11443
    TRUSTED_PROXIES: 172.16.0.0/12
  volumes:
    - nextcloud-data:/var/www/html
```

### 6. Frontend — variables d'env

Le React doit s'adapter à `localhost:9443` côté navigateur du laptop. Dans `frontend/src/lib/oidc.ts` :

```ts
const OIDC_CONFIG = {
  authority: `${import.meta.env.VITE_KC_URL}/realms/galaxis`,
  client_id: 'galaxis-portal',
  redirect_uri: `${window.location.origin}/auth/callback`,
  response_type: 'code',
  scope: 'openid profile email',
  // PKCE auto avec oidc-client-ts
};
```

Variables Vite (`frontend/.env.example`) :
```env
VITE_KC_URL=https://localhost:8443
VITE_API_URL=https://localhost:9443/api
```

Comme c'est un build statique servi par Caddy, ces variables sont **figées au build time**. Documenter clairement que pour changer d'environnement (laptop différent, autre VM), il faut rebuild le front. Pour la démo c'est OK car la commande SSH normalise toujours les ports.

### 7. Bootstrap automatique au premier `docker compose up`

L'objectif : qu'un `git clone && cp .env.example .env && docker compose up -d` suffise pour tout démarrer, **sans étape manuelle**.

Crée un service `init` (ou utilise les `depends_on` + scripts d'entrypoint) qui :
1. Attend que Keycloak soit healthy
2. Lance `configure-keycloak.sh` (crée le realm, le client OIDC, les 5 users de démo)
3. Lance les migrations Laravel
4. Lance le seeder `DemoSeeder`

Option propre : un conteneur `galaxis-init` (image alpine + bash + curl + psql + jq) qui orchestre tout via une stratégie type "init container" Kubernetes, avec un fichier sentinel (`/data/.initialized`) pour idempotence.

Alternative simple : tout mettre dans un script `scripts/bootstrap.sh` lancé depuis le Makefile, qui est idempotent.

### 8. Makefile final

```makefile
.PHONY: help up down logs ps restart demo bootstrap clean nuke test lint

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Démarre toute la stack (11 conteneurs)
	docker compose up -d

down: ## Arrête la stack (conserve les volumes)
	docker compose down

logs: ## Logs en suivi
	docker compose logs -f

ps: ## État des 11 conteneurs
	docker compose ps

restart: down up ## Redémarre

bootstrap: ## Configure Keycloak + migrations + seed (idempotent)
	./scripts/bootstrap.sh

demo: up bootstrap ## Démo complète : up + bootstrap
	@echo ""
	@echo "✅ Démo prête."
	@echo ""
	@echo "Depuis le laptop :"
	@echo "  ssh -L 8443:127.0.0.1:8443 -L 9443:127.0.0.1:9443 -L 10443:127.0.0.1:10443 -L 11443:127.0.0.1:11443 user@<vm-ip>"
	@echo ""
	@echo "Puis ouvrir :"
	@echo "  https://localhost:9443    → Portail Galaxis"
	@echo "  https://localhost:8443    → Keycloak"
	@echo "  https://localhost:10443   → Vaultwarden"
	@echo "  https://localhost:11443   → Nextcloud"
	@echo ""
	@echo "Comptes démo : marc, sophie, julien, chloe, admin / mdp : Demo2026!"

clean: ## Stop + supprime les conteneurs (conserve les volumes)
	docker compose down --remove-orphans

nuke: ## Tout supprime (conteneurs + volumes + réseaux). DANGER.
	docker compose down -v --remove-orphans
	docker volume prune -f

test: ## Tests backend (Pest) + frontend (Vitest)
	docker compose exec app-php php artisan test
	cd frontend && npm test

lint: ## Lint backend + frontend
	docker compose exec app-php ./vendor/bin/pint --test
	cd frontend && npm run lint
```

---

## ✅ Critères de fini

1. ✅ **`docker compose ps` affiche exactement 11 conteneurs** running et healthy
2. ✅ **`docker network ls | grep galaxis` affiche exactement 3 réseaux**
3. ✅ **`docker network inspect galaxis-iam-net`** contient : `caddy-iam`, `keycloak`, `keycloak-db`, `app-php`
4. ✅ **`docker network inspect galaxis-app-net`** contient : `app-caddy`, `app-php`, `app-db`, `app-redis`
5. ✅ **`docker network inspect galaxis-services-net`** contient : `caddy-services`, `vaultwarden`, `nextcloud`, `nextcloud-db`
6. ✅ **`app-php` apparaît dans 2 réseaux** (app-net + iam-net) — c'est le pont JWT
7. ✅ Tous les ports VM sont sur `127.0.0.1` (jamais `0.0.0.0`)
8. ✅ `git clone <repo> && cp .env.example .env && make demo` démarre tout sans intervention manuelle
9. ✅ Depuis le laptop avec le tunnel SSH, le flow complet marche : `https://localhost:9443` → login OIDC PKCE → dashboard avec claims → liens vers Vaultwarden et Nextcloud fonctionnels
10. ✅ Le warning de certificat dans le navigateur est **unique par sous-domaine** au premier accès, puis le navigateur retient
11. ✅ `make test` passe (Pest + Vitest, couverture ≥ 60%)
12. ✅ `make lint` passe
13. ✅ Aucun secret commité (grep manuel sur `password=`, `secret=`, `token=`, `eyJ...`)
14. ✅ Documentation à jour (voir section dédiée ci-dessous)

---

## 📚 Documentation à mettre à jour

### `docs/documentations/technique/01-architecture-poc.md`
Refléter exactement l'architecture des 11 conteneurs + 3 Caddy + 3 réseaux + pont JWT app-php. Schéma Mermaid avec les 11 boîtes + les liens de communication.

### `docs/documentations/technique/04-installation.md`
Réécrire en mode "git clone + docker compose up" :
1. Prérequis : Docker 24+, Docker Compose v2, 4 GB RAM libres, ports 8443/9443/10443/11443 libres sur loopback VM
2. `git clone git@github.com:AstroTechsRepo/Galaxis-POC.git`
3. `cd Galaxis-POC && cp .env.example .env`
4. `make demo`
5. Tunnel SSH depuis le laptop
6. Premier accès aux 4 URLs

### `docs/documentations/technique/05-deploiement-ansible.md`
Mettre à jour : le playbook `00-prereqs.yml` installe **Docker + Docker Compose** sur la cible. Les playbooks 01, 02, 03 deviennent **optionnels** (l'archi conteneurisée se déploie en un seul `docker compose up`). Documenter que les playbooks Ansible restent utiles pour le bootstrap d'une nouvelle VM (Docker, swap, fail2ban, copie du repo).

### `docs/documentations/technique/08-reseaux-docker.md`
Matrice complète des 3 réseaux + appartenance des 11 conteneurs + tableau des 15 flux (slide A01).

### `docs/documentations/demo-guide.md`
- Commande SSH complète avec les 4 `-L`
- Les 4 URLs à mémoriser
- **Procédure de gestion du warning HTTPS** au premier accès (cliquer "avancer" sur chaque URL — c'est attendu, expliqué au jury)
- Comptes démo + scénario de démo (marc en principal, sophie en RBAC user)
- Plan B si un service plante : `docker compose restart <service>`

### `README.md` racine
Quickstart en 3 commandes max :
```bash
git clone git@github.com:AstroTechsRepo/Galaxis-POC.git
cd Galaxis-POC && cp .env.example .env
make demo
```
+ commande SSH laptop + 4 URLs.

### `LIVRAISON.md`
Mettre à jour la section "Comment lancer la démo" avec la nouvelle archi 11 conteneurs.

---

## 🚦 Commits attendus

Conventional Commits, un par feature :

- ✅ `refactor(infra): docker-compose racine avec 11 conteneurs et 3 réseaux conformes aux slides`
- ✅ `refactor(infra): 3 caddyfiles dédiés par tier avec tls internal`
- ✅ `feat(backend): dockerfile multi-stage php-fpm + healthcheck`
- ✅ `feat(frontend): dockerfile multi-stage build + volume partagé caddy`
- ✅ `feat(infra): bootstrap script idempotent (keycloak config + migrations + seed)`
- ✅ `refactor(infra): makefile aligné nouvelle archi + commandes demo`
- ✅ `fix(frontend): variables vite alignées localhost:8443 et localhost:9443`
- ✅ `fix(iam): keycloak configuré derrière reverse proxy caddy-iam (KC_PROXY=edge)`
- ✅ `fix(services): vaultwarden + nextcloud configurés derrière caddy-services`
- ✅ `docs: mise à jour technique/install/réseaux/demo-guide pour la nouvelle archi`
- ✅ `docs: readme racine + livraison + changelog`

---

## 🚢 Push GitHub final

Comme pour les Phases A et B :

```bash
git status
git log --oneline -30
git push origin main
git tag -a v1.1-conteneurise -m "POC GALAXIS 11 conteneurs alignés slides, prêt soutenance"
git push origin v1.1-conteneurise
```

Si tag `v1.0-soutenance` existe déjà, on le garde (c'était l'état avant cette phase C). Le nouveau tag `v1.1-conteneurise` marque l'état "prêt à livrer".

---

## 🚀 Démarre maintenant

Travaille en mode autonome. Relis d'abord les slides citées en haut, puis attaque le refactor.

Si tu détectes que certains travaux de la Phase A sont **réutilisables tels quels** (code Laravel, code React, factories, tests, docs), garde-les et ne les refais pas. C'est uniquement la **couche infrastructure** (compose, Caddy, Dockerfiles, ports, réseaux) qui change. Le code applicatif lui-même est probablement bon.

À la fin, produis un rapport global qui couvre :
1. État des 14 critères de fini
2. Sortie de `docker compose ps` (preuve des 11 conteneurs)
3. Sortie de `docker network ls | grep galaxis` (preuve des 3 réseaux)
4. Sortie de `docker network inspect galaxis-iam-net galaxis-app-net galaxis-services-net --format '{{.Name}}: {{range .Containers}}{{.Name}} {{end}}'` (preuve que app-php est multi-réseau)
5. Liste des commits créés (`git log --oneline v1.0-soutenance..HEAD`)
6. Confirmation push GitHub (lien repo + tag `v1.1-conteneurise`)
7. La commande SSH exacte pour la démo

**Go.**
