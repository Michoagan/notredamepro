<?php
require 'vendor/autoload.php';
use Illuminate\Support\Facades\Http;

$out = "=== DEBUT TEST API PROFESSEUR ===\n\n";

// 1. Authentification via API
$loginRes = Http::post('http://localhost:8000/api/professeur/login', [
    'email' => 'marsben200@gmail.com',
    'password' => 'MITCH1059'
]);

if (!$loginRes->successful()) {
    $out .= "Login échoué: " . $loginRes->body() . "\n";
    file_put_contents('test_prof_api_out.txt', $out);
    die("Login failed");
}

$loginData = $loginRes->json();
$token = $loginData['token'] ?? null;
if (!$token) {
     $out .= "Token manquant dans la réponse: " . json_encode($loginData) . "\n";
     file_put_contents('test_prof_api_out.txt', $out);
     die("No token");
}

$out .= "Token récupéré avec succès.\n\n";

$endpoints = [
    '/api/professeurs/espace/dashboard',
    '/api/professeurs/espace/emploi-du-temps',
    '/api/professeurs/classes',
    '/api/notes',
    '/api/cahier-texte'
];

foreach ($endpoints as $uri) {
    $out .= "--- GET $uri ---\n";
    $apiUrl = 'http://localhost:8000' . $uri;
    
    $res = Http::withToken($token)->withHeaders(['Accept' => 'application/json'])->get($apiUrl);
    
    $status = $res->status();
    $out .= "STATUS: $status\n";
    
    if ($status === 500) {
        $out .= "ERREUR 500: " . $res->body() . "\n\n";
    } else {
        $json = $res->json();
        if (is_array($json)) {
            $out .= "SUCCESS - Clés: " . implode(', ', array_keys($json)) . "\n";
        } else {
            $out .= "Raw: " . substr($res->body(), 0, 100) . "...\n";
        }
    }
    $out .= "\n";
}

file_put_contents('test_prof_api_out.txt', $out);
echo "Fin du script HTTP. Résultats dans test_prof_api_out.txt\n";
