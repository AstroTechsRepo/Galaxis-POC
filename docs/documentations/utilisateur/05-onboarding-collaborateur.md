# 05 — Onboarding d'un collaborateur

> Sophie rejoint votre équipe lundi prochain. Comment lui donner accès à tout ?

---

## Le scénario

Sophie arrive lundi 8 juin. Elle sera **commerciale** dans votre TPE. Vous voulez qu'à 9h du matin, elle puisse :

- Se connecter à **Galaxis** avec ses identifiants
- Voir **Vaultwarden** sur son dashboard (et y avoir accès aux mots de passe de son équipe)
- Voir **Nextcloud** sur son dashboard (et accéder au dossier "Commerciaux")

Total temps d'admin nécessaire : **~10 minutes** si vous suivez ce guide.

---

## Étape 1 — Créer le compte Galaxis (Keycloak)

> **Note POC** : dans la version actuelle, cette étape se fait dans la **console d'administration Keycloak**. C'est un écran plus technique que le reste de Galaxis. Si vous n'êtes pas à l'aise, demandez à votre prestataire de vous accompagner la première fois.

### Accéder à la console admin

1. Ouvrez Galaxis dans le navigateur
2. Ajoutez `/admin` à l'URL → `http://localhost:8080/admin`
3. Connectez-vous avec le compte **admin** Keycloak que votre prestataire vous a fourni

> **Astuce** : mettez cette page dans vos favoris du navigateur. Vous y reviendrez à chaque arrivée/départ.

### Créer Sophie

1. En haut à gauche, vérifiez que vous êtes bien sur le realm **"galaxis"** (et pas "master")
2. Dans le menu de gauche : **Users → Add user**
3. Remplissez :
   - **Username** : `sophie` (court, pas d'espaces, en minuscules)
   - **Email** : `sophie@votre-tpe.fr`
   - **First name** : `Sophie`
   - **Last name** : `Martin`
   - **Email verified** : ✅ ON (cochez)
   - **Enabled** : ✅ ON (cochez)
4. Cliquez **"Create"**

### Définir son mot de passe initial

1. Sur la fiche de Sophie qui vient de se créer, cliquez sur l'onglet **"Credentials"**
2. Cliquez **"Set password"**
3. Choisissez :
   - **Password** : un mot de passe initial (par exemple `Bienvenue-sophie-2026!`)
   - **Temporary** : ✅ ON (Sophie sera forcée de le changer à sa première connexion)
4. Cliquez **"Save"**

✅ Sophie a maintenant un compte Galaxis.

---

## Étape 2 — Communiquer ses accès à Sophie

Envoyez à Sophie (par mail ou en personne, jamais par SMS si possible) :

```
Bonjour Sophie,

Bienvenue ! Voici tes accès Galaxis :

Adresse : https://galaxis.votre-tpe.fr (ou http://localhost:9080 si POC)
Identifiant : sophie
Mot de passe temporaire : Bienvenue-sophie-2026!

À ta première connexion, Galaxis te demandera de choisir
un nouveau mot de passe personnel.

Bonne arrivée !
— Marc
```

> **Astuce** : pour les TPE plus organisées, créez un **document type "Welcome pack"** dans Nextcloud avec toutes les infos pratiques (équipe, locaux, outils, organigramme). Vous le partagez à chaque nouvelle arrivée.

---

## Étape 3 — Donner accès à Vaultwarden

Le compte Vaultwarden est **séparé** du compte Galaxis dans la version actuelle. Procédure :

1. Connectez-vous à **Vaultwarden** avec votre compte admin
2. Allez dans **"Organisations"** → choisissez votre orga d'équipe (ou créez-en une si pas encore fait)
3. Onglet **"Membres"** → bouton **"Inviter un membre"**
4. Entrez l'**e-mail de Sophie** + son **rôle** (User, Manager…)
5. Vaultwarden envoie à Sophie un mail d'invitation à créer son coffre

Sophie suit le lien dans le mail, crée son mot de passe maître Vaultwarden, accepte l'invitation à l'organisation. Elle voit maintenant les mots de passe partagés.

> **Important** : Sophie devra créer un **mot de passe maître Vaultwarden** différent de son mot de passe Galaxis. Préviens-la et insiste : *"Tu ne dois jamais oublier ce mot de passe maître."*

---

## Étape 4 — Donner accès à Nextcloud

Pareil, le compte Nextcloud est séparé pour le POC. Procédure :

1. Connectez-vous à **Nextcloud** avec votre compte admin
2. En haut à droite, cliquez sur votre **avatar → "Utilisateurs"**
3. Cliquez sur **"+ Nouvel utilisateur"** en haut
4. Remplissez :
   - **Nom d'utilisateur** : `sophie` (le même qu'avant pour la cohérence)
   - **Nom complet** : `Sophie Martin`
   - **Email** : `sophie@votre-tpe.fr`
   - **Mot de passe** : laissez vide → Nextcloud enverra un lien d'activation
   - **Groupes** : ajoutez `commerciaux` (ou autre selon votre organisation)
