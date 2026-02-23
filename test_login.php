<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$request = Illuminate\Http\Request::create('/api/parent/login', 'POST', [
    'email' => 'michoagansegbegnon@gmail.com',  
    'password' => 'Password@123',
]);

$controller = $app->make(App\Http\Controllers\TuteurController::class);

$parent = App\Models\Tuteur::where('email', 'michoagansegbegnon@gmail.com')->first();
echo "Found Parent: " . ($parent ? 'Yes (ID: '.$parent->id.')' : 'No') . "\n";
if ($parent) {
    echo "Password Match: " . (Illuminate\Support\Facades\Hash::check('Password@123', $parent->password) ? 'Yes' : 'No') . "\n";
}

$response = $controller->login($request);

echo "Status: " . $response->getStatusCode() . "\n";
echo "Body: " . $response->getContent() . "\n";
