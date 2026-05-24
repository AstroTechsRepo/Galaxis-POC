# 08 — Réseaux Docker isolés

> **Audience** : devops, sécurité réseau · **Version** : v1.1-conteneurise · **Source** : `docker-compose.yml`, slides 10, 12, A01

---

## Pourquoi 3 réseaux

Par défaut, Docker met tous les services dans un seul bridge. Galaxis **segmente** pour limiter le blast radius : un Nextcloud compromis ne peut pas scanner Keycloak.

---

## Tableau d'attachement des 11 conteneurs

| Conteneur | iam-net | app-net | services-net |
|---|:---:|:---:|:---:|
| `caddy-iam` | ✅ | | |
| `keycloak` | ✅ | | |
| `keycloak-db` | ✅ | | |
| `app-caddy` | | ✅ | |
| **`app-php`** | **✅** | **✅** | |
| `app-db` | | ✅ | |
| `app-redis` | | ✅ | |
| `caddy-services` | | | ✅ |
| `vaultwarden` | | | ✅ |
| `nextcloud` | | | ✅ |
| `nextcloud-db` | | | ✅ |

**Un seul pont** : `app-php` est sur `iam-net` + `app-net` pour valider les JWT contre les JWKS de Keycloak (slide 12). Aucune autre passerelle n'existe.

---

## Matrice de communication autorisée

| Source ↓ \ Cible → | caddy-iam | keycloak | keycloak-db | app-caddy | app-php | app-db | app-redis | caddy-svc | vaultwarden | nextcloud | nextcloud-db |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **caddy-iam** | — | ✅ | | | | | | | | | |
| **keycloak** | | — | ✅ | | | | | | | | |
| **app-caddy** | | | | — | ✅ | | | | | | |
| **app-php** | | ✅ | | | — | ✅ | ✅ | | | | |
| **caddy-svc** | | | | | | | | — | ✅ | ✅ | |
| **nextcloud** | | | | | | | | | | — | ✅ |

Tout le reste est **bloqué** par l'isolation réseau Docker.

---

## Vérifier l'isolation

```bash
# Les 3 réseaux
docker network ls --filter "name=galaxis"

# Membres de chaque réseau
docker network inspect galaxis-iam-net --format '{{.Name}}: {{range .Containers}}{{.Name}} {{end}}'
docker network inspect galaxis-app-net --format '{{.Name}}: {{range .Containers}}{{.Name}} {{end}}'
docker network inspect galaxis-services-net --format '{{.Name}}: {{range .Containers}}{{.Name}} {{end}}'

# app-php DOIT apparaître dans 2 réseaux (le pont JWT)
docker inspect app-php --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}'

# Test d'isolation : vaultwarden NE PEUT PAS joindre keycloak
docker exec vaultwarden timeout 2 sh -c 'cat </dev/tcp/keycloak/8080' 2>&1 || echo "Bloqué (attendu)"
```

---

## Ports VM (loopback uniquement)

| Port hôte | Bind | Caddy → brique | Protocole | URL laptop |
|---|---|---|---|---|
| `127.0.0.1:8080` | loopback | caddy-iam:80 → Keycloak | HTTP | `http://localhost:8080` |
| `127.0.0.1:9080` | loopback | app-caddy:80 → React + API | HTTP | `http://localhost:9080` |
| `127.0.0.1:10180` | loopback | caddy-services:80 → Vaultwarden | HTTP | `http://localhost:10180` |
| `127.0.0.1:11180` | loopback | caddy-services:81 → Nextcloud | HTTP | `http://localhost:11180` |

**Aucun port sur `0.0.0.0`.** L'accès externe passe exclusivement via tunnel SSH.

---

## Liens internes
- Architecture complète : [01-architecture-poc.md](./01-architecture-poc.md)
- Sécurité : [09-securite.md](./09-securite.md)
