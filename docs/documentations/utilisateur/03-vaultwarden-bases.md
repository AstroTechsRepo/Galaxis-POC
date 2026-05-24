# 03 — Vaultwarden : les bases

> Le coffre-fort de mots de passe expliqué simplement.

---

## C'est quoi Vaultwarden ?

Vaultwarden est un **coffre-fort numérique** où vous stockez vos **mots de passe**. Il est **chiffré** (= protégé par cryptographie), ce qui veut dire que même si quelqu'un volait le serveur, il ne pourrait pas lire vos mots de passe sans votre **mot de passe maître**.

> 💡 **Image mentale** : c'est comme un coffre-fort de banque, mais numérique. Vous seul·e avez la clé.

---

## Ouvrir Vaultwarden depuis Galaxis

1. Connectez-vous à Galaxis
2. Sur votre dashboard, cliquez sur la carte **"Vaultwarden"**
3. Un nouvel onglet s'ouvre

---

## Créer votre compte Vaultwarden (première fois)

> ⚠️ **Important** : dans la version actuelle (POC), Vaultwarden a son **propre compte** séparé de Galaxis. Vous devez créer votre compte Vaultwarden la première fois.

Si l'inscription publique est désactivée (par défaut pour la sécurité), demandez à votre prestataire de vous créer un compte. Sinon :

1. Sur la page d'accueil de Vaultwarden, cliquez sur **"Créer un compte"**
2. Renseignez :
   - **Adresse e-mail** : la même que celle de Galaxis (recommandé)
   - **Nom** : votre prénom + nom
   - **Mot de passe maître** : ⚠️ **TRÈS IMPORTANT** — choisissez un mot de passe **fort** que vous **ne devez jamais oublier**

> ⚠️ **Attention** : si vous oubliez votre mot de passe maître Vaultwarden, **personne ne peut le récupérer**. C'est le prix de la sécurité totale. Notez-le **dans un endroit sûr hors ligne** (papier dans un tiroir fermé à clé, par exemple) la première fois.

3. Validez. Vous êtes connecté·e.

---

## Stocker votre premier mot de passe

Imaginons que vous voulez stocker le mot de passe de votre compte Twitter pro.

1. En haut à droite, cliquez sur **"+ Nouveau"** (ou similaire selon la version)
2. Choisissez le type **"Identifiant"**
3. Remplissez :
   - **Nom** : *Twitter pro* (ce sera le label affiché dans la liste)
   - **URL** : `https://twitter.com`
   - **Nom d'utilisateur** : votre login Twitter
   - **Mot de passe** : votre mot de passe Twitter
4. Cliquez sur **"Enregistrer"**

✅ C'est fait ! Votre mot de passe est maintenant dans le coffre.

---

## Générer un mot de passe fort

Vous créez un nouveau compte sur un site et vous ne savez pas quel mot de passe choisir ? Laissez Vaultwarden le faire :

1. Sur la fiche du nouveau mot de passe, dans le champ **"Mot de passe"**, cliquez sur la petite **icône de dés** 🎲 (ou "Générer")
2. Choisissez les options : longueur (16 caractères minimum), inclure majuscules/chiffres/symboles
3. Cliquez sur **"Utiliser ce mot de passe"**
4. Enregistrez

> 💡 **Astuce** : utilisez un mot de passe **différent** pour chaque site. C'est tout l'intérêt d'avoir un coffre-fort : vous n'avez plus besoin de les retenir.

---

## Récupérer un mot de passe stocké

Plus tard, quand vous voulez vous reconnecter à Twitter :

1. Allez sur Vaultwarden
2. Dans la liste à gauche, trouvez **"Twitter pro"** (vous pouvez taper dans la barre de recherche)
3. Cliquez sur la fiche
4. Cliquez sur l'icône **"Copier"** à côté du mot de passe
5. Collez-le sur la page Twitter

🎉 Vous venez de vous connecter sans avoir tapé votre mot de passe — vous ne l'aviez même pas en mémoire !

