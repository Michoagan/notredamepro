<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Professeur;
use Illuminate\Http\Request;

try {
    $prof = Professeur::where('email', 'marsben200@gmail.com')->first();
    if (!$prof) die("Professeur introuvable");
    
    auth()->guard('professeur')->login($prof);
    $token = $prof->createToken('auth_token')->plainTextToken;
    
    $out = "Professeur: {$prof->first_name} {$prof->last_name}\n\n";
    
    $endpoints = [
        '/api/professeurs/espace/dashboard',
        '/api/professeurs/espace/emploi-du-temps',
        '/api/professeurs/classes',
        '/api/notes',
        '/api/cahier-texte'
    ];
    
    foreach ($endpoints as $uri) {
        $out .= "=== GET $uri ===\n";
        try {
            $request = Request::create($uri, 'GET');
            $request->headers->set('Authorization', 'Bearer ' . $token);
            $request->headers->set('Accept', 'application/json');
            
            $response = app()->handle($request);
            $status = $response->getStatusCode();
            $out .= "STATUS: $status\n";
            
            $content = $response->getContent();
            $json = json_decode($content, true);
            
            if ($status === 500) {
                $out .= "ERREUR 500: " . print_r($json ?? $content, true) . "\n";
            } else {
                if (is_array($json)) {
                     $out .= "SUCCESS. Keys: " . implode(', ', array_keys($json)) . "\n";
                     if (isset($json['message'])) $out .= "Message: " . $json['message'] . "\n";
                } else {
                     $out .= "Raw: " . substr($content, 0, 100) . "...\n";
                }
            }
        } catch (\Exception $e) {
            $out .= "EXCEPTION: " . $e->getMessage() . "\n";
        }
        $out .= "\n";
    }
    
    file_put_contents('test_professeur_output.txt', $out);
    echo "Done. Log written to test_professeur_output.txt\n";
} catch (\Exception $e) {
    echo "Fatal Error: " . $e->getMessage();
}
