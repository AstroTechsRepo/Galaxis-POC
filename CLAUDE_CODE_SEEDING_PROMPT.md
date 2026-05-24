# 🌱 Mission Claude Code — Seeding données de démo GALAXIS

> Tu viens de finir le rebuild complet du POC GALAXIS. Maintenant, tu vas créer un **jeu de données de démo cohérent** entre **Laravel** et **Keycloak**, pour que Lucas puisse faire une démo crédible au jury ESGI.

---

## 🎯 Objectif

Permettre à Lucas de :
1. Se logger en démo avec **n'importe lequel des users** créés (vrais comptes Keycloak)
2. Voir dans le dashboard des **claims réels** (nom, email, rôles depuis le JWT)
3. Montrer un endpoint `/api/audit` qui contient ~20 entrées **cohérentes** des derniers jours
4. Tout ça **sans manipulation manuelle** — un `make seed` et c'est fait

---

## 🎭 Scénario narratif (inspiré du persona Marc — slide 05)

L'entreprise fictive de démo est **« Atelier Marchand »**, une TPE de menuiserie de 5 personnes.

### Les 5 users à créer (cohérents dans Keycloak ET Laravel)

| Username | Email | Prénom Nom | Rôle Keycloak | Description |
|---|---|---|---|---|
| `marc` | `marc@atelier-marchand.demo` | Marc Marchand | `admin` | Gérant, le persona principal — slide 05 |
| `sophie` | `sophie@atelier-marchand.demo` | Sophie Lemoine | `user` | Comptable à mi-temps |
| `julien` | `julien@atelier-marchand.demo` | Julien Petit | `user` | Apprenti menuisier |
| `chloe` | `chloe@atelier-marchand.demo` | Chloé Dubois | `user` | Commerciale terrain |
| `admin` | `admin@galaxis.demo` | Admin Galaxis | `admin` | Compte technique de démo |

**Mots de passe** : tous `Demo2026!` (documenté dans `LIVRAISON.md` et le `demo-guide.md`, jamais commité en .env)

> ⚠️ Ces mots de passe sont **uniquement** pour la démo POC. Documenter explicitement que ce n'est pas une pratique prod.

---

## 🛠️ Tâches à exécuter (mode autonome)

### 1. Étendre `infrastructure/scripts/configure-keycloak.sh`

Modifier le script idempotent existant pour qu'il crée aussi les 5 users ci-dessus :

- Création via `kcadm.sh` (le CLI admin Keycloak)
- Vérifier l'existence avant `create` (idempotent — relançable sans erreur)
- Assigner le bon rôle Keycloak (créer les rôles realm `admin` et `user` s'ils n'existent pas)
- Définir le mot de passe non-temporaire (`--temporary false`)
- Remplir `firstName`, `lastName`, `email`, `emailVerified=true`

### 2. Créer les factories Laravel

#### `database/factories/UserFactory.php`
Factory standard Laravel, avec :
- `keycloak_sub` (UUID — sera réconcilié au premier login OIDC réel)
- `username`, `email`, `first_name`, `last_name`
- `role` (`admin` ou `user`)
- `created_at` : entre 30 et 90 jours dans le passé (les users existent depuis un moment)

#### `database/factories/AuditLogFactory.php`
Factory pour la table `audit_logs`, avec :
- `user_id` (foreign key vers users)
- `event` : un parmi `login_success`, `login_failure`, `logout`, `token_refresh`, `access_denied`
- `ip_address` : faker IP
- `user_agent` : faker user agent (browser réaliste)
- `context` (JSON) : `{"client_id": "galaxis-portal", "auth_method": "oidc_pkce"}`
- `created_at` : étalé sur les 7 derniers jours, biaisé vers les jours ouvrés et les heures de bureau (9h-19h)

### 3. Créer le seeder `DemoSeeder`

#### `database/seeders/DemoSeeder.php`

Crée les **5 users exacts** ci-dessus (pas via factory aléatoire — explicites, pour rester cohérents avec Keycloak) :

```php
$users = [
    ['username' => 'marc',   'email' => 'marc@atelier-marchand.demo',   'first_name' => 'Marc',   'last_name' => 'Marchand', 'role' => 'admin'],
    ['username' => 'sophie', 'email' => 'sophie@atelier-marchand.demo', 'first_name' => 'Sophie', 'last_name' => 'Lemoine',  'role' => 'user'],
    ['username' => 'julien', 'email' => 'julien@atelier-marchand.demo', 'first_name' => 'Julien', 'last_name' => 'Petit',    'role' => 'user'],
    ['username' => 'chloe',  'email' => 'chloe@atelier-marchand.demo',  'first_name' => 'Chloé',  'last_name' => 'Dubois',   'role' => 'user'],
    ['username' => 'admin',  'email' => 'admin@galaxis.demo',           'first_name' => 'Admin',  'last_name' => 'Galaxis',  'role' => 'admin'],
];
```

