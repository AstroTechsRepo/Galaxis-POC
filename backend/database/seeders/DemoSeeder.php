<?php

namespace Database\Seeders;

use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

/**
 * Galaxis POC — DemoSeeder.
 *
 * Crée le jeu de données démo « Atelier Marchand » :
 *   - 5 users explicites (alignés 1-pour-1 avec ceux créés par
 *     `configure-keycloak.sh`)
 *   - ~20 audit_logs distribués sur les 7 derniers jours, biaisés
 *     vers les jours ouvrés et heures de bureau
 *
 * Idempotent au sens « migrate:fresh --seed » : la migration vide
 * les tables avant exécution. Si lancé sans migrate:fresh, le
 * seeder fait un upsert sur (username) pour éviter les doublons,
 * et il purge les audit_logs liés aux 5 users avant d'en générer
 * de nouveaux.
 */
class DemoSeeder extends Seeder
{
    /**
     * Les 5 comptes de démo Atelier Marchand (TPE menuiserie 5 personnes).
     * Doit rester aligné avec `infrastructure/scripts/configure-keycloak.sh`.
     */
    private const DEMO_USERS = [
        ['username' => 'marc',   'email' => 'marc@atelier-marchand.demo',   'first_name' => 'Marc',   'last_name' => 'Marchand', 'role' => 'admin'],
        ['username' => 'sophie', 'email' => 'sophie@atelier-marchand.demo', 'first_name' => 'Sophie', 'last_name' => 'Lemoine',  'role' => 'user'],
        ['username' => 'julien', 'email' => 'julien@atelier-marchand.demo', 'first_name' => 'Julien', 'last_name' => 'Petit',    'role' => 'user'],
        ['username' => 'chloe',  'email' => 'chloe@atelier-marchand.demo',  'first_name' => 'Chloé',  'last_name' => 'Dubois',   'role' => 'user'],
        ['username' => 'admin',  'email' => 'admin@galaxis.demo',           'first_name' => 'Admin',  'last_name' => 'Galaxis',  'role' => 'admin'],
    ];

    /**
     * Distribution cible des connexions (login_success) par user sur 7 jours.
     * Total = 21 + 1 login_failure + 1 access_denied = 23 audit logs cibles
     * (entre 18 et 25 — borne attendue par DemoSeederTest).
     */
    private const LOGIN_DISTRIBUTION = [
        'marc'   => 6,  // gérant, ~tous les jours ouvrés
        'sophie' => 3,  // comptable mi-temps
        'julien' => 4,  // apprenti, présent souvent
        'chloe'  => 3,  // commerciale terrain
        'admin'  => 2,  // compte technique, sporadique
    ];

    public function run(): void
    {
        $this->command?->info('🌱 DemoSeeder — Atelier Marchand');

        // ---- 1) Upsert des 5 users (idempotent même hors migrate:fresh)
        $users = [];
        foreach (self::DEMO_USERS as $data) {
            $users[$data['username']] = User::updateOrCreate(
                ['username' => $data['username']],
                [
                    // keycloak_sub : UUID v4 stable (sera réécrit au 1er vrai login OIDC)
                    'keycloak_sub' => 'demo-'.Str::uuid()->toString(),
                    'email'        => $data['email'],
                    'first_name'   => $data['first_name'],
                    'last_name'    => $data['last_name'],
                    'role'         => $data['role'],
                    'last_login_at'=> Carbon::now()->subHours(rand(1, 48)),
                    'created_at'   => Carbon::now()->subDays(rand(30, 90)),
                ],
            );
        }
        $this->command?->info(sprintf('  → %d users seedés', count($users)));

        // ---- 2) Purge des audit_logs des 5 users (idempotence sans migrate:fresh)
        AuditLog::whereIn('user_id', collect($users)->pluck('id')->all())->delete();

        // ---- 3) Génère ~21 login_success répartis sur 7 jours ouvrés
        $created = 0;
        foreach (self::LOGIN_DISTRIBUTION as $username => $count) {
            $user = $users[$username];
            for ($i = 0; $i < $count; $i++) {
                AuditLog::factory()
                    ->loginSuccess()
                    ->forUser($user)
                    ->atDate($this->randomBusinessDateTime())
                    ->create();
                $created++;
            }
        }

        // Sophie ferme parfois sa session manuellement (1 logout)
        AuditLog::factory()
            ->logout()
            ->forUser($users['sophie'])
            ->atDate($this->randomBusinessDateTime())
            ->create();
        $created++;

        // ---- 4) 1 login_failure (Julien s'est trompé de mot de passe)
        AuditLog::factory()
            ->loginFailure('invalid_credentials')
            ->forUser($users['julien'])
            ->atDate($this->randomBusinessDateTime())
            ->create();
        $created++;

        // ---- 5) 1 access_denied (Chloé a tenté d'accéder à la page admin)
        AuditLog::factory()
            ->accessDenied('/admin/users')
            ->forUser($users['chloe'])
            ->atDate($this->randomBusinessDateTime())
            ->create();
        $created++;

        $this->command?->info(sprintf('  → %d audit_logs seedés (fenêtre 7 jours, biais bureau)', $created));
        $this->command?->info('✅ Démo Atelier Marchand prête.');
    }

    /**
     * Date aléatoire dans les 7 derniers jours, biaisée jours ouvrés + 9h-19h.
     */
    private function randomBusinessDateTime(): Carbon
    {
        // jusqu'à 8 essais pour tomber en jour ouvré + heure de bureau ; sinon on garde le dernier
        for ($i = 0; $i < 8; $i++) {
            $when = Carbon::now()
                ->subDays(rand(0, 6))
                ->setTime(rand(8, 20), rand(0, 59), rand(0, 59));
            if ($when->dayOfWeekIso <= 5 && $when->hour >= 9 && $when->hour <= 19) {
                return $when;
            }
        }
        return $when;
    }
}
