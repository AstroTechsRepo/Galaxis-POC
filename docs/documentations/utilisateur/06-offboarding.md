# 06 — Offboarding propre

> Sophie part vendredi. Comment couper proprement ses accès, sans tout casser ?

---

## Pourquoi un offboarding propre est crucial

Un offboarding bâclé, c'est :

- Un ex-employé qui garde l'accès au Vaultwarden 2 mois après son départ (anecdote vécue par Marc, slide 5)
- Un commercial débauché qui télécharge la base clients la veille de partir
- Un audit qui découvre 12 comptes "fantômes" actifs dans Keycloak
- Un risque RGPD/DORA réel — vous êtes responsable des accès accordés

Galaxis est conçu pour que **l'offboarding soit aussi simple qu'un clic**. Profitons-en.

---

## La règle d'or

> **L'offboarding doit être fait LE JOUR MÊME du départ, pas "quand on aura le temps".**

Idéalement : à 17h30 le dernier jour, avant que la personne quitte les locaux.

---

## La procédure express (5 minutes)

### Étape 1 — Désactiver le compte Galaxis (Keycloak)

C'est la **clé maîtresse**. En désactivant le compte Galaxis, vous coupez l'accès à toutes les briques qui dépendent de Galaxis (à terme, en v2.0, ce sera vraiment tout d'un coup).

1. Ouvrez la console Keycloak : `https://galaxis.votre-tpe.fr/admin` (ou `http://localhost:8080/admin` en POC)
2. Realm `galaxis` → **Users**
3. Cherchez `sophie`
4. Sur sa fiche, onglet **Details** :
   - Décochez **Enabled** (=> compte désactivé)
   - OU mieux : utilisez le bouton **Disable** en haut
5. Cliquez **Save**

✅ Sophie ne peut plus se connecter à Galaxis.

### Étape 2 — Forcer la déconnexion des sessions actives

Si Sophie a une session ouverte sur son téléphone ou un PC, il faut l'**éjecter** :

1. Sur sa fiche, onglet **Sessions**
2. Cliquez **"Logout all sessions"**

✅ Toutes ses sessions sont fermées. Si elle essaie d'utiliser un onglet déjà ouvert, ça ne marchera plus.

---

### Étape 3 — Couper Vaultwarden

> Dans la version actuelle POC, Vaultwarden est séparé. Procédez **manuellement** :

1. Ouvrez Vaultwarden avec votre compte admin
2. Allez dans **Organisations** → votre orga d'équipe
3. Onglet **Membres** → trouvez `sophie@votre-tpe.fr`
4. Cliquez **"Retirer"** ou **"Supprimer le membre"**

✅ Sophie perd l'accès aux mots de passe partagés. Son **coffre personnel** Vaultwarden reste à elle (c'est normal — elle l'a chiffré avec son mot de passe maître, vous ne pouvez pas y toucher).

---

### Étape 4 — Couper Nextcloud

1. Ouvrez Nextcloud avec votre compte admin
2. Avatar en haut à droite → **Utilisateurs**
3. Trouvez `sophie`
4. Soit :
   - **Désactiver** (compte conservé mais inactif, fichiers conservés) — recommandé si vous voulez récupérer ses fichiers de travail plus tard
   - **Supprimer** (compte + fichiers persos effacés définitivement) — choisir si départ définitif et données non nécessaires

> **Avant de désactiver/supprimer** : récupérez les fichiers professionnels que Sophie a dans son espace privé. Demandez-lui de **les déplacer dans un dossier d'équipe** avant de partir, ou copiez-les depuis l'admin si elle est partie sans le faire.

---

### Étape 5 — Vérifier l'audit log

Pour la traçabilité :

1. Dans Galaxis, allez sur **Profil** (votre profil admin)
2. Section **"Activité d'authentification"** : vous voyez les dernières connexions, dont celles de Sophie
3. Pour un audit complet, demandez à votre prestataire d'exporter les logs sur la période concernée

> **Astuce** : **prenez une capture d'écran** de l'écran "Sessions: 0" et "Status: Disabled" sur la fiche Keycloak de Sophie. Datez-la. C'est votre **preuve d'offboarding** en cas de contrôle ou de litige.

---

## Cas particuliers

### Sophie est en arrêt maladie longue durée

Désactivez le compte mais **ne le supprimez pas** : à son retour, vous le réactivez en 1 clic. Tous ses fichiers et historique restent intacts.

### Sophie quitte avec un préavis

Profitez du préavis pour :

- Lui faire transférer ses dossiers en cours dans les espaces partagés
- Récupérer la documentation interne qu'elle aurait pu créer
- Faire un transfert de connaissance avec son·sa remplaçant·e

Le **jour du départ**, désactivez le compte (pas avant).

### Sophie part en mauvais termes / licenciement

- **Désactivez son compte IMMÉDIATEMENT**, idéalement **avant** la conversation difficile
- **Forcez la déconnexion** de toutes les sessions
- **Changez les mots de passe partagés** auxquels elle avait accès (Vaultwarden : utilisez la fonction "rotate" si dispo)
- Faites un export de l'audit log pour preuves

### Sophie revient en freelance plus tard

Vous pouvez **réactiver** le compte avec une **date d'expiration** (préavis de mission). Le compte reste désactivé en dehors de la mission. Pas besoin de tout recréer.

---

## Checklist offboarding à imprimer

Imprimez cette checklist et cochez à chaque départ :

```
☐ Compte Galaxis désactivé (Keycloak)
☐ Toutes les sessions Keycloak fermées
☐ Membre retiré de l'organisation Vaultwarden
☐ Compte Nextcloud désactivé ou supprimé
☐ Fichiers professionnels récupérés
☐ Mots de passe partagés sensibles changés (si départ conflictuel)
☐ Capture d'écran de l'audit faite et archivée
☐ Date et nom du collaborateur notés dans le registre interne
☐ (Si freelance) date d'expiration paramétrée pour réactivation future
```

---

## Temps moyen

| Scénario | Durée |
|---|---|
| Offboarding standard (départ amical) | ~ 5 minutes |
| Offboarding sensible (conflit, urgence) | ~ 10 minutes + changement mots de passe |
| Offboarding par préavis avec récupération données | ~ 30 minutes |

À comparer aux **2 mois** où l'ex-alternant de Marc gardait l'accès au coffre avant Galaxis…

---

## Erreur fréquente

**"J'ai désactivé son compte mais elle s'est reconnectée hier !"**

Cause probable : son **navigateur avait un token valide** (le token reste valide ~30 minutes après désactivation Keycloak).

Solution :
- Onglet **Sessions** de l'utilisateur → **Logout all sessions** (force la révocation)
- Si urgent : redémarrer Keycloak (demandez au prestataire) coupe TOUTES les sessions de TOUT le monde

---

## Bilan

Vous savez maintenant :

- ✅ Désactiver un compte Galaxis en 1 clic
- ✅ Forcer la déconnexion des sessions actives
- ✅ Retirer des organisations Vaultwarden
- ✅ Désactiver / supprimer un compte Nextcloud
- ✅ Gérer les cas particuliers (préavis, conflit, freelance)
- ✅ Garder une preuve d'offboarding pour vos audits

Plus jamais d'ex-employé fantôme dans vos systèmes.

Étape suivante : [FAQ](./07-faq.md)
