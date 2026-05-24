<?php

namespace Database\Factories;

use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * Galaxis POC — AuditLogFactory.
 *
 * Génère un événement d'audit cohérent avec le schéma de la table
 * `audit_logs`. Note : la table utilise les colonnes `ip` et `payload`
 * (renommables `ip_address`/`context` au niveau applicatif si besoin) ;
 * la factory respecte les noms réels de colonnes pour ne pas casser
 * le middleware ValidateJwt existant.
 *
 * @extends Factory<AuditLog>
 */
class AuditLogFactory extends Factory
{
    protected $model = AuditLog::class;

    /** Browsers réalistes 2026 — distribution représentative d'une TPE */
    private const USER_AGENTS = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.15',
        'Mozilla/5.0 (X11; Linux x86_64; rv:126.0) Gecko/20100101 Firefox/126.0',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1',
    ];

    public function definition(): array
    {
        $createdAt = $this->businessHourTimestamp();

        return [
            'user_id'    => User::factory(),
            'event'      => $this->faker->randomElement([
                'login_success', 'login_success', 'login_success', 'login_success',
                'token_refresh', 'token_refresh',
                'logout',
                'login_failure',
                'access_denied',
            ]),
            'ip'         => $this->faker->ipv4(),
            'user_agent' => $this->faker->randomElement(self::USER_AGENTS),
            'payload'    => [
                'client_id'   => 'galaxis-portal',
                'auth_method' => 'oidc_pkce',
            ],
            'created_at' => $createdAt,
            'updated_at' => $createdAt,
        ];
    }

    // ============================================================
    // States par type d'événement (utile dans DemoSeeder)
    // ============================================================

    public function loginSuccess(): static
    {
        return $this->state(fn () => ['event' => 'login_success']);
    }

    public function loginFailure(?string $reason = null): static
    {
        return $this->state(fn () => [
            'event'   => 'login_failure',
            'payload' => [
                'client_id'   => 'galaxis-portal',
                'auth_method' => 'oidc_pkce',
                'reason'      => $reason ?? 'invalid_credentials',
            ],
        ]);
    }

    public function logout(): static
    {
        return $this->state(fn () => ['event' => 'logout']);
    }

    public function tokenRefresh(): static
    {
        return $this->state(fn () => ['event' => 'token_refresh']);
    }

    public function accessDenied(?string $resource = null): static
    {
        return $this->state(fn () => [
            'event'   => 'access_denied',
            'payload' => [
                'client_id'   => 'galaxis-portal',
                'auth_method' => 'oidc_pkce',
                'resource'    => $resource ?? '/admin/users',
                'reason'      => 'insufficient_role',
            ],
        ]);
    }

    public function forUser(User $user): static
    {
        return $this->state(fn () => ['user_id' => $user->id]);
    }

    public function atDate(\DateTimeInterface $when): static
    {
        return $this->state(fn () => [
            'created_at' => $when,
            'updated_at' => $when,
        ]);
    }

    // ============================================================
    // Helpers internes
    // ============================================================

    /**
     * Génère un timestamp dans les 7 derniers jours, biaisé vers
     * les jours ouvrés (lun-ven) et les heures de bureau (9h-19h).
     * Quelques événements en dehors restent acceptés (réalisme).
     */
    private function businessHourTimestamp(): \DateTimeImmutable
    {
        // 7 tentatives : on accepte le premier timestamp qui tombe en heures de bureau ;
        // sinon on garde le dernier (laisse passer un peu de bruit hors-bureau, 1/8e environ).
        $tries = 0;
        do {
            $ts = $this->faker->dateTimeBetween('-7 days', 'now');
            $dow = (int) $ts->format('N');   // 1=Mon ... 7=Sun
            $hour = (int) $ts->format('G');
            $tries++;
            if ($dow <= 5 && $hour >= 9 && $hour <= 19) {
                break;
            }
        } while ($tries < 7);

        return \DateTimeImmutable::createFromMutable($ts);
    }
}
