<?php

namespace App\Http\Controllers;

use App\Models\CahierTexte;
use App\Models\Classe;
use App\Models\Eleve;
use App\Models\Matiere;
use App\Models\Note;
use App\Models\Paiement;
use App\Models\Professeur;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use PDF;

class DirecteurController extends Controller
{
    /**
     * Afficher la liste des classes avec leurs élèves
     */
    public function classesEleves(Request $request)
    {
        // Récupérer tous les niveaux distincts pour le filtre
        $niveaux = Classe::distinct()->pluck('niveau');

        // Récupérer les classes avec le nombre d'élèves et le professeur principal
        $classes = Classe::withCount(['eleves as nombre_eleves'])
            ->with(['professeurPrincipal'])
            ->when($request->niveau, function ($query, $niveau) {
                return $query->where('niveau', $niveau);
            })
            ->orderBy('niveau')
            ->orderBy('nom')
            ->get();

        // Retourner JSON
        return response()->json([
            'success' => true,
            'classes' => $classes,
            'niveaux' => $niveaux,
        ]);
    }

    /**
     * Récupérer les élèves d'une classe spécifique
     */
    public function getElevesByClasse(Classe $classe, Request $request)
    {
        // Charger les élèves avec leurs relations
        $eleves = $classe->eleves()
            ->with(['tuteurs'])
            ->orderBy('nom')
            ->orderBy('prenom')
            ->get();

        // Compter les garçons et les filles
        $stats = [
            'garcons' => $eleves->where('sexe', 'M')->count(),
            'filles' => $eleves->where('sexe', 'F')->count(),
            'total' => $eleves->count(),
        ];

        return response()->json([
            'success' => true,
            'eleves' => $eleves,
            'classe' => $classe->load('professeurPrincipal'),
            'stats' => $stats,
        ]);
    }

    /**
     * Récupérer les détails d'un élève spécifique
     */
    public function getEleveDetails(Eleve $eleve, Request $request)
    {
        // Charger les relations de l'élève
        $eleve->load([
            'classe',
            'tuteurs',
            'paiements' => function ($query) {
                $query->orderBy('date_paiement', 'desc')->limit(5);
            },
        ]);

        return response()->json([
            'success' => true,
            'eleve' => $eleve,
        ]);
    }

    /**
     * Rechercher des élèves
     */
    public function searchEleves(Request $request)
    {
        $request->validate([
            'search' => 'required|string|min:2',
        ]);

        $searchTerm = $request->search;

        $eleves = Eleve::with(['classe'])
            ->where(function ($query) use ($searchTerm) {
                $query->where('nom', 'LIKE', "%{$searchTerm}%")
                    ->orWhere('prenom', 'LIKE', "%{$searchTerm}%")
                    ->orWhere('matricule', 'LIKE', "%{$searchTerm}%")
                    ->orWhere('email', 'LIKE', "%{$searchTerm}%");
            })
            ->when($request->classe_id, function ($query, $classeId) {
                return $query->where('classe_id', $classeId);
            })
            ->orderBy('nom')
            ->orderBy('prenom')
            ->limit(50)
            ->get();

        return response()->json([
            'eleves' => $eleves,
            'searchTerm' => $searchTerm,
        ]);
    }

