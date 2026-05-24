# Galaxis POC

> **One core. Infinite orbits.**
> L'orchestrateur souverain de votre ecosysteme open source — POC realise par Lucas PEREZ (ESGI 2 - Campus Educative - 2025/2026), edite par AstroTechs.

---

## En une phrase

Galaxis deploie sur **une seule VM Debian**, en **une seule commande**, **11 conteneurs Docker** organises en **3 reseaux isoles** — un portail unifie qui orchestre une IAM (Keycloak 26), un coffre-fort de mots de passe (Vaultwarden) et un drive collaboratif (Nextcloud), le tout en **open source souverain**, accessible via **tunnel SSH** pour la demo.

---

## Demarrage express (3 commandes)

### Sur la VM (deploiement initial)

```bash
git clone git@github.com:AstroTechsRepo/Galaxis-POC.git && cd Galaxis-POC
cp .env.example .env && $EDITOR .env   # remplacez tous les change-me-*
make demo
```

### Sur le laptop (a chaque demo)

```bash
ssh -L 8080:127.0.0.1:8080  \
    -L 9080:127.0.0.1:9080  \
    -L 10180:127.0.0.1:10180 \
    -L 11180:127.0.0.1:11180 \
    user@<VM_IP>
```

### Ouvrir dans le navigateur du laptop

| URL | Brique |
|---|---|
| **`http://localhost:9080`** | Portail Galaxis (entry point) |
| `http://localhost:8080` | Keycloak admin |
| `http://localhost:10180` | Vaultwarden |
| `http://localhost:11180` | Nextcloud |

- Pas de modification `/etc/hosts`
- HTTP plain — zero certificat a installer, zero warning navigateur
- Aucune installation supplementaire sur le laptop

Connectez-vous avec **`marc / Demo2026!`** et explorez votre orbite.

> **5 comptes demo "Atelier Marchand"** disponibles : `marc` (admin), `sophie` (user), `julien` (user), `chloe` (user), `admin` (admin). Mot de passe partage : `Demo2026!`.

---

## Ce que vous verrez

1. **Landing page Galaxis** (`http://localhost:9080`) : fond espace, gradient bleu-violet, tagline *One core. Infinite orbits.*
2. **Login OIDC PKCE** : redirection vers Keycloak (`http://localhost:8080`), login `marc / Demo2026!`, retour authentifie
3. **Dashboard** : *Bienvenue, Marc* + 3 cartes briques + tableau des claims JWT decodes cote serveur
4. **Profil** : session OIDC + journal d'audit (~24 entrees seedees)
5. **Vaultwarden** (`http://localhost:10180`) : coffre-fort de mots de passe
6. **Nextcloud** (`http://localhost:11180`) : drive collaboratif
7. **Keycloak admin** (`http://localhost:8080/admin`) : pour creer / desactiver des comptes

---

## Architecture POC

```
              +---------------------------------------------+
  Laptop -SSH->  VM Debian (127.0.0.1 loopback uniquement) |
              |  +--- caddy-iam (:8080) -----> keycloak     |
              |  +--- app-caddy (:9080) -----> app-php      |
              |  +--- caddy-services ----------+            |
              |       :10180 -> vaultwarden    |            |
              |       :11180 -> nextcloud      |            |
              |                                             |
              |  galaxis-iam-net | galaxis-app-net |         |
              |  galaxis-services-net                       |
              +---------------------------------------------+
```

**11 conteneurs - 3 reseaux Docker isoles - 3 reverse proxies Caddy.**

Details : [doc technique 01](./docs/documentations/technique/01-architecture-poc.md)

---

## Documentation livree au jury

3 documentations dediees dans [`docs/documentations/`](./docs/documentations/) :

| Doc | Pour qui ? | Quoi ? |
|---|---|---|
| [**Technique**](./docs/documentations/technique/README.md) | devs, devops, admin sys | 10 chapitres : archi POC + cible AWS, stack, install, deploiement, IAM, JWT, reseaux, securite, exploitation |
| [**Projet**](./docs/documentations/projet/README.md) | jury, sponsor | 9 chapitres : contexte, persona, valeur, perimetre, archi fonctionnelle, gestion, difficultes, roadmap |
| [**Utilisateur**](./docs/documentations/utilisateur/README.md) | Marc et son equipe TPE | 8 chapitres : premiere connexion, Vaultwarden, Nextcloud, on/offboarding, FAQ, glossaire |

---

## Tests et qualite

```bash
make test    # Pest (backend) + Vitest (frontend)
make lint    # Pint + ESLint + Prettier
```

---

## Commandes utiles

| Commande | Fait quoi ? |
|---|---|
| `make demo` | `up` + `seed` — stack demarree + jeu de donnees demo pret (~3 min) |
| `make seed` | (Re)joue le seed Keycloak + Laravel — idempotent |
| `make up` / `make down` / `make restart` | Cycle de vie sans rebuild |
| `make logs` | Suit les logs de toute la stack |
| `make test` | Pest + Vitest |
| `make lint` | Pint + ESLint + Prettier |
| `make ps` | Statut des conteneurs |
| `make nuke` | SUPPRIME les volumes (destructif) |

---

## Securite du POC

- **PKCE S256** obligatoire (client public React)
- **Validation JWT serveur** : signature RS256, `iss`, `aud`, `exp`, `nbf`
- **Cache JWKS Redis** TTL 5 min + refresh on miss kid
- **CORS strict** : seul `APP_URL` autorise
- **Headers Caddy** : X-Content-Type-Options, X-Frame-Options, Referrer-Policy
- **0 secret commite** (verifie par grep)
- **3 reseaux Docker isoles** (cf. matrice de communication doc 08)
- **Audit log centralise** (table `audit_logs`)

---

## Perimetre

**IN scope POC** : Portail React + Login OIDC PKCE + IAM Keycloak centralise + Vaultwarden + Nextcloud + validation JWT serveur + 3 reseaux Docker isoles + deploiement Ansible.

**OUT scope POC** : SSO bout-en-bout vers Vaultwarden/Nextcloud, MFA, RBAC fin, multi-tenant, migration cloud effective, monitoring, TLS Let's Encrypt (prevu pour la prod cible AWS).

---

## Contact

- **Auteur** : Lucas PEREZ — ESGI 2, Campus Educative
- **Soutenance** : 26 juin 2026
- **Editeur** : AstroTechs

---

## Licence

Code source POC sous licence proprietaire. Les briques tierces gardent leurs licences originales (Keycloak Apache 2.0, Vaultwarden GPLv3, Nextcloud AGPL, Laravel MIT, React MIT, etc.).
