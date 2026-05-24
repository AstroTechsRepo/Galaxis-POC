# 02 — Fiche projet

> **Audience** : jury, sponsor, future équipe · **Source** : présentation soutenance + arbitrages cadrage

---

## Identité

| Item | Valeur |
|---|---|
| **Nom de produit** | Galaxis |
| **Tagline** | One core. Infinite orbits. |
| **Description courte** | L'orchestrateur souverain de votre écosystème open source |
| **Éditeur** | AstroTechs |
| **Sponsor académique** | ESGI 2 — Campus Éductive |
| **Auteur** | Lucas PEREZ |
| **Année académique** | 2025 / 2026 |
| **Date de soutenance** | 26 juin 2026 |
| **Version POC** | v1.0-soutenance |

---

## Mission du POC

> *Démontrer qu'on peut déployer en quelques minutes, sur une VM standard, une plateforme **souveraine** qui réunit l'identité centralisée, le coffre de mots de passe et le drive collaboratif d'une TPE, derrière un portail unique avec SSO OIDC.*

C'est un POC. Il sera complet **fonctionnellement sur le flow critique (login + briques visibles)**, mais ne prétend ni couvrir tous les cas d'usage TPE, ni être prêt à déployer en production telle quelle.

---

## Objectifs SMART

| # | Objectif | Mesurable | Atteint en POC ? |
|---|---|---|---|
| O1 | Authentification SSO portail → API | Login OIDC + JWT validé serveur fonctionnent | ✅ |
| O2 | Briques métier intégrées | Vaultwarden + Nextcloud déployés et accessibles depuis le portail | ✅ |
| O3 | Démo "1 clic" pour le jury | Lucas démarre la stack en une commande et présente sans friction | ✅ (cf. `make demo`) |
| O4 | Déploiement scripté reproductible | 4 playbooks Ansible idempotents | ✅ |
| O5 | Tests automatisés sur la sécurité | ≥ 60 % couverture backend (Pest) et frontend (Vitest) | ✅ |
| O6 | Aucun secret commité dans le repo | grep manuel sur la base de code | ✅ |
| O7 | Documentation livrable au jury | 3 docs (technique, projet, utilisateur) complètes | ✅ |

---

## KPIs cibles (à 12 mois post-soutenance, hors POC)

| KPI | Cible | Mesure |
|---|---|---|
| Onboarding TPE de bout en bout | < 1 h | du `make demo` à un utilisateur productif |
| Onboarding d'un nouvel employé | < 5 min | par l'admin de la TPE |
| Offboarding d'un employé | < 1 min | révocation totale (audit prouvable) |
| Disponibilité (cible prod AWS) | 99,5 % | sur 30 jours glissants |
| Coût d'infra par TPE 10 personnes | < 50 € / mois | hébergement + ops |
| Temps de réponse `/api/me` p95 | < 200 ms | depuis le navigateur |

---

## Hypothèses validées et non validées

### Validées par l'enquête (cf. [01-contexte-marche.md](./01-contexte-marche.md))

- Les TPE veulent de la centralisation (79 %)
- Les TPE sont prêtes à payer (36,8 %)
- La satisfaction des outils actuels est moyenne (3,58/5)

### Non validées (à valider en v2)

- Les TPE accepteront-elles d'héberger elles-mêmes (sur leur VPS ou cloud) plutôt qu'en SaaS managé Galaxis ?
- Le prix tenable pour une TPE de 10 personnes est-il < 50 € / mois ?
- La courbe d'apprentissage pour Marc est-elle réellement passable sans assistance ?

→ Ces hypothèses font partie du programme MVP (cf. [09-roadmap.md](./09-roadmap.md)).

---

## Contraintes du POC

| Contrainte | Décision |
|---|---|
| Soutenance en juin 2026 | Date butoir absolue — pas de glissement |
| Auteur unique (Lucas) | Périmètre minutieusement borné (slide 7) |
| Démo depuis laptop sans friction | Tunnel SSH unique + Caddy reverse proxy HTTP sur 8080 |
| Pas de cloud payant | Tout tourne sur VM locale (mutualisation campus / lab perso) |
| Open source obligatoire | Aucune brique propriétaire dans la stack |
| Souveraineté française | Toutes les briques sont communautaires ou européennes |

---

## Livrables formels du POC

| # | Livrable | Format | Statut |
|---|---|---|---|
| L1 | Code source POC complet | Git monorepo | ✅ |
| L2 | Scripts de déploiement | Ansible (4 playbooks) | ✅ |
| L3 | Démo fonctionnelle | `make demo` + tunnel SSH | ✅ |
| L4 | Documentation technique | 10 chapitres Markdown | ✅ |
| L5 | Documentation projet | 9 chapitres Markdown | ✅ |
| L6 | Documentation utilisateur | 8 chapitres Markdown | ✅ |
| L7 | Présentation de soutenance | 18 slides HTML + annexes | ✅ (déjà en `docs/soutenance/`) |
| L8 | Récapitulatif de livraison | `LIVRAISON.md` | ✅ |

---

## Équipe et rôles

| Rôle | Personne | Charge POC |
|---|---|---|
| Sponsor académique | Encadrant ESGI | revue ponctuelle |
| Sponsor produit | AstroTechs | définition cible TPE |
| Architecte / Dev / DevOps / Rédacteur | Lucas PEREZ | 100 % |
| Consultations externes | Camarades ESGI, pairs DSI | revue informelle |

---

## Risques projet identifiés

| Risque | P | I | Mitigation |
|---|:---:|:---:|---|
| Glissement de planning | M | É | Périmètre borné slide 7, kill features de second rang |
| Bug bloquant dans Keycloak v25 | F | É | Pinning de version, fallback documenté vers 24.x |
| Incompréhension cadrage HTTP vs HTTPS pour la démo | M | M | Document EXPLORATION.md + section dédiée dans la doc technique |
| Démo qui plante le jour J | F | É | Procédure de plan B documentée dans `demo-guide.md` |
| Secret accidentellement commité | F | É | `.gitignore` strict + grep avant chaque commit + gitleaks recommandé |
| Lassitude / qualité doc qui baisse | M | É | Doc rédigée AVANT la deadline, pas après |
| Régression entre commits | F | É | Pest + Vitest en CI manuelle, `make test` avant push |

Légende : P = Probabilité (F faible, M moyen, É élevé) · I = Impact (idem)

---

## Liens internes

- Marché : [01-contexte-marche.md](./01-contexte-marche.md)
- Périmètre : [05-perimetre-decisions.md](./05-perimetre-decisions.md)
- Gestion projet : [07-gestion-projet.md](./07-gestion-projet.md)
