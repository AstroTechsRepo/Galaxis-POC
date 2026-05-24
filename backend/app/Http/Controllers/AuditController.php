<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/*
 * Galaxis POC — GET /api/audit
 * Liste paginée des derniers événements d'authentification.
 */
class AuditController
{
    public function __invoke(Request $request): JsonResponse
    {
        $limit = (int) min(max($request->integer('limit', 50), 1), 200);

        $logs = AuditLog::query()
            ->orderByDesc('created_at')
            ->limit($limit)
            ->get(['id', 'user_id', 'event', 'ip', 'user_agent', 'payload', 'created_at']);

        return response()->json([
            'count' => $logs->count(),
            'limit' => $limit,
            'logs'  => $logs,
        ]);
    }
}
