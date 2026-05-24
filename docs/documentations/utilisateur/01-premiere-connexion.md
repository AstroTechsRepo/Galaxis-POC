# 01 — Première connexion

> Le tour du propriétaire en 10 minutes ⏱️

---

## Avant de commencer

Votre Galaxis est déjà **installé** par votre prestataire (AstroTechs, ou la personne qui s'est occupée de la mise en route). Vous avez normalement reçu :

- 🔗 **L'adresse de votre Galaxis** — quelque chose comme `http://localhost:8080` (en démo) ou `https://galaxis.votre-entreprise.fr` (en vrai)
- 👤 **Votre identifiant** — par exemple `lucas-test`
- 🔑 **Votre mot de passe initial** — par exemple `demo` (à changer dès la première connexion !)

> 💡 **Astuce** : si vous n'avez rien reçu, demandez à votre prestataire ces 3 informations avant de commencer. Sans elles, ce guide ne servira à rien.

---

## Étape 1 — Ouvrir Galaxis

1. Ouvrez votre **navigateur favori** (Firefox, Chrome, Edge, Safari, peu importe)
2. Cliquez dans la barre d'adresse (tout en haut)
3. Tapez l'**adresse de votre Galaxis** que votre prestataire vous a donnée
4. Appuyez sur **Entrée**

✅ Vous devez voir une page sombre avec **le nom "Galaxis" en grand**, avec un dégradé de bleu vers violet. C'est la page d'accueil.

---

## Étape 2 — Cliquer sur "Se connecter"

Sur la page d'accueil :

1. Repérez le **gros bouton** au milieu de l'écran. Il est marqué *"Se connecter avec Keycloak"*.
2. Cliquez dessus.

> 🤔 **Keycloak ?** C'est le nom du système qui s'occupe de votre identité (un peu comme "France Connect" mais pour votre entreprise). Vous le verrez seulement à ce moment — promis, on ne vous embête plus avec ce mot après.

La page va changer : vous arrivez sur **l'écran de connexion**.

---

## Étape 3 — Saisir vos identifiants

Sur l'écran de connexion :

1. Dans le champ **"Nom d'utilisateur ou e-mail"** : tapez votre identifiant (ex : `lucas-test`)
2. Dans le champ **"Mot de passe"** : tapez votre mot de passe
3. Cliquez sur le bouton **"Se connecter"** (ou appuyez sur Entrée)

> ⚠️ **Attention** : si votre mot de passe ne marche pas, vérifiez :
> - que vous n'avez pas la touche **Verr. Maj.** activée (CapsLock)
> - que vous ne confondez pas un `O` (lettre) et un `0` (chiffre)
> - que vous tapez le bon identifiant

---

## Étape 4 — Bienvenue sur votre dashboard

✅ Si tout va bien, vous arrivez sur **votre dashboard** : un écran qui vous dit *"Bienvenue, [votre prénom]"* avec plusieurs cartes en dessous.

### Ce que vous voyez :

```
┌────────────────────────────────────────────┐
│  Galaxis                  Dashboard  Profil│ ← le menu en haut
├────────────────────────────────────────────┤
│                                            │
│   Bienvenue, Lucas                         │ ← votre nom
│   Vos briques sont prêtes.                 │
│                                            │
│   VOS BRIQUES                              │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│   │Vaultwarden│ │ Nextcloud│ │   VPN    │  │
│   │ disponible│ │disponible│ │ à venir  │  │
│   └──────────┘ └──────────┘ └──────────┘  │
│                                            │
│   IDENTITÉ & CLAIMS                        │
│   ┌────────────────────────────────────┐  │
│   │ sub : abc-123-...                  │  │
│   │ email : lucas-test@galaxis.local   │  │
│   │ …                                  │  │
│   └────────────────────────────────────┘  │
└────────────────────────────────────────────┘
```

### Les éléments importants

- **Les "cartes"** en haut sont vos **briques** : ce sont les outils auxquels vous avez accès. Cliquez sur l'une pour l'ouvrir.
- **Le tableau du bas** affiche vos **informations d'identité**. Pas besoin d'y toucher, c'est juste pour information.
- **Le menu en haut à droite** : *Dashboard* (retour ici), *Profil* (vos infos perso + historique), et un bouton *Déconnexion*.

---

## Étape 5 — Tester l'ouverture d'une brique

1. Cliquez sur la carte **Vaultwarden** (la première à gauche)
2. Un **nouvel onglet** s'ouvre dans votre navigateur
3. Vous arrivez sur la page d'accueil de Vaultwarden

> 💡 **Astuce** : à cette étape, Vaultwarden vous demandera de vous identifier (avec un compte Vaultwarden, qui peut être le même que votre identifiant Galaxis ou un autre, selon ce que votre admin a configuré). Voir le [chapitre 03 — Vaultwarden : les bases](./03-vaultwarden-bases.md).

Revenez à l'onglet Galaxis et faites pareil avec **Nextcloud** (chapitre [04](./04-nextcloud-bases.md) pour les détails).

---

## Étape 6 — Changer votre mot de passe initial (recommandé)

Si votre mot de passe est `demo` ou un autre mot de passe trivial donné par votre prestataire, **changez-le tout de suite** :

1. Cliquez sur **votre nom d'utilisateur** en haut à droite (ou allez sur le menu Profil)
2. *(Dans la version POC, le changement de mot de passe se fait dans la console Keycloak — demandez à votre prestataire de vous accompagner cette première fois. Dans la version 2.0, ce sera un bouton dans le Profil.)*

> ⚠️ **Attention** : un mot de passe sûr doit faire **au moins 12 caractères**, mélanger majuscules/minuscules, chiffres et symboles. Vaultwarden peut générer un mot de passe fort pour vous (voir chapitre 03).

---

## Étape 7 — Se déconnecter

En fin de journée :

1. Cliquez sur **Déconnexion** en haut à droite
2. Vous revenez à la page d'accueil

> 💡 **Astuce** : si vous fermez juste votre navigateur sans vous déconnecter, votre session reste ouverte pendant ~30 minutes. C'est pratique si vous rouvrez vite, mais moins sûr sur un ordinateur partagé.

---

## 🎉 Et voilà !

Vous avez fait le tour. Vous savez maintenant :

- ✅ Ouvrir Galaxis dans le navigateur
- ✅ Vous connecter avec votre identifiant
- ✅ Voir votre dashboard et vos briques
- ✅ Ouvrir une brique (Vaultwarden, Nextcloud)
- ✅ Vous déconnecter

Étape suivante : comprendre vos briques en détail → [chapitre 02](./02-gerer-mes-acces.md)

---

## 🆘 Ça n'a pas marché ?

| Problème | Solution |
|---|---|
| La page Galaxis ne s'ouvre pas | Vérifiez l'adresse, ou demandez à votre prestataire si la VM est bien démarrée |
| "Identifiants invalides" | Re-tapez attentivement, ou demandez un reset à votre admin |
| Page blanche après connexion | Rafraîchissez (F5), ou vider le cache du navigateur (Ctrl+Maj+R) |
| Le bouton "Se connecter" ne marche pas | Désactivez vos bloqueurs (uBlock, etc.) temporairement |

Pour plus d'aide, voir la [FAQ](./07-faq.md).
