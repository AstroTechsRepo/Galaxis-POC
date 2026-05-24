<?php

namespace App\Http\Controllers;

use GuzzleHttp\Client;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;

/*
 * Galaxis POC — GET /api/health (public)
 * Sonde infra : DB, Redis, JWKS accessibles ?
 */
class HealthController
{
    public function __invoke(): JsonResponse
    {
        $checks = [
            'db'    => $this->checkDb(),
            'redis' => $this->checkRedis(),
            'jwks'  => $this->checkJwks(),
        ];
        $allOk = ! in_array(false, array_column($checks, 'ok'), true);

        return response()->json([
            'service' => 'galaxis-backend',
            'status' => $allOk ? 'ok' : 'degraded',
            'checks' => $checks,
        ], $allOk ? 200 : 503);
    }

    /** @return array{ok: bool, detail?: string} */
    private function checkDb(): array
    {
        try {
            DB::select('select 1');
            return ['ok' => true];
        } catch (\Throwable $e) {
            return ['ok' => false, 'detail' => $e->getMessage()];
        }
    }

    /** @return array{ok: bool, detail?: string} */
    private function checkRedis(): array
    {
        try {
            $pong = Redis::ping();
            return ['ok' => (bool) $pong];
        } catch (\Throwable $e) {
            return ['ok' => false, 'detail' => $e->getMessage()];
        }
    }

    /** @return array{ok: bool, detail?: string} */
    private function checkJwks(): array
    {
        try {
            $url = config('oidc.base_internal').'/realms/'.config('oidc.realm').'/protocol/openid-connect/certs';
            $client = new Client(['timeout' => 3]);
            $resp = $client->get($url);
            $payload = json_decode((string) $resp->getBody(), true);
            return ['ok' => isset($payload['keys']) && is_array($payload['keys']) && count($payload['keys']) > 0];
        } catch (\Throwable $e) {
            return ['ok' => false, 'detail' => $e->getMessage()];
        }
    }
}
