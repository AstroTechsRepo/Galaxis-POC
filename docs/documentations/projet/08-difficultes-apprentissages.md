# 08 — Difficultés et apprentissages

> **Audience** : jury, équipe technique, repreneur · **Source slide** : 14 (Dossier de tests et difficultés)

---

## Posture

Plutôt que de prétendre qu'il n'y a pas eu de blocage, ce chapitre **liste honnêtement** ce qui a coincé, comment on s'en est sorti, et ce qu'on en retient pour la v2 et pour les futurs projets.

---

## 1. Conception en amont — arbitrer POC vs cible

### La difficulté

Dès le démarrage, il a fallu choisir : *« On code d'abord le POC mono-VM, puis on réfléchira au cloud ? Ou on dessine la cible AWS dès le début et on rétro-projette ? »*

Le risque de la première approche : faire des choix POC incompatibles avec la cible (ex : se cabler sur SQLite en POC puis devoir réécrire pour RDS).
Le risque de la seconde : sur-architecturer le POC, perdre du temps.

### La solution

**Dessiner la cible AWS au cadrage** (slide 11) **sans la coder**, puis ne choisir en POC que des briques **compatibles** avec cette cible :

- PostgreSQL POC = PostgreSQL RDS cible
- Redis POC = ElastiCache cible
- Docker Compose POC = ECS Fargate cible
- Caddy POC = ALB + ACM cible

Aucune rupture de pattern. La migration sera une migration **de produit**, pas **de paradigme**.

### Apprentissage

> **Dessiner la cible avant le POC, mais coder le POC avant la cible.** Les deux exercices se nourrissent.

---

## 2. Validation JWT serveur — gestion fine des erreurs

### La difficulté

Implémenter la validation JWT, c'est facile en théorie : prendre `firebase/php-jwt`, lui passer la clé publique, voilà.

En vrai :
- L'audience peut être une **string** ou un **array** dans le JWT
- Le `kid` change quand Keycloak rotate ses clés (rare mais arrive)
- Le décalage d'horloge VM/Keycloak peut faire rejeter un token "frais"
- L'issuer peut être en URL **interne** Docker (`http://keycloak:8080/realms/galaxis`) ou en URL **publique** (`http://localhost:8080/realms/galaxis`) selon qui émet le test

### La solution

- `aud` accepté comme string OU array (`array_intersect`)
- Cache JWKS Redis avec **refresh sur miss de `kid`** (et pas seulement TTL expiré)
- `JWT::$leeway = 30s` tolérance horloge
- Issuer accepté en URL publique **ET** URL interne (utile pour les tests cross-container)
- 8 tests Pest spécifiques (cf. `JwtMiddlewareTest.php`)

### Apprentissage

> **Les bibliothèques crypto ne pardonnent pas la précipitation.** Lire la RFC OAuth 2.0 (RFC 6749 + 8252 PKCE) avant de coder, pas après le premier bug.

---

## 3. Isolation réseau Docker — passerelles inévitables

### La difficulté

L'idéal : 3 réseaux totalement étanches. La réalité : `app-php` doit pouvoir appeler Keycloak pour les JWKS. Comment isoler tout en laissant ce pont sans le rendre trivial à exploiter ?

### La solution

- `app-php` est branché sur `app-net` ET `iam-net` (single bridge documenté)
- Aucun autre service applicatif n'a accès à `iam-net`
- En cible AWS : ce sera un **Security Group rule** précis (port 8080 entrant sur SG Keycloak depuis SG app-php uniquement)

### Apprentissage

> **L'isolation parfaite n'existe pas.** Documentez vos passerelles, justifiez-les, écrivez des tests qui vérifient qu'elles sont les seules.

---

## 4. La galère HTTPS/HTTP du POC

### La difficulté

Initialement, la slide 10 prévoyait **HTTPS partout avec CA locale Caddy**. C'était propre techniquement. Mais à la première démo blanche : *« Tu veux que j'importe quel certificat dans mon Firefox ? Et je dois éditer mon `/etc/hosts` ? »*

Conclusion : **pour une démo jury, c'est impraticable.**

### La solution

