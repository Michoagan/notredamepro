<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth; // Added for Auth facade
use App\Models\CahierTexte; // Added for CahierTexte model
use Illuminate\Support\Facades\Log; // Added for Log facade

class CahierTexteController extends Controller
{

    public function cahierTexte(Request $request)
{
    if (!Auth::guard('professeur')->check()) {
        return response()->json(['error' => 'Non authentifié', 'message' => 'Veuillez vous connecter pour accéder à cette ressource.'], 401);
    }
    
    $professeur = Auth::guard('professeur')->user();
    
    // Charger les classes
    $professeur->load(['classes' => function($query) {
        $query->orderBy('nom');
    }]);
    
    $classe_selectionnee = null;
    $cahier_existant = null;
    $cahiers_recents = collect();
    
    // Récupérer les cahiers de texte récents (15 derniers jours)
    $cahiers_recents = CahierTexte::with('classe')
        ->where('professeur_id', $professeur->id)
        ->where('date_cours', '>=', now()->subDays(15))
        ->orderBy('date_cours', 'desc')
        ->orderBy('created_at', 'desc')
        ->get();
    
    // Si une classe et une date sont sélectionnées
    if ($request->has('classe_id') && $request->has('date_cours')) {
        $classe_selectionnee = $professeur->classes->firstWhere('id', $request->classe_id);
        
        if ($classe_selectionnee) {
            // Vérifier s'il existe déjà une entrée
            $cahier_existant = CahierTexte::where('classe_id', $request->classe_id)
                ->where('date_cours', $request->date_cours)
                ->where('professeur_id', $professeur->id)
                ->first();
        }
    }
    
    return response()->json([
        'success' => true,
        'professeur' => $professeur,
        'classe_selectionnee' => $classe_selectionnee,
        'cahier_existant' => $cahier_existant,
        'cahiers_recents' => $cahiers_recents
    ]);
}

public function storeCahierTexte(Request $request)
{
    $professeur = Auth::user();

    if (!$professeur instanceof \App\Models\Professeur) {
         return response()->json(['error' => 'Non autorisé'], 403);
    }
    
    $request->validate([
        'classe_id' => 'required|exists:classes,id',
        'date_cours' => 'required|date',
        'duree_cours' => 'required|integer|min:1|max:4',
        'heure_debut' => 'required',
        'notion_cours' => 'required|string|max:255',
        'objectifs' => 'required|string',
        'contenu_cours' => 'required|string',
        'travail_a_faire' => 'nullable|string',
        'observations' => 'nullable|string'
    ]);
    

    
    // Vérifier que le professeur a accès à cette classe
    if (!$professeur->classes->contains($request->classe_id)) {
        return response()->json(['error' => 'Vous n\'êtes pas assigné à cette classe.'], 403);
    }
    
    try {
        CahierTexte::updateOrCreate(
            [
                'classe_id' => $request->classe_id,
                'date_cours' => $request->date_cours,
                'professeur_id' => $professeur->id
            ],
            [
                'duree_cours' => $request->duree_cours,
                'heure_debut' => $request->heure_debut,
                'notion_cours' => $request->notion_cours,
                'objectifs' => $request->objectifs,
                'contenu_cours' => $request->contenu_cours,
                'travail_a_faire' => $request->travail_a_faire,
                'observations' => $request->observations
            ]
        );
        
        return response()->json([
            'success' => true,
            'message' => 'Cahier de texte enregistré avec succès!'
        ]);
        
    } catch (\Exception $e) {
        Log::error('Erreur enregistrement cahier texte: ' . $e->getMessage());
        
        return response()->json([
            'success' => false,
            'message' => 'Erreur lors de l\'enregistrement: ' . $e->getMessage()
        ], 500);
    }
}

public function destroyCahierTexte($id)
{
    $professeur = Auth::user();

    if (!$professeur instanceof \App\Models\Professeur) {
         return response()->json(['error' => 'Non autorisé'], 403);
    }
    

    
    try {
        $cahier = CahierTexte::findOrFail($id);
        
        // Vérifier que le professeur est propriétaire de cette entrée
        if ($cahier->professeur_id !== $professeur->id) {
            return response()->json(['error' => 'Action non autorisée.'], 403);
        }
        
        $cahier->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Entrée du cahier de texte supprimée avec succès!'
        ]);
        
    } catch (\Exception $e) {
        Log::error('Erreur suppression cahier texte: ' . $e->getMessage());
        
        return response()->json([
            'success' => false,
            'message' => 'Erreur lors de la suppression: ' . $e->getMessage()
        ], 500);
    }
}
    //
}
