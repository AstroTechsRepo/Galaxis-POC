# ============================================================
# Galaxis POC v1.2 — Makefile (archi 100% conteneurisée)
# 11 conteneurs · 3 Caddy · 3 réseaux · HTTP plain (zero cert)
# ============================================================

.PHONY: help up down restart logs ps demo bootstrap clean nuke \
        test test-backend test-frontend lint lint-backend lint-frontend \
        seed configure-keycloak backend-shell frontend-shell \
        ansible-prereqs ansible-all

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
	@printf "$(P)║$(X)  $(C)Galaxis POC v1.2$(X) — Makefile (11 conteneurs)              $(P)║$(X)\n"
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
	@printf "$(G)║  ✅ Démo Galaxis POC v1.2 prête$(X)                              $(G)║$(X)\n"
	@printf "$(G)╠══════════════════════════════════════════════════════════════╣$(X)\n"
	@printf "$(G)║  $(X)Depuis le laptop, un seul tunnel SSH avec 4 forwards :       $(G)║$(X)\n"
	@printf "$(G)║$(X)\n"
	@printf "$(C)║    ssh -L 8080:127.0.0.1:8080  -L 9080:127.0.0.1:9080 \\$(X)\n"
	@printf "$(C)║        -L 10180:127.0.0.1:10180 -L 11180:127.0.0.1:11180 \\$(X)\n"
	@printf "$(C)║        user@<vm-ip>$(X)\n"
	@printf "$(G)║$(X)\n"
	@printf "$(G)║  $(X)Puis ouvrir dans le navigateur :                              $(G)║$(X)\n"
	@printf "$(G)║    $(C)http://localhost:9080$(X)    → Portail Galaxis $(G)              ║$(X)\n"
	@printf "$(G)║    $(C)http://localhost:8080$(X)    → Keycloak admin $(G)               ║$(X)\n"
	@printf "$(G)║    $(C)http://localhost:10180$(X)   → Vaultwarden $(G)                  ║$(X)\n"
	@printf "$(G)║    $(C)http://localhost:11180$(X)   → Nextcloud $(G)                    ║$(X)\n"
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
	@printf "$(Y)⚠  Cela va supprimer TOUTES les données (DB, vaults, fichiers)$(X)\n"
	@read -p "Confirmer (oui/non) ? " ans && [ "$$ans" = "oui" ]
	docker compose down -v --remove-orphans

# ----------------------------------------------------------------
# Shells utilitaires
# ----------------------------------------------------------------

backend-shell: ## Shell dans app-php
	docker compose exec app-php sh

frontend-shell: ## Shell dans frontend-builder (one-shot recréé à la volée)
	docker compose run --rm --no-deps --entrypoint sh frontend-builder

# ----------------------------------------------------------------
# Déploiement Ansible (depuis poste opérateur vers VM cible)
# ----------------------------------------------------------------

ansible-prereqs: ## Playbook 00 — Docker + swap + UFW + fail2ban + clone repo
	cd infrastructure/ansible && ansible-playbook -i inventory playbooks/00-prereqs.yml

ansible-all: ansible-prereqs ## Prépare la VM, puis 'make demo' fait le reste
	@printf "$(G)→ VM préparée. Maintenant sur la VM :$(X)\n"
	@printf "   $(C)cd /opt/galaxis && cp .env.example .env && \$$EDITOR .env && make demo$(X)\n"
