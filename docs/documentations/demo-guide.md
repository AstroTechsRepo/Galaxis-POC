# 🎬 Guide démo — Galaxis POC pour la soutenance

> Document à lire avant la soutenance. Tient en une page A4. Lucas, c'est ton fil d'Ariane le jour J.

---

## ⏱️ Avant la soutenance (J-1)

| ☐ | Tâche |
|:-:|---|
| ☐ | Vérifier que la VM est démarrée et accessible en SSH depuis le laptop |
| ☐ | Sur la VM : `git pull` puis `make demo` → attendre healthy |
| ☐ | Sur la VM : `docker compose ps` → tous les conteneurs `Up (healthy)` ou `Up` |
| ☐ | Sur le laptop : `ssh -L 8080:127.0.0.1:8080 user@<VM_IP>` → test tunnel |
| ☐ | Sur le laptop : ouvrir `http://localhost:8080` → landing visible |
| ☐ | Tester un login complet `lucas-test / demo` → dashboard apparaît |
| ☐ | Cliquer la carte **Vaultwarden** → s'ouvre dans un nouvel onglet |
| ☐ | Cliquer la carte **Nextcloud** → s'ouvre dans un nouvel onglet |
| ☐ | Préparer une vidéo de démo locale (plan B) — captures écran de chaque étape |
| ☐ | Charger la batterie laptop à 100 % + adaptateur HDMI + souris |
| ☐ | Mettre la slide de présentation en plein écran F11 dans Chrome/Firefox |

---

## 🎯 Le jour J — séquence de démo (2 min 30, cf. slide 13)

### Étape 0 — Préparation (avant l'entrée du jury)

- 2 fenêtres préparées sur le laptop :
  1. **Présentation slides** en plein écran
  2. **Browser Galaxis** sur `http://localhost:8080`, déjà sur la landing
- Tunnel SSH déjà actif (vérifier 30 s avant)
- 1 terminal ouvert sur la VM avec `docker compose ps` (au cas où)

### Étape 1 — `docker ps` (~15 s)

> *« Voici les 11 conteneurs qui tournent : Caddy, Keycloak, sa Postgres, Laravel et sa Postgres et Redis, le front React, Vaultwarden, Nextcloud et sa Postgres. Tous healthy. »*

Montrer la sortie de `docker compose ps`. Pointer la colonne `STATUS`.

### Étape 2 — `curl /api/health` (~15 s)

> *« La sonde applicative confirme DB ok, Redis ok, JWKS reachable. »*

```bash
curl -s http://127.0.0.1:8080/api/health | jq .
```

### Étape 3 — Flow OIDC PKCE complet (~1 min)

1. Browser : `http://localhost:8080` → **landing avec gradient**
2. Cliquer **Se connecter** → redirection vers Keycloak (URL `/iam/.../auth`)
3. Login `lucas-test / demo`
4. Retour automatique sur `/dashboard`
5. Montrer les **claims décodés** dans le tableau du bas

> *« Le flow : code + PKCE, échange du code, JWT RS256 validé serveur contre les JWKS de Keycloak en cache Redis. Le tableau du bas montre ce que le backend a lu et accepté. »*

### Étape 4 — Vaultwarden (~30 s)

1. Cliquer la carte **Vaultwarden** sur le dashboard
2. Nouvel onglet ouvre `/vault/`
3. Montrer la page d'accueil Vaultwarden

> *« Une brique disponible, accessible par lien depuis le portail. Dans la v2.0, ce sera fédéré OIDC bout-en-bout — pour le POC, c'est un login local. »*

### Étape 5 — `docker network inspect` (~30 s)

```bash
docker network inspect galaxis-iam-net | jq '.[0].Containers | keys'
docker network inspect galaxis-app-net | jq '.[0].Containers | keys'
docker network inspect galaxis-services-net | jq '.[0].Containers | keys'
```

> *« 3 réseaux isolés. Keycloak n'est joignable que par le proxy et par app-php — ce dernier pour valider les JWT. Vaultwarden ne peut pas atteindre la DB Keycloak, c'est par design. »*

---

## ⚠️ Points de vigilance

| Risque | Que faire ? |
|---|---|
| Le tunnel SSH lâche | Refaire `ssh -L 8080:...` immédiatement, le navigateur va re-tenir |
| Healthcheck rouge sur un conteneur | `docker compose restart <service>` puis attendre |
| Login échoue | Vérifier que le mot de passe `.env` correspond à ce qui a été passé au script `configure-keycloak.sh` |
| Le browser garde un cache trop ancien | Ctrl+Shift+R pour forcer le rechargement |
| `make demo` n'a jamais été relancé après un reboot | `cd /opt/galaxis && make up` (sans rebuild) |

---

## 🛟 Plan B : démo qui plante en direct

Si **vraiment** rien ne marche le jour J :

1. **Garder son calme.** Le jury le verra avant vous.
2. Dire calmement : *« On a un imprévu live. J'avais préparé une vidéo de la démo, je vous la montre. »*
3. Lancer la **vidéo de démo enregistrée la veille** (mp4, 2 min 30, voix off).
4. Commenter en parallèle ce qui s'affiche, comme si c'était live.

> **Une démo plantée + plan B exécuté avec sang-froid laisse une meilleure impression qu'une démo nickel.**

---

## 🎤 Phrases-clés à ne pas oublier

- *« Le tunnel SSH chiffre laptop ↔ VM. En production cible AWS, Caddy + Let's Encrypt prennent le relais. »*
- *« 3 réseaux Docker isolés, un seul pont volontaire : app-php vers Keycloak pour les JWKS. »*
- *« Cache JWKS Redis avec refresh on miss de kid : robuste face à la rotation de clés. »*
- *« Le SSO bout-en-bout vers Vaultwarden et Nextcloud est conçu, documenté, mais OUT scope POC. C'est la v2.0. »*
- *« Ajouter une brique = ajouter une carte dans le portail. »*

---

## 📦 Après la soutenance

- ☐ Tag git : `git tag v1.0-soutenance && git push --tags`
- ☐ Export PDF de la doc unifiée (si pandoc dispo)
- ☐ Sauvegarde des DBs (Postgres dumps + volumes Vaultwarden/Nextcloud)
- ☐ Capture de l'audit log final
- ☐ Rétro perso : qu'est-ce qui a marché, qu'est-ce qu'on referait

---

## 🙏 Bonne soutenance, Lucas.

*« J'espère avoir mis quelques étoiles dans vos yeux. »* — slide 18
