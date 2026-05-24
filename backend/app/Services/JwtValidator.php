<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

/*
 * Galaxis POC — JwtValidator
 *
 * Valide un access_token Keycloak (RS256) :
 *   - signature contre la clé publique (kid) issue de JWKS
 *   - issuer : KC_BASE_PUBLIC/realms/<realm>
 *   - audience : galaxis-portal OU "account"
 *   - exp / nbf / iat avec leeway
 *
 * Renvoie le payload décodé sous forme de tableau associatif.
 */
class JwtValidator
{
    public function __construct(
        private readonly JwksService $jwks,
    ) {}

    /**
     * @return array<string, mixed>
     *
     * @throws \UnexpectedValueException si le token est invalide
     */
    public function validate(string $jwt): array
    {
        // Extrait le kid du header sans valider
        $header = $this->decodeHeader($jwt);

        if (! isset($header['alg']) || ! in_array($header['alg'], config('oidc.allowed_algos', ['RS256']), true)) {
            throw new \UnexpectedValueException('JWT algorithm not allowed');
        }
        if (! isset($header['kid'])) {
            throw new \UnexpectedValueException('JWT header missing kid');
        }

        $key = $this->jwks->getKeyForKid($header['kid']);
        if (! $key instanceof Key) {
            throw new \UnexpectedValueException('Unknown kid (no matching JWKS key)');
        }

        JWT::$leeway = (int) config('oidc.leeway', 30);
        $payload = (array) JWT::decode($jwt, $key);

        // Validation issuer
        $expectedIss = config('oidc.base_public').'/realms/'.config('oidc.realm');
        $iss = (string) ($payload['iss'] ?? '');
        if ($iss !== $expectedIss) {
            // On accepte aussi l'URL interne (utile en test depuis app-php)
            $expectedInternal = config('oidc.base_internal').'/realms/'.config('oidc.realm');
            if ($iss !== $expectedInternal) {
                throw new \UnexpectedValueException('JWT issuer mismatch: '.$iss);
            }
        }

        // Validation audience (peut être string ou array)
        $aud = $payload['aud'] ?? null;
        $audList = is_array($aud) ? $aud : [$aud];
        $accepted = (array) config('oidc.accepted_audiences', []);
        $matches = array_intersect(array_filter($audList), $accepted);
        if (empty($matches)) {
            throw new \UnexpectedValueException('JWT audience not accepted');
        }

        return $payload;
    }

    /**
     * @return array<string, mixed>
     */
    private function decodeHeader(string $jwt): array
    {
        $parts = explode('.', $jwt);
        if (count($parts) !== 3) {
            throw new \UnexpectedValueException('Malformed JWT');
        }
        $raw = $this->base64UrlDecode($parts[0]);
        $arr = json_decode($raw, true);
        if (! is_array($arr)) {
            throw new \UnexpectedValueException('Invalid JWT header');
        }
        return $arr;
    }

    private function base64UrlDecode(string $data): string
    {
        $remainder = strlen($data) % 4;
        if ($remainder) {
            $data .= str_repeat('=', 4 - $remainder);
        }
        return base64_decode(strtr($data, '-_', '+/'), true) ?: '';
    }
}
