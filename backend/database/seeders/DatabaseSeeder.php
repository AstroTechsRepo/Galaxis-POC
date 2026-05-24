<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /*
     * Pas de seed obligatoire en POC : les utilisateurs sont auto-créés
     * au premier login OIDC depuis les claims Keycloak.
     */
    public function run(): void
    {
        //
    }
}
