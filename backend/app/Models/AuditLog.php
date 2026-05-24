<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;

/*
 * Galaxis POC — AuditLog
 *
 * Journal applicatif des événements d'authentification.
 * Volontairement simple et centralisé pour le POC.
 */
class AuditLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'event',
        'ip',
        'user_agent',
        'payload',
    ];

    protected function casts(): array
    {
        return [
            'payload' => 'array',
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    public static function record(?int $userId, string $event, array $payload, ?Request $request = null): self
    {
        return self::create([
            'user_id'    => $userId,
            'event'      => $event,
            'ip'         => $request?->ip(),
            'user_agent' => $request ? substr((string) $request->userAgent(), 0, 255) : null,
            'payload'    => $payload,
        ]);
    }
}
