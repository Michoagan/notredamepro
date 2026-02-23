<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Vérifier si l'admin existe déjà
        if (!User::where('username', 'admin')->exists()) {
            User::create([
                'name' => 'Admin Principal',
                'username' => 'admin',
                'email' => 'admin@notredamepro.com',
                'password' => Hash::make('adminndtg'),
            ]);
            $this->command->info('Admin user created successfully.');
        } else {
            $this->command->info('Admin user already exists.');
        }
    }
}
