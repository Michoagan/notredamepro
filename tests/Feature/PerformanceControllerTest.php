<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\Professeur;
use App\Models\Matiere;
use Laravel\Sanctum\Sanctum;

class PerformanceControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_get_teacher_performance_stats(): void
    {
        // Setup Direction user since the route is protected by sanctum
        $user = User::factory()->create(['role' => 'directeur']);
        Sanctum::actingAs($user, ['*']);

        // Create Professeur with Matiere
        $matiere = Matiere::factory()->create();
        $professeur = Professeur::factory()->create([
            'matiere_id' => $matiere->id
        ]);

        // Attempt fetching without data
        $response = $this->getJson("/api/direction/professeurs/{$professeur->id}/performance");
        
        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'professeur' => ['id', 'nom_complet', 'matiere'],
                     'assiduite' => ['taux', 'heures_prevues', 'heures_assurees'],
                     'programme' => ['cahiers_remplis', 'heures_enseignees', 'taux_progression'],
                     'impact_pedagogique' => ['moyenne_globale', 'taux_reussite', 'total_evaluations']
                 ]);
                 
        // Assert empty state defaults
        $response->assertJsonPath('assiduite.taux', 100);
        $response->assertJsonPath('programme.taux_progression', 0);
        $response->assertJsonPath('impact_pedagogique.taux_reussite', 0);
    }
}
