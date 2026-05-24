# 10 — IA et LLM comme levier de productivite

> **Audience** : jury, encadrant ESGI, futur repreneur
>
> Ce chapitre documente comment j'ai utilise les modeles de langage comme **outil d'execution** dans le cadre du POC Galaxis — et pourquoi cette approche demande autant de rigueur qu'un developpement classique.

---

## Ma posture : architecte, pas operateur

Je suis arrive sur ce projet avec une vision complete :

- **L'idee produit** : un orchestrateur souverain pour TPE, parce que l'enquete terrain (500 repondants) m'a confirme que la centralisation etait le besoin n°1
- **L'architecture** : 3 reseaux Docker isoles, un pont JWT unique, OIDC PKCE, separation des tiers — concue en amont, validee par mes recherches sur Keycloak et les patterns OAuth 2.1
- **Les choix technologiques** : Laravel pour le time-to-feature, React pour la modernite, Keycloak pour la souverainete — chaque choix est argumente dans le chapitre 03
- **Le scenario de demo** : Atelier Marchand, 5 personas, un flow demonstrable en 2min30
- **Le perimetre** : ce qu'on fait, ce qu'on ne fait pas, et **pourquoi**

L'IA n'a rien decide. Elle a **execute**.

---

## Le workflow : concevoir en amont, deleguer l'execution

### Phase 1 — Conception (moi seul + Claude comme sparring partner)

J'ai utilise Claude (chat) comme un **collegue a qui on soumet ses idees** :

- "Voila mon archi, qu'est-ce qui ne tiendrait pas en prod ?"
- "Keycloak vs Authelia vs Ory Hydra : confirme-moi que Keycloak est le bon choix pour mon cas"
- "Voici mon diagramme de sequence OIDC, est-ce que le refresh token est bien gere ?"

A chaque fois : **je proposais, l'IA challengeait, je tranchais**. Le resultat : 18 slides d'architecture et de cadrage qui m'appartenaient a 100 %, concues avec le meme soin qu'un cahier des charges remis a un prestataire.

### Phase 2 — Execution (Claude Code sous supervision)

Une fois l'architecture figee dans les slides, j'ai redige des **specifications d'execution** ultra-precises. Pas des prompts vagues — des briefs de mission de 500 lignes qui ne laissaient aucune marge d'interpretation :

```
Voici mes slides. Lis-les. Elles sont ta source de verite.
Voici la stack. Non negociable.
Voici le perimetre. IN scope : ca. OUT scope : ca.
Voici les contraintes de demo. Non negociables.
Voici la structure de fichiers attendue.
Voici les criteres de fini.
Execute.
```

**L'IA n'avait aucune liberte de conception** — uniquement de l'implementation dans un cadre que j'avais entierement defini. Exactement comme on brieferait un developpeur junior tres rapide.

### Phase 3 — Supervision permanente

Chaque sortie a ete :

1. **Testee en conditions reelles** sur ma VM, dans mon navigateur, avec mon tunnel SSH
2. **Reviewee fichier par fichier** — pas un `git merge` aveugle
3. **Corrigee quand necessaire** — j'ai du iterer 3 fois sur l'architecture reseau parce que mes premiers briefs contenaient des erreurs de cadrage que j'ai detectees au test

L'IA ne detecte pas ses propres incoherences. C'est mon role.

---

## La discipline du perimetre : savoir ne PAS faire

Le point le plus important de cette demarche n'est pas ce que j'ai fait faire a l'IA. C'est **ce que j'ai refuse de lui faire faire**.

### Exemple : le SSO bout-en-bout vers Vaultwarden et Nextcloud

Techniquement, j'aurais pu ecrire un prompt : "Configure le SSO OIDC de bout en bout entre Keycloak, Vaultwarden et Nextcloud." L'IA aurait produit quelque chose. Ca aurait peut-etre meme fonctionne au premier essai.

**Je ne l'ai pas fait.** Pourquoi :

- Le SSO bout-en-bout vers Vaultwarden necessite de comprendre le **flow OIDC cote Bitwarden**, les contraintes de redirect URI avec un reverse proxy sub-path, les implications sur le chiffrement zero-knowledge du coffre
- Le SSO vers Nextcloud implique une **architecture de trust** entre le Social Login plugin, Keycloak, et la gestion des comptes Nextcloud — avec des edge cases sur le provisioning automatique
- **Je ne maitrisais pas suffisamment ces sujets** pour ecrire un brief qui garantisse un resultat correct et maintenable

