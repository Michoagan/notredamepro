<?php
use App\Models\Direction;
use App\Models\Professeur;
use App\Models\Tuteur;
use Illuminate\Support\Facades\Hash;

$direction = Direction::create([
    'nom' => 'Test',
    'prenom' => 'Directeur',
    'email' => 'directeur@test.com',
    'password' => Hash::make('password123'),
    'role' => 'directeur',
    'telephone' => '11111111'
]);

$prof = Professeur::create([
    'nom' => 'Prof',
    'prenom' => 'Test',
    'email' => 'prof@test.com',
    'telephone' => '12345678',
    'sexe' => 'M',
    'code' => 'PROF123',
    'password' => Hash::make('password123'),
    'date_naissance' => '1980-01-01',
    'lieu_naissance' => 'Paris',
    'adresse' => 'Paris'
]);

$parent = Tuteur::create([
    'nom' => 'Parent',
    'prenom' => 'Test',
    'telephone' => '87654321',
    'email' => 'parent@test.com',
    'profession' => 'Ingenieur',
    'password' => Hash::make('password123')
]);

echo "Accounts created successfully.\n";
