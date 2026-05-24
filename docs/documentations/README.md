# 📚 Galaxis — Documentations livrables

> Index global · Livrable formel remis au jury ESGI · Soutenance 26 juin 2026

Ce dossier contient **trois documentations distinctes**, chacune pensée pour une audience précise. Une même fonctionnalité y est donc présentée trois fois sous des angles différents : technique, projet, utilisateur. C'est volontaire.

---

## 🎯 Comment choisir où aller ?

| Vous êtes… | Allez voir | Ce que vous y trouverez |
|---|---|---|
| **Développeur·se, admin sys, devops** — vous devez installer, déployer, maintenir, faire évoluer GALAXIS | [`technique/`](./technique/README.md) | Archi POC + cible AWS, stack, install pas-à-pas, déploiement Ansible, flow OIDC/JWT, réseaux Docker, sécurité, exploitation |
| **Jury, chef de projet, sponsor** — vous voulez comprendre pourquoi et comment ce projet a été mené | [`projet/`](./projet/README.md) | Contexte marché (500 répondants), fiche projet, persona, value proposition, périmètre, archi fonctionnelle, gestion projet, roadmap |
| **Utilisateur final TPE** (Marc, Sarah, Karim) — vous devez utiliser GALAXIS au quotidien | [`utilisateur/`](./utilisateur/README.md) | Première connexion, gérer les accès, Vaultwarden, Nextcloud, onboarding/offboarding, FAQ, glossaire |

---

## 📦 Inventaire

### Doc technique — 10 chapitres
1. [Architecture POC](./technique/01-architecture-poc.md)
2. [Architecture cible AWS](./technique/02-architecture-cible.md)
3. [Stack technique](./technique/03-stack-technique.md)
4. [Installation from scratch](./technique/04-installation.md)
5. [Déploiement Ansible](./technique/05-deploiement-ansible.md)
6. [IAM Keycloak](./technique/06-iam-keycloak.md)
7. [Flow OIDC + validation JWT](./technique/07-flow-oidc-jwt.md)
8. [Réseaux Docker isolés](./technique/08-reseaux-docker.md)
9. [Sécurité](./technique/09-securite.md)
10. [Exploitation](./technique/10-exploitation.md)

### Doc projet — 9 chapitres
1. [Contexte marché](./projet/01-contexte-marche.md)
2. [Fiche projet](./projet/02-fiche-projet.md)
3. [Persona & rôles](./projet/03-persona-roles.md)
4. [Proposition de valeur](./projet/04-proposition-valeur.md)
5. [Périmètre & décisions](./projet/05-perimetre-decisions.md)
6. [Architecture fonctionnelle](./projet/06-architecture-fonctionnelle.md)
7. [Gestion de projet](./projet/07-gestion-projet.md)
8. [Difficultés & apprentissages](./projet/08-difficultes-apprentissages.md)
9. [Roadmap](./projet/09-roadmap.md)

### Doc utilisateur — 8 chapitres
1. [Première connexion](./utilisateur/01-premiere-connexion.md)
2. [Gérer mes accès](./utilisateur/02-gerer-mes-acces.md)
3. [Vaultwarden : les bases](./utilisateur/03-vaultwarden-bases.md)
4. [Nextcloud : les bases](./utilisateur/04-nextcloud-bases.md)
5. [Onboarding d'un collaborateur](./utilisateur/05-onboarding-collaborateur.md)
6. [Offboarding propre](./utilisateur/06-offboarding.md)
7. [FAQ](./utilisateur/07-faq.md)
8. [Glossaire](./utilisateur/08-glossaire.md)

---

## 🧭 Convention d'écriture

| Doc | Ton | Format des schémas | Niveau de jargon |
|---|---|---|---|
| Technique | factuel, précis | Mermaid + tableaux | élevé (assumé) |
| Projet | narratif, structuré | Mermaid + matrices | modéré (expliqué) |
| Utilisateur | chaleureux, pas-à-pas | descriptions textuelles | nul (tout est expliqué) |

---

## 📄 Livrable PDF (optionnel)

Si `pandoc` est installé sur le poste opérateur, on peut générer un PDF unifié des 3 docs :

```bash
make -C docs/documentations pdf   # crée Galaxis_Documentation_Complete.pdf
```

*(La commande est documentée dans `docs/documentations/Makefile` — voir Phase 10.)*

---

## ✍️ Identité du livrable

- **Produit** : Galaxis — l'orchestrateur souverain
- **Tagline** : *One core. Infinite orbits.*
- **Éditeur** : AstroTechs
- **Auteur** : Lucas PEREZ — ESGI 2, Campus Éductive, 2025/2026
- **Version POC** : v1.0-soutenance (mai 2026)
