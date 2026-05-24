# 02 — Gérer mes accès

> Comprendre ce qui se cache derrière les "briques" de votre dashboard.

---

## C'est quoi une brique ?

Sur votre dashboard, vous voyez des **cartes** alignées. Chacune est une **brique** : un outil prêt à l'emploi pour votre équipe.

> 💡 **Image mentale** : votre Galaxis est un **étui à crayons**. Chaque crayon (= brique) sert à quelque chose de précis. Vous choisissez quels crayons mettre dans votre étui.

Une brique a 3 caractéristiques :

| Caractéristique | Exemple |
|---|---|
| **Un nom** | Vaultwarden, Nextcloud, VPN souverain |
| **Un rôle** | "ranger les mots de passe", "partager les fichiers", etc. |
| **Un statut** | *disponible* (vous pouvez l'utiliser) ou *à venir* (prévu plus tard) |

---

## Vos briques disponibles aujourd'hui

### 🔐 Vaultwarden — votre coffre-fort de mots de passe

**À quoi ça sert ?**

À stocker **tous vos mots de passe** (et ceux de votre équipe) au même endroit, en sécurité. Plus jamais besoin de retenir 50 mots de passe ou de les écrire sur un post-it.

**Ce que vous pouvez y faire :**
- Enregistrer un mot de passe pour un site (ex : votre banque pro, votre CRM…)
- Partager un mot de passe avec un collègue (ex : le compte Twitter de l'entreprise)
- Générer un mot de passe **fort** automatiquement
- Y accéder depuis votre téléphone (appli Bitwarden compatible)

👉 Suite : [chapitre 03 — Vaultwarden : les bases](./03-vaultwarden-bases.md)

---

### ☁️ Nextcloud — votre drive d'équipe

**À quoi ça sert ?**

À stocker vos **fichiers** (documents, images, contrats…) et les **partager** avec votre équipe, sans dépendre de Google Drive ou Dropbox.

**Ce que vous pouvez y faire :**
- Uploader un fichier ou un dossier entier
- Le partager avec un collègue (ou avec un client externe, par lien)
- Travailler à plusieurs sur un même document
- Synchroniser des fichiers sur votre PC (comme Dropbox)
- Avoir un **calendrier** d'équipe partagé (en bonus)

👉 Suite : [chapitre 04 — Nextcloud : les bases](./04-nextcloud-bases.md)

---

### 🔒 VPN souverain — *à venir*

**À quoi ça servira ?**

À permettre à votre équipe de se connecter à distance à vos ressources internes (par exemple, votre serveur de fichiers ou votre intranet) **comme si elle était au bureau**, sans passer par un fournisseur étranger.

> Cette brique est prévue dans la prochaine version de Galaxis. La carte apparaît grisée sur votre dashboard avec la mention *"à venir"*.

---

## Comment ces briques sont protégées

Toutes vos briques sont **derrière votre Galaxis**. Cela veut dire :

- 🔒 Personne ne peut y accéder **sans passer par votre Galaxis** d'abord
- 👤 Chaque brique sait **qui vous êtes** (grâce à votre connexion Galaxis)
- 📝 Tout ce qui se passe est **enregistré** (vous pouvez voir l'historique dans la page Profil)

> 💡 **Astuce** : si un employé part demain, vous coupez son accès Galaxis et **toutes ses briques** sont automatiquement coupées en même temps. Plus besoin de courir éteindre 10 comptes différents. C'est ça, la magie de la **centralisation**.

---

## Ajouter une nouvelle brique (admin)

Cette opération est faite par votre **prestataire** ou par vous-même si vous êtes à l'aise avec un peu de technique. Le principe :

1. Le prestataire ajoute la brique (un nouveau service) sur votre serveur Galaxis
2. Elle apparaît dans votre dashboard comme une nouvelle carte
3. Vos collaborateurs y ont accès immédiatement (selon les droits configurés)

C'est ce qu'on appelle **l'extensibilité** : Galaxis n'est pas figé, il grandit avec votre entreprise.

---

## Désactiver / retirer une brique

Si vous ne vous servez plus d'une brique :

1. Demandez à votre prestataire de la désactiver
2. La carte disparaît du dashboard de toute l'équipe
3. Les données de cette brique sont **conservées en sauvegarde** (si vous changez d'avis dans 6 mois) puis supprimées définitivement après un délai

⚠️ Ne supprimez **jamais** une brique sans en avoir discuté avec votre équipe : peut-être que Sarah s'en sert tous les jours sans vous le dire !

---

## Vos droits sur chaque brique

| Brique | Tout le monde peut… | Vous (l'admin) pouvez en plus… |
|---|---|---|
| Vaultwarden | Stocker, consulter, partager ses propres mots de passe | Voir les coffres partagés d'équipe, créer des organisations |
| Nextcloud | Uploader, télécharger, partager ses fichiers | Voir le quota global, créer des espaces partagés, gérer les utilisateurs |
| Galaxis lui-même | Voir son dashboard, son profil, ses logs | (en v2.0 — admin Galaxis dédié) |

---

## 🎯 Bilan

À ce stade, vous savez :

- ✅ Ce qu'est une **brique** dans Galaxis
- ✅ À quoi sert **Vaultwarden** (mots de passe)
- ✅ À quoi sert **Nextcloud** (fichiers)
- ✅ Ce qui est **prévu plus tard** (VPN)
- ✅ Comment vos briques sont **protégées** et **centralisées**

Maintenant, **passez à la pratique** :
- 🔐 [Vaultwarden : les bases](./03-vaultwarden-bases.md)
- ☁️ [Nextcloud : les bases](./04-nextcloud-bases.md)
