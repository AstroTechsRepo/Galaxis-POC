# ============================================================
# Galaxis POC v1.1 — Makefile (archi 100% conteneurisée)
# 11 conteneurs · 3 Caddy · 3 réseaux · HTTPS via CA locale Caddy
# ============================================================

.PHONY: help up down restart logs ps demo bootstrap clean nuke \
        test test-backend test-frontend lint lint-backend lint-frontend \
        seed configure-keycloak backend-shell frontend-shell \
        ca ca-iam ca-app ca-services \
        ansible-prereqs ansible-iam ansible-app ansible-services ansible-all

SHELL := /bin/bash

# Couleurs
B := \033[34m
P := \033[35m
C := \033[36m
G := \033[32m
Y := \033[33m
X := \033[0m

help: ## Affiche cette aide
	@printf "$(P)╔══════════════════════════════════════════════════════════════╗$(X)\n"
	@printf "$(P)║$(X)  $(C)Galaxis POC v1.1$(X) — Makefile (11 conteneurs)              $(P)║$(X)\n"
	@printf "$(P)╚══════════════════════════════════════════════════════════════╝$(X)\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?##/ { printf "  $(B)%-22s$(X) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# ----------------------------------------------------------------
# Cycle de vie de la stack
# ----------------------------------------------------------------

up: ## Démarre les 11 conteneurs (build si nécessaire)
	@printf "$(C)→ Galaxis POC — docker compose up$(X)\n"
	@test -f .env || (printf "$(Y)Création de .env depuis .env.example$(X)\n" && cp .env.example .env)
	docker compose up -d --build
	@printf "$(G)✓ Stack démarrée — vérification du statut :$(X)\n"
	@docker compose ps --format "table {{.Name}}\t{{.Status}}"

down: ## Arrête la stack (conserve les volumes)
	docker compose down

restart: ## Redémarre toute la stack (down + up)
	docker compose down
	$(MAKE) up

logs: ## Suit les logs en temps réel (tous services)
	docker compose logs -f --tail=120

ps: ## État des 11 conteneurs running
	@docker compose ps

# ----------------------------------------------------------------
# Démarrage démo (one-liner pour le jury)
# ----------------------------------------------------------------

demo: up bootstrap ## Démo complète : up + bootstrap (Keycloak + migrations + seed)
	@printf "$(G)╔══════════════════════════════════════════════════════════════╗$(X)\n"
	@printf "$(G)║  ✅ Démo Galaxis POC v1.1 prête$(X)                              $(G)║$(X)\n"
	@printf "$(G)╠══════════════════════════════════════════════════════════════╣$(X)\n"
	@printf "$(G)║  $(X)Depuis le laptop, un seul tunnel SSH avec 4 forwards :       $(G)║$(X)\n"
	@printf "$(G)║$(X)\n"
	@printf "$(C)║    ssh -L 8443:127.0.0.1:8443 -L 9443:127.0.0.1:9443 \\$(X)\n"
	@printf "$(C)║        -L 10443:127.0.0.1:10443 -L 11443:127.0.0.1:11443 \\$(X)\n"
	@printf "$(C)║        user@<vm-ip>$(X)\n"
	@printf "$(G)║$(X)\n"
	@printf "$(G)║  $(X)Puis ouvrir dans le navigateur :                              $(G)║$(X)\n"
	@printf "$(G)║    $(C)https://localhost:9443$(X)   → Portail Galaxis $(G)              ║$(X)\n"
	@printf "$(G)║    $(C)https://localhost:8443$(X)   → Keycloak admin $(G)               ║$(X)\n"
	@printf "$(G)║    $(C)https://localhost:10443$(X)  → Vaultwarden $(G)                  ║$(X)\n"
	@printf "$(G)║    $(C)https://localhost:11443$(X)  → Nextcloud $(G)                    ║$(X)\n"
	@printf "$(G)║$(X)\n"
	@printf "$(G)║  $(X)Comptes : $(C)marc · sophie · julien · chloe · admin$(X)            $(G)║$(X)\n"
	@printf "$(G)║  $(X)Mot de passe partagé : $(C)Demo2026!$(X)                            $(G)║$(X)\n"
	@printf "$(G)╚══════════════════════════════════════════════════════════════╝$(X)\n"

bootstrap: ## Idempotent : attend Keycloak, configure realm + 5 users, migre + seed
	@./scripts/bootstrap.sh

# Alias rétro-compatibles
seed: bootstrap ## Alias rétro-compatible vers bootstrap
configure-keycloak: ## (Re)joue uniquement la config Keycloak
	./infrastructure/scripts/configure-keycloak.sh

# ----------------------------------------------------------------
# Tests & lint
# ----------------------------------------------------------------

test: test-backend test-frontend ## Tests Pest (backend) + Vitest (frontend)

test-backend: ## Tests Pest backend dans le conteneur app-php
	docker compose exec -T app-php php artisan test --no-interaction

test-frontend: ## Tests Vitest frontend (depuis l'image frontend-builder)
	docker compose run --rm --no-deps frontend-builder sh -c "cd /app && npm test"

lint: lint-backend lint-frontend ## Lint backend + frontend

lint-backend: ## Pint (PSR-12) dans le conteneur app-php
	docker compose exec -T app-php vendor/bin/pint --test

lint-frontend: ## ESLint + Prettier (image frontend-builder)
	docker compose run --rm --no-deps frontend-builder sh -c "cd /app && npm run lint && npm run format:check"

# ----------------------------------------------------------------
# Cleanup
# ----------------------------------------------------------------

clean: ## Arrête + supprime les conteneurs (conserve les volumes)
	docker compose down --remove-orphans

nuke: ## ⚠ DESTRUCTIF — supprime conteneurs + volumes + réseaux
	@printf "$(Y)⚠  Cela va supprimer TOUTES les données (DB, vaults, fichiers, CA Caddy)$(X)\n"
	@read -p "Confirmer (oui/non) ? " ans && [ "$$ans" = "oui" ]
	docker compose down -v --remove-orphans
	-docker volume rm $$(docker volume ls -q | grep '^galaxis_\|caddy-iam\|caddy-app\|caddy-services\|app-db\|app-redis\|keycloak-db\|nextcloud\|vaultwarden') 2>/dev/null || true

# ----------------------------------------------------------------
# Shells utilitaires
# ----------------------------------------------------------------

backend-shell: ## Shell dans app-php
	docker compose exec app-php sh

frontend-shell: ## Shell dans frontend-builder (one-shot recréé à la volée)
	docker compose run --rm --no-deps --entrypoint sh frontend-builder

# ----------------------------------------------------------------
# CA locale Caddy — récupération pour pré-import navigateur
# ----------------------------------------------------------------

ca: ca-iam ca-app ca-services ## Récupère les 3 CA Caddy (un par tier) dans ./ca/

ca-iam: ## Récupère le CA Caddy du tier IAM dans ./ca/caddy-iam.crt
	@mkdir -p ca
	docker cp caddy-iam:/data/caddy/pki/authorities/local/root.crt ca/caddy-iam.crt
	@printf "$(G)✓ CA IAM exporté : ca/caddy-iam.crt$(X) — à importer dans le navigateur du laptop\n"

ca-app: ## Récupère le CA Caddy du tier APP dans ./ca/caddy-app.crt
	@mkdir -p ca
	docker cp app-caddy:/data/caddy/pki/authorities/local/root.crt ca/caddy-app.crt
	@printf "$(G)✓ CA APP exporté : ca/caddy-app.crt$(X)\n"

ca-services: ## Récupère le CA Caddy du tier SERVICES dans ./ca/caddy-services.crt
	@mkdir -p ca
	docker cp caddy-services:/data/caddy/pki/authorities/local/root.crt ca/caddy-services.crt
	@printf "$(G)✓ CA SERVICES exporté : ca/caddy-services.crt$(X)\n"

# ----------------------------------------------------------------
# Déploiement Ansible (depuis poste opérateur vers VM cible)
# ----------------------------------------------------------------

ansible-prereqs: ## Playbook 00 — Docker + swap + UFW + fail2ban + clone repo
	cd infrastructure/ansible && ansible-playbook -i inventory playbooks/00-prereqs.yml

ansible-iam: ## Playbook 01 — déprécié v1.1 (tout est dans le compose racine)
	@printf "$(Y)Note v1.1 : l'archi conteneurisée se déploie en 'docker compose up' unique.$(X)\n"
	@printf "$(Y)Ce playbook reste utile pour rejouer uniquement le tier IAM en cas de souci.$(X)\n"
	cd infrastructure/ansible && ansible-playbook -i inventory playbooks/01-iam.yml

ansible-app: ## Playbook 02 — déprécié v1.1 (idem)
	cd infrastructure/ansible && ansible-playbook -i inventory playbooks/02-app.yml

ansible-services: ## Playbook 03 — déprécié v1.1 (idem)
	cd infrastructure/ansible && ansible-playbook -i inventory playbooks/03-services.yml

ansible-all: ansible-prereqs ## v1.1 : 00-prereqs prépare la VM puis 'make demo' fait le reste
	@printf "$(G)→ VM préparée. Maintenant sur la VM :$(X)\n"
	@printf "   $(C)cd /opt/galaxis && cp .env.example .env && \$$EDITOR .env && make demo$(X)\n"
