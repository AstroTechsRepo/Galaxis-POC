# Guide demo — Galaxis POC v1.2 pour la soutenance

> Document a lire avant la soutenance. Lucas, c'est ton fil d'Ariane le jour J.

---

## Avant la soutenance (J-1)

| Done | Tache |
|:-:|---|
| | VM demarree et accessible en SSH depuis le laptop |
| | Sur la VM : `cd ~/Galaxis-POC && git pull && make demo` → attendre "prete" |
| | Sur la VM : `docker compose ps` → tous les conteneurs `Up (healthy)` ou `Up` |
| | Sur le laptop : tunnel SSH (voir commande ci-dessous) |
| | Sur le laptop : ouvrir `http://localhost:9080` → landing visible |
| | Tester un login complet `marc / Demo2026!` → dashboard avec "Bienvenue Marc" |
| | Verifier l'audit log : sur la page Profil, le journal affiche ~24 entrees |
| | Cliquer la carte **Vaultwarden** → s'ouvre dans un nouvel onglet (port 10180) |
| | Cliquer la carte **Nextcloud** → s'ouvre dans un nouvel onglet (port 11180) |
| | Tester aussi `sophie / Demo2026!` pour demontrer le RBAC (role user) |
| | Preparer une video de demo locale (plan B) — captures ecran de chaque etape |
| | Charger la batterie laptop a 100 % + adaptateur HDMI + souris |

---

## Commande tunnel SSH

Depuis le laptop, une seule commande avec 4 forwards :

```bash
ssh -L 8080:127.0.0.1:8080  \
    -L 9080:127.0.0.1:9080  \
    -L 10180:127.0.0.1:10180 \
    -L 11180:127.0.0.1:11180 \
    user@192.168.50.145
```

Laisser cette session SSH ouverte pendant toute la demo.

---

## URLs dans le navigateur (laptop)

| Service | URL | Usage |
|---|---|---|
| **Portail Galaxis** | http://localhost:9080 | Page d'accueil + login OIDC |
| **Keycloak admin** | http://localhost:8080 | Console admin IAM |
| **Vaultwarden** | http://localhost:10180 | Coffre-fort mots de passe |
| **Nextcloud** | http://localhost:11180 | Drive collaboratif |

---

## Procedure de demarrage complet (cold start)

Si la VM a ete rebootee ou si les conteneurs sont arretes :

```bash
# 1. Se connecter en SSH a la VM
ssh user@192.168.50.145

# 2. Aller dans le projet
cd ~/Galaxis-POC

# 3. Demarrer la stack + configurer + seeder
make demo

# 4. Attendre le message "prete" (2-3 min au premier boot)
# 5. Ouvrir un NOUVEAU terminal sur le laptop pour le tunnel SSH
# (voir commande tunnel ci-dessus)
# 6. Ouvrir http://localhost:9080 dans Firefox
```

**Important** : `make demo` fait TOUT (build, start, config Keycloak, migrations, seed). Il n'y a rien d'autre a faire. C'est idempotent, on peut le relancer autant de fois que necessaire.

---

## Si les conteneurs sont deja demarres

Si `docker compose ps` montre les conteneurs deja `Up`, pas besoin de `make demo`. Il suffit de :

1. Monter le tunnel SSH depuis le laptop
2. Ouvrir http://localhost:9080

Pour relancer le seed uniquement :
```bash
make seed
```

---

## Le jour J — sequence de demo (2 min 30)

### Etape 0 — Preparation (avant l'entree du jury)

- 2 fenetres preparees sur le laptop :
  1. **Presentation slides** en plein ecran
  2. **Browser Galaxis** sur `http://localhost:9080`, deja sur la landing
- Tunnel SSH deja actif (verifier 30 s avant)
- 1 terminal ouvert sur la VM avec `docker compose ps` (au cas ou)

### Etape 1 — `docker ps` (~15 s)

> *"Voici les 11 conteneurs qui tournent : Caddy, Keycloak, sa Postgres, Laravel et sa Postgres et Redis, le front React, Vaultwarden, Nextcloud et sa Postgres. Tous healthy."*

Montrer la sortie de `docker compose ps`. Pointer la colonne `STATUS`.

### Etape 2 — `curl /api/health` (~15 s)

> *"La sonde applicative confirme DB ok, Redis ok, JWKS reachable."*

