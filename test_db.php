<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

DB::connection()->enableQueryLog();

$start = microtime(true);
$ctrl = new App\Http\Controllers\ProfesseurController();
$ctrl->index();
$end = microtime(true);

$queries = DB::getQueryLog();
file_put_contents('query_log.json', json_encode([
    'total_queries' => count($queries),
    'queries' => reset($queries),
    'all_queries' => $queries,
    'execution_time' => $end - $start
], JSON_PRETTY_PRINT));
