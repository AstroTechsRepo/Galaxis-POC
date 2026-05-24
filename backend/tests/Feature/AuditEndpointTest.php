<?php

use App\Models\AuditLog;

/*
 * Galaxis POC — Endpoint /api/audit
 *
 * Couvre :
 *  - sans token : 401
 *  - avec token valide : retourne la liste paginée
 */

beforeEach(function () {
    $this->keys = makeJwtKeyPair();
    $this->kid = 'kid-test-audit';
    publishMockJwks($this->kid, $this->keys['n'], $this->keys['e']);
});

it('rejects /api/audit without auth', function () {
    $this->getJson('/api/audit')->assertStatus(401);
});

it('lists audit logs when authenticated', function () {
    // On insère quelques logs
    AuditLog::create(['event' => 'auth.success', 'payload' => ['test' => 1]]);
    AuditLog::create(['event' => 'auth.rejected', 'payload' => ['reason' => 'expired']]);

    $claims = [
        'iss' => config('oidc.base_public').'/realms/'.config('oidc.realm'),
        'aud' => 'galaxis-portal',
        'sub' => 'audit-test-user',
        'iat' => time() - 5,
        'nbf' => time() - 5,
        'exp' => time() + 300,
        'preferred_username' => 'audit-test',
        'email' => 'audit@galaxis.local',
    ];
    $jwt = signTestJwt($this->keys['private_pem'], $this->kid, $claims);

    $response = $this->getJson('/api/audit', ['Authorization' => "Bearer $jwt"]);

    $response->assertOk()
        ->assertJsonStructure(['count', 'limit', 'logs' => [['id', 'event', 'created_at']]]);
    expect($response->json('count'))->toBeGreaterThanOrEqual(2);
});
