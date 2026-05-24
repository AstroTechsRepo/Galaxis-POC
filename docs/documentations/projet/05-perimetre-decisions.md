# 05 — Périmètre et décisions de cadrage

> **Audience** : jury, équipe technique, futur repreneur · **Source slide** : 07 (macro-périmètre)

---

## Le principe : un POC honnête

Un POC qui tente de tout couvrir devient un POC qui ne convainc personne. Galaxis assume **un périmètre serré** mais **fini, propre, et démontrable**.

> Règle d'or du cadrage : *« Si on doit choisir entre montrer mal beaucoup ou montrer bien peu, on choisit toujours bien peu. »*

---

## Matrice IN / OUT scope (issue slide 07)

### ✅ IN scope — implémenté dans le POC

| Domaine | Items |
|---|---|
| **Fonctionnalités** | • Portail Galaxis (React) <br> • Login OIDC + PKCE <br> • IAM Keycloak centralisé <br> • Vaultwarden (mots de passe) <br> • Nextcloud (drive) |
| **Conception** | • 3 réseaux Docker isolés <br> • Validation JWT serveur RS256 |
| **Déploiement** | • Ansible scripté (4 playbooks idempotents) |
| **Sécurité** | • Cache JWKS Redis <br> • CORS strict <br> • Headers de sécurité Caddy <br> • Audit log applicatif <br> • 0 secret commité |

### 🟡 OUT of scope — conçu, documenté, à suivre

