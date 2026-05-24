# 04 — Nextcloud : les bases

> Votre drive d'équipe, version souveraine.

---

## C'est quoi Nextcloud ?

Nextcloud est un **drive collaboratif** — un peu comme Google Drive ou Dropbox, mais **chez vous** (sur votre serveur Galaxis). Vous y stockez vos fichiers, vous les partagez avec votre équipe, vous travaillez à plusieurs sur un document.

> **Image mentale** : c'est l'**armoire à dossiers** numérique de votre entreprise. Chacun a sa zone perso, et il y a des zones partagées.

---

## Ouvrir Nextcloud depuis Galaxis

1. Connectez-vous à Galaxis
2. Sur votre dashboard, cliquez sur la carte **"Nextcloud"**
3. Un nouvel onglet s'ouvre

---

## Première connexion à Nextcloud

> **Note POC** : comme Vaultwarden, Nextcloud a son **propre compte** dans la version actuelle. Demandez à votre prestataire vos identifiants Nextcloud lors de la mise en route.

À la première connexion, identifiez-vous avec :
- **Nom d'utilisateur** : celui fourni par votre admin
- **Mot de passe** : celui fourni par votre admin

✅ Vous arrivez sur la page d'accueil Nextcloud : une grille de fichiers (vide pour l'instant) avec un menu en haut.

---

## Uploader votre premier fichier

