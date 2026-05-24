# Identifiants de démo — Galaxis POC

> Ce document regroupe l'ensemble des identifiants nécessaires pour faire tourner et présenter la démo du POC Galaxis.

## Comptes utilisateurs (Portail Galaxis)

Accès via **http://localhost:9080** — Authentification OIDC (Keycloak).

**Mot de passe partagé par tous les comptes :** `Demo2026!`

| Utilisateur | Email                          | Prénom | Nom      | Rôle  |
|-------------|--------------------------------|--------|----------|-------|
| marc        | marc@atelier-marchand.demo     | Marc   | Marchand | admin |
| sophie      | sophie@atelier-marchand.demo   | Sophie | Lemoine  | user  |
| julien      | julien@atelier-marchand.demo   | Julien | Petit    | user  |
| chloe       | chloe@atelier-marchand.demo    | Chloé  | Dubois   | user  |
| admin       | admin@galaxis.demo             | Admin  | Galaxis  | admin |

Le compte recommandé pour la démo est **marc** (persona principal du scénario "Atelier Marchand").

## Administration Keycloak

Accès via **http://localhost:8080**

| Champ        | Valeur              |
|--------------|---------------------|
| Utilisateur  | `admin`             |
| Mot de passe | `GxKcAdmin2026!Poc` |

Realm de la démo : `galaxis` — Client OIDC : `galaxis-portal` (public, PKCE S256).

## Nextcloud

Accès via **http://localhost:11180**

| Champ        | Valeur              |
|--------------|---------------------|
| Utilisateur  | `admin`             |
| Mot de passe | `GxNcAdmin2026!Poc` |

## Vaultwarden

Accès via **http://localhost:10180**

| Champ       | Valeur                                           |
|-------------|--------------------------------------------------|
| Token admin | `GxVaultLongRandomToken2026PocDemoSecure4891`    |

Les inscriptions sont désactivées par défaut (`SIGNUPS_ALLOWED=false`). Les comptes utilisateurs doivent être créés manuellement ou via invitation depuis le panneau admin (`/admin`).

## Bases de données (usage interne)

Ces identifiants ne sont pas nécessaires pour la démo mais sont documentés pour référence.

| Service       | Utilisateur  | Mot de passe         |
|---------------|--------------|----------------------|
| Keycloak DB   | `keycloak`   | `GxKcDb8472SecRet`   |
| App DB        | `galaxis`    | `GxAppDb5931SecRet`  |
| Nextcloud DB  | `nextcloud`  | `GxNcDb6283SecRet`   |
| Redis         | —            | `GxRedis7614SecRet`  |
