<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\Direction;
use App\Models\Professeur;
use Illuminate\Support\Facades\Hash;

class ApiSanctumTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test Direction Authentication Flow.
     */
    public function test_direction_can_login_and_get_token()
    {
        $email = 'test_directeur_' . uniqid() . '@ecole.com';
        $password = 'password123';

        // Create Direction User
        $direction = Direction::create([
            'last_name' => 'Directeur',
            'first_name' => 'Test',
            'email' => $email,
            'password' => Hash::make($password),
            'role' => 'directeur',
            'gender' => 'M',
            'phone' => '00000000',
            'birth_date' => '1980-01-01',
            'is_active' => true,
            'approved_by_admin' => true,
        ]);

        // Attempt Login
        $response = $this->postJson('/api/direction/login', [
            'email' => $email,
            'password' => $password,
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure(['access_token', 'token_type']);

        $token = $response->json('access_token');

        // Test Protected Route
        $responseProtected = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/user');

        $responseProtected->assertStatus(200)
                          ->assertJson(['email' => $email]);
        
        // Cleanup
        $direction->delete();
    }

    /**
     * Test Professeur Authentication Flow.
     */
    public function test_professeur_can_login_and_get_token()
    {
        $email = 'test_prof_' . uniqid() . '@ecole.com';
        $personalCode = 'PROF_' . uniqid();

        // Create Professeur
        $professeur = Professeur::create([
            'last_name' => 'Prof',
            'first_name' => 'Test',
            'email' => $email,
            'personal_code' => Hash::make($personalCode), // Stored as hash
            'gender' => 'M',
            'phone' => '11111111',
            'birth_date' => '1985-01-01',
            'matiere' => 'Maths',
            'is_active' => true,
        ]);

        // Attempt Login
        $response = $this->postJson('/api/professeur/login', [
            'email' => $email,
            'personal_code' => $personalCode,
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure(['access_token']);

        $token = $response->json('access_token');

        // Test Protected Route (e.g., NoteController access check which we fixed)
        // Note: NoteController endpoints might require specific classes assigned, 
        // but /api/user should always work.
        $responseProtected = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/user');

        $responseProtected->assertStatus(200)
                          ->assertJson(['email' => $email]);

        // Cleanup
        $professeur->delete();
    }
    /**
     * Test Tuteur Authentication Flow.
     */
    public function test_tuteur_can_login_and_get_token()
    {
        $email = 'test_parent_' . uniqid() . '@ecole.com';
        $password = 'password123';

        // Need an Eleve associated
        $eleve = \App\Models\Eleve::create([
            'matricule' => 'E' . uniqid(),
            'nom' => 'Enfant',
            'prenom' => 'Test',
            'date_naissance' => '2010-01-01',
            'lieu_naissance' => 'Cotonou',
            'sexe' => 'M',
            'nom_parent' => 'Parent Test',
            'telephone_parent' => '90909090',
            'email' => null,
            'classe_id' => \App\Models\Classe::create(['nom' => '6eme A', 'niveau' => '6eme', 'cout_scolarite' => 50000, 'cout_inscription' => 10000])->id
        ]);

        // Create Parent
        $parent = \App\Models\ParentModel::create([
            'nom' => 'Parent',
            'prenom' => 'Test',
            'email' => $email,
            'telephone' => '90909090',
            'password' => Hash::make($password),
        ]);

        // Relation (Direct DB insert for simplicity as pivot might have fields)
        \Illuminate\Support\Facades\DB::table('eleve_tuteur')->insert([
            'tuteur_id' => $parent->id,
            'eleve_id' => $eleve->id,
            'lien_tuteur' => 'père'
        ]);

        // Attempt Login
        $response = $this->postJson('/api/parent/login', [
            'email' => $email,
            'password' => $password,
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure(['access_token']);
    }

    /**
     * Test Professeur Note Access (Fixed Controller Verification).
     */
    public function test_professeur_access_notes_endpoint()
    {
        $email = 'test_prof_notes_' . uniqid() . '@ecole.com';
        $personalCode = 'PROF_' . uniqid();

        $professeur = Professeur::create([
            'last_name' => 'Prof',
            'first_name' => 'Notes',
            'email' => $email,
            'personal_code' => Hash::make($personalCode),
            'gender' => 'M',
            'phone' => '11111112',
            'birth_date' => '1985-01-01',
            'matiere' => 'Maths',
            'is_active' => true,
        ]);

        $response = $this->postJson('/api/professeur/login', [
            'email' => $email,
            'personal_code' => $personalCode,
        ]);

        $token = $response->json('access_token');

        // Access Protected Note Route (GET /api/professeurs/notes)
        // Should return 200 (even with empty data)
        $responseNotes = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/professeurs/notes');

        $responseNotes->assertStatus(200);
    }
}