    /**
     * Exporter la liste des élèves d'une classe
     */
    public function exportEleves(Classe $classe, Request $request)
    {
        $eleves = $classe->eleves()
            ->with(['tuteurs'])
            ->orderBy('nom')
            ->orderBy('prenom')
            ->get();

        $format = $request->format ?? 'pdf';

        if ($format === 'pdf') {
            $pdf = PDF::loadView('directeur.classes-eleves.export-pdf', [
                'classe' => $classe,
                'eleves' => $eleves,
                'date' => now()->format('d/m/Y'),
            ]);

            return $pdf->download('eleves-'.$classe->nom.'-'.now()->format('Y-m-d').'.pdf');
        }

        // Format Excel (CSV)
        if ($format === 'excel') {
            $fileName = 'eleves-'.$classe->nom.'-'.now()->format('Y-m-d').'.csv';

            $headers = [
                'Content-Type' => 'text/csv',
                'Content-Disposition' => 'attachment; filename="'.$fileName.'"',
            ];

            $callback = function () use ($eleves, $classe) {
                $file = fopen('php://output', 'w');

                // Entête
                fputcsv($file, [
                    'Liste des élèves - '.$classe->nom,
                    '',
                    '',
                    '',
                ]);

                fputcsv($file, [
                    'Exporté le: '.now()->format('d/m/Y à H:i'),
                    '',
                    '',
                    '',
                ]);

                fputcsv($file, []); // Ligne vide

                // En-têtes des colonnes
                fputcsv($file, [
                    'Matricule',
                    'Nom',
                    'Prénom',
                    'Date de naissance',
                    'Sexe',
                    'Téléphone',
                    'Email',
                    'Parent',
                    'Téléphone parent',
                ]);

                // Données
                foreach ($eleves as $eleve) {
                    $parentPrincipal = $eleve->tuteurs->first();

                    fputcsv($file, [
                        $eleve->matricule,
                        $eleve->nom,
                        $eleve->prenom,
                        $eleve->date_naissance->format('d/m/Y'),
                        $eleve->sexe === 'M' ? 'Masculin' : 'Féminin',
                        $eleve->telephone,
                        $eleve->email,
                        $parentPrincipal ? $parentPrincipal->nom.' '.$parentPrincipal->prenom : $eleve->nom_parent,
                        $parentPrincipal ? $parentPrincipal->telephone : $eleve->telephone_parent,
                    ]);
                }

                fclose($file);
            };

            return response()->stream($callback, 200, $headers);
        }

        return response()->json(['success' => false, 'message' => 'Format non supporté'], 400);
    }

    /**
     * Obtenir les statistiques générales
     */
    public function getStats()
    {
        $totalEleves = Eleve::count();
        $totalClasses = Classe::where('is_active', true)->count();
        $totalProfesseurs = Professeur::where('is_active', true)->count();

        // Répartition par sexe
        $repartitionSexe = Eleve::select('sexe', DB::raw('count(*) as count'))
            ->groupBy('sexe')
            ->get()
            ->mapWithKeys(function ($item) {
                return [$item->sexe => $item->count];
            });

        // Répartition par niveau
        $repartitionNiveau = Classe::withCount('eleves')
            ->get()
            ->mapWithKeys(function ($classe) {
                return [$classe->niveau => $classe->eleves_count];
            });

        return response()->json([
            'totalEleves' => $totalEleves,
            'totalClasses' => $totalClasses,
            'totalProfesseurs' => $totalProfesseurs,
            'repartitionSexe' => $repartitionSexe,
            'repartitionNiveau' => $repartitionNiveau,
        ]);
    }

    /**
     * Dashboard du directeur
     */
    public function dashboard()
    {
        $totalEleves = Eleve::count();
        $totalClasses = Classe::where('is_active', true)->count();
        $totalProfesseurs = Professeur::where('is_active', true)->count();

        $derniersEleves = Eleve::with('classe')->orderBy('created_at', 'desc')->limit(5)->get();
        $derniersProfesseurs = Professeur::orderBy('created_at', 'desc')->limit(5)->get();

        $repartitionSexe = [
            'garcons' => Eleve::where('sexe', 'M')->count(),
            'filles' => Eleve::where('sexe', 'F')->count(),
        ];

        // Récupération des données pour les graphiques
        $labels = Classe::where('is_active', true)->pluck('nom');
        $elevesParClasse = Classe::withCount('eleves')->where('is_active', true)->pluck('eleves_count');

        // Calcul des revenus du mois en cours
        $debutMois = Carbon::now()->startOfMonth();
        $finMois = Carbon::now()->endOfMonth();

        $revenusMois = Paiement::where('statut', 'réussi')
            ->whereBetween('date_paiement', [$debutMois, $finMois])
            ->sum('montant');

        // Récupération des derniers paiements
        $derniersPaiements = Paiement::with('eleve.classe')
            ->orderBy('date_paiement', 'desc')
            ->limit(5)
            ->get();

        // Pour le graphique "genre"
        $garcons = Eleve::where('sexe', 'M')->count();
        $filles = Eleve::where('sexe', 'F')->count();

        return response()->json([
            'success' => true,
            'data' => compact(
                'totalEleves', 'totalClasses', 'totalProfesseurs',
                'derniersEleves', 'derniersProfesseurs', 'repartitionSexe',
                'labels', 'elevesParClasse', 'revenusMois', 'derniersPaiements',
                'garcons', 'filles'
            ),
        ]);
    }

