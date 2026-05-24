# Documentation TECHNIQUE — Galaxis POC

> **Audience** : développeurs, admin systèmes, devops · **Version** : v1.0-soutenance · **Édition** : mai 2026

Cette documentation décrit **comment fonctionne le POC Galaxis sur le plan technique**, comment l'installer, le déployer, le faire évoluer et l'exploiter. Elle est volontairement détaillée et technique.

---

## Sommaire

| # | Chapitre | Pour quoi ? |
|---|---|---|
| 01 | [Architecture POC](./01-architecture-poc.md) | Vue d'ensemble, 11 conteneurs, 3 réseaux Docker, mono-VM |
| 02 | [Architecture cible AWS](./02-architecture-cible.md) | Multi-VPC, ECS Fargate, RDS, mapping POC → prod |
| 03 | [Stack technique](./03-stack-technique.md) | Versions exactes, dépendances, justifications |
| 04 | [Installation from scratch](./04-installation.md) | Pas-à-pas Debian 12/13 vierge → POC fonctionnel |
| 05 | [Déploiement Ansible](./05-deploiement-ansible.md) | Les 4 playbooks, ordre, idempotence, rollback |
| 06 | [IAM Keycloak](./06-iam-keycloak.md) | Realm, client public PKCE, users, claims, customisation |
| 07 | [Flow OIDC + validation JWT](./07-flow-oidc-jwt.md) | Authorization Code + PKCE, RS256, cache JWKS Redis |
| 08 | [Réseaux Docker isolés](./08-reseaux-docker.md) | 3 networks, matrice de communication, isolation |
| 09 | [Sécurité](./09-securite.md) | Threat model POC, secrets, durcissement, OUT scope |
| 10 | [Exploitation](./10-exploitation.md) | Logs, monitoring, backup/restore, mise à jour |

---

## Démarrage express (pour les pressés)

```bash
# 1) Cloner et configurer
git clone <repo>.git Galaxis-POC && cd Galaxis-POC
cp .env.example .env && $EDITOR .env   # changer tous les mots de passe

# 2) Lancer la stack complète
make demo

# 3) Tunnel SSH depuis le laptop
ssh -L 8080:127.0.0.1:8080 user@<vm-ip>

# 4) Ouvrir http://localhost:8080 dans le navigateur
```

→ Pour le détail, lire les chapitres 04 puis 05.

---

## Conventions de la doc

- Tous les chemins sont **absolus** depuis la racine du repo (ex : `infrastructure/scripts/configure-keycloak.sh`)
- Les schémas sont en **Mermaid** (rendus par GitHub, GitLab, VS Code, etc.)
- Les commandes shell sont **copiables-collables** telles quelles
- Les variables d'environnement utilisent `${VAR}` (la valeur réelle est dans `.env`, jamais ici)
- Les blocs `Attention` signalent les pièges, les `Astuce` signalent les raccourcis utiles
