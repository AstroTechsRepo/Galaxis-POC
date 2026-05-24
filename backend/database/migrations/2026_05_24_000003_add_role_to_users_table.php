<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /*
     * Galaxis POC — Ajout du rôle applicatif sur users.
     *
     * Le rôle est synchronisé depuis le claim Keycloak `realm_access.roles`
     * au premier login (cf. middleware ValidateJwt + DemoSeeder pour la démo).
     * Valeurs attendues : 'admin' ou 'user'. NULL accepté jusqu'au premier
     * login pour les comptes hérités.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('role', 32)->nullable()->index()->after('last_name');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['role']);
            $table->dropColumn('role');
        });
    }
};
