<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Professeur;
use App\Models\Classe;
use App\Models\Presence;
use App\Models\PresenceRemarque;
use App\Models\Matiere;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class PresenceController extends Controller
{

  public function presences(Request $request)
{
    if (!Auth::check()) {
        return response()->json(['error' => 'Non authentifié'], 401);
    }
    
    $professeur = Auth::user();
    
    // Charger les classes avec leurs matières enseignées par ce professeur
    $professeur->load(['classes' => function($query) use ($professeur) {
        $query->with(['matieres' => function($q) use ($professeur) {
            $q->wherePivot('professeur_id', $professeur->id)
              ->orderBy('pivot_ordre_affichage');
        }])->withCount('eleves');
    }]);
    
    $matieres = collect();
    $classe_selectionnee = null;
    $eleves = collect();
    $presences_existantes = collect();
    $remarques_generales = null;
    
    // Si une classe est sélectionnée, charger ses matières enseignées par ce professeur
    if ($request->has('classe_id')) {
        $classe_selectionnee = $professeur->classes->firstWhere('id', $request->classe_id);
        if ($classe_selectionnee) {
            $matieres = $classe_selectionnee->matieres;
        }
    }
    
    // Si une classe, une date et un cours sont sélectionnés
    if ($request->has('classe_id') && $request->has('date') && $request->has('cours')) {
        $classe_selectionnee = $professeur->classes->firstWhere('id', $request->classe_id);
        
        // Vérifier que le professeur a bien cette classe
        if (!$classe_selectionnee) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas assigné à cette classe.'
            ]);
        }
        
        // Vérifier que la matière est enseignée par ce professeur dans cette classe
        $matiere_enseignee = $classe_selectionnee->matieres->firstWhere('id', $request->cours);
        if (!$matiere_enseignee) {
                return response()->json([
                    'success' => false,
                'message' => 'Vous n\'enseignez pas cette matière dans cette classe.'
            ]);
        }
        
        // Charger les élèves de la classe
        $eleves = $classe_selectionnee->eleves()->orderBy('nom')->orderBy('prenom')->get();
        
        // Charger les présences existantes pour cette date et cours
        $presences_existantes = Presence::where('classe_id', $request->classe_id)
            ->where('date', $request->date)
            ->where('cours_id', $request->cours)
            ->get()
            ->keyBy('eleve_id');
            
        // Charger les remarques générales si elles existent
        $remarques_generales = PresenceRemarque::where('classe_id', $request->classe_id)
            ->where('date', $request->date)
            ->where('cours_id', $request->cours)
            ->value('remarques');
    }
    
   return response()->json([
        'professeur', 
        'classe_selectionnee', 
        'eleves', 
        'presences_existantes',
        'remarques_generales',
        'matieres'
    ]);
}

   public function storePresences(Request $request)
{
    if (!Auth::check()) {
        return response()->json(['error' => 'Non authentifié'], 401);
    }
    
    $request->validate([
        'classe_id' => 'required|exists:classes,id',
        'date' => 'required|date',
        'cours' => 'required|exists:matieres,id',
        'absents' => 'nullable|array',
        'absents.*' => 'exists:eleves,id',
        'remarques_generales' => 'nullable|string|max:1000'
    ]);
    
    $professeur = Auth::user();
    $classe = Classe::with('matieres')->findOrFail($request->classe_id);
    
    // Vérifier que la matière est enseignée dans cette classe
    if (!$classe->matieres->contains('id', $request->cours)) {
        return response()->json([
            'success' => false,
            'message' => 'Cette matière n\'est pas enseignée dans cette classe.'
        ]);
    }
    
    // Vérifier que le professeur a bien cette classe
    if (!$professeur->classes->contains($request->classe_id)) {
        return response()->json([
            'success' => false,
            'message' => 'Vous n\'êtes pas assigné à cette classe.'
        ]);
    }
    
    // Vérifier que la matière existe
    $matiere = Matiere::findOrFail($request->cours);
    
    DB::beginTransaction();
    
    try {
        $classe = Classe::findOrFail($request->classe_id);
        $eleves = $classe->eleves;
        
        // Récupérer les IDs des élèves absents
        $absentsIds = $request->absents ?? [];
        
        foreach ($eleves as $eleve) {
            $estAbsent = in_array($eleve->id, $absentsIds);
            
            if ($estAbsent) {
                // Enregistrer seulement les absents
                Presence::updateOrCreate(
                    [
                        'eleve_id' => $eleve->id,
                        'classe_id' => $request->classe_id,
                        'date' => $request->date,
                        'cours_id' => $matiere->id // Utiliser cours_id au lieu de cours
                    ],
                    [
                        'present' => false, // Marqué comme absent
                        'professeur_id' => $professeur->id
                    ]
                );
            } else {
                // Supprimer l'enregistrement si l'élève n'est plus absent
                Presence::where('eleve_id', $eleve->id)
                    ->where('classe_id', $request->classe_id)
                    ->where('date', $request->date)
                    ->where('cours_id', $matiere->id)
                    ->delete();
            }
        }
        
        // Enregistrer les remarques générales seulement s'il y a des absents
        if ($request->remarques_generales && !empty($absentsIds)) {
            PresenceRemarque::updateOrCreate(
                [
                    'classe_id' => $request->classe_id,
                    'date' => $request->date,
                    'cours_id' => $matiere->id // Utiliser cours_id au lieu de cours
                ],
                [
                    'remarques' => $request->remarques_generales,
                    'professeur_id' => $professeur->id
                ]
            );
        } elseif (empty($absentsIds)) {
            // Supprimer les remarques s'il n'y a pas d'absents
            PresenceRemarque::where('classe_id', $request->classe_id)
                ->where('date', $request->date)
                ->where('cours_id', $matiere->id)
                ->delete();
        }
        
        DB::commit();
        
        $message = empty($absentsIds) 
            ? 'Aucun absent enregistré pour cette séance.' 
            : 'Présences enregistrées avec succès! ' . count($absentsIds) . ' absent(s) marqué(s).';
            
        return response()->json([
            'success' => true,
            'message' => $message
        ]);
        
    } catch (\Exception $e) {
        DB::rollBack();
        Log::error('Erreur enregistrement présences: ' . $e->getMessage());
        
        return response()->json([
            'success' => false,
            'message' => 'Erreur lors de l\'enregistrement des présences: ' . $e->getMessage()
        ]);
    }
}

