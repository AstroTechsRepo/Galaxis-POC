<?php

/*
 * Galaxis POC — Pest bootstrap.
 *
 * Tous les tests Feature utilisent RefreshDatabase pour repartir
 * d'une base SQLite vierge en mémoire (cf. phpunit.xml).
 */

use Illuminate\Foundation\Testing\RefreshDatabase;

uses(Tests\TestCase::class, RefreshDatabase::class)->in('Feature');
uses(Tests\TestCase::class)->in('Unit');

/*
 * Helpers globaux pour générer des JWT signés (RS256) avec une clé
 * de test, et exposer un JWKS « mock » dans le cache.
 */
function makeJwtKeyPair(): array
{
    $res = openssl_pkey_new([
        'private_key_bits' => 2048,
        'private_key_type' => OPENSSL_KEYTYPE_RSA,
    ]);
    openssl_pkey_export($res, $privatePem);
    $details = openssl_pkey_get_details($res);
    return [
        'private_pem' => $privatePem,
        'public_pem'  => $details['key'],
        'n' => Firebase\JWT\JWT::urlsafeB64Encode($details['rsa']['n']),
        'e' => Firebase\JWT\JWT::urlsafeB64Encode($details['rsa']['e']),
    ];
}

function publishMockJwks(string $kid, string $n, string $e): void
{
    Illuminate\Support\Facades\Cache::put('galaxis:jwks:keys', [
        'keys' => [[
            'kid' => $kid,
            'kty' => 'RSA',
            'alg' => 'RS256',
            'use' => 'sig',
            'n'   => $n,
            'e'   => $e,
        ]],
    ], 300);
}

function signTestJwt(string $privatePem, string $kid, array $claims): string
{
    return Firebase\JWT\JWT::encode(
        payload: $claims,
        key: $privatePem,
        alg: 'RS256',
        keyId: $kid,
    );
}
