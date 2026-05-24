<?php

/*
 * Galaxis POC — Configuration OIDC / Keycloak
 *
 * Le backend Laravel valide les JWT (access_token) émis par Keycloak,
 * signés en RS256. Les clés publiques sont récupérées via JWKS
 * et cachées dans Redis pour limiter les allers-retours.
 */
return [
    'realm' => env('KC_REALM', 'galaxis'),

    // URL interne (réseau Docker) pour récupérer les JWKS sans sortir
    'base_internal' => rtrim(env('KC_BASE_INTERNAL', 'http://keycloak:8080/iam'), '/'),

    // URL publique (vue depuis le navigateur) — sert à valider l'issuer
    'base_public' => rtrim(env('KC_BASE_PUBLIC', 'http://localhost:8080/iam'), '/'),

    'client_id' => env('KC_CLIENT_ID', 'galaxis-portal'),

    // TTL du cache JWKS dans Redis (en secondes). 300 = 5 minutes.
    'jwks_cache_ttl' => (int) env('JWKS_CACHE_TTL', 300),

    // Tolérance d'horloge pour exp/nbf/iat (secondes).
    'leeway' => (int) env('JWT_LEEWAY', 30),

    // Audiences acceptées (le client OIDC + 'account' que Keycloak ajoute par défaut)
    'accepted_audiences' => array_filter([
        env('KC_CLIENT_ID', 'galaxis-portal'),
        'account',
    ]),

    // Algorithmes autorisés (RS256 uniquement en POC)
    'allowed_algos' => ['RS256'],
];
