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
| ☐ | Lancer `make seed` une dernière fois → 5 users + ~24 audit_logs prêts |
| ☐ | Tester un login complet `marc / Demo2026!` → dashboard avec « Bienvenue Marc » |
| ☐ | Vérifier l'audit log : sur la page Profil, le journal affiche ~24 entrées |
| ☐ | Cliquer la carte **Vaultwarden** → s'ouvre dans un nouvel onglet |
| ☐ | Cliquer la carte **Nextcloud** → s'ouvre dans un nouvel onglet |
| ☐ | Tester aussi `sophie / Demo2026!` pour démontrer le RBAC (rôle user) |
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
3. Login **`marc / Demo2026!`** (le persona du discours)
4. Retour automatique sur `/dashboard` → **« Bienvenue Marc »**
5. Montrer les **claims décodés** dans le tableau du bas
6. Cliquer **Profil** → montrer le journal d'audit (~24 entrées des 7 derniers jours, dont 1 login_failure de Julien et 1 access_denied de Chloé)

> *« Le flow : code + PKCE, échange du code, JWT RS256 validé serveur contre les JWKS de Keycloak en cache Redis. Le tableau du bas montre ce que le backend a lu et accepté. L'audit log montre que toute l'équipe d'Atelier Marchand est tracée — y compris les tentatives ratées. »*

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

## 🎭 Comptes utilisables pendant la démo

Le jeu de données « Atelier Marchand » est seedé automatiquement par `make seed` (lui-même invoqué par `make demo`). 5 comptes alignés Keycloak ↔ Laravel :

| Username | Email | Rôle | Quand l'utiliser dans la démo |
|---|---|---|---|
| **`marc`** ⭐    | `marc@atelier-marchand.demo`   | `admin` | **Démo principale** — c'est le persona du discours (slide 05). Dashboard, claims, audit log → tout est cohérent narrativement. |
| `sophie`         | `sophie@atelier-marchand.demo` | `user`  | Pour démontrer le **RBAC** : son token n'a pas le rôle admin, donc certaines actions seraient refusées (cf. son `access_denied` dans l'audit). |
| `julien`         | `julien@atelier-marchand.demo` | `user`  | Le seul user avec un `login_failure` dans l'audit log — utile pour montrer la traçabilité des tentatives ratées. |
| `chloe`          | `chloe@atelier-marchand.demo`  | `user`  | Sa tentative d'accès à `/admin/users` apparaît en `access_denied`. |
| `admin`          | `admin@galaxis.demo`           | `admin` | Compte technique, à présenter si on veut un 2e admin distinct de Marc. |

**Mot de passe partagé pour les 5 comptes** : `Demo2026!`

> 💡 **Recommandation séquence** :
> 1. **Démo principale** = login avec **`marc`** (le persona, le dashboard, les claims, l'audit log avec ses 6 connexions de la semaine)
> 2. **Bonus RBAC** = se déconnecter, login avec **`sophie`** → montrer qu'elle voit les mêmes cartes mais que côté backend son rôle est `user` (`/api/me` retourne `"role":"user"`)
>
> ⚠️ **POC démo uniquement** : le mot de passe partagé `Demo2026!` n'est pas une pratique prod. Documenté dans `LIVRAISON.md`.

---

## ⚠️ Points de vigilance

| Risque | Que faire ? |
|---|---|
| Le tunnel SSH lâche | Refaire `ssh -L 8080:...` immédiatement, le navigateur va re-tenir |
| Healthcheck rouge sur un conteneur | `docker compose restart <service>` puis attendre |
| Login échoue | Vérifier que `make seed` a bien tourné (5 users Keycloak + 5 users Laravel + ~24 logs). Sinon relancer : `make seed`. |
| L'audit log est vide | `make seed` n'a pas fini ou a échoué côté Laravel. Relancer : `make seed`. |
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
