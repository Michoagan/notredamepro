<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$parent = App\Models\Tuteur::find(1);
Illuminate\Support\Facades\Auth::login($parent);

$request = Illuminate\Http\Request::create('/api/parent/paiements', 'GET', ['eleve_id' => 1]);
$controller = $app->make(App\Http\Controllers\PaiementController::class);
$response = $controller->index($request);

echo $response->getContent();