```bash
curl -s http://127.0.0.1:9080/api/health | jq .
```

### Etape 3 — Flow OIDC PKCE complet (~1 min)

1. Browser : `http://localhost:9080` → **landing avec gradient**
2. Cliquer **Se connecter** → redirection vers Keycloak
3. Login **`marc / Demo2026!`** (le persona du discours)
4. Retour automatique sur `/dashboard` → **"Bienvenue Marc"**
5. Montrer les **claims decodes** dans le tableau du bas
6. Cliquer **Profil** → montrer le journal d'audit (~24 entrees des 7 derniers jours)

> *"Le flow : code + PKCE, echange du code, JWT RS256 valide serveur contre les JWKS de Keycloak en cache Redis."*

### Etape 4 — Vaultwarden (~30 s)

1. Cliquer la carte **Vaultwarden** sur le dashboard
2. Nouvel onglet ouvre `http://localhost:10180`
3. Montrer la page d'accueil Vaultwarden

> *"Une brique disponible, accessible par lien depuis le portail. Dans la v2.0, ce sera federe OIDC bout-en-bout — pour le POC, c'est un login local."*

### Etape 5 — `docker network inspect` (~30 s)

```bash
docker network inspect galaxis-iam-net | jq '.[0].Containers | keys'
docker network inspect galaxis-app-net | jq '.[0].Containers | keys'
docker network inspect galaxis-services-net | jq '.[0].Containers | keys'
```

> *"3 reseaux isoles. Keycloak n'est joignable que par le proxy et par app-php — ce dernier pour valider les JWT. Vaultwarden ne peut pas atteindre la DB Keycloak, c'est par design."*

---

## Comptes utilisables pendant la demo

| Username | Email | Role | Quand l'utiliser |
|---|---|---|---|
| **`marc`** | `marc@atelier-marchand.demo` | `admin` | **Demo principale** — le persona du discours |
| `sophie` | `sophie@atelier-marchand.demo` | `user` | Pour demontrer le **RBAC** |
| `julien` | `julien@atelier-marchand.demo` | `user` | Le seul user avec un `login_failure` dans l'audit |
| `chloe` | `chloe@atelier-marchand.demo` | `user` | Sa tentative `access_denied` visible dans l'audit |
| `admin` | `admin@galaxis.demo` | `admin` | Compte technique |

**Mot de passe partage pour tous les comptes** : `Demo2026!`

---

## Points de vigilance

| Risque | Que faire ? |
|---|---|
| Le tunnel SSH lache | Refaire la commande SSH tunnel immediatement |
| Healthcheck rouge sur un conteneur | `docker compose restart <service>` puis attendre |
| Login echoue | Verifier que `make seed` a bien tourne. Sinon relancer : `make seed` |
| L'audit log est vide | Relancer `make seed` |
| Le browser garde un cache trop ancien | Ctrl+Shift+R pour forcer le rechargement |
| Les conteneurs sont arretes apres un reboot | `cd ~/Galaxis-POC && make demo` |
| Port "restricted" dans Firefox | Ne pas utiliser les ports 10080/6000/6666 — les ports actuels (8080, 9080, 10180, 11180) sont compatibles Firefox |

---

## Plan B : demo qui plante en direct

1. **Garder son calme.** Le jury le verra avant vous.
2. Dire calmement : *"On a un imprevu live. J'avais prepare une video de la demo, je vous la montre."*
3. Lancer la **video de demo enregistree la veille** (mp4, 2 min 30, voix off).
4. Commenter en parallele ce qui s'affiche, comme si c'etait live.

---

## Phrases-cles a ne pas oublier

- *"Le tunnel SSH chiffre laptop — VM. En production cible AWS, Caddy + Let's Encrypt prennent le relais."*
- *"3 reseaux Docker isoles, un seul pont volontaire : app-php vers Keycloak pour les JWKS."*
- *"Cache JWKS Redis avec refresh on miss de kid : robuste face a la rotation de cles."*
- *"Le SSO bout-en-bout vers Vaultwarden et Nextcloud est concu, documente, mais OUT scope POC. C'est la v2.0."*

---

## Apres la soutenance

- Tag git : `git tag v1.2-soutenance && git push --tags`
- Sauvegarde des DBs (Postgres dumps + volumes Vaultwarden/Nextcloud)
- Retro perso : qu'est-ce qui a marche, qu'est-ce qu'on referait
