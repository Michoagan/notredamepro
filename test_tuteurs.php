<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$eleves = App\Models\Eleve::all(['id', 'nom', 'prenom', 'email', 'telephone_parent']);
file_put_contents(__DIR__ . '/eleves_dump.json', json_encode($eleves, JSON_PRETTY_PRINT));
echo "Dumped to eleves_dump.json\n";