Deleguer a l'IA un sujet qu'on ne maitrise pas, c'est **perdre le controle**. On ne peut pas reviewer ce qu'on ne comprend pas. On ne peut pas tester ce qu'on ne sait pas valider. On se retrouve avec du code qui "marche" sans savoir pourquoi, et qui cassera sans qu'on sache le reparer.

J'ai donc place le SSO bout-en-bout en **OUT scope POC** (slide 07, documentee dans le chapitre 05), avec une justification claire : "concu, documente, mais necessite une architecture plus poussee — prevu pour la v2.0". C'est une decision d'architecte, pas un aveu de faiblesse.

### Meme logique pour les autres OUT scope

| Feature OUT scope | Pourquoi je ne l'ai pas deleguee a l'IA |
|---|---|
| SSO bout-en-bout Vault/Cloud | Complexite architecturale que je ne pouvais pas cadrer assez finement |
| MFA Keycloak | Necessite de comprendre les flows TOTP/WebAuthn dans le contexte de mon architecture |
| Multi-tenant | Impact structurel sur le modele de donnees et l'isolation — pas un "ajout" |
| Migration AWS effective | Infrastructure reelle, couts reels, consequences irreversibles |

A l'inverse, voici ce que j'ai delegue avec confiance :

| Feature IN scope | Pourquoi je pouvais la deleguer |
|---|---|
| Middleware JWT RS256 + cache JWKS | Je comprends le flow, je peux review le code, je peux tester avec un token forge |
| Docker Compose 11 conteneurs | J'ai l'architecture en tete, je peux valider chaque mapping de port et de reseau |
| Documentation 27 chapitres | J'ai le plan, la structure, le niveau de detail — je peux relire et corriger |
| Tests Pest + Vitest | Je sais ce que chaque test doit prouver, je peux lire les assertions |

**La regle** : je ne delegue que ce que je suis capable de **reviewer avec un regard critique**.

---

## Gains concrets

| Metrique | Sans IA (estimation) | Avec IA (reel) |
|----------|---------------------|----------------|
| Code backend + frontend + infra | ~3-4 semaines | ~3 jours d'execution |
| 27 chapitres de documentation | ~2-3 semaines | ~2 jours de generation + 2 jours de review |
| Tests automatises (23) | ~1 semaine | ~1 jour |
| **Total estimation** | **~8-10 semaines de dev** | **~2 semaines effectives** |

Le gain n'est pas "gratuit" : les 2 semaines ne comptent pas le temps de **conception en amont** (architecture, slides, scenarios) ni le temps de **review et correction**. Le cycle complet reste ~6 mois. L'IA a compresse la phase d'execution, pas la phase de reflexion.

---

## Ce que cette approche m'a appris

### 1. Specifier est plus dur que coder

Ecrire un brief de 500 lignes sans ambiguite est un exercice d'architecture en soi. Si je ne peux pas l'ecrire clairement, c'est que je n'ai pas assez compris le sujet — et dans ce cas, je ne dois pas deleguer.

### 2. Reviewer du code qu'on n'a pas ecrit developpe le sens critique

Lire du code produit par quelqu'un d'autre (humain ou IA) et identifier les incoherences demande une comprehension profonde du systeme. C'est la meme competence qu'un tech lead qui review les PRs de son equipe.

### 3. Savoir s'arreter est une competence

La tentation avec un outil puissant est de vouloir tout faire. Resister a cette tentation — placer des OUT scope clairs, refuser de deleguer ce qu'on ne maitrise pas — est la marque d'un ingenieur mature.

### 4. L'IA amplifie, elle ne remplace pas

Un bon brief + une IA = un resultat excellent.
Un mauvais brief + une IA = un resultat qui a l'air bon mais qui est fragile.
Pas de brief + une IA = un resultat aleatoire.

La qualite du resultat est **proportionnelle a la qualite de la reflexion en amont**.

---

## Conclusion

L'utilisation de l'IA dans ce projet n'est pas un raccourci. C'est une **methode de travail** qui exige :

- Une vision claire avant de commencer
- Des specifications rigoureuses
- Une supervision permanente
- La discipline de ne pas aller au-dela de ce qu'on peut controler

Le POC Galaxis est **mon projet** — concu par moi, architecture par moi, cadre par moi. L'IA est l'outil qui m'a permis de le **materialiser seul en 6 mois** avec un niveau de qualite qui aurait normalement necessite une equipe.

---

## Liens internes
- Gestion de projet : [07-gestion-projet.md](./07-gestion-projet.md)
- Difficultes et apprentissages : [08-difficultes-apprentissages.md](./08-difficultes-apprentissages.md)
- Perimetre et decisions : [05-perimetre-decisions.md](./05-perimetre-decisions.md)
