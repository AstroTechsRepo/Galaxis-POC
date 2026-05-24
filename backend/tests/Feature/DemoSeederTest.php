<?php

use App\Models\AuditLog;
use App\Models\User;
use Database\Seeders\DemoSeeder;

/**
 * Galaxis POC — Tests du DemoSeeder Atelier Marchand.
 *
 * Vérifie qu'après seed :
 *   - exactement 5 users sont créés
 *   - marc existe avec le rôle 'admin'
 *   - sophie/julien/chloe existent avec le rôle 'user'
 *   - admin existe avec le rôle 'admin'
 *   - il y a entre 18 et 25 audit_logs
 *   - tous les audit_logs ont un user_id qui pointe vers un user existant
 *   - aucun audit_log n'est antérieur à 8 jours
 *   - le seeder est idempotent (re-run sans casser ni doubler)
 */

beforeEach(function () {
    // Reset des tables avant chaque test
    AuditLog::query()->delete();
    User::query()->delete();
});

it('crée exactement 5 users après seed', function () {
    $this->seed(DemoSeeder::class);

    expect(User::count())->toBe(5);
});

it('crée les 5 users attendus avec les bons rôles', function () {
    $this->seed(DemoSeeder::class);

    $marc = User::where('username', 'marc')->first();
    expect($marc)->not->toBeNull();
    expect($marc->role)->toBe('admin');
    expect($marc->email)->toBe('marc@atelier-marchand.demo');
    expect($marc->first_name)->toBe('Marc');
    expect($marc->last_name)->toBe('Marchand');

    expect(User::where('username', 'sophie')->value('role'))->toBe('user');
    expect(User::where('username', 'julien')->value('role'))->toBe('user');
    expect(User::where('username', 'chloe')->value('role'))->toBe('user');
    expect(User::where('username', 'admin')->value('role'))->toBe('admin');
});

it('crée entre 18 et 25 audit_logs', function () {
    $this->seed(DemoSeeder::class);

    $count = AuditLog::count();
    expect($count)->toBeGreaterThanOrEqual(18);
    expect($count)->toBeLessThanOrEqual(25);
});

it('garantit que tous les audit_logs ont un user_id valide', function () {
    $this->seed(DemoSeeder::class);

    $userIds = User::pluck('id')->all();
    $orphans = AuditLog::whereNotIn('user_id', $userIds)->orWhereNull('user_id')->count();

    expect($orphans)->toBe(0);
});

it('garantit qu aucun audit_log n est antérieur à 8 jours', function () {
    $this->seed(DemoSeeder::class);

    $oldest = AuditLog::min('created_at');
    $threshold = now()->subDays(8);

    expect($oldest)->not->toBeNull();
    expect(\Carbon\Carbon::parse($oldest)->greaterThanOrEqualTo($threshold))->toBeTrue();
});

it('inclut au moins un login_failure et un access_denied', function () {
    $this->seed(DemoSeeder::class);

    expect(AuditLog::where('event', 'login_failure')->count())->toBeGreaterThanOrEqual(1);
    expect(AuditLog::where('event', 'access_denied')->count())->toBeGreaterThanOrEqual(1);
    expect(AuditLog::where('event', 'login_success')->count())->toBeGreaterThanOrEqual(15);
});

it('est idempotent : re-run sans dupliquer les users ni exploser les logs', function () {
    $this->seed(DemoSeeder::class);
    $firstUserCount = User::count();
    $firstLogCount  = AuditLog::count();

    $this->seed(DemoSeeder::class);

    // Toujours 5 users (upsert sur username)
    expect(User::count())->toBe(5);
    expect(User::count())->toBe($firstUserCount);

    // Les audit_logs sont purgés puis régénérés → même ordre de grandeur
    $secondLogCount = AuditLog::count();
    expect($secondLogCount)->toBeGreaterThanOrEqual(18);
    expect($secondLogCount)->toBeLessThanOrEqual(25);
});

it('audit_logs contiennent les payloads JSON attendus', function () {
    $this->seed(DemoSeeder::class);

    $any = AuditLog::where('event', 'login_success')->first();
    expect($any)->not->toBeNull();
    expect($any->payload)->toBeArray();
    expect($any->payload)->toHaveKey('client_id');
    expect($any->payload['client_id'])->toBe('galaxis-portal');
    expect($any->payload['auth_method'])->toBe('oidc_pkce');
});

it('le access_denied porte la ressource ciblée', function () {
    $this->seed(DemoSeeder::class);

    $denied = AuditLog::where('event', 'access_denied')->first();
    expect($denied)->not->toBeNull();
    expect($denied->payload)->toHaveKey('resource');
    expect($denied->payload['resource'])->toBe('/admin/users');
});
