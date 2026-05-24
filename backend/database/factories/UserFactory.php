<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * Galaxis POC — UserFactory.
 *
 * Génère un user synthétique. Les comptes de démo Atelier Marchand
 * sont créés explicitement (cf. DemoSeeder), pas via cette factory.
 * Celle-ci sert pour les tests qui ont besoin de users génériques.
 *
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    protected $model = User::class;

    public function definition(): array
    {
        $first = $this->faker->firstName();
        $last  = $this->faker->lastName();
        $createdAt = $this->faker->dateTimeBetween('-90 days', '-30 days');

        return [
            // keycloak_sub : UUID v4 — sera réconcilié au premier login OIDC réel
            'keycloak_sub'  => (string) Str::uuid(),
            'username'      => $this->faker->unique()->userName(),
            'email'         => $this->faker->unique()->safeEmail(),
            'first_name'    => $first,
            'last_name'     => $last,
            'role'          => $this->faker->randomElement(['user', 'user', 'user', 'admin']),
            'last_login_at' => $this->faker->optional(0.7)->dateTimeBetween('-7 days', 'now'),
            'created_at'    => $createdAt,
            'updated_at'    => $createdAt,
        ];
    }

    public function admin(): static
    {
        return $this->state(fn () => ['role' => 'admin']);
    }

    public function user(): static
    {
        return $this->state(fn () => ['role' => 'user']);
    }
}
