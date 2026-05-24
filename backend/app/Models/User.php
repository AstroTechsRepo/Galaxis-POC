<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/*
 * Galaxis POC — User
 *
 * Synchronisé depuis les claims du JWT Keycloak au premier login.
 * Pas de mot de passe local (auth déléguée à Keycloak).
 */
class User extends Model
{
    use HasFactory;

    protected $fillable = [
        'keycloak_sub',
        'username',
        'email',
        'first_name',
        'last_name',
        'last_login_at',
    ];

    protected function casts(): array
    {
        return [
            'last_login_at' => 'datetime',
        ];
    }
}
