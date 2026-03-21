<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$res = \DB::table('notes')
    ->select('classe_id', 'matiere_id', 'trimestre')
    ->distinct()
    ->get();

file_put_contents('test_notes_distinct.json', json_encode($res, JSON_PRETTY_PRINT));
echo "Done";
