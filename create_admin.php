<?php

use App\Models\Direction;
use Illuminate\Support\Facades\Hash;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

try {
    $existing = Direction::where('email', 'admin@notredame.com')->first();
    if ($existing) {
        echo "User already exists. ID: " . $existing->id . "\n";
        exit(0);
    }

    $user = Direction::create([
        'first_name' => 'Admin',
        'last_name' => 'Principal',
        'email' => 'admin@notredame.com',
        'password' => Hash::make('password123'),
        'role' => 'directeur',
        'is_active' => true,
        'approved_by_admin' => true,
        'approved_at' => now(),
        'phone' => '00000000'
    ]);
    
    echo "User created successfully. ID: " . $user->id . "\n";
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
