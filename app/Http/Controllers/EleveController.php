<?php

namespace App\Http\Controllers;

use App\Models\Eleve;
use App\Models\Classe;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class EleveController extends Controller
{
    /**
     * Afficher la liste des élèves
     */
    public function index(Request $request)
{
    // Récupérer les paramètres de recherche
    $search = $request->input('search');
    $classeId = $request->input('classe_id');
    $sexe = $request->input('sexe');
    $dateNaissance = $request->input('date_naissance');
    
    // Récupérer toutes les classes avec leurs élèves
    $classes = Classe::with(['eleves' => function($query) use ($search, $classeId, $sexe, $dateNaissance) {
        $query->when($search, function($query, $search) {
            $query->where(function($q) use ($search) {
                $q->where('nom', 'like', "%{$search}%")
                  ->orWhere('prenom', 'like', "%{$search}%")
                  ->orWhere('matricule', 'like', "%{$search}%")
                  ->orWhere('nom_parent', 'like', "%{$search}%")
                  ->orWhere('telephone_parent', 'like', "%{$search}%")
                  ->orWhere('lieu_naissance', 'like', "%{$search}%")
                  ->orWhere(\DB::raw('CAST(date_naissance AS TEXT)'), 'like', "%{$search}%");
            });
        })
        ->when($classeId, function($query, $classeId) {
            $query->where('classe_id', $classeId);
        })
        ->when($sexe, function($query, $sexe) {
            $query->where('sexe', $sexe);
        })
        ->when($dateNaissance, function($query, $dateNaissance) {
            $query->whereDate('date_naissance', $dateNaissance);
        })
        ->orderBy('nom')->orderBy('prenom');
    }])
    ->withCount(['eleves' => function($query) use ($search, $classeId, $sexe, $dateNaissance) {
        $query->when($search, function($query, $search) {
            $query->where(function($q) use ($search) {
                $q->where('nom', 'like', "%{$search}%")
                  ->orWhere('prenom', 'like', "%{$search}%")
                  ->orWhere('matricule', 'like', "%{$search}%")
                  ->orWhere('nom_parent', 'like', "%{$search}%")
                  ->orWhere('telephone_parent', 'like', "%{$search}%")
                  ->orWhere('lieu_naissance', 'like', "%{$search}%")
                  ->orWhere(\DB::raw('CAST(date_naissance AS TEXT)'), 'like', "%{$search}%");
            });
        })
        ->when($classeId, function($query, $classeId) {
            $query->where('classe_id', $classeId);
        })
        ->when($sexe, function($query, $sexe) {
            $query->where('sexe', $sexe);
        })
        ->when($dateNaissance, function($query, $dateNaissance) {
            $query->whereDate('date_naissance', $dateNaissance);
        });
    }])
    ->orderBy('niveau')
    ->orderBy('nom')
    ->get();
    
    // Filtrer les classes qui ont des élèves correspondant aux critères
    if ($search || $classeId || $sexe || $dateNaissance) {
        $classes = $classes->filter(function($classe) {
            return $classe->eleves_count > 0;
        })->values();
    }
    
    return response()->json([
        'success' => true,
        'classes' => $classes,
        'search' => $search
    ]);
}
    /**
     * Afficher le formulaire de création
     */
    public function create()
    {
        $classes = Classe::all();
        return response()->json([
            'success' => true,
            'classes' => $classes
        ]);
    }

    /**
     * Enregistrer un nouvel élève
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'matricule' => 'required|unique:eleves,matricule',
            'nom' => 'required|string|max:255',
            'prenom' => 'required|string|max:255',
            'date_naissance' => 'required|date',
            'lieu_naissance' => 'required|string|max:255',
            'sexe' => 'required|in:M,F',
            'adresse' => 'nullable|string',
            'telephone' => 'nullable|string|max:20',
            'email' => 'nullable|email',
            'nom_parent' => 'required|string|max:255',
            'telephone_parent' => 'required|string|max:20',
            'classe_id' => 'required|exists:classes,id',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            Log::error('Erreur validation élève:', $validator->errors()->toArray());
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();

        try {
            $eleve = new Eleve($request->except('photo'));
            
            if ($request->hasFile('photo')) {
                $path = $request->file('photo')->store('eleves/photos', 'public');
                $eleve->photo = $path;
            }

            $eleve->save();
            
            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Élève inscrit avec succès.',
                'eleve' => $eleve
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Erreur lors de l\'inscription de l\'élève: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Une erreur est survenue lors de l\'inscription: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Afficher les élèves par classe
     */
     public function byClasse($classeId)
    {
        $classe = Classe::with(['eleves' => function($query) {
            $query->orderBy('nom')->orderBy('prenom');
        }])->findOrFail($classeId);
        
        $classes = Classe::withCount('eleves')->get();
        
        return response()->json([
            'success' => true,
            'classe' => $classe,
            'classes' => $classes
        ]);
    }

    /**
 * Importer des élèves via fichier CSV/Excel simple
 */
    /**
     * Importer des élèves via fichier CSV
     */
    public function import(Request $request)
    {
        $request->validate([
            'fichier_excel' => 'required|file|mimes:csv,txt'
        ]);

        DB::beginTransaction();

        try {
            $file = $request->file('fichier_excel');
            $filePath = $file->getRealPath();
            
            // Lire le fichier en tant que CSV
            $data = $this->readCSV($filePath);
            
            if (count($data) < 1) {
                throw new \Exception("Le fichier est vide ou mal formaté.");
            }

            // Traiter les données
            $importedCount = 0;
            $errors = [];
            
            // Detecter si la première ligne est un entête
            $header = $data[0];
            $startIndex = $this->isHeaderRow($header) ? 1 : 0;

            for ($i = $startIndex; $i < count($data); $i++) {
                $row = $data[$i];
                // Skip empty rows
                if (empty(array_filter($row))) continue;

                try {
                    $this->createEleveFromRow($row);
                    $importedCount++;
                } catch (\Exception $e) {
                    $errors[] = "Ligne " . ($i + 1) . ": " . $e->getMessage();
                }
            }
            
            DB::commit();
            
            $message = $importedCount . " élève(s) importé(s) avec succès.";
            if (!empty($errors)) {
                $message .= " Erreurs: " . implode(', ', $errors);
            }
            
            return response()->json([
                'success' => true,
                'message' => $message
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Erreur lors de l\'importation: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'importation: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Lire un fichier CSV de manière robuste
     */
    private function readCSV($filePath)
    {
        $data = [];
        if (($handle = fopen($filePath, 'r')) !== false) {
            while (($row = fgetcsv($handle, 1000, ',')) !== false) {
                $data[] = $row;
            }
            fclose($handle);
        }
        return $data;
    }

    /**
     * Vérifier si c'est une ligne d'en-tête
     */
    private function isHeaderRow($row)
    {
        if (empty($row)) return false;
        
        $headerKeywords = ['matricule', 'nom', 'prenom', 'classe', 'date', 'naissance', 'sexe'];
        $rowString = strtolower(implode(' ', $row));
        
        foreach ($headerKeywords as $keyword) {
            if (strpos($rowString, $keyword) !== false) {
                return true;
            }
        }
        
        return false;
    }

/**
 * Créer un élève à partir d'une ligne de données
 */
private function createEleveFromRow($row)
{
    // Adaptez cette méthode selon le format de votre fichier
    $data = [
        'matricule' => $row[0] ?? null,
        'nom' => $row[1] ?? '',
        'prenom' => $row[2] ?? '',
        'date_naissance' => $row[3] ?? '',
        'lieu_naissance' => $row[4] ?? '',
        'sexe' => $row[5] ?? '',
        'adresse' => $row[6] ?? null,
        'telephone' => $row[7] ?? null,
        'email' => $row[8] ?? null,
        'nom_parent' => $row[9] ?? '',
        'telephone_parent' => $row[10] ?? '',
        'classe' => $row[11] ?? '',
    ];
    
    $classe = Classe::where('nom', $data['classe'])->first();
    
    if (!$classe) {
        throw new \Exception("Classe '{$data['classe']}' non trouvée");
    }
    
    $eleve = new Eleve([
        'matricule' => $data['matricule'] ?? $this->generateMatricule(),
        'nom' => $data['nom'],
        'prenom' => $data['prenom'],
        'date_naissance' => $this->parseDate($data['date_naissance']),
        'lieu_naissance' => $data['lieu_naissance'],
        'sexe' => strtoupper($data['sexe']),
        'adresse' => $data['adresse'],
        'telephone' => $data['telephone'],
        'email' => $data['email'],
        'nom_parent' => $data['nom_parent'],
        'telephone_parent' => $data['telephone_parent'],
        'classe_id' => $classe->id,
    ]);
    
    $eleve->save();
}

public function edit(Eleve $eleve)
    {
        $classes = Classe::all();
        return response()->json([
            'success' => true,
            'eleve' => $eleve,
            'classes' => $classes
        ]);
    }
     public function update(Request $request, Eleve $eleve)
    {
        $validator = Validator::make($request->all(), [
            'matricule' => 'required|unique:eleves,matricule,' . $eleve->id,
            'nom' => 'required|string|max:255',
            'prenom' => 'required|string|max:255',
            'date_naissance' => 'required|date',
            'lieu_naissance' => 'required|string|max:255',
            'sexe' => 'required|in:M,F',
            'adresse' => 'nullable|string',
            'telephone' => 'nullable|string|max:20',
            'email' => 'nullable|email',
            'nom_parent' => 'required|string|max:255',
            'telephone_parent' => 'required|string|max:20',
            'classe_id' => 'required|exists:classes,id',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();

        try {
            // Sauvegarder l'ancienne photo pour suppression si nécessaire
            $oldPhoto = $eleve->photo;
            
            // Mettre à jour les données de l'élève
            $eleve->fill($request->except('photo'));
            
            // Gérer la photo
            if ($request->hasFile('photo')) {
                // Supprimer l'ancienne photo si elle existe
                if ($oldPhoto && Storage::disk('public')->exists($oldPhoto)) {
                    Storage::disk('public')->delete($oldPhoto);
                }
                
                // Stocker la nouvelle photo
                $path = $request->file('photo')->store('eleves/photos', 'public');
                $eleve->photo = $path;
            }
            
            $eleve->save();
            
            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Élève modifié avec succès.',
                'eleve' => $eleve
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Erreur lors de la modification de l\'élève: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Une erreur est survenue lors de la modification: ' . $e->getMessage()
            ], 500);
        }
    }
}