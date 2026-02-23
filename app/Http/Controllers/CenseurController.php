<?php

namespace App\Http\Controllers;

use App\Models\Classe;
use App\Models\Professeur;
use App\Models\ModificationLog;
use App\Models\EmploiDuTemps;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CenseurController extends Controller
{
    // === DASHBOARD & LOGS ===

    public function dashboard()
    {
        $stats = [
            'classes_count' => Classe::count(),
            'professeurs_count' => Professeur::count(),
            'notes_pending_validation' => \App\Models\Note::where('is_validated', false)->count(),
            'recent_logs' => ModificationLog::orderBy('created_at', 'desc')->take(5)->get()
        ];

        return response()->json(['success' => true, 'data' => $stats]);
    }

    public function getLogs()
    {
        $logs = ModificationLog::orderBy('created_at', 'desc')->paginate(20);
        return response()->json(['success' => true, 'logs' => $logs]);
    }

    // === EMPLOI DU TEMPS (TIMETABLES) ===

    public function getEmploiDuTemps($classeId)
    {
        $slots = EmploiDuTemps::with(['matiere', 'professeur'])
            ->where('classe_id', $classeId)
            ->get();
        
        return response()->json(['success' => true, 'slots' => $slots]);
    }

    public function updateEmploiDuTemps(Request $request, $classeId)
    {
        $request->validate([
            'slots' => 'present|array',
            'slots.*.matiere_id' => 'required|exists:matieres,id',
            'slots.*.professeur_id' => 'nullable|exists:professeurs,id',
            'slots.*.jour' => 'required|in:Lundi,Mardi,Mercredi,Jeudi,Vendredi,Samedi,Dimanche',
            'slots.*.heure_debut' => 'required',
            'slots.*.heure_fin' => 'required',
        ]);

        DB::beginTransaction();
        try {
            // Remove existing slots for this class (Simplest strategy: Replace all)
            // Or detailed sync (more complex). We'll assume full replace per class for simplicity of UI
            EmploiDuTemps::where('classe_id', $classeId)->delete();

            foreach ($request->slots as $slot) {
                EmploiDuTemps::create([
                    'classe_id' => $classeId,
                    'matiere_id' => $slot['matiere_id'],
                    'professeur_id' => $slot['professeur_id'] ?? null,
                    'jour' => $slot['jour'],
                    'heure_debut' => $slot['heure_debut'],
                    'heure_fin' => $slot['heure_fin'],
                    'salle' => $slot['salle'] ?? null,
                ]);
            }
            
            // Log action
            $this->logAction('update', 'EmploiDuTemps', $classeId, ['classe_id' => $classeId]);

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Emploi du temps mis à jour']);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Error updating timetable: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Erreur mise à jour emploi du temps'], 500);
        }
    }

    // === NOTES VALIDATION ===

    public function getNotesValidationData(Request $request)
    {
        $classeId = $request->query('classe_id');
        $matiereId = $request->query('matiere_id');
        $trimestre = $request->query('trimestre');

        if (!$classeId || !$matiereId || !$trimestre) {
            return response()->json(['success' => false, 'message' => 'Paramètres manquants'], 400);
        }

        $notes = \App\Models\Note::with(['eleve'])
            ->where('classe_id', $classeId)
            ->where('matiere_id', $matiereId)
            ->where('trimestre', $trimestre)
            ->orderBy(DB::raw('eleves.nom')) // Requires join usually, but simpler: get and sort collection
            ->get();
            
        // Assuming Note belongsTo Eleve
        $notes = $notes->sortBy(function($note) {
            return $note->eleve->nom;
        })->values();

        return response()->json(['success' => true, 'notes' => $notes]);
    }

    public function validateNotes(Request $request)
    {
        $request->validate([
            'note_ids' => 'required|array',
            'action' => 'required|in:validate,invalidate'
        ]);

        $isValid = $request->action === 'validate';
        
        \App\Models\Note::whereIn('id', $request->note_ids)
            ->update([
                'is_validated' => $isValid,
                'validated_at' => $isValid ? now() : null,
                'validated_by' => 'Censeur' // TODO: Get authenticatd user if available
            ]);

        $this->logAction($request->action, 'Note', null, ['count' => count($request->note_ids)]);

        return response()->json(['success' => true, 'message' => 'Statut des notes mis à jour']);
    }

    // === PROGRAMMATION (MATIERES & CLASSES) ===

    public function programmation(Request $request)
    {
        $request->validate([
            'classe_id' => 'required|exists:classes,id',
            'matieres' => 'required|array',
            'matieres.*.matiere_id' => 'required|exists:matieres,id',
            'matieres.*.coefficient' => 'required|integer|min:1',
            'matieres.*.volume_horaire' => 'required|integer|min:1',
            'matieres.*.professeur_id' => 'nullable|exists:professeurs,id',
        ]);

        $classe = Classe::findOrFail($request->classe_id);

        foreach ($request->matieres as $m) {
            $classe->matieres()->syncWithoutDetaching([
                $m['matiere_id'] => [
                    'coefficient' => $m['coefficient'],
                    'volume_horaire' => $m['volume_horaire'],
                    'professeur_id' => $m['professeur_id'] ?? null
                ]
            ]);
        }
        
        $this->logAction('update', 'Programmation', $classe->id, ['classe' => $classe->nom]);

        return response()->json(['success' => true, 'message' => 'Programmation mise à jour']);
    }

    public function setProfPrincipal(Request $request) 
    {
        $request->validate([
            'classe_id' => 'required|exists:classes,id',
            'professeur_id' => 'required|exists:professeurs,id'
        ]);

        $classe = Classe::findOrFail($request->classe_id);
        $classe->professeur_principal_id = $request->professeur_id;
        $classe->save();

        $this->logAction('update', 'ProfPrincipal', $classe->id, ['prof_principal' => $request->professeur_id]);

        return response()->json(['success' => true, 'message' => 'Professeur principal assigné']);
    }

    // === CONTACTS & ANNUAIRE ===

    public function contacts()
    {
        $professeurs = Professeur::select('id', 'nom', 'prenom', 'email', 'telephone', 'specialite')
            ->where('is_active', true)
            ->get();
            
        return response()->json([
            'success' => true, 
            'professeurs' => $professeurs
        ]);
    }

    // === CAHIERS DE TEXTE ===
    public function cahiersTexte(Request $request)
    {
        $query = \App\Models\CahierTexte::with(['professeur', 'classe']);

        if ($request->has('classe_id') && $request->classe_id) {
            $query->where('classe_id', $request->classe_id);
        }
        if ($request->has('date') && $request->date) {
            $query->whereDate('date_cours', $request->date);
        }

        $cahiers = $query->orderBy('date_cours', 'desc')->paginate(20);

        return response()->json(['success' => true, 'data' => $cahiers]);
    }

    private function logAction($action, $model, $modelId, $changes)
    {
        try {
            ModificationLog::create([
                'user_name' => 'Censeur', // Placeholder, use Auth::user()->name
                'user_role' => 'Censeur',
                'action' => $action,
                'model' => $model,
                'model_id' => $modelId,
                'changes' => $changes,
                'ip_address' => request()->ip()
            ]);
        } catch (\Exception $e) {
            Log::error("Failed to log action: " . $e->getMessage());
        }
    }
}
