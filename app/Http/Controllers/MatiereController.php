<?php

namespace App\Http\Controllers;

use App\Models\Matiere;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MatiereController extends Controller
{
    /**
     * Afficher le formulaire de création d'une matière
     */
    public function create()
    {
        // Récupérer toutes les matières existantes
        $matieres = Matiere::orderBy('nom', 'asc')->get();

        return response()->json([
            'success' => true,
            'matieres' => $matieres,
        ]);
    }

    /**
     * Enregistrer une nouvelle matière
     */
    public function store(Request $request)
    {
        // Validation des données
        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:255|unique:matieres,nom',
        ], [
            'nom.required' => 'Le nom de la matière est obligatoire.',
            'nom.unique' => 'Cette matière existe déjà.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Création de la matière
            Matiere::create([
                'nom' => $request->nom,
                'is_active' => true, // Par défaut, la matière est active
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Matière créée avec succès!',
                'matiere' => $request->nom,
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la création de la matière: '.$e->getMessage(),
            ], 500);
        }
    }

    /**
     * Afficher la liste des matières
     */
    public function index()
    {
        $matieres = Matiere::orderBy('nom', 'asc')->get();

        return response()->json([
            'success' => true,
            'matieres' => $matieres,
        ]);
    }

    /**
     * Afficher le formulaire de modification d'une matière
     */
    public function edit(Matiere $matiere)
    {
        return response()->json([
            'success' => true,
            'matiere' => $matiere,
        ]);
    }

    /**
     * Mettre à jour une matière
     */
    public function update(Request $request, Matiere $matiere)
    {
        // Validation des données
        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:255|unique:matieres,nom,'.$matiere->id,
        ], [
            'nom.required' => 'Le nom de la matière est obligatoire.',
            'nom.unique' => 'Cette matière existe déjà.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Mise à jour de la matière
            $matiere->update([
                'nom' => $request->nom,
                'is_active' => $request->has('is_active'),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Matière modifiée avec succès!',
                'matiere' => $matiere,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la modification de la matière: '.$e->getMessage(),
            ], 500);
        }
    }

    /**
     * Supprimer une matière
     */
    public function destroy(Matiere $matiere)
    {
        try {
            // Vérifier si la matière est utilisée dans des classes
            if ($matiere->classes()->count() > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Impossible de supprimer cette matière car elle est associée à des classes.',
                ], 400);
            }

            $matiere->delete();

            return response()->json([
                'success' => true,
                'message' => 'Matière supprimée avec succès!',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression de la matière: '.$e->getMessage(),
            ], 500);
        }
    }
}
