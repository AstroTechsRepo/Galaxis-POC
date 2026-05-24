# 07 — FAQ — Questions fréquentes

> Si vous êtes coincé·e, regardez ici avant d'appeler votre prestataire. La réponse y est sûrement.

---

## 🔐 Connexion à Galaxis

### Q : J'ai oublié mon mot de passe Galaxis.

**A** : Demandez à votre administrateur (Marc, ou la personne qui gère vos accès) de **réinitialiser votre mot de passe**. Procédure pour l'admin : console Keycloak → votre fiche utilisateur → onglet Credentials → Reset password → cochez "Temporary" → envoyez-vous le nouveau mot de passe.

Vous saisirez ce nouveau mot de passe à votre prochaine connexion, et Galaxis vous demandera d'en choisir un personnel.

---

### Q : La page Galaxis ne s'ouvre pas du tout.

**A** : Vérifiez dans l'ordre :

1. **L'adresse est-elle correcte ?** Si vous avez `http://localhost:8080` (POC), il faut que le tunnel SSH soit actif.
2. **Êtes-vous connecté à internet ?** (test : ouvrez google.fr)
3. **Votre prestataire est-il en train de faire une maintenance ?** Demandez.
4. **Le navigateur a-t-il un cache corrompu ?** Essayez Ctrl+Shift+R (rechargement forcé) ou un autre navigateur.

Si rien ne marche, contactez votre prestataire.

---

### Q : J'ai un message "Connexion non sécurisée" / "Cette page n'est pas privée".

**A** : Cela arrive si le serveur Galaxis n'a pas (encore) de certificat HTTPS valide. **En version POC**, c'est attendu (le tunnel SSH chiffre le trafic à votre place). En **version prod**, ce ne devrait pas arriver — appelez votre prestataire.

---

### Q : Je clique "Se connecter" mais rien ne se passe.

**A** : Probable cause : un **bloqueur de publicité** (uBlock, Brave Shield…) bloque la redirection. Désactivez-le pour le site Galaxis et réessayez.

---

## 👤 Mon profil

### Q : Mon nom est mal écrit sur le dashboard.

**A** : Votre admin doit corriger ça dans la console Keycloak : votre fiche → champs *First name* / *Last name*. Vous verrez le changement à votre prochaine connexion.

---

### Q : Comment changer mon adresse email ?

**A** : Demandez à votre admin. Procédure Keycloak : votre fiche → champ Email → modifier → Save.

---

### Q : Je veux voir l'historique de mes connexions.

**A** : Sur Galaxis, cliquez sur **Profil** dans le menu en haut. La section "Activité d'authentification" liste vos dernières connexions avec date et IP. Si vous voyez des connexions que vous ne reconnaissez pas, prévenez immédiatement votre admin.

---

## 🔐 Vaultwarden

### Q : J'ai oublié mon mot de passe maître Vaultwarden. Que faire ?

**A** : **Personne ne peut le récupérer.** C'est le principe d'un coffre chiffré. Vos options :

1. Demandez à votre admin de **réinitialiser votre compte Vaultwarden** — vous perdez tout le contenu mais récupérez un compte vide
2. Re-saisissez vos mots de passe à partir de souvenirs / écrits perso

C'est la raison pour laquelle on insiste à l'inscription : **notez votre mot de passe maître sur papier, en lieu sûr**.

---

### Q : Mon collègue ne voit pas le mot de passe que j'ai créé pour l'équipe.

**A** : Vous avez probablement créé le mot de passe dans votre **coffre personnel** au lieu de l'**organisation** d'équipe. Allez sur la fiche du mot de passe → champ "Owner" → changez de "Moi" vers "Organisation X". Votre collègue le verra immédiatement.

---

### Q : Vaultwarden me dit "Verrouillé". Comment déverrouiller ?

**A** : Par sécurité, Vaultwarden se verrouille après un délai d'inactivité. Saisissez votre **mot de passe maître** pour déverrouiller. C'est normal.

---

### Q : Comment générer un mot de passe sans Vaultwarden ouvert ?

**A** : Installez l'**extension navigateur Bitwarden** : un clic sur l'icône → onglet "Générateur" → mot de passe prêt à copier.

---

## ☁️ Nextcloud

### Q : J'ai dépassé mon quota de stockage.

**A** : Faites le ménage dans vos fichiers personnels, ou demandez une augmentation à votre admin. Procédure admin : Nextcloud → Utilisateurs → votre fiche → champ Quota → augmenter.

---

### Q : J'ai supprimé un fichier par erreur.

**A** : Allez dans **"Fichiers supprimés"** dans le menu de gauche de Nextcloud. Vous pouvez restaurer un fichier jusqu'à **30 jours** après suppression. Au-delà, c'est définitif.

---

### Q : Le lien de partage que j'ai envoyé à mon client ne marche plus.

**A** : Vérifiez :

1. **La date d'expiration** — peut-être qu'elle est passée. Refaites un lien avec une nouvelle date.
2. **Le mot de passe** — votre client le saisit-il correctement ?
3. **L'accès est-il toujours autorisé ?** Quelqu'un a peut-être révoqué le partage.

