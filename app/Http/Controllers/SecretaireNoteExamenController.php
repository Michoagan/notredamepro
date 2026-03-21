<?php

namespace App\Http\Controllers;

use App\Models\Classe;
use App\Models\Eleve;
use App\Models\NoteExamen;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SecretaireNoteExamenController extends Controller
{
    /**
     * Récupère la liste des élèves d'une classe avec leurs notes d'examen spécifiées.
     */
    public function index(Request $request)
    {
        $request->validate([
            'classe_id' => 'required|exists:classes,id',
            'type_examen' => 'required|string|in:Examen Blanc,Examen National',
            'annee_scolaire' => 'required|string',
            'matiere_id' => 'nullable|exists:matieres,id',
        ]);

        $classeId = $request->classe_id;
        $typeExamen = $request->type_examen;
        $anneeScolaire = $request->annee_scolaire;
        $matiereId = $request->matiere_id;

        // Récupérer les élèves de la classe
        $eleves = Eleve::where('classe_id', $classeId)
            ->with(['notesExamens' => function ($query) use ($typeExamen, $anneeScolaire, $matiereId) {
                $query->where('type_examen', $typeExamen)
                      ->where('annee_scolaire', $anneeScolaire)
                      ->where('matiere_id', $matiereId);
            }])
            ->orderBy('nom')
            ->orderBy('postnom')
            ->orderBy('prenom')
            ->get();

        // Mapper les résultats pour une utilisation facile dans le frontend
        $result = $eleves->map(function ($eleve) {
            $note = $eleve->notesExamens->first();
            return [
                'eleve_id' => $eleve->id,
                'nom_complet' => $eleve->nom_complet,
                'matricule' => $eleve->matricule,
                'valeur' => $note ? $note->valeur : null,
            ];
        });

        return response()->json($result);
    }

    /**
     * Sauvegarde ou met à jour les notes d'examen en lot.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'classe_id' => 'required|exists:classes,id',
            'type_examen' => 'required|string|in:Examen Blanc,Examen National',
            'annee_scolaire' => 'required|string',
            'matiere_id' => 'nullable|exists:matieres,id',
            'notes' => 'required|array',
            'notes.*.eleve_id' => 'required|exists:eleves,id',
            'notes.*.valeur' => 'nullable|numeric|min:0|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Données invalides', 'errors' => $validator->errors()], 422);
        }

        $classeId = $request->classe_id;
        $typeExamen = $request->type_examen;
        $anneeScolaire = $request->annee_scolaire;
        $matiereId = $request->matiere_id;
        $notes = $request->notes;

        $savedCount = 0;

        foreach ($notes as $noteData) {
            // Ne pas enregistrer de ligne si la valeur est totalement vide et qu'elle n'existe pas déjà
            if (is_null($noteData['valeur']) || $noteData['valeur'] === '') {
                // Si une note existait on peut la supprimer ou la mettre à null. On la met à null.
                $existing = NoteExamen::where('eleve_id', $noteData['eleve_id'])
                    ->where('type_examen', $typeExamen)
                    ->where('annee_scolaire', $anneeScolaire)
                    ->where('matiere_id', $matiereId)
                    ->first();
                if ($existing) {
                    $existing->update(['valeur' => null]);
                    $savedCount++;
                }
                continue;
            }

            NoteExamen::updateOrCreate(
                [
                    'eleve_id' => $noteData['eleve_id'],
                    'type_examen' => $typeExamen,
                    'annee_scolaire' => $anneeScolaire,
                    'matiere_id' => $matiereId,
                ],
                [
                    'classe_id' => $classeId,
                    'valeur' => $noteData['valeur'],
                ]
            );
            $savedCount++;
        }

        return response()->json([
            'message' => 'Notes enregistrées avec succès',
            'count' => $savedCount
        ]);
    }
}