Pivot vers HTTP en interne sur la VM + chiffrement par tunnel SSH :
- Aucun certif à importer
- Pas de `/etc/hosts`
- Pas de warning navigateur
- Le SSH chiffre **vraiment** le trafic laptop ↔ VM (c'est son métier)
- La cible AWS, elle, aura du vrai TLS via ACM + ALB

Discours assumé au jury : *« Le POC démontre les flux et la sécurité applicative. Le TLS est traité par l'infra AWS en cible. Ne pas confondre POC et prod. »*

### Apprentissage

> **La démo est un produit en soi.** Ce qui passe en CI doit aussi passer "en showroom". Couper la friction d'accès, c'est aussi de l'ingénierie produit.

---

## 5. Tests d'intégration sans casser l'isolation

### La difficulté

En env de test (`phpunit.xml`), pas de Keycloak ni de Redis disponibles. Comment tester le middleware JWT sans dépendre d'un IdP réel ?

### La solution

- Générer une **paire de clés RSA à la volée** dans Pest (`openssl_pkey_new`)
- Publier un faux JWKS dans le cache `array` Laravel via un helper `publishMockJwks()`
- Signer les tokens de test avec la clé privée correspondante
- Les 8 tests couvrent tous les cas : signature OK, signature KO, kid inconnu, iss/aud/exp invalides, etc.

### Apprentissage

> **Les helpers de test sont du code. Soigne-les comme du code de production.** `tests/Pest.php` est ce qui rend les 8 tests JWT lisibles et maintenables.

---

## 6. Direction artistique cohérente sans designer pro

### La difficulté

Lucas n'est pas designer. Les slides ont une DA très soignée (gradient bleu→violet, fond espace, glassmorphism). Reproduire ça dans le frontend sans tomber dans le "POC moche".

### La solution

- **Extraire la DA des slides directement** (CSS variables des `<style>` slide 01)
- Centraliser dans `frontend/src/styles/tokens.ts` (source unique de vérité)
- Étendre Tailwind avec ces tokens (`tailwind.config.ts`)
- Composants `<OrbBackground>`, `<Logo>`, classes `.galaxis-text-gradient`, `.galaxis-card` qui partagent ces tokens
- Pas de pixel-perfect, juste de la cohérence

### Apprentissage

> **Le design system est un contrat.** Une fois posé, on ne refait pas chaque composant en réinventant les couleurs.

---

## 7. Documentation à 3 audiences distinctes

### La difficulté

Écrire la même information **3 fois** sous 3 angles (technique, projet, utilisateur) sans devenir incohérent ni se contredire.

### La solution

- **Source de vérité unique** = code + slides + EXPLORATION.md
- Chaque doc référence l'autre via liens relatifs
- Chaque doc a son **ton dédié** et son **vocabulaire dédié** (jargon assumé en technique, pédagogie en utilisateur)
- Relecture croisée : *« Est-ce que Marc comprendrait ce paragraphe ? »* avant chaque section utilisateur

### Apprentissage

> **L'audience guide le ton.** Ne pas écrire pour soi, écrire pour quelqu'un en particulier — un lecteur incarné, pas abstrait.

---

## 8. Ce qui reste **non résolu** à ce jour

(extrait slide 14)

| Sujet | Statut |
|---|---|
| **SSO Keycloak ↔ services métier** (Vaultwarden, Nextcloud) | conçu, non implémenté |
| **Migration cloud effective** | architecture cible dessinée, déploiement non testé |
| **Tests E2E Playwright** | identifiés, pas écrits |
| **Tests de charge API** | identifiés, pas joués |
| **MFA Keycloak** | activable dans la config, non POC |
| **CI/CD GitHub Actions** | hors POC, à faire pour le v2 |

C'est cohérent avec la slide 7 (OUT scope) et la roadmap (chapitre 09).

---

## 9. Ce qu'on garde précieusement

| Pratique | Pourquoi on continue |
|---|---|
| **Conventional Commits** | git log lisible, automation possible (changelog auto) |
| **Doc d'exploration en début de projet** | force à clarifier avant de coder |
| **Tests qui couvrent la sécurité** (JWT) | non négociable même en POC |
| **Mermaid dans le Markdown** | versionnable, pas d'outil externe à installer |
| **Tokens DA centralisés** | un changement de couleur = un fichier, pas 20 |
| **Scripts shell idempotents** | rejouables, débugables, lisibles |
| **Cible AWS dessinée AVANT le POC** | guide les choix sans les forcer |

---

## 10. Conseils à un futur étudiant qui referait ce projet

1. **Cadre serré, livre fini.** Tu auras toujours envie d'ajouter "juste une feature". Ne le fais pas.
2. **Écris la doc en parallèle du code, pas après.** À la fin du projet, tu n'auras ni l'énergie ni la lucidité.
3. **Démontre que ça marche, pas que c'est joli.** Une démo qui plante, c'est pire qu'une démo sobre.
4. **Le jury n'est pas que tech.** Une diapo trop technique le perd ; une trop business le frustre. Calibre.
5. **Le tunnel SSH est ton ami.** N'oblige personne à toucher son `/etc/hosts`.

---

## Liens internes

- Périmètre : [05-perimetre-decisions.md](./05-perimetre-decisions.md)
- Gestion projet : [07-gestion-projet.md](./07-gestion-projet.md)
- Roadmap : [09-roadmap.md](./09-roadmap.md)
