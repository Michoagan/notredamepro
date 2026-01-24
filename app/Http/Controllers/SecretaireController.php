<?php

namespace App\Http\Controllers;

use App\Models\Eleve;
use App\Models\Classe;
use App\Models\Bulletin;
use App\Models\Note;
use App\Models\Matiere;
use Illuminate\Http\Request;

class SecretaireController extends Controller
{
    /**
     * Tableau de bord du secrétariat
     */
    public function dashboard()
    {
        $totalEleves = Eleve::count();
        $totalClasses = Classe::count();
        $bulletinsGeneres = Bulletin::where('statut', 'généré')->count();
        $notesSaisies = Note::count();
        
        return response()->json([
            'success' => true,
            'stats' => [
                'total_eleves' => $totalEleves,
                'total_classes' => $totalClasses,
                'bulletins_generes' => $bulletinsGeneres,
                'notes_saisies' => $notesSaisies
            ]
        ]);
    }

    /**
     * Gestion des élèves
     */
    public function eleves()
    {
        $eleves = Eleve::with('classe')->orderBy('nom')->get();
        $classes = Classe::all();
        
        return response()->json([
            'success' => true,
            'eleves' => $eleves,
            'classes' => $classes
        ]);
    }

    /**
     * Gestion des bulletins
     */
    public function bulletins()
    {
        $bulletins = Bulletin::with(['eleve', 'classe'])
            ->orderBy('created_at', 'desc')
            ->get();
        
        return response()->json([
            'success' => true,
            'bulletins' => $bulletins
        ]);
    }

    /**
     * Gestion des notes
     */
    public function notes()
    {
        $notes = Note::with(['eleve', 'matiere'])
            ->orderBy('created_at', 'desc')
            ->get();
        
        $eleves = Eleve::all();
        $matieres = Matiere::all();
        
        return response()->json([
            'success' => true,
            'notes' => $notes,
            'eleves' => $eleves,
            'matieres' => $matieres
        ]);
    }

    /**
     * Affichage des résultats
     */
    public function resultats()
    {
        $classes = Classe::with(['eleves', 'matieres'])->get();
        
        return response()->json([
            'success' => true,
            'classes' => $classes
        ]);
    }
}