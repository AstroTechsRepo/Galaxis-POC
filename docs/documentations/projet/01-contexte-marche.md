# 01 — Contexte marché

> **Audience** : jury, sponsor · **Source slides** : 02, 03, 04

---

## 1. Le terrain

### AstroTechs, l'éditeur

AstroTechs est une société qui mêle **prestations, conseil et IA**. Sa mission : *accompagner les entreprises dans leur univers numérique — de la formation aux outils, du conseil à la souveraineté.*

Galaxis est **le premier produit propre** d'AstroTechs : une plateforme d'orchestration souveraine pour TPE. C'est aussi le premier POC industrialisable que l'équipe pose, après plusieurs missions de prestation.

### Le problème observé chez les TPE françaises

Lors des missions de conseil, AstroTechs voit revenir **toujours les mêmes douleurs** chez les TPE de 1 à 20 personnes :

- **Sprawl SaaS** : 8 à 15 outils SaaS différents (Google Workspace, Slack, Trello, Dropbox, Lastpass, Notion, etc.), chacun avec son compte utilisateur, son mot de passe, sa facture mensuelle
- **Onboarding pénible** : à chaque embauche, demi-journée perdue à créer manuellement 10 comptes
- **Offboarding raté** : un ex-employé garde ses accès des semaines après son départ (cf. anecdote slide 5 : *« Marc a découvert qu'un alternant gardait l'accès au coffre 2 mois après son départ. »*)
- **Dépendance extra-européenne** : la quasi-totalité des SaaS B2B utilisés sont US, ce qui pose un problème de souveraineté de la donnée (RGPD, DORA, NIS2)
- **Pas de DSI, pas de sysadmin** : le gérant gère lui-même, à 21h, entre deux factures

---

## 2. La validation marché

### L'enquête de terrain — Avril 2026

AstroTechs a mené une enquête quantitative pour valider l'intuition.

| Indicateur | Valeur | Commentaire |
|---|---|---|
| **Répondants** | **500** | échantillon représentatif TPE + indépendants + PME |
| **Intérêt pour la solution** | **4,02 / 5** | très favorable |
| **Prêts à investir** | **36,8 %** | un répondant sur trois prêt à payer |
| **Satisfaction des outils actuels** | **3,58 / 5** | médiocre — laisse une vraie place pour mieux faire |

### Répartition par taille d'organisation

| Segment | Nombre |
|---|---|
| TPE (2-10) | 153 |
| Indépendants / micro | 115 |
| PE (11-50) | 92 |
| PME (51-250) | 55 |
| Autre | 23 |

**268 répondants** sur 500 sont sur la cible primaire (TPE + indépendants). C'est plus de **50 %** de l'échantillon — la cible est confirmée.

### Besoins exprimés (top 3)

| Besoin | Votes | % |
|---|---|---|
| **Centralisation** | 393 | **79 %** |
| Accès & sécurité | 67 | 13 % |
| Pilotage | 40 | 8 % |

> **Verbatim clé** : *« J'aimerais un truc simple, où je crée une fois, je révoque une fois, et je sais en permanence ce qui se passe. Et si en plus c'est français et open source, je signe demain. »* — Marc, dirigeant fictif inspiré de plusieurs propos terrain (slide 5).

---

## 3. La synthèse de l'enquête

- **Cible confirmée** : TPE & indépendants
- **Besoin dominant** : centralisation (79 % en tête)
- **MVP recommandé** : plateforme simple, centralisée et modulaire

C'est exactement le brief que Galaxis transforme en produit.

---

## 4. Le contexte réglementaire qui pousse à agir

Trois textes structurants poussent les TPE/PME à reprendre la main :

- **RGPD** (UE) : déjà applicable, mais bien plus surveillé en 2026 qu'au lancement
- **DORA** (Digital Operational Resilience Act, UE) : applicable depuis janvier 2025, exige une cartographie et un contrôle des dépendances tierces
- **NIS2** (Network and Information Security 2, UE) : entrée en vigueur 2024, étend les obligations cyber à beaucoup plus d'acteurs

Pour Marc, un orchestrateur self-hosted = **moins de fournisseurs tiers à auditer**, **donnée qui reste chez lui**, **conformité plus facile à démontrer**.

---

## 5. La concurrence

| Concurrent | Forces | Faiblesses pour TPE |
|---|---|---|
| **JumpCloud** | IAM cloud, polyvalent | Cher, US, SaaS → contre-positionnement souverain |
| **Auth0 / Okta** | Mature, marketing massif | US, SaaS, gouvernance opaque |
| **Bitwarden Teams** | Coffre + équipes | Brique unique (passwords seulement), SaaS |
| **Nextcloud Hub** | Self-hosted | UX admin complexe pour non-tech |
| **Bricolage DIY** | Gratuit | Demande un sysadmin compétent |

Le **trou de marché** : *un produit qui pré-cable les bonnes briques open source, masque la complexité, et que Marc peut déployer sans embaucher un sysadmin.*

C'est la promesse Galaxis.

---

## 6. Pourquoi maintenant ?

Trois forces convergent :

1. **Maturité des briques open source** (Keycloak 25, Vaultwarden, Nextcloud 30) : on peut vraiment offrir une expérience « cloud-like » sans payer un SaaS US
2. **Pression réglementaire** (DORA + NIS2) : la demande de souveraineté devient pragmatique, pas juste idéologique
3. **Souveraineté = sujet vendeur** : les TPE comprennent enfin pourquoi c'est important pour leur business

→ La fenêtre d'opportunité s'ouvre.

---

## Liens internes

- Persona Marc en détail : [03-persona-roles.md](./03-persona-roles.md)
- Périmètre du POC : [05-perimetre-decisions.md](./05-perimetre-decisions.md)
- Roadmap : [09-roadmap.md](./09-roadmap.md)