1. Sur la page principale (l'icône **"Fichiers"** dans le menu du haut)
2. Cliquez sur le bouton **"+ Nouveau"** ou **"+"** en haut
3. Choisissez **"Téléverser un fichier"**
4. Sélectionnez le fichier sur votre ordinateur (par exemple `mon-contrat.pdf`)
5. Attendez la fin du téléversement (barre de progression en bas)

✅ Votre fichier apparaît dans la liste.

> **Astuce** : vous pouvez aussi simplement **faire glisser** un fichier (ou plusieurs) depuis votre Explorateur/Finder directement dans la fenêtre Nextcloud. Drag & drop, comme un grand.

---

## Créer un dossier

Pour s'organiser :

1. Cliquez sur **"+ Nouveau"** → **"Nouveau dossier"**
2. Donnez-lui un nom : par exemple `Comptabilité 2026`
3. Validez avec Entrée

✅ Le dossier apparaît. Cliquez dessus pour entrer dedans.

> **Astuce** : adoptez tôt une **convention de nommage** dans votre équipe :
> - Année + thème : `2026 - Comptabilité`
> - Client + projet : `ClientX - Refonte site`
> - Type + date : `Contrats - 2026-Q1`
>
> Vous remercierez votre vous-d'aujourd'hui dans 6 mois.

---

## Partager un fichier ou un dossier

Imaginons : vous voulez partager le dossier `Comptabilité 2026` avec votre comptable Sophie.

### Partage interne (avec un collaborateur)

1. À côté du dossier, cliquez sur l'icône **"Partager"** (un petit nuage avec une flèche)
2. Dans le champ de recherche, tapez le **nom de Sophie**
3. Sélectionnez Sophie dans la liste
4. Choisissez ses droits :
   - **Lecture** : elle peut voir/télécharger mais pas modifier
   - **Modification** : elle peut éditer et ajouter des fichiers
   - **Suppression** : elle peut supprimer (à donner avec prudence !)
5. Cliquez pour valider

✅ Sophie reçoit une notification dans son Nextcloud et voit le dossier dans sa liste.

### Partage externe (avec un client par lien)

Pour donner un fichier à un client qui n'a pas de compte Nextcloud :

1. Cliquez sur **"Partager"** → onglet **"Partage par lien"**
2. Cliquez sur **"+"** pour créer un nouveau lien
3. Configurez :
   - **Date d'expiration** : très recommandé (ex : dans 7 jours)
   - **Mot de passe** : optionnel mais conseillé pour les fichiers sensibles
   - **Permission** : Lecture seule (par défaut, ce qu'il faut)
4. Cliquez sur **"Copier le lien"**
5. Envoyez ce lien au client par mail (et le mot de passe par un autre canal, ex : SMS)

✅ Le client clique sur le lien, entre le mot de passe, télécharge le fichier.

> **Attention** : un lien partagé **sans expiration ni mot de passe** est accessible par n'importe qui qui obtient l'URL. Configurez toujours **au moins une protection** pour les documents sensibles.

---

## Synchroniser avec votre ordinateur (recommandé)

Pour que vos fichiers Nextcloud soient **automatiquement présents** sur votre PC (comme Dropbox) :

1. Téléchargez le **client Nextcloud Desktop** depuis [nextcloud.com/clients](https://nextcloud.com/clients) (Windows, Mac, Linux)
2. Installez-le
3. Au premier lancement, renseignez :
   - **URL** du serveur Nextcloud (donnée par votre admin)
   - **Identifiants** Nextcloud
4. Choisissez le **dossier local** où synchroniser (par défaut : `~/Nextcloud`)

✅ Maintenant, vous pouvez glisser des fichiers dans ce dossier local et ils apparaissent automatiquement dans Nextcloud (et inversement).

---

## Application mobile

L'app **Nextcloud** existe sur iOS et Android (gratuite).

- Vous pouvez **consulter** vos fichiers
- **Télécharger** un PDF pour lecture hors-ligne
- **Uploader** une photo prise avec le téléphone directement dans le bon dossier
- Activer **l'auto-upload des photos** (très pratique si vous prenez beaucoup de photos pro)

---

## Calendrier et tâches (bonus)

Nextcloud inclut aussi :

- **Calendrier** : à partager avec votre équipe, synchronisable avec Outlook / Google Calendar
- **Contacts** : carnet d'adresses partagé
- **Tâches** : todo list collaborative
- **Talk** : visioconférence intégrée (option à activer par votre admin)

Pour y accéder : icônes en haut à droite de Nextcloud.

---

## Bonnes pratiques

| Faites | Ne faites pas |
|---|---|
| ✅ **Organisez en dossiers** dès le début | ❌ Ne mettez pas 500 fichiers vrac à la racine |
| ✅ **Mettez une date d'expiration** sur les liens partagés externes | ❌ Ne partagez pas avec "Tout le monde" sauf cas précis |
| ✅ Pour les **gros fichiers**, prévenez votre équipe (impact quota) | ❌ Ne stockez pas de **vidéos perso** sur le drive pro |
| ✅ **Activez la 2FA** sur votre compte Nextcloud si dispo | ❌ Ne laissez pas une session Nextcloud ouverte sur un PC public |

---

## Questions courantes

**Q : Combien d'espace ai-je ?**
A : En bas à gauche, vous voyez votre quota (ex : *2,3 Go sur 10 Go utilisés*). Votre admin peut l'augmenter à la demande.

**Q : Je veux récupérer un fichier que j'ai supprimé hier.**
A : Dans le menu de gauche, cliquez sur **"Fichiers supprimés"**. Vous pouvez restaurer un fichier jusqu'à 30 jours après sa suppression.

**Q : Comment éditer un Word/Excel en ligne directement ?**
A : Si votre admin a activé **Collabora Online** (intégration libre office), un double-clic sur un .docx ouvre un éditeur intégré au navigateur. Sinon, téléchargez le fichier, éditez-le sur votre PC, réuploadez.

**Q : Mes collègues peuvent-ils voir mes fichiers persos ?**
A : Non, sauf si vous les avez explicitement partagés. Chacun a son espace **privé**. Les **dossiers partagés** sont visibles uniquement par les personnes invitées.

---

## Bilan

Vous savez maintenant :

- ✅ Ouvrir Nextcloud depuis Galaxis
- ✅ Uploader un fichier et créer des dossiers
- ✅ Partager en interne et en externe (avec lien sécurisé)
- ✅ Synchroniser avec votre ordinateur et votre téléphone
- ✅ Utiliser les fonctions bonus (calendrier, contacts)
- ✅ Les bonnes pratiques de partage sécurisé

Étape suivante : [Onboarding d'un collaborateur](./05-onboarding-collaborateur.md)
