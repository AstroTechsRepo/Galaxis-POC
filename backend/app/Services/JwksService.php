<?php

namespace App\Services;

use Firebase\JWT\JWK;
use Firebase\JWT\Key;
use GuzzleHttp\Client;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

/*
 * Galaxis POC — JwksService
 *
 * Récupère les clés publiques de Keycloak (JWKS) et les cache dans Redis.
 * Le cache est invalidé soit par TTL (5 min par défaut) soit par miss
 * sur un `kid` inconnu (clé rotée côté Keycloak).
 */
class JwksService
{
    private const CACHE_KEY = 'galaxis:jwks:keys';

    public function __construct(
        private readonly Client $http = new Client(['timeout' => 5]),
    ) {}

    /**
     * Retourne le tableau de Keys indexé par kid, prêt à passer à JWT::decode().
     *
     * @param  bool  $forceRefresh  ignore le cache (utilisé sur miss de kid)
     * @return array<string, Key>
     */
    public function getKeys(bool $forceRefresh = false): array
    {
        $ttl = (int) config('oidc.jwks_cache_ttl', 300);

        if ($forceRefresh) {
            Cache::forget(self::CACHE_KEY);
        }

        $jwks = Cache::remember(self::CACHE_KEY, $ttl, function () {
            return $this->fetchJwks();
        });

        return JWK::parseKeySet($jwks, 'RS256');
    }

    /**
     * Si on rencontre un kid inconnu, on recharge le JWKS depuis Keycloak.
     */
    public function getKeyForKid(string $kid): ?Key
    {
        $keys = $this->getKeys(false);
        if (isset($keys[$kid])) {
            return $keys[$kid];
        }
        // kid inconnu : on retente avec un refresh forcé
        $keys = $this->getKeys(true);
        return $keys[$kid] ?? null;
    }

    /**
     * @return array{keys: array<int, array<string, mixed>>}
     */
    private function fetchJwks(): array
    {
        $url = config('oidc.base_internal').'/realms/'.config('oidc.realm').'/protocol/openid-connect/certs';
        Log::debug('JwksService: fetching JWKS', ['url' => $url]);

        $response = $this->http->get($url);
        $payload = json_decode((string) $response->getBody(), true, 512, JSON_THROW_ON_ERROR);

        if (! is_array($payload) || ! isset($payload['keys']) || ! is_array($payload['keys'])) {
            throw new \RuntimeException('JWKS endpoint returned an invalid payload');
        }
        return $payload;
    }
}