---

### Q : Comment voir qui a téléchargé mon fichier partagé ?

**A** : Activité Nextcloud (icône cloche en haut à droite) → vous voyez les events de partage et de téléchargement.

---

### Q : Je veux éditer un Word/Excel sans le télécharger.

**A** : Si votre admin a installé **Collabora Online** (LibreOffice intégré), double-clic sur le fichier l'ouvre dans le navigateur. Sinon, vous devez le télécharger, l'éditer localement, le re-uploader.

---

## 🚪 Onboarding / Offboarding

### Q : Je dois créer un compte pour un nouveau collaborateur. Comment faire ?

**A** : Voir le chapitre [05 — Onboarding d'un collaborateur](./05-onboarding-collaborateur.md). En résumé : créer le compte Keycloak, inviter sur Vaultwarden, créer sur Nextcloud, envoyer un mail d'accueil. ~10 minutes.

---

### Q : Quelqu'un est parti, comment couper ses accès rapidement ?

**A** : Voir le chapitre [06 — Offboarding propre](./06-offboarding.md). En résumé : désactiver le compte Keycloak, forcer la déconnexion des sessions, retirer de Vaultwarden, désactiver Nextcloud. ~5 minutes.

---

## 🆘 Sécurité

### Q : Je pense que mon compte a été piraté. Que faire ?

**A** :

1. **Changez immédiatement votre mot de passe Galaxis** (passez par votre admin)
2. **Changez votre mot de passe maître Vaultwarden**
3. **Forcez la déconnexion de toutes les sessions** (votre admin le fait via Keycloak)
4. **Regardez votre historique** d'authentification — y a-t-il des connexions étrangères ?
5. **Activez la 2FA** si pas déjà fait
6. **Prévenez votre admin et votre prestataire**

---

### Q : Quelqu'un peut-il lire mes fichiers / mots de passe sur le serveur ?

**A** :

- **Vaultwarden** : non, vos mots de passe sont chiffrés avec votre mot de passe maître. Même l'admin technique ne peut pas les lire.
- **Nextcloud** : par défaut, **non**, vos fichiers persos sont privés. Seuls les dossiers partagés sont accessibles aux personnes invitées. L'admin technique peut techniquement lire les fichiers stockés sur le serveur — c'est pour ça qu'on choisit un prestataire de confiance.

---

### Q : Mes données sont-elles bien en France / Europe ?

**A** : Cela dépend de **où votre Galaxis est hébergé**.

- Si auto-hébergé chez vous : oui, c'est chez vous, point.
- Si chez un prestataire : demandez où est physiquement le serveur (datacenter à Strasbourg ? Paris ? Allemagne ?). Votre prestataire doit pouvoir répondre clairement.

C'est tout l'intérêt de Galaxis : **vous savez où sont vos données**.

---

## 💻 Aspects techniques (pour les curieux)

### Q : C'est quoi Keycloak / OIDC / JWT ?

**A** : Voir le [glossaire](./08-glossaire.md). Version courte : ce sont les outils techniques qui font que vous vous connectez une seule fois et que tout reste sûr. Vous n'avez normalement **jamais besoin de les voir** en tant qu'utilisateur.

---

### Q : Galaxis fonctionne-t-il sans internet ?

**A** : Si votre serveur Galaxis est dans vos locaux : oui, en local. Si chez un prestataire : non, il faut internet pour y accéder.

---

### Q : Galaxis fonctionne-t-il sur mon téléphone ?

**A** :

- **Le portail Galaxis lui-même** : oui dans le navigateur du téléphone, mais moins ergonomique qu'un PC.
- **Vaultwarden** : oui, via l'app **Bitwarden** (gratuite, iOS + Android).
- **Nextcloud** : oui, via l'app **Nextcloud** (gratuite, iOS + Android).

---

## 📞 Quand contacter votre prestataire

Vous devriez contacter votre prestataire (AstroTechs, ou autre) si :

- Galaxis est complètement injoignable depuis plusieurs heures
- Vous avez besoin d'**ajouter une brique** (ex : ajout d'un wiki, d'une messagerie)
- Vous voulez **migrer vers le cloud** (AWS Sovereign)
- Vous suspectez une **intrusion** ou un **incident de sécurité**
- Vous avez besoin de **récupérer des données** depuis un backup
- Vous voulez une **formation approfondie** pour votre équipe

Pour le reste (utilisation quotidienne), 95 % des questions trouvent leur réponse dans ce guide.

---

## 🎯 Vous n'avez pas trouvé votre réponse ?

1. Cherchez dans le **[glossaire](./08-glossaire.md)** — le mot qui vous bloque y est peut-être expliqué
2. Demandez à votre **équipe** (peut-être que Sarah ou Karim a déjà eu le même souci)
3. Contactez votre **prestataire**
4. Faites-nous remonter la question pour qu'on l'ajoute à cette FAQ
