<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'service' => 'galaxis-backend',
        'message' => 'Galaxis API. See /api/health, /api/me, /api/audit',
    ]);
});