    public function gestionNotes(Request $request)
    {
        // Récupérer les filtres
        $filters = [
            'classe_id' => $request->classe_id,
            'eleve_id' => $request->eleve_id,
            'matiere_id' => $request->matiere_id,
            'professeur_id' => $request->professeur_id,
            'trimestre' => $request->trimestre,
        ];

        // Requête de base avec les relations
        $query = Note::with(['eleve', 'classe', 'matiere', 'professeur']);

        // Appliquer les filtres
        if ($filters['classe_id']) {
            $query->where('classe_id', $filters['classe_id']);
        }

        if ($filters['eleve_id']) {
            $query->where('eleve_id', $filters['eleve_id']);
        }

        if ($filters['matiere_id']) {
            $query->where('matiere_id', $filters['matiere_id']);
        }

        if ($filters['professeur_id']) {
            $query->where('professeur_id', $filters['professeur_id']);
        }

        if ($filters['trimestre']) {
            $query->where('trimestre', $filters['trimestre']);
        }

        // Ordonner par classe, élève, matière et trimestre
        $notes = $query->orderBy('classe_id')
            ->orderBy('eleve_id')
            ->orderBy('matiere_id')
            ->orderBy('trimestre')
            ->paginate(20);

        // Données pour les filtres
        $classes = Classe::where('is_active', true)->orderBy('niveau')->orderBy('nom')->get();
        $eleves = Eleve::orderBy('nom')->orderBy('prenom')->get();
        $matieres = Matiere::orderBy('nom')->get();
        $professeurs = Professeur::where('is_active', true)->orderBy('last_name')->get();
        $trimestres = [1, 2, 3];

        // Statistiques
        $stats = [
            'total_notes' => $notes->total(),
            'moyenne_generale' => $query->avg('moyenne_trimestrielle'),
            'notes_par_trimestre' => Note::select('trimestre', \DB::raw('COUNT(*) as count'))
                ->groupBy('trimestre')
                ->get(),
        ];

        return response()->json([
            'success' => true,
            'notes' => $notes,
            'classes' => $classes,
            'eleves' => $eleves,
            'matieres' => $matieres,
            'professeurs' => $professeurs,
            'trimestres' => $trimestres,
            'filters' => $filters,
            'stats' => $stats,
        ]);
    }

    /**
     * Export des notes
     */
    public function exportNotes(Request $request)
    {
        $filters = $request->only(['classe_id', 'eleve_id', 'matiere_id', 'professeur_id', 'trimestre']);

        $query = Note::with(['eleve', 'classe', 'matiere', 'professeur']);

        foreach ($filters as $key => $value) {
            if ($value) {
                $query->where($key, $value);
            }
        }

        $notes = $query->orderBy('classe_id')
            ->orderBy('eleve_id')
            ->orderBy('matiere_id')
            ->orderBy('trimestre')
            ->get();

        // Générer le PDF
        $pdf = \PDF::loadView('directeur.notes.export', [
            'notes' => $notes,
            'filters' => $filters,
            'date' => now()->format('d/m/Y'),
        ]);

        return $pdf->download('notes-export-'.now()->format('Y-m-d').'.pdf');
    }

