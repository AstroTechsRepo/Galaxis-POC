<?php

use App\Http\Controllers\AuditController;
use App\Http\Controllers\HealthController;
use App\Http\Controllers\MeController;
use Illuminate\Support\Facades\Route;

/*
 * Galaxis POC — Routes API
 * Préfixées automatiquement par /api (cf. bootstrap/app.php).
 */

// Sonde publique — pas d'auth, monitoring infra
Route::get('/health', HealthController::class);

// Endpoints protégés par le middleware JWT
Route::middleware('jwt')->group(function () {
    Route::get('/me', MeController::class);
    Route::get('/audit', AuditController::class);
});
