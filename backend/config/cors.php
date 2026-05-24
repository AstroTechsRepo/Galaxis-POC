<?php

/*
 * Galaxis POC v1.1 — CORS strict.
 * Seul APP_URL (le portail React) est autorisé.
 * v1.1 : le portail est sur https://localhost:9443 (app-caddy HTTPS).
 * L'API /api/* est servie par le MÊME origin (app-caddy route
 * handle_path /api/* → php_fastcgi app-php:9000), donc dans le cas
 * nominal il n'y a même pas de CORS preflight (same-origin).
 * On configure quand même pour les cas edge (développement local, tests).
 */
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    'allowed_origins' => [
        env('APP_URL', 'https://localhost:9443'),
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['Authorization', 'Content-Type', 'X-Requested-With'],
    'exposed_headers' => [],
    'max_age' => 600,
    'supports_credentials' => false,
];
