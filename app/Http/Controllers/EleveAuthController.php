<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Eleve;
use Illuminate\Support\Facades\Hash;

class EleveAuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'matricule' => 'required|string',
            'password' => 'required|string|min:4|confirmed',
        ]);

        $eleve = Eleve::where('matricule', $request->matricule)->first();

        if (!$eleve) {
            return response()->json(['message' => 'Matricule invalide ou élève non trouvé.'], 404);
        }

        if ($eleve->password !== null) {
            return response()->json(['message' => 'Ce compte a déjà été activé.'], 400);
        }

        $eleve->password = Hash::make($request->password);
        $eleve->save();

        $token = $eleve->createToken('eleve_token')->plainTextToken;

        return response()->json([
            'message' => 'Compte activé avec succès.',
            'eleve' => [
                'id' => $eleve->id,
                'nom' => $eleve->nomComplet,
                'matricule' => $eleve->matricule,
                'classe_id' => $eleve->classe_id,
                'classe_nom' => $eleve->classe ? $eleve->classe->nom : null,
            ],
            'token' => $token
        ]);
    }

    public function login(Request $request)
    {
        $request->validate([
            'matricule' => 'required|string',
            'password' => 'required|string',
        ]);

        $eleve = Eleve::with('tuteurs')->where('matricule', $request->matricule)->first();

        if (!$eleve) {
            return response()->json([
                'message' => 'Matricule incorrect.'
            ], 401);
        }

        // Vérification avec le téléphone des tuteurs (Maitres/Parents)
        $validPassword = false;
        foreach ($eleve->tuteurs as $tuteur) {
            // Remove spaces from database phone and input phone just in case
            $dbPhone = str_replace(' ', '', $tuteur->telephone);
            $reqPhone = str_replace(' ', '', $request->password);
            
            if ($reqPhone === $dbPhone) {
                $validPassword = true;
                break;
            }
        }

        // Fallback or explicit check
        if (!$validPassword) {
            return response()->json([
                'message' => 'Mot de passe (numéro de téléphone parent) incorrect.'
            ], 401);
        }

        // Revoke older tokens
        $eleve->tokens()->delete();

        $token = $eleve->createToken('eleve_token')->plainTextToken;

        return response()->json([
            'message' => 'Connexion réussie',
            'eleve' => [
                'id' => $eleve->id,
                'nom' => $eleve->nomComplet,
                'matricule' => $eleve->matricule,
                'classe_id' => $eleve->classe_id,
                'classe_nom' => $eleve->classe ? $eleve->classe->nom : null,
            ],
            'token' => $token
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Déconnexion réussie']);
    }
}