Puis génère **~20 audit logs** distribués de façon réaliste :
- Marc se connecte ~tous les jours ouvrés (5-6 entrées sur 7 jours)
- Sophie ~3 fois (mi-temps)
- Julien ~4 fois
- Chloé ~3 fois (terrain)
- Admin ~2 fois
- 1-2 `login_failure` épars (réalisme)
- 1 `access_denied` (pour montrer que le RBAC log les refus)

Toujours via la factory (pas d'array gigantesque dans le seeder), avec contrôle de la distribution.

### 4. Brancher `DatabaseSeeder`

Le `DatabaseSeeder` par défaut appelle `DemoSeeder` :

```php
public function run(): void
{
    $this->call([
        DemoSeeder::class,
    ]);
}
```

### 5. Ajouter une target Makefile

```makefile
.PHONY: seed
seed: ## Peupler la base de démo (users + audit logs) + sync Keycloak
	@echo "🌱 Seeding Keycloak users..."
	./infrastructure/scripts/configure-keycloak.sh
	@echo "🌱 Seeding Laravel database..."
	docker compose exec app-php php artisan migrate:fresh --seed --force
	@echo "✅ Démo prête. Logins disponibles : marc, sophie, julien, chloe, admin (mdp: Demo2026!)"
```

Et mettre à jour la target `demo` pour qu'elle appelle `seed` :

```makefile
.PHONY: demo
demo: up seed
	@echo "🚀 Démo prête sur http://localhost:8080"
```

### 6. Tests Pest pour le seeder

Créer `tests/Feature/DemoSeederTest.php` qui vérifie qu'après seed :
- Il y a exactement 5 users
- `marc` existe avec le rôle `admin`
- Il y a entre 18 et 25 audit_logs
- Tous les audit_logs ont un `user_id` valide
- Aucun audit_log n'est antérieur à 8 jours

### 7. Documentation

Mettre à jour 3 fichiers :

**a. `LIVRAISON.md`** — ajouter une section "Comptes de démo" avec le tableau des 5 users et le mot de passe.

**b. `docs/documentations/demo-guide.md`** — ajouter une section "Comptes utilisables pendant la démo" avec :
- Le tableau
- Recommandation : pour la démo principale, se connecter avec `marc` (c'est le persona principal du discours)
- Pour montrer le RBAC : se connecter avec `sophie` (rôle user, ne voit pas les fonctionnalités admin)

**c. `docs/documentations/technique/04-installation.md`** — ajouter à la section "premier démarrage" la commande `make seed` et expliquer son comportement idempotent.

---

## ✅ Critères de fini

1. `make seed` est **idempotent** : on peut le relancer, ça remet à zéro proprement (Laravel : `migrate:fresh --seed`, Keycloak : check-then-create)
2. Après `make seed`, on peut se logger avec `marc` / `Demo2026!` via le flow OIDC complet
3. `GET /api/me` (avec le JWT de marc) retourne ses claims réels
4. `GET /api/audit` retourne ~20 entrées, ordonnées DESC sur `created_at`
5. `make test` passe (incluant `DemoSeederTest`)
6. Aucun mot de passe en dur dans le code committé (le `Demo2026!` est uniquement dans le script et la doc — pas dans `.env`)
7. Les 3 fichiers de doc cités sont à jour

---

## 🚦 Commits attendus

- ✅ `feat(iam): seeding 5 users démo dans keycloak (idempotent)`
- ✅ `feat(backend): factories User + AuditLog + DemoSeeder`
- ✅ `feat(infra): make seed cohérent laravel + keycloak`
- ✅ `test(backend): tests pest pour DemoSeeder`
- ✅ `docs: comptes démo dans livraison + guide démo + doc install`

---

## 🚀 Go

Travaille en autonome, lis le code existant pour respecter les conventions déjà en place dans ce repo, et commit comme indiqué. À la fin, fais un mini rapport :

1. Liste des users seedés (Keycloak + Laravel)
2. Nombre d'audit logs créés
3. Commande exacte que je dois lancer pour tester en condition réelle
4. Confirmation des 7 critères de fini cochés
