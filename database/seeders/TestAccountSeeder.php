<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Direction;
use App\Models\Professeur;
use App\Models\Tuteur;
use App\Models\Eleve;
use App\Models\Classe;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class TestAccountSeeder extends Seeder
{
    public function run()
    {
        Direction::updateOrCreate(
            ['email' => 'directeur@test.com'],
            [
                'last_name' => 'Test',
                'first_name' => 'Directeur',
                'password' => Hash::make('password123'),
                'role' => 'directeur',
                'phone' => '11111111'
            ]
        );

        Professeur::updateOrCreate(
            ['email' => 'prof@test.com'],
            [
                'last_name' => 'Prof',
                'first_name' => 'Test',
                'phone' => '12345678',
                'gender' => 'M',
                'birth_date' => '1980-01-01',
                'matiere' => 'Mathematiques',
                'personal_code' => Hash::make('PROF123'),
            ]
        );

        $parent = Tuteur::updateOrCreate(
            ['email' => 'parent@test.com'],
            [
                'nom' => 'Parent',
                'prenom' => 'Test',
                'telephone' => '87654321',
                'password' => Hash::make('password123')
            ]
        );

        $eleve = Eleve::first();

        if ($eleve && !$parent->eleves()->where('eleves.id', $eleve->id)->exists()) {
            $parent->eleves()->attach($eleve->id, ['lien_tuteur' => 'Pere']);
        }

        echo "Accounts created successfully!\n";
    }
}