5. Cliquez **"+ Ajouter un nouvel utilisateur"**

### Partager les dossiers d'équipe avec Sophie

1. Allez dans **Fichiers**
2. Trouvez le dossier **"Commerciaux"** (s'il existe — sinon, créez-le)
3. Cliquez sur l'icône **Partager** → entrez `sophie` ou `commerciaux` (si vous l'avez ajoutée au groupe)
4. Choisissez les permissions (modifier = oui pour son dossier d'équipe)

✅ Sophie voit maintenant ses dossiers d'équipe dès sa première connexion.

---

## Étape 5 — Le jour J : accompagner Sophie

Quand Sophie arrive lundi, prévoyez **15 minutes** pour la première connexion :

1. Elle ouvre Galaxis sur son ordi
2. Elle se connecte avec son identifiant + mot de passe temporaire
3. Galaxis lui demande de **choisir un nouveau mot de passe** — qu'elle choisit fort
4. Elle découvre son dashboard avec Vaultwarden et Nextcloud
5. Elle active Vaultwarden (suit le lien dans le mail d'invitation)
6. Elle active Nextcloud (suit le lien d'activation reçu par mail)
7. Elle installe les apps mobiles si elle le souhaite

> **Astuce** : profitez de cette première session pour lui montrer **où sont les choses importantes** (le dossier "Comptabilité", l'accès Twitter pro dans Vaultwarden, etc.). 10 minutes d'accompagnement = des heures de questions évitées plus tard.

---

## Étape 6 — Lui transmettre la doc utilisateur

Envoyez à Sophie le lien vers **ce guide** que vous lisez maintenant :

`docs/documentations/utilisateur/README.md`

ou le PDF unifié si vous l'avez généré (cf. chapitre 09 — Phase 9 dans la doc projet).

Elle pourra y revenir quand elle aura un doute.

---

## Récapitulatif chronologique

| Quand ? | Tâche | Durée |
|---|---|---|
| Vendredi soir avant l'arrivée | Créer le compte Galaxis (Keycloak) | 3 min |
| Vendredi soir | Inviter sur Vaultwarden | 2 min |
| Vendredi soir | Créer compte Nextcloud + partager dossiers | 4 min |
| Vendredi soir | Préparer le mail d'accueil avec accès | 5 min |
| Lundi matin | Envoyer le mail à Sophie | 1 min |
| Lundi 9h-9h15 | Accompagner sa première connexion | 15 min |
| **Total** | | **~ 30 min** |

À comparer aux **demi-journées perdues** dans l'ancien fonctionnement TPE avec 10 SaaS différents !

---

## Cas particuliers

### Sophie est freelance / temporaire

→ Définissez une **date d'expiration** sur son compte Keycloak (onglet Details → Account expiration). Quand cette date arrive, son compte est automatiquement désactivé. Vous évitez les oublis d'offboarding.

### Sophie a besoin d'accès admin temporaires

→ Ne lui donnez **PAS** le mot de passe admin Keycloak ! Ajoutez-lui des **rôles** dans Keycloak (`manage-users` par exemple) plutôt que de partager un compte super-admin.

### Sophie travaille à distance

→ Elle peut accéder à Galaxis depuis n'importe où **si votre serveur est exposé sur internet** (cas prod) ou via le VPN (cas POC). Demandez à votre prestataire la procédure de connexion à distance.

---

## Bilan

Vous savez maintenant :

- ✅ Créer un nouveau compte utilisateur (Galaxis + Vaultwarden + Nextcloud)
- ✅ Envoyer un mail d'accueil professionnel
- ✅ Accompagner la première connexion
- ✅ Partager des ressources avec le nouveau collaborateur
- ✅ Gérer les cas particuliers (freelance, droits spécifiques)

Étape suivante : [Offboarding propre](./06-offboarding.md) — le pendant inverse.
