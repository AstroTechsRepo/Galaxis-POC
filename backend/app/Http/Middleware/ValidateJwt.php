<?php

namespace App\Http\Middleware;

use App\Models\AuditLog;
use App\Models\User;
use App\Services\JwtValidator;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

/*
 * Galaxis POC — Middleware JWT
 *
 * - Extrait le Bearer token de l'Authorization header
 * - Valide la signature, l'issuer, l'audience, exp/nbf via JwtValidator
 * - Sync l'utilisateur en base au premier login (à partir des claims)
 * - Log l'événement dans audit_logs
 * - Injecte les claims dans Request::attributes pour les contrôleurs
 */
class ValidateJwt
{
    public function __construct(
        private readonly JwtValidator $validator,
    ) {}

    public function handle(Request $request, Closure $next): Response
    {
        $auth = (string) $request->header('Authorization', '');
        if (! str_starts_with($auth, 'Bearer ')) {
            return $this->reject($request, 'missing_bearer', 'Missing or malformed Authorization header');
        }
        $token = substr($auth, 7);
        if ($token === '' || str_word_count($token) === 0) {
            return $this->reject($request, 'empty_token', 'Empty Bearer token');
        }

        try {
            $claims = $this->validator->validate($token);
        } catch (\Throwable $e) {
            Log::warning('JWT validation failed', ['error' => $e->getMessage()]);
            return $this->reject($request, 'invalid_token', $e->getMessage());
        }

        $user = $this->syncUser($claims);

        $request->attributes->set('jwt_claims', $claims);
        $request->attributes->set('auth_user', $user);

        AuditLog::record(
            userId: $user?->id,
            event: 'auth.success',
            payload: [
                'sub'   => $claims['sub']   ?? null,
                'email' => $claims['email'] ?? null,
                'route' => $request->path(),
            ],
            request: $request,
        );

        return $next($request);
    }

    /**
     * @param  array<string, mixed>  $claims
     */
    private function syncUser(array $claims): ?User
    {
        $sub = $claims['sub'] ?? null;
        if (! is_string($sub) || $sub === '') {
            return null;
        }
        return User::updateOrCreate(
            ['keycloak_sub' => $sub],
            [
                'username'   => (string) ($claims['preferred_username'] ?? $sub),
                'email'      => (string) ($claims['email'] ?? ''),
                'first_name' => (string) ($claims['given_name'] ?? ''),
                'last_name'  => (string) ($claims['family_name'] ?? ''),
                'last_login_at' => now(),
            ],
        );
    }

    private function reject(Request $request, string $code, string $message): Response
    {
        AuditLog::record(null, 'auth.rejected', ['code' => $code, 'message' => $message], $request);
        return response()->json([
            'error' => 'unauthorized',
            'code' => $code,
            'message' => $message,
        ], 401, ['WWW-Authenticate' => 'Bearer error="invalid_token"']);
    }
}
