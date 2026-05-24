<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/*
 * Galaxis POC — GET /api/me
 * Renvoie l'utilisateur en base + les claims du JWT actuels.
 */
class MeController
{
    public function __invoke(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');
        $claims = $request->attributes->get('jwt_claims', []);

        // Liste de claims qu'on remonte au front (pas tout, pour rester clean)
        $publicClaims = array_intersect_key((array) $claims, array_flip([
            'sub', 'preferred_username', 'email', 'email_verified',
            'given_name', 'family_name', 'name',
            'iss', 'aud', 'iat', 'exp', 'azp', 'session_state',
            'realm_access', 'resource_access',
        ]));

        return response()->json([
            'user' => $user?->only(['id', 'username', 'email', 'first_name', 'last_name', 'last_login_at']),
            'claims' => $publicClaims,
        ]);
    }
}
