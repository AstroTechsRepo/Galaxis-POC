# ============================================================
# Galaxis POC — Makefile
# Cibles principales : demo, up, down, install, test, lint, seed, logs
# ============================================================

.PHONY: help demo up down restart install test lint seed logs ps clean \
        configure-keycloak backend-shell front-shell caddy-reload \
        ansible-prereqs ansible-iam ansible-app ansible-services ansible-all

SHELL := /bin/bash

# Couleurs ANSI pour les messages
BLUE   := \033[34m
PURPLE := \033[35m
CYAN   := \033[36m
GREEN  := \033[32m
YELLOW := \033[33m
RESET  := \033[0m

help: ## Affiche cette aide
	@printf "$(PURPLE)╔══════════════════════════════════════════════════════════════╗$(RESET)\n"
	@printf "$(PURPLE)║$(RESET)  $(CYAN)Galaxis POC$(RESET) — Targets disponibles                         $(PURPLE)║$(RESET)\n"
	@printf "$(PURPLE)╚══════════════════════════════════════════════════════════════╝$(RESET)\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?##/ { printf "  $(BLUE)%-22s$(RESET) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# ----------------------------------------------------------------
# Démo / Lifecycle Docker
# ----------------------------------------------------------------

demo: ## Démarre toute la stack POC (idempotent)
	@printf "$(CYAN)→ Galaxis POC — démarrage complet$(RESET)\n"
	@test -f .env || (printf "$(YELLOW)Création de .env depuis .env.example$(RESET)\n" && cp .env.example .env)
	docker compose up -d --build
	@printf "$(GREEN)✓ Stack démarrée$(RESET)\n"
	@printf "$(CYAN)→ Attente que Keycloak soit prêt (peut prendre ~60s)…$(RESET)\n"
	@./infrastructure/scripts/wait-for-keycloak.sh || true
	@printf "$(CYAN)→ Configuration Keycloak (idempotent)$(RESET)\n"
	@./infrastructure/scripts/configure-keycloak.sh
	@printf "$(GREEN)╔══════════════════════════════════════════════════════════════╗$(RESET)\n"
	@printf "$(GREEN)║  Galaxis POC est prêt$(RESET)                                        $(GREEN)║$(RESET)\n"
	@printf "$(GREEN)║  $(RESET)Sur le laptop : $(CYAN)ssh -L 8080:127.0.0.1:8080 user@<VM_IP>$(RESET) $(GREEN)║$(RESET)\n"
	@printf "$(GREEN)║  $(RESET)Puis ouvrir : $(CYAN)http://localhost:8080$(RESET)                      $(GREEN)║$(RESET)\n"
	@printf "$(GREEN)╚══════════════════════════════════════════════════════════════╝$(RESET)\n"

up: ## Démarre la stack sans rebuild ni configuration
	docker compose up -d

down: ## Arrête tous les conteneurs (volumes conservés)
	docker compose down

restart: down up ## Redémarre toute la stack

clean: ## Arrête tout ET supprime volumes/réseaux (destructif)
	@printf "$(YELLOW)⚠  Cela va supprimer toutes les données (DB, vaults, fichiers)$(RESET)\n"
	@read -p "Confirmer (oui/non) ? " ans && [ "$$ans" = "oui" ]
	docker compose down -v --remove-orphans

ps: ## Liste les conteneurs Galaxis
	@docker compose ps

logs: ## Suit les logs de toute la stack
	docker compose logs -f --tail=100

# ----------------------------------------------------------------
# Installation locale (sans Docker, pour dev)
# ----------------------------------------------------------------

install: ## Installe les dépendances backend (composer) et frontend (npm)
	@printf "$(CYAN)→ Installation backend Laravel$(RESET)\n"
	cd backend && composer install
	@printf "$(CYAN)→ Installation frontend React$(RESET)\n"
	cd frontend && npm ci

# ----------------------------------------------------------------
# Tests et lint
# ----------------------------------------------------------------

test: ## Lance Pest (backend) + Vitest (frontend)
	@printf "$(CYAN)→ Tests backend (Pest)$(RESET)\n"
	cd backend && vendor/bin/pest --coverage --min=60
	@printf "$(CYAN)→ Tests frontend (Vitest)$(RESET)\n"
	cd frontend && npm test -- --coverage

lint: ## PHP-CS-Fixer + ESLint + Prettier
	@printf "$(CYAN)→ Lint backend (Pint)$(RESET)\n"
	cd backend && vendor/bin/pint --test
	@printf "$(CYAN)→ Lint frontend (ESLint + Prettier)$(RESET)\n"
	cd frontend && npm run lint && npm run format:check

# ----------------------------------------------------------------
# Backend / Keycloak helpers
# ----------------------------------------------------------------

seed: ## Lance migrations + seeders Laravel
	docker compose exec app-php php artisan migrate --force
	docker compose exec app-php php artisan db:seed --force

configure-keycloak: ## (Re)joue le script de configuration Keycloak (idempotent)
	./infrastructure/scripts/configure-keycloak.sh

backend-shell: ## Shell dans le conteneur Laravel
	docker compose exec app-php sh

front-shell: ## Shell dans le conteneur frontend (build)
	docker compose exec app-front sh

caddy-reload: ## Reload de la config Caddy sans downtime
	docker compose exec proxy caddy reload --config /etc/caddy/Caddyfile

# ----------------------------------------------------------------
# Déploiement Ansible (depuis poste opérateur vers VM)
# ----------------------------------------------------------------

ansible-prereqs: ## Playbook 00 — pré-requis VM
	cd infrastructure/ansible && ansible-playbook -i inventory playbooks/00-prereqs.yml

ansible-iam: ## Playbook 01 — stack IAM + configure-keycloak
	cd infrastructure/ansible && ansible-playbook -i inventory playbooks/01-iam.yml

ansible-app: ## Playbook 02 — stack APP + migrations
	cd infrastructure/ansible && ansible-playbook -i inventory playbooks/02-app.yml

ansible-services: ## Playbook 03 — stack services
	cd infrastructure/ansible && ansible-playbook -i inventory playbooks/03-services.yml

ansible-all: ansible-prereqs ansible-iam ansible-app ansible-services ## Déploie tout dans l'ordre
