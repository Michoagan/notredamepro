<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$request = Illuminate\Http\Request::create('/api/parent/register', 'POST', [
    'nom' => 'Test',
    'prenom' => 'Parent',
    'email' => 'michoagansegbegnon@gmail.com',  // The correct email from eleves table
    'telephone' => '0156722257',
    'password' => 'Password@123',
    'password_confirmation' => 'Password@123',
]);

$controller = $app->make(App\Http\Controllers\TuteurController::class);
$response = $controller->register($request);

echo "Status: " . $response->getStatusCode() . "\n";
echo "Body: " . $response->getContent() . "\n";
