<?php

use App\Services\JwksService;
use Firebase\JWT\Key;

/*
 * Galaxis POC — JwksService : cache hit / miss
 */

it('reads JWKS from cache without HTTP call', function () {
    $keys = makeJwtKeyPair();
    publishMockJwks('kid-cache-1', $keys['n'], $keys['e']);

    $svc = app(JwksService::class);
    $set = $svc->getKeys();

    expect($set)->toBeArray();
    expect($set)->toHaveKey('kid-cache-1');
    expect($set['kid-cache-1'])->toBeInstanceOf(Key::class);
});

it('returns the matching key for a known kid', function () {
    $keys = makeJwtKeyPair();
    publishMockJwks('kid-cache-2', $keys['n'], $keys['e']);

    $svc = app(JwksService::class);
    expect($svc->getKeyForKid('kid-cache-2'))->toBeInstanceOf(Key::class);
});
