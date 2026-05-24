# ============================================================
# Galaxis POC — Frontend
# Multi-stage : build Vite → image Caddy ultra légère
# ============================================================

# ---- Stage 1 : build
FROM node:20-alpine AS builder
WORKDIR /app

# Args VITE_ injectés depuis docker-compose
ARG VITE_API_BASE=/api
ARG VITE_KC_BASE=/iam
ARG VITE_KC_REALM=galaxis
ARG VITE_KC_CLIENT_ID=galaxis-portal
ARG VITE_PUBLIC_ORIGIN=http://localhost:8080

ENV VITE_API_BASE=${VITE_API_BASE} \
    VITE_KC_BASE=${VITE_KC_BASE} \
    VITE_KC_REALM=${VITE_KC_REALM} \
    VITE_KC_CLIENT_ID=${VITE_KC_CLIENT_ID} \
    VITE_PUBLIC_ORIGIN=${VITE_PUBLIC_ORIGIN}

COPY package.json package-lock.json* ./
RUN npm ci --no-audit --no-fund || npm install --no-audit --no-fund

COPY . .
RUN npm run build

# ---- Stage 2 : runtime caddy
FROM caddy:2.8-alpine AS runtime
WORKDIR /srv
COPY --from=builder /app/dist /srv
COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 80