---

## Partager un mot de passe avec un collègue

C'est là que ça devient intéressant pour une équipe. Imaginons : le compte LinkedIn de votre entreprise doit être accessible par Sarah et par vous, mais pas par tout le monde.

> ⚠️ **Note POC** : la fonctionnalité de partage avancée (organisations Vaultwarden) demande quelques étapes que votre prestataire vous accompagnera à mettre en place la première fois. Une fois configurée, le partage marche comme suit :

1. Créez une **"Organisation"** dans Vaultwarden (= un coffre partagé d'équipe)
2. Invitez Sarah par e-mail
3. Créez les mots de passe d'équipe **dans cette organisation** (pas dans votre coffre perso)
4. Sarah les verra automatiquement quand elle se connecte

---

## Utiliser Vaultwarden sur votre téléphone

Vaultwarden est compatible avec l'**application Bitwarden** (gratuite, sur iOS et Android).

1. Téléchargez **Bitwarden** depuis l'App Store ou Google Play
2. Au premier lancement, choisissez **"Self-hosted"** (auto-hébergé)
3. Renseignez l'URL de votre Vaultwarden (votre prestataire vous la donnera)
4. Connectez-vous avec votre e-mail et votre mot de passe maître

Vos mots de passe sont maintenant accessibles partout, et synchronisés en temps réel.

---

## Extension navigateur (très pratique)

Pour ne plus jamais taper de mot de passe :

1. Installez l'**extension Bitwarden** dans Firefox/Chrome/Edge
2. Configurez-la avec votre URL Vaultwarden + vos identifiants
3. À chaque fois que vous arrivez sur un site connu, l'extension propose **d'auto-remplir** votre login/mot de passe

> 💡 **Astuce** : cliquez sur l'icône Bitwarden quand vous êtes sur un site (Twitter, banque, etc.) → vos mots de passe associés à ce site apparaissent. Un clic = connecté.

---

## ⚠️ Bonnes pratiques de sécurité

| Faites | Ne faites pas |
|---|---|
| ✅ Utilisez un **mot de passe maître très fort** | ❌ Ne réutilisez **jamais** le même mot de passe sur 2 sites différents |
| ✅ Activez la **2FA** sur votre compte Vaultwarden si possible | ❌ Ne partagez **jamais** votre mot de passe maître |
| ✅ **Notez** votre mot de passe maître **hors ligne** (papier en sécurité) | ❌ N'envoyez **jamais** un mot de passe par mail ou SMS |
| ✅ **Verrouillez** Vaultwarden sur votre téléphone (FaceID, PIN) | ❌ Ne laissez **jamais** une session Vaultwarden ouverte sur un PC partagé |

---

## 🆘 Questions courantes

**Q : J'ai oublié mon mot de passe maître. Que faire ?**
A : Malheureusement, personne ne peut le récupérer (c'est le principe d'un coffre-fort chiffré). Votre admin peut **réinitialiser votre compte** (vous perdez tout le contenu) mais ne peut pas le **retrouver**.

**Q : Quelqu'un peut-il voir mes mots de passe en regardant le serveur ?**
A : Non. Vos mots de passe sont chiffrés **avant** d'arriver sur le serveur. Même votre admin n'y a pas accès en clair.

**Q : Si Internet tombe, je perds tout ?**
A : Non. L'application Bitwarden (mobile et navigateur) **garde une copie locale chiffrée**. Vous pouvez lire vos mots de passe hors ligne.

---

## 🎯 Bilan

Vous savez maintenant :

- ✅ Ouvrir Vaultwarden depuis Galaxis
- ✅ Stocker un mot de passe
- ✅ Générer un mot de passe fort
- ✅ Récupérer un mot de passe stocké
- ✅ Utiliser l'app mobile et l'extension navigateur
- ✅ Les bonnes pratiques de sécurité

Étape suivante : [Nextcloud : les bases](./04-nextcloud-bases.md)