| Domaine | Items | Pourquoi reporté |
|---|---|---|
| **Fonctionnalités** | • SSO bout-en-bout vers les services métier (Vaultwarden/Nextcloud) <br> • Multi-tenant (1 realm = 1 client pour l'instant) <br> • Provisioning auto utilisateur (SCIM) <br> • Monitoring (Prometheus / Loki) <br> • MFA <br> • RBAC fin par groupe | Complexité élevée vs valeur démo : on montre le **flow** pas l'**exhaustivité** |
| **Conception** | • Passage cloud multi-VPC AWS <br> • IaC Terraform <br> • CI/CD GitHub Actions | Cible documentée (chapitre 02), implémentation phase post-soutenance |
| **TLS** | • Let's Encrypt en prod | Le POC tourne en HTTP via tunnel SSH (cf. choix démo) |

### 🔴 Hors-périmètre absolu

| Items | Raison |
|---|---|
| Démarchage commercial TPE | Pas le rôle d'un POC technique |
| Business plan détaillé | Esquissé dans [04-proposition-valeur](./04-proposition-valeur.md), pas un BP formel |
| Conformité DORA / NIS2 certifiée | Le produit aide à la conformité mais ne se substitue pas à un audit |
| Support production 24/7 | Hors mission POC |

---

## Décisions de cadrage et leur justification

### Décision 1 — Mono-VM, pas multi-VM

**Choix** : tout sur une seule VM Debian, orchestré par Docker Compose.

**Justification** :
- Démo possible depuis le laptop avec **1 seul tunnel SSH**
- Onboarding setup en < 30 min pour un opérateur
- Coût matériel négligeable (1 VPS 5 €/mois suffit)
- L'isolation réseau Docker simule l'intention de la cible AWS multi-VPC

**Conséquence** : on perd la résilience (1 VM = 1 SPOF). C'est acceptable en POC, pas en prod.

---

### Décision 2 — HTTP en interne + SSH pour la démo (pas de TLS POC)

**Choix** : Caddy écoute en HTTP sur `127.0.0.1:8080`. Le chiffrement laptop↔VM est assuré par SSH.

**Justification** (la plus discutée du projet) :
- ✅ Pas de certificat à importer dans le navigateur du laptop → **friction zéro pour le jury**
- ✅ Pas de modification `/etc/hosts`
- ✅ Pas de warning navigateur "connexion non sécurisée"
- ✅ Le trafic est **déjà chiffré** par SSH entre laptop et VM
- ✅ Cohérent avec la cible AWS où c'est l'ALB + ACM qui gèrent TLS — ce ne sera **pas** un changement de pattern, juste un changement de produit

**Alternative écartée** : Caddy + CA locale auto-signée → demande d'importer le CA dans le browser du laptop = friction démo, perte de temps explication jury.

**Documenté pour le jury** : phrase prête à dire — *« Le tunnel SSH chiffre le trafic laptop ↔ VM. En production cible AWS, Caddy + Let's Encrypt prennent le relais (voir slide 11). Ne pas confondre POC démo locale et déploiement prod. »*

---

### Décision 3 — Login local pour Vaultwarden et Nextcloud (pas de SSO bout-en-bout)

**Choix** : les briques Vaultwarden et Nextcloud ont leur propre login local. Les cartes du dashboard ouvrent juste les URLs, l'utilisateur s'identifie une 2e fois.

**Justification** :
- Le vrai SSO Keycloak ↔ Nextcloud / Vaultwarden = développement spécifique non trivial (mapper LDAP, user_oidc app, etc.)
- Pour le POC, **démontrer le portail unique + l'identité centralisée IAM** est plus important que démontrer la fédération complète
- C'est explicite dans la slide 7 : "SSO bout-en-bout" est OUT scope

**Conséquence honnête au jury** : *« Dans le POC, Sarah se reconnecte à Vaultwarden et Nextcloud. Dans la v2, ces deux briques seront fédérées via OIDC et la connexion sera unique. »*

---

### Décision 4 — Stack PHP/JS et pas tout-Go ni tout-Node

**Choix** : Laravel (PHP) backend, React (TS) frontend.

**Justification** :
- **Laravel** : maturité écosystème pour le pattern "API + auth + DB + queues", très bonne courbe d'entrée pour les contributeurs futurs (énormément de doc FR)
- **React + TS** : type safety, écosystème OIDC mature, build statique léger
- **Pas un monorepo full-stack** (Next.js) : on veut un **contrat API explicite** dès le POC pour faciliter le scaling cible (front sur S3+CloudFront, back sur ECS)

---

### Décision 5 — Pas de TLS Let's Encrypt en POC

Conséquence de la décision 2. Documenté dans la cible AWS (chapitre 02). Pas d'ambiguïté.

---

### Décision 6 — 3 personas synthétiques, 1 développé en détail

**Choix** : Marc est développé persona complet (slide 5). Sarah et Karim sont mentionnés (slide 6) mais sans la profondeur de Marc.

**Justification** : Marc est l'**acheteur**. C'est lui qui signe le chèque. C'est lui qu'on doit convaincre. Sarah et Karim sont des utilisateurs : importants pour le design, mais subordonnés à la décision de Marc.

---

### Décision 7 — Doc utilisateur écrite POUR Marc

**Choix** : la doc utilisateur ([../utilisateur/](../utilisateur/)) est écrite en français simple, sans jargon, pour Marc — pas pour un sysadmin.

**Justification** : si Marc ne peut pas lire la doc, il ne peut pas vendre Galaxis à son équipe. La pédagogie est partie intégrante du produit.

---

## Critères de "fini" du POC

(Cf. brief Claude Code — 15 critères validés.)

| # | Critère | Statut |
|---|---|---|
| 1 | `make demo` lance toute la stack healthy en < 3 min | ✅ |
| 2 | Tunnel SSH + `http://localhost:8080` → portail visible avec DA | ✅ |
| 3 | Login `lucas-test/demo` → dashboard avec claims | ✅ |
| 4 | Cartes Vaultwarden + Nextcloud + liens fonctionnels | ✅ |
| 5 | `make test` (Pest + Vitest) ≥ 60 % couverture | ✅ |
| 6 | `make lint` passe (Pint + ESLint + Prettier) | ✅ |
| 7 | Script Keycloak idempotent (relançable) | ✅ |
| 8 | 0 secret commité (`grep -i 'password=\|secret=\|key='`) | ✅ |
| 9 | 3 réseaux Docker bien isolés (`docker network inspect`) | ✅ |
| 10 | Aucun warning certificat dans navigateur laptop | ✅ |
| 11 | Aucune modification `/etc/hosts` requise | ✅ |
| 12 | 3 documentations complètes dans `docs/documentations/` | ✅ |
| 13 | README racine permet install + démo < 30 min | ✅ |
| 14 | PDF livrable unifié (si pandoc dispo) | ⚠️ optionnel |
| 15 | `LIVRAISON.md` à la racine, exhaustif | ✅ |

---

## Liens internes

- Architecture fonctionnelle : [06-architecture-fonctionnelle.md](./06-architecture-fonctionnelle.md)
- Difficultés rencontrées : [08-difficultes-apprentissages.md](./08-difficultes-apprentissages.md)
- Roadmap post-POC : [09-roadmap.md](./09-roadmap.md)
