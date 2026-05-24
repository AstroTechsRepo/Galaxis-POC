<?php

return [
    'realm' => env('KC_REALM', 'galaxis'),

    'base_internal' => rtrim(env('KC_BASE_INTERNAL', 'http://keycloak:8080'), '/'),
    'base_public' => rtrim(env('KC_BASE_PUBLIC', 'http://localhost:8080'), '/'),

    'client_id' => env('KC_CLIENT_ID', 'galaxis-portal'),

    'jwks_cache_ttl' => (int) env('JWKS_CACHE_TTL', 300),
    'leeway' => (int) env('JWT_LEEWAY', 30),
    'accepted_audiences' => array_filter([
        env('KC_CLIENT_ID', 'galaxis-portal'),
        'account',
    ]),

    'allowed_algos' => ['RS256'],
];
