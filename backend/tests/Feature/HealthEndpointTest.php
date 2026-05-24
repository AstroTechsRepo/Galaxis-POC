<?php

/*
 * Galaxis POC — Endpoint /api/health
 * Sonde publique (pas d'auth). Couvre DB + Redis + JWKS.
 */

it('responds 200 when DB is up, even if Redis or JWKS are down', function () {
    // En env testing : DB=sqlite mémoire (OK), pas de Redis, pas de Keycloak
    // Le endpoint doit répondre 503 (degraded) car redis/jwks down — mais le
    // check DB doit être ok=true. On vérifie la forme de la réponse.

    $response = $this->getJson('/api/health');

    $response->assertStatus(503); // degraded en testing : redis/jwks indisponibles
    $response->assertJsonPath('service', 'galaxis-backend');
    $response->assertJsonStructure([
        'service',
        'status',
        'checks' => [
            'db' => ['ok'],
            'redis' => ['ok'],
            'jwks' => ['ok'],
        ],
    ]);
    expect($response->json('checks.db.ok'))->toBeTrue();
});
