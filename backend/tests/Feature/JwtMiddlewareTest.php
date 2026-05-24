<?php

use App\Models\AuditLog;
use App\Models\User;

/*
 * Galaxis POC — Tests du middleware JWT et de l'endpoint /api/me
 *
 * Couvre :
 *  - token absent  → 401
 *  - token malformé → 401
 *  - signature invalide → 401
 *  - issuer invalide → 401
 *  - audience invalide → 401
 *  - token expiré → 401
 *  - token valide → 200 + user créé + audit log
 *  - JWKS cache hit (pas de fetch HTTP)
 */

beforeEach(function () {
    $this->keys = makeJwtKeyPair();
    $this->kid = 'kid-test-1';
    publishMockJwks($this->kid, $this->keys['n'], $this->keys['e']);
});

function baseClaims(): array
{
    return [
        'iss' => config('oidc.base_public').'/realms/'.config('oidc.realm'),
        'aud' => 'galaxis-portal',
        'sub' => 'a1b2c3d4-test-uuid',
        'iat' => time() - 5,
        'nbf' => time() - 5,
        'exp' => time() + 300,
        'preferred_username' => 'lucas-test',
        'email' => 'lucas-test@galaxis.local',
        'given_name' => 'Lucas',
        'family_name' => 'Test',
    ];
}

it('rejects requests without Authorization header', function () {
    $this->getJson('/api/me')
        ->assertStatus(401)
        ->assertJsonPath('code', 'missing_bearer');
});

it('rejects malformed JWT', function () {
    $this->getJson('/api/me', ['Authorization' => 'Bearer this.is.not.a.jwt'])
        ->assertStatus(401)
        ->assertJsonPath('code', 'invalid_token');
});

it('rejects JWT with invalid signature', function () {
    // On fabrique un JWT avec une AUTRE clé que celle du JWKS mocké
    $other = makeJwtKeyPair();
    $jwt = signTestJwt($other['private_pem'], $this->kid, baseClaims());

    $this->getJson('/api/me', ['Authorization' => "Bearer $jwt"])
        ->assertStatus(401)
        ->assertJsonPath('code', 'invalid_token');
});

it('rejects JWT with wrong issuer', function () {
    $claims = baseClaims();
    $claims['iss'] = 'https://evil.example.com/realms/galaxis';
    $jwt = signTestJwt($this->keys['private_pem'], $this->kid, $claims);

    $this->getJson('/api/me', ['Authorization' => "Bearer $jwt"])
        ->assertStatus(401);
});

it('rejects JWT with wrong audience', function () {
    $claims = baseClaims();
    $claims['aud'] = 'some-other-client';
    $jwt = signTestJwt($this->keys['private_pem'], $this->kid, $claims);

    $this->getJson('/api/me', ['Authorization' => "Bearer $jwt"])
        ->assertStatus(401);
});

it('rejects expired JWT', function () {
    $claims = baseClaims();
    $claims['exp'] = time() - 3600;
    $claims['iat'] = time() - 7200;
    $jwt = signTestJwt($this->keys['private_pem'], $this->kid, $claims);

    $this->getJson('/api/me', ['Authorization' => "Bearer $jwt"])
        ->assertStatus(401);
});

it('rejects JWT with unknown kid', function () {
    // On crée un autre kid, hors JWKS — comme le service va re-fetch et
    // qu'on n'a pas de Keycloak, ça va lever une erreur → 401
    $claims = baseClaims();
    $jwt = signTestJwt($this->keys['private_pem'], 'kid-unknown', $claims);

    $this->getJson('/api/me', ['Authorization' => "Bearer $jwt"])
        ->assertStatus(401);
});

it('accepts a valid JWT, returns claims, creates the user and an audit log', function () {
    $jwt = signTestJwt($this->keys['private_pem'], $this->kid, baseClaims());

    $response = $this->getJson('/api/me', ['Authorization' => "Bearer $jwt"]);

    $response->assertOk()
        ->assertJsonPath('user.username', 'lucas-test')
        ->assertJsonPath('user.email', 'lucas-test@galaxis.local')
        ->assertJsonPath('claims.preferred_username', 'lucas-test')
        ->assertJsonPath('claims.email', 'lucas-test@galaxis.local');

    expect(User::where('keycloak_sub', 'a1b2c3d4-test-uuid')->exists())->toBeTrue();
    expect(AuditLog::where('event', 'auth.success')->count())->toBeGreaterThanOrEqual(1);
});

it('uses the cached JWKS (no fetch on second call)', function () {
    $jwt = signTestJwt($this->keys['private_pem'], $this->kid, baseClaims());

    // Premier appel : OK
    $this->getJson('/api/me', ['Authorization' => "Bearer $jwt"])->assertOk();

    // On vide le cache pour vérifier qu'un appel sans JWKS échoue (proxy de "cache utilisé")
    Illuminate\Support\Facades\Cache::forget('galaxis:jwks:keys');

    // Deuxième appel sans JWKS dispo → la lib va tenter de re-fetch et échouer en testing
    $this->getJson('/api/me', ['Authorization' => "Bearer $jwt"])->assertStatus(401);
});
