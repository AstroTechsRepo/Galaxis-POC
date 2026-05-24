# ============================================================
# Galaxis POC — Documentation builder
# Génère un PDF unifié des 3 documentations (si pandoc dispo).
# ============================================================

OUT := Galaxis_Documentation_Complete.pdf
TITLE := Galaxis POC — Documentation complète
SUBTITLE := Technique · Projet · Utilisateur
AUTHOR := Lucas PEREZ — ESGI 2 / AstroTechs / 2025-2026

# Concaténation déterministe : index global → 3 docs dans l'ordre
SOURCES := \
  README.md \
  technique/README.md \
  technique/01-architecture-poc.md \
  technique/02-architecture-cible.md \
  technique/03-stack-technique.md \
  technique/04-installation.md \
  technique/05-deploiement-ansible.md \
  technique/06-iam-keycloak.md \
  technique/07-flow-oidc-jwt.md \
  technique/08-reseaux-docker.md \
  technique/09-securite.md \
  technique/10-exploitation.md \
  projet/README.md \
  projet/01-contexte-marche.md \
  projet/02-fiche-projet.md \
  projet/03-persona-roles.md \
  projet/04-proposition-valeur.md \
  projet/05-perimetre-decisions.md \
  projet/06-architecture-fonctionnelle.md \
  projet/07-gestion-projet.md \
  projet/08-difficultes-apprentissages.md \
  projet/09-roadmap.md \
  utilisateur/README.md \
  utilisateur/01-premiere-connexion.md \
  utilisateur/02-gerer-mes-acces.md \
  utilisateur/03-vaultwarden-bases.md \
  utilisateur/04-nextcloud-bases.md \
  utilisateur/05-onboarding-collaborateur.md \
  utilisateur/06-offboarding.md \
  utilisateur/07-faq.md \
  utilisateur/08-glossaire.md

.PHONY: pdf html clean help

help:
	@echo "Targets : pdf, html, clean"
	@echo "  pdf   : génère $(OUT) (nécessite pandoc + (xelatex|wkhtmltopdf))"
	@echo "  html  : génère un HTML monolithique (fallback si pandoc-PDF KO)"

pdf:
	@which pandoc >/dev/null || (echo "pandoc requis : sudo apt install pandoc texlive-xetex"; exit 1)
	@echo "→ Génération $(OUT)…"
	@pandoc $(SOURCES) \
	  --from=gfm+yaml_metadata_block \
	  --to=pdf \
	  --pdf-engine=xelatex \
	  --toc --toc-depth=2 \
	  --top-level-division=chapter \
	  --variable=geometry:a4paper,margin=2cm \
	  --variable=mainfont:"DejaVu Sans" \
	  --variable=monofont:"DejaVu Sans Mono" \
	  --metadata title="$(TITLE)" \
	  --metadata subtitle="$(SUBTITLE)" \
	  --metadata author="$(AUTHOR)" \
	  --metadata date="$$(date +%Y-%m-%d)" \
	  -o $(OUT)
	@echo "✓ $(OUT) généré"

html:
	@which pandoc >/dev/null || (echo "pandoc requis"; exit 1)
	@pandoc $(SOURCES) \
	  --from=gfm \
	  --to=html5 \
	  --standalone \
	  --toc --toc-depth=2 \
	  --metadata title="$(TITLE)" \
	  -o Galaxis_Documentation_Complete.html
	@echo "✓ Galaxis_Documentation_Complete.html généré"

clean:
	rm -f $(OUT) Galaxis_Documentation_Complete.html
