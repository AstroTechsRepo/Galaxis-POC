<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Galaxis POC — seeder racine.
     *
     * En prod, les users sont auto-créés au premier login OIDC depuis
     * les claims Keycloak. En démo / dev / test, on délègue à DemoSeeder
     * pour avoir un jeu de données cohérent avec le scénario Atelier
     * Marchand (cf. configure-keycloak.sh + persona slide 05).
     */
    public function run(): void
    {
        $this->call([
            DemoSeeder::class,
        ]);
    }
}
