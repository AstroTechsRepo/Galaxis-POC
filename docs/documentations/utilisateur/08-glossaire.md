# 08 — Glossaire

> Tous les mots compliqués de Galaxis, expliqués en français simple.

---

## A

**Admin (administrateur)**
La personne qui gère Galaxis pour votre équipe. Elle crée les comptes, ajoute les briques, gère les droits. Dans une petite TPE, c'est souvent le dirigeant lui-même (Marc) ou son prestataire.

---

**Annuaire**
La liste de tous les utilisateurs (collaborateurs) de votre entreprise dans Galaxis. C'est un peu comme un répertoire téléphonique numérique.

---

**API**
*Application Programming Interface*. Le langage technique par lequel deux logiciels se parlent entre eux. Quand votre dashboard Galaxis affiche votre nom, c'est qu'il a appelé une API du serveur.
> Vous n'avez jamais besoin de comprendre ça en tant qu'utilisateur.

---

## B

**Brique**
Un outil intégré à Galaxis. Vaultwarden est une brique, Nextcloud en est une autre. Le principe : vous ajoutez les briques dont vous avez besoin, vous retirez celles qui ne servent plus.

---

**Bitwarden**
L'application mobile officielle compatible avec Vaultwarden. Vous l'installez sur votre téléphone pour accéder à vos mots de passe en mobilité.

---

## C

**Caddy**
Le **portier** de Galaxis. C'est le logiciel qui reçoit votre clic sur "Galaxis" dans le navigateur et qui dit "Ah, tu veux Vaultwarden ? Ok, je t'envoie vers la bonne porte". Vous ne le voyez jamais, mais sans lui rien ne marche.

---

**Claims**
Les **informations** qu'un JWT (voir ci-dessous) contient à votre sujet : votre nom, votre email, votre identifiant unique, vos rôles. Sur votre dashboard, le tableau "Identité & claims" les affiche en détail (utile pour le diagnostic).

---

**Cloud / Cloud souverain**
Le "cloud" = un ordinateur ailleurs (chez un prestataire) qui tourne 24/7 pour vous. Le **cloud souverain** = un cloud où la donnée reste dans la juridiction de votre choix (souvent : France ou Europe), avec des garanties juridiques.

---

**Coffre-fort (de mots de passe)**
Un programme qui stocke vos mots de passe **chiffrés**. C'est ce que fait Vaultwarden. Vous n'avez qu'un seul mot de passe à retenir (le "mot de passe maître") et le coffre se souvient de tous les autres.

---

**CORS**
*Cross-Origin Resource Sharing*. Une règle de sécurité qui empêche un site malveillant d'utiliser votre Galaxis en votre nom. Configuré strictement.
> Vous n'avez jamais besoin de comprendre ça en tant qu'utilisateur.

---

## D

**Dashboard**
Le tableau de bord. C'est l'écran que vous voyez quand vous vous connectez : avec votre nom en haut et les cartes des briques en dessous.

---

**Docker**
Le logiciel qui fait tourner Galaxis sous forme de **petits conteneurs** indépendants (un conteneur Keycloak, un conteneur Vaultwarden, etc.). Ça permet de tout démarrer / arrêter facilement, et d'isoler les briques entre elles.

---

**DORA**
*Digital Operational Resilience Act*. Règlement européen 2025 qui impose aux entreprises certaines obligations de cybersécurité et de gestion des risques numériques. Galaxis aide à y répondre (donnée chez vous, traçabilité).

---

## E

**Extension navigateur**
Un petit programme qu'on ajoute à Firefox / Chrome / Edge pour avoir des fonctions en plus. L'extension Bitwarden vous permet de remplir automatiquement vos mots de passe sur les sites.

---

## H

