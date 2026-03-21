<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class TestProfesseur extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'test:prof';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Teste les APIs du Professeur localement';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info("Début du test API Professeur");
        $prof = \App\Models\Professeur::where('email', 'marsben200@gmail.com')->first();
        if (!$prof) {
            $this->error("Prof introuvable");
            return;
        }
        
        // Removed guard login to prevent TypeError, using setUserResolver below instead.
        $this->info("User set to: " . $prof->first_name . " " . $prof->last_name);

        try {
            \Laravel\Sanctum\Sanctum::actingAs($prof);
            $controller = app(\App\Http\Controllers\ProfesseurController::class);
            
            $request = \Illuminate\Http\Request::create('/api/professeurs/espace/dashboard', 'GET');
            $request->setUserResolver(function () use ($prof) {
                return $prof;
            });
            // 1. Dashboard
            $this->info("=== TEST DASHBOARD ===");
            $response = $controller->dashboard($request);
            $this->line("Status: " . $response->getStatusCode());
            if ($response->getStatusCode() == 500) {
                 $this->error("500: " . $response->content());
            } else {
                 $data = json_decode($response->content(), true);
                 $this->info("Données: " . implode(', ', array_keys($data ?? [])));
            }

            // 2. Classes
            $this->info("\n=== TEST CLASSES ===");
            try {
                $reqClasses = \Illuminate\Http\Request::create('/api/professeurs/classes', 'GET');
                $reqClasses->setUserResolver(function () use ($prof) {
                    return $prof;
                });
                $response = $controller->mesClasses($reqClasses);
                $this->line("Status: " . $response->getStatusCode());
                 if ($response->getStatusCode() == 500) {
                     $this->error("Erreur 500 des classes.");
                     dump(json_decode($response->content(), true) ?? $response->content());
                     return;
                } else {
                     $data = json_decode($response->content(), true);
                     $this->info("Classes trouvées: " . (is_array($data['classes'] ?? []) ? count($data['classes']) : 'Error'));
                }
            } catch (\Exception $e) {
                 $this->error("Erreur classes: ".$e->getMessage() . " \n " . $e->getTraceAsString());
            }
            
            // 3. Emploi du temps
             $this->info("\n=== TEST EMPLOI DU TEMPS ===");
            $reqEdt = \Illuminate\Http\Request::create('/api/professeurs/espace/emploi-du-temps', 'GET');
            $reqEdt->setUserResolver(function () use ($prof) {
                return $prof;
            });
            $response = $controller->emploiDuTemps($reqEdt);
            $this->line("Status: " . $response->getStatusCode());
            
            $this->info("Fin des tests.");

        } catch (\Exception $e) {
            $this->error("EXCEPTION: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            $this->error($e->getTraceAsString());
        }
    }
}