    /**
     * Statistiques détaillées
     */
    public function statsNotes(Request $request)
    {
        $filters = $request->only(['classe_id', 'matiere_id', 'trimestre']);

        $query = Note::with(['classe', 'matiere']);

        foreach ($filters as $key => $value) {
            if ($value) {
                $query->where($key, $value);
            }
        }

        // Statistiques par classe
        $statsClasse = $query->select('classe_id', \DB::raw('
            COUNT(*) as total_notes,
            AVG(moyenne_trimestrielle) as moyenne_classe,
            MIN(moyenne_trimestrielle) as min_note,
            MAX(moyenne_trimestrielle) as max_note
        '))->groupBy('classe_id')->get();

        // Statistiques par matière
        $statsMatiere = $query->select('matiere_id', \DB::raw('
            COUNT(*) as total_notes,
            AVG(moyenne_trimestrielle) as moyenne_matiere
        '))->groupBy('matiere_id')->get();

        // Répartition des appréciations
        $statsAppreciations = $query->select('commentaire', \DB::raw('COUNT(*) as count'))
            ->groupBy('commentaire')
            ->orderBy('count', 'desc')
            ->get();

        $classes = Classe::where('is_active', true)->orderBy('niveau')->orderBy('nom')->get();
        $matieres = Matiere::orderBy('nom')->get();
        $trimestres = [1, 2, 3];

        return response()->json([
            'success' => true,
            'statsClasse' => $statsClasse,
            'statsMatiere' => $statsMatiere,
            'statsAppreciations' => $statsAppreciations,
            'classes' => $classes,
            'matieres' => $matieres,
            'trimestres' => $trimestres,
            'filters' => $filters,
        ]);
    }

    /**
     * Détails d'une note spécifique
     */
    public function detailNote(Note $note)
    {
        $note->load(['eleve', 'classe', 'matiere', 'professeur']);

        return response()->json([
            'success' => true,
            'note' => $note,
        ]);
    }

    public function detailProfesseur(Professeur $professeur, Request $request)
    {
        // Filtres pour les cahiers de texte
        $filters = [
            'date_debut' => $request->date_debut,
            'date_fin' => $request->date_fin,
            'classe_id' => $request->classe_id,
        ];

        // Charger les relations
        $professeur->load([
            'classesPrincipales',
            'matieresEnseignees',
            'notes' => function ($query) {
                $query->orderBy('created_at', 'desc')->limit(10);
            },
            'classes' => function ($query) {
                $query->withCount('eleves');
            },
        ]);

        // Cahiers de texte du professeur
        $cahiersQuery = CahierTexte::with('classe')
            ->where('professeur_id', $professeur->id);

        if ($filters['date_debut']) {
            $cahiersQuery->where('date_cours', '>=', $filters['date_debut']);
        }

        if ($filters['date_fin']) {
            $cahiersQuery->where('date_cours', '<=', $filters['date_fin']);
        }

        if ($filters['classe_id']) {
            $cahiersQuery->where('classe_id', $filters['classe_id']);
        }

        $cahiers = $cahiersQuery->orderBy('date_cours', 'desc')
            ->orderBy('heure_debut', 'desc')
            ->paginate(15, ['*'], 'cahiers_page');

        // Statistiques du professeur
        $stats = [
            'total_notes' => $professeur->notes->count(),
            'moyenne_notes' => $professeur->notes->avg('moyenne_trimestrielle'),
            'classes_principales' => $professeur->classesPrincipales->count(),
            'matieres_enseignees' => $professeur->matieresEnseignees->count(),
            'total_eleves' => $professeur->classes->sum('eleves_count'),
            'total_cahiers' => CahierTexte::where('professeur_id', $professeur->id)->count(),
            'cahiers_7j' => CahierTexte::where('professeur_id', $professeur->id)
                ->where('date_cours', '>=', Carbon::now()->subDays(7))
                ->count(),
        ];

        // Classes pour le filtre
        $classes = $professeur->classes;

        return response()->json([
            'success' => true,
            'professeur' => $professeur,
            'stats' => $stats,
            'cahiers' => $cahiers,
            'filters' => $filters,
            'classes' => $classes,
        ]);
    }

    /**
     * Activer/Désactiver un professeur
     */
    public function toggleProfesseur(Professeur $professeur)
    {
        $professeur->update([
            'is_active' => ! $professeur->is_active,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Statut du professeur mis à jour avec succès.',
            'is_active' => $professeur->is_active,
        ]);
    }

    /**
     * Exporter la liste des professeurs
     */
    public function exportProfesseurs(Request $request)
    {
        $filters = $request->only(['is_active', 'matiere', 'search']);

        $query = Professeur::with(['classesPrincipales', 'matieresEnseignees']);

        foreach ($filters as $key => $value) {
            if ($value !== null && $value !== '') {
                if ($key === 'search') {
                    $query->where(function ($q) use ($value) {
                        $q->where('last_name', 'like', '%'.$value.'%')
                            ->orWhere('first_name', 'like', '%'.$value.'%')
                            ->orWhere('email', 'like', '%'.$value.'%')
                            ->orWhere('personal_code', 'like', '%'.$value.'%');
                    });
                } else {
                    $query->where($key, $value);
                }
            }
        }

        $professeurs = $query->orderBy('last_name')
            ->orderBy('first_name')
            ->get();

        // Générer le PDF
        $pdf = \PDF::loadView('directeur.professeurs.export', [
            'professeurs' => $professeurs,
            'filters' => $filters,
            'date' => now()->format('d/m/Y'),
        ]);

        return $pdf->download('professeurs-export-'.now()->format('Y-m-d').'.pdf');
    }

    /**
     * Voir les détails d'un cahier de texte
     */
    public function detailCahierTexte(CahierTexte $cahier)
    {
        $cahier->load(['professeur', 'classe']);

        return response()->json([
            'success' => true,
            'cahier' => $cahier,
        ]);
    }
}
