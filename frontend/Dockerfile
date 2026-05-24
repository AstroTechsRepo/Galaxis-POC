# ============================================================
# Galaxis POC v1.1 — Frontend builder (ONE-SHOT)
# Multi-stage : node:20-alpine build → copie dist/* dans /output
# Le volume /output est partagé avec app-caddy en RO sur /srv/frontend
# Le conteneur exit 0 après le copy — il n'est pas "running"
# ============================================================

# ============================================================
# STAGE 1 — build Vite
# ============================================================
FROM node:20-alpine AS builder

WORKDIR /app

# Args build-time pour Vite (figés dans le bundle JS)
ARG VITE_KC_URL=https://localhost:8443
ARG VITE_API_URL=https://localhost:9443/api
ARG VITE_KC_REALM=galaxis
ARG VITE_KC_CLIENT_ID=galaxis-portal

ENV VITE_KC_URL=${VITE_KC_URL} \
    VITE_API_URL=${VITE_API_URL} \
    VITE_KC_REALM=${VITE_KC_REALM} \
    VITE_KC_CLIENT_ID=${VITE_KC_CLIENT_ID}

# Cache layer pour les deps
COPY package.json package-lock.json* ./
RUN npm ci --no-audit --no-fund || npm install --no-audit --no-fund

# Copie code et build
COPY . .
RUN npm run build

# ============================================================
# STAGE 2 — one-shot copy vers volume partagé
# Image minimale (alpine) qui rsync dist/ → /output puis exit
# ============================================================
FROM alpine:3.20 AS copier

LABEL org.opencontainers.image.title="galaxis-frontend-builder" \
      org.opencontainers.image.description="Build statique React copié dans le volume galaxis-frontend-build" \
      org.opencontainers.image.version="1.1"

RUN apk add --no-cache rsync

# Copie le résultat du build
COPY --from=builder /app/dist /dist

# Le entrypoint : rsync vers /output (volume monté) puis exit 0
# --delete supprime les anciens fichiers obsolètes du volume
COPY <<'EOF' /usr/local/bin/deploy-frontend.sh
#!/usr/bin/env sh
set -e
echo "[frontend-builder] Copie de /dist → /output"
mkdir -p /output
rsync -a --delete /dist/ /output/
echo "[frontend-builder] ✓ Copie terminée — $(ls /output | wc -l) entrées dans /output"
ls -la /output | head -20
EOF
RUN chmod +x /usr/local/bin/deploy-frontend.sh

VOLUME ["/output"]

ENTRYPOINT ["/usr/local/bin/deploy-frontend.sh"]