**HTTPS**
La version sécurisée d'HTTP (le protocole web). Quand vous voyez `https://` dans votre barre d'adresse et un cadenas, c'est que le trafic est chiffré entre vous et le site.
> En version POC, Galaxis utilise HTTP via un tunnel SSH (qui chiffre aussi, mais d'une autre manière). En version production, c'est du HTTPS standard.

---

## I

**IAM**
*Identity and Access Management*. Le système qui gère **qui est qui** et **qui a accès à quoi**. Dans Galaxis, c'est Keycloak qui joue ce rôle.

---

**Identifiant**
Le nom court (sans espaces) qui vous identifie sur Galaxis. Par exemple `marc-dubreuil` ou `sophie`. Différent du nom complet ("Marc Dubreuil" ou "Sophie Martin").

---

**Inscription** (registration)
Le fait de créer un nouveau compte. **Désactivée par défaut** sur votre Galaxis : seul l'admin crée les comptes (sinon n'importe qui pourrait s'inscrire).

---

## J

**JWT**
*JSON Web Token*. Une sorte de **passe technique** que votre navigateur reçoit après votre connexion. Il prouve à toutes les briques que c'est bien vous, sans avoir à retaper votre mot de passe partout.
> Conceptuellement : un bracelet de festival qu'on vous met à l'entrée, et qu'on vérifie à chaque concert sans vous redemander votre billet.

---

## K

**Keycloak**
Le logiciel qui gère votre identité dans Galaxis. C'est lui qui sait qui vous êtes, vous demande votre mot de passe, et émet les JWT. En tant qu'utilisateur, vous le voyez seulement à l'écran de connexion. L'admin l'utilise pour créer/désactiver les comptes.

---

## L

**LDAP**
Un vieux standard d'annuaire d'entreprise (Microsoft Active Directory l'utilise). Galaxis peut s'y connecter en cible v2.0 si vous avez déjà un AD interne.

---

**Loopback**
Un terme technique pour dire "depuis l'ordinateur lui-même, pas depuis l'extérieur". `127.0.0.1` (ou `localhost`) est l'adresse loopback. Dans le POC, Galaxis n'est accessible **qu'en loopback** sur la VM — l'extérieur passe par un tunnel SSH.

---

## M

**MFA**
*Multi-Factor Authentication*. L'authentification à plusieurs facteurs : votre mot de passe + un code temporaire envoyé sur votre téléphone, par exemple. Bien plus sûr qu'un mot de passe seul. **Prévue en v2.0** de Galaxis.

---

**Mot de passe maître**
Le mot de passe **unique** qui ouvre votre coffre Vaultwarden. C'est le seul que vous devez retenir (et bien noter en lieu sûr). Si vous l'oubliez, **personne** ne peut le récupérer.

---

## N

**Nextcloud**
La brique "drive collaboratif" de Galaxis. Permet de stocker, partager, synchroniser des fichiers entre les membres de votre équipe.

---

**NIS2**
*Network and Information Security 2*. Directive européenne qui étend les obligations cyber à beaucoup plus d'entreprises (dont les TPE/PME dans certains secteurs). Galaxis aide à la conformité.

---

## O

**OIDC**
*OpenID Connect*. La norme moderne pour se connecter à un site via un compte central (comme "Se connecter avec Google" ailleurs sur le web). Galaxis utilise OIDC pour que vos briques fassent confiance à Keycloak.

---

**Offboarding**
Le processus de **départ** d'un collaborateur : couper ses accès proprement. Voir [chapitre 06](./06-offboarding.md).

---

**Onboarding**
Le processus d'**arrivée** d'un collaborateur : créer ses accès. Voir [chapitre 05](./05-onboarding-collaborateur.md).

---

**Open Source**
Un logiciel dont le code est **public**. N'importe qui peut le lire, l'auditer, contribuer. Galaxis n'utilise **que** des briques open source. Avantage : pas de surprise propriétaire, vous gardez le contrôle.

---

**Orchestrateur**
Un logiciel qui **coordonne** plusieurs autres logiciels pour qu'ils travaillent ensemble. Galaxis est un orchestrateur : il met Keycloak, Vaultwarden et Nextcloud autour d'une table et fait en sorte qu'ils parlent la même langue.

---

## P

**PKCE**
*Proof Key for Code Exchange*. Un mécanisme cryptographique qui sécurise votre connexion depuis le navigateur. Vous ne le voyez jamais, mais il vous protège contre certaines attaques.
> Conceptuellement : c'est comme si vous donniez à la banque un demi-billet de loterie en partant, et l'autre demi en revenant. Si quelqu'un vole le ticket en route, il ne peut rien en faire sans votre demi.

---

**Portail (Galaxis)**
Le **point d'entrée unique** de toutes vos briques. C'est la première page que vous voyez en ouvrant Galaxis. Concept central du produit.

---

**PostgreSQL**
Une **base de données** open source utilisée par Keycloak, Galaxis et Nextcloud pour stocker leurs informations. Vous ne la voyez jamais.

---

## R

**Realm**
En Keycloak, un realm = un **groupe d'utilisateurs** isolé. Galaxis utilise un realm appelé `galaxis`. Pour la v3 multi-tenant, on aura un realm par TPE cliente.

---

**Reverse proxy**
Un terme technique pour Caddy. Voir "Caddy" ci-dessus.

---

**Redis**
Une **mémoire ultra-rapide** que Galaxis utilise pour mémoriser temporairement des choses (votre session, les clés cryptographiques). Vous ne la voyez jamais.

---

**RBAC**
*Role-Based Access Control*. Système de droits par **rôles** (admin, manager, user…). En POC, Galaxis l'utilise de manière basique. La v2.0 aura une gestion fine par groupe (Karim peut gérer son équipe sans voir les autres).

---

**RGPD**
*Règlement Général sur la Protection des Données*. La loi européenne sur la donnée personnelle. Galaxis aide à la conformité en gardant votre donnée chez vous.

---

## S

**SaaS**
*Software as a Service*. Un logiciel auquel on s'abonne mensuellement et qui tourne **chez l'éditeur** (ex : Google Workspace, Notion, Slack). L'opposé du **self-hosted**.

---

**Self-hosted**
Un logiciel qu'on **héberge soi-même** (chez soi ou chez son prestataire de confiance). Galaxis est self-hosted par nature. L'opposé du SaaS.

---

**Session**
La période pendant laquelle vous êtes connecté·e à Galaxis. Par défaut, elle dure ~30 min d'inactivité puis vous êtes déconnecté·e automatiquement (pour la sécurité).

---

**SSH**
*Secure Shell*. Un protocole pour se connecter à un serveur à distance, en chiffrant tout le trafic. Pour la démo POC, Lucas utilise un tunnel SSH pour atteindre Galaxis depuis son laptop.

---

**SSO**
*Single Sign-On*. La fonctionnalité magique qui fait que vous vous connectez **une seule fois** et que vous accédez ensuite à plusieurs applications sans retaper votre mot de passe. Galaxis POC le fait pour le portail. La v2.0 l'étendra à Vaultwarden et Nextcloud (SSO bout-en-bout).

---

**Souverain / Souveraineté numérique**
Le fait de garder la **maîtrise** de ses données et de ses outils, sans dépendre de fournisseurs étrangers ni juridictions extra-européennes. Galaxis a la souveraineté dans son ADN.

---

## T

**Token**
Un mot anglais pour "jeton". Quand on dit "votre token expire dans 30 minutes", on parle du JWT (voir ci-dessus) qui vous identifie auprès de Galaxis.

---

**Tunnel SSH**
Une **connexion sécurisée** entre votre laptop et un serveur distant. Lucas l'utilise pour ouvrir Galaxis depuis son laptop pendant la démo : `ssh -L 8080:127.0.0.1:8080 user@vm`. Le tunnel chiffre tout, pas besoin de HTTPS en plus pour la démo.

---

## U

**UFW**
*Uncomplicated Firewall*. Le pare-feu installé sur la VM Galaxis. Il bloque tout sauf le port SSH. Vous ne le voyez jamais.

---

## V

**Vaultwarden**
La brique "coffre-fort de mots de passe" de Galaxis. Compatible avec l'application Bitwarden sur mobile et l'extension de navigateur.

---

**VM (Virtual Machine / machine virtuelle)**
Un ordinateur "simulé" sur lequel Galaxis tourne. En POC, c'est typiquement une VM Debian 12 ou 13 avec 2 vCPU et 4 GB de RAM.

---

**VPN souverain**
Une **future brique** de Galaxis (v2.5). Permettra à votre équipe de se connecter à distance à vos ressources internes en sécurité.

---

## Un mot manque ?

Si vous tombez sur un mot ou une notion qui n'est pas dans ce glossaire, **faites-le-nous savoir** : on l'ajoutera.

Toute la documentation Galaxis vise à être **lisible par un dirigeant de TPE non technique**. Si quelque chose vous échappe, c'est notre faute, pas la vôtre.

---

**Vous avez fini les 8 chapitres du guide utilisateur !** Vous savez maintenant utiliser Galaxis au quotidien.

← Revenir au [sommaire](./README.md)