public function getPresencesDuJour($classeId)
{
    try {
        $date = now()->format('Y-m-d');
        $presences = Presence::where('classe_id', $classeId)
            ->where('date', $date)
            ->with('eleve')
            ->get()
            ->keyBy('eleve_id');

        return response()->json([
            'success' => true,
            'presences' => $presences
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Erreur lors du chargement des présences'
        ], 500);
    }
}

public function marquerPresences(Request $request)
{
    $request->validate([
        'classe_id' => 'required|exists:classes,id',
        'date' => 'required|date',
        'presences' => 'required|array',
        'presences.*.eleve_id' => 'required|exists:eleves,id',
        'presences.*.present' => 'required|boolean'
    ]);

    DB::beginTransaction();

    try {
        $professeur = Auth::user();

        foreach ($request->presences as $presenceData) {
            Presence::updateOrCreate(
                [
                    'eleve_id' => $presenceData['eleve_id'],
                    'classe_id' => $request->classe_id,
                    'date' => $request->date
                ],
                [
                    'present' => $presenceData['present'],
                    'professeur_id' => $professeur->id,
                    'remarque' => $presenceData['remarque'] ?? null
                ]
            );
        }

        DB::commit();

        return response()->json([
            'success' => true,
            'message' => 'Présences enregistrées avec succès!'
        ]);

    } catch (\Exception $e) {
        DB::rollBack();
        Log::error('Erreur lors de l\'enregistrement des présences: ' . $e->getMessage());

        return response()->json([
            'success' => false,
            'message' => 'Erreur lors de l\'enregistrement des présences'
        ], 500);
    }
}
    //
}
