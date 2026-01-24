<?php

namespace App\Http\Controllers;

use App\Models\Professeur;
use App\Models\Classe;
use App\Models\Matiere;
use App\Models\Eleve;
use App\Models\Direction;
use App\Models\PasswordResetCode;
use App\Models\Note;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use App\Notifications\ProfessorAccountCreatedNotification;
use App\Notifications\PasswordResetCodeNotification;

class ProfesseurController extends Controller
{
    // public function create() removed


    public function store(Request $request)
{
    $validated = $request->validate([
        'last_name' => 'required|string|max:255',
        'first_name' => 'required|string|max:255',
        'gender' => 'required|in:M,F',
        'birth_date' => 'required|date|before:-18 years',
        'email' => 'required|email|unique:professeurs,email',
        'phone' => 'required|string|max:20',
        'matiere' => 'required|string|max:255',
        'photo' => 'required|image|mimes:jpg,jpeg,png|max:2048'
    ]);

    $personalCode = strtoupper(substr($validated['last_name'], 0, 5)) . rand(1000, 9999);
    
    // Gérer l'upload de la photo
    if ($request->hasFile('photo')) {
        $photo = $request->file('photo');
        $photoName = 'prof_' . time() . '_' . Str::slug($validated['last_name']) . '.' . $photo->getClientOriginalExtension();
        
        // Stocker l'image dans storage/app/public/professeurs
        $photoPath = $photo->storeAs('professeurs', $photoName, 'public');
    }

    // Créer le professeur
    $professeur = Professeur::create([
        'last_name' => $validated['last_name'],
        'first_name' => $validated['first_name'],
        'gender' => $validated['gender'],
        'birth_date' => $validated['birth_date'],
        'email' => $validated['email'],
        'phone' => $validated['phone'],
        'matiere' => $validated['matiere'],
        'photo' => $photoName, // Stocker seulement le nom du fichier
        'personal_code' => Hash::make($personalCode), // Stocker le hash en base
    ]);

    // Envoyer la notification avec le code personnel EN CLAIR
    $professeur->notify(new ProfessorAccountCreatedNotification($professeur, $personalCode));
    
    // Réponse JSON au lieu de redirect
    return response()->json([
        'success' => true,
        'message' => 'Professeur inscrit avec succès! Un email avec le code personnel a été envoyé.',
        'data' => $professeur
    ], 201);
}

    /**
     * Afficher la liste des professeurs
     */
   // Dans votre méthode index() ou show() du contrôleur
public function index()
{
    try {
        $classes = Classe::with([
            'professeurPrincipal',
            'matieres.professeur', // Charger le professeur pour chaque matière
            'eleves' // Si vous avez une relation avec les élèves
        ])
        ->withCount('eleves')
        ->orderBy('niveau')
        ->orderBy('nom')
        ->get();
        
        return response()->json([
            'success' => true,
            'classes' => $classes
        ]);
    } catch (\Exception $e) {
        Log::error('Erreur lors de la récupération des classes: ' . $e->getMessage());
        return response()->json([
            'success' => false,
            'message' => 'Une erreur est survenue lors du chargement des classes.'
        ], 500);
    }
}

    /**
     * Afficher le formulaire de modification
     */
    // public function edit(Professeur $professeur) removed


    /**
     * Mettre à jour un professeur
     */
   

    /**
     * Supprimer un professeur
     */
    public function destroy(Professeur $professeur)
    {
        try {
            // Supprimer la photo
            if ($professeur->photo) {
                Storage::disk('public')->delete('professeurs/' . $professeur->photo);
            }

            $professeur->delete();

            return response()->json([
                'success' => true,
                'message' => 'Professeur supprimé avec succès!'
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur suppression professeur: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression: ' . $e->getMessage()
            ], 500);
        }
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
            'email' => 'nullable|email|unique:eleves,email,' . $eleve->id,
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
                'message' => 'Élève modifié avec succès'
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Erreur lors de la modification de l\'élève: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Une erreur est survenue lors de la modification.'
            ], 500);
        }
    }
    // showLoginForm() removed


    public function login(Request $request)
    {
        // Removed session check for API


        $request->validate([
            'email' => 'required|email',
            'personal_code' => 'required|string',
        ]);

        $credentials = $request->only('email', 'personal_code');

        // Vérifier si le professeur existe avec cet email
        $professeur = Professeur::where('email', $credentials['email'])->first();

        if (!$professeur) {
            return back()->withErrors([
                'email' => 'Aucun professeur trouvé avec cet email.',
            ])->withInput();
        }

        // Vérifier le code personnel
        // Vérifier le code personnel
        if (!Hash::check($credentials['personal_code'], $professeur->personal_code)) {
             return response()->json([
                'success' => false,
                'message' => 'Code personnel incorrect.',
            ], 401);
        }

        // Créer un token Sanctum
        $token = $professeur->createToken('professeur_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Connexion réussie',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $professeur
        ]);
    }
     public function logout()
    {
        // Révoquer le token actuel
        if (Auth::guard('sanctum')->check()) {
            Auth::guard('sanctum')->user()->currentAccessToken()->delete();
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Déconnexion réussie'
        ]);
    }

    public function dashboard()
    {
        // Auth via Sanctum
        $professeur = Auth::user();
        // ...

    
    // Charger les classes avec les élèves
    $professeur->load(['classes.eleves' => function($query) {
        $query->orderBy('nom')->orderBy('prenom');
    }]);
    
    // Récupérer les statistiques
    $stats = [
        'classes_count' => $professeur->classes->count(),
        'eleves_count' => $professeur->classes->sum(function($classe) {
            return $classe->eleves->count();
        }),
        'cours_semaine' => 8 // Exemple statique
    ];

    return response()->json([
        'professeur',
        'stats'
    ]);
}

    public function matieresParClasse($classeId)
    {
        $professeur = Auth::user();
        
        // Vérifier que c'est bien un professeur
        if (!$professeur instanceof Professeur) {
             return response()->json(['error' => 'Non autorisé'], 403);
        }
        // ...

    
    // Vérifier que le professeur a accès à cette classe
    if (!$professeur->classes->contains($classeId)) {
        return response()->json(['error' => 'Accès non autorisé'], 403);
    }
    
    $classe = Classe::with(['matieres' => function($query) {
        $query->orderBy('pivot_ordre_affichage');
    }])->findOrFail($classeId);
    
    return response()->json([
        'matieres' => $classe->matieres
    ]);
}

// Dans la classe ProfesseurController

    public function analyseNotes(Request $request)
    {
        $professeur = Auth::user();
        
        if (!$professeur instanceof Professeur) {
             return response()->json(['error' => 'Non autorisé'], 403);
        }

    
    // Charger les classes avec leurs matières enseignées par ce professeur
    $professeur->load(['classes' => function($query) use ($professeur) {
        $query->with(['matieres' => function($q) use ($professeur) {
            $q->wherePivot('professeur_id', $professeur->id)
              ->orderBy('pivot_ordre_affichage');
        }])->withCount('eleves');
    }]);
    
    $eleve_selectionne = null;
    $analyse_data = null;
    $classe_selectionnee = null;
    $matiere_selectionnee = null;
    $eleves = collect();
    
    // Charger les élèves si une classe est sélectionnée
    if ($request->has('classe_id')) {
        $classe_selectionnee = $professeur->classes->firstWhere('id', $request->classe_id);
        
        if ($classe_selectionnee) {
            // Charger les élèves de cette classe
            $eleves = $classe_selectionnee->eleves()->orderBy('nom')->orderBy('prenom')->get();
        }
    }
    
    // Si un élève est sélectionné
    if ($request->has('eleve_id') && $request->has('classe_id') && $request->has('matiere_id')) {
        $classe_selectionnee = $professeur->classes->firstWhere('id', $request->classe_id);
        $matiere_selectionnee = Matiere::find($request->matiere_id);
        $eleve_selectionne = Eleve::find($request->eleve_id);
        
        if ($classe_selectionnee && $matiere_selectionnee && $eleve_selectionne) {
            $analyse_data = $this->getAnalyseNotesEleve(
                $eleve_selectionne->id,
                $classe_selectionnee->id,
                $matiere_selectionnee->id,
                $professeur->id
            );
        }
    }
    
    return response()->json( [   
        'professeur',
        'eleve_selectionne',
        'analyse_data',
        'classe_selectionnee',
        'matiere_selectionnee',
        'eleves'
    ]);
}

private function getAnalyseNotesEleve($eleveId, $classeId, $matiereId, $professeurId)
{
    try {
        // Récupérer toutes les notes de l'élève pour cette matière sur les 3 trimestres
        $notes = Note::where('eleve_id', $eleveId)
            ->where('classe_id', $classeId)
            ->where('matiere_id', $matiereId)
            ->where('professeur_id', $professeurId)
            ->orderBy('trimestre')
            ->get();
        
        if ($notes->isEmpty()) {
            return null;
        }
        
        // Préparer les données pour les graphiques
        $data = [
            'trimestres' => [],
            'moyennes_eleve' => [],
            'moyennes_classe' => [],
            'notes_interros' => [],
            'notes_devoirs' => [],
            'statistiques' => []
        ];
        
        // Récupérer les moyennes de classe pour comparaison
        $moyennes_classe = Note::where('classe_id', $classeId)
            ->where('matiere_id', $matiereId)
            ->where('professeur_id', $professeurId)
            ->select('trimestre', DB::raw('AVG(moyenne_trimestrielle) as moyenne'))
            ->groupBy('trimestre')
            ->orderBy('trimestre')
            ->get()
            ->keyBy('trimestre');
        
        // Préparer les données par trimestre
        foreach ([1, 2, 3] as $trimestre) {
            $note_trimestre = $notes->firstWhere('trimestre', $trimestre);
            
            if ($note_trimestre) {
                $data['trimestres'][] = "Trimestre $trimestre";
                $data['moyennes_eleve'][] = $note_trimestre->moyenne_trimestrielle;
                $data['moyennes_classe'][] = $moyennes_classe->get($trimestre)->moyenne ?? 0;
                
                // Collecter les notes détaillées
                $notes_interro = array_filter([
                    $note_trimestre->premier_interro,
                    $note_trimestre->deuxieme_interro,
                    $note_trimestre->troisieme_interro,
                    $note_trimestre->quatrieme_interro
                ]);
                
                $notes_devoir = array_filter([
                    $note_trimestre->premier_devoir,
                    $note_trimestre->deuxieme_devoir
                ]);
                
                $data['notes_interros'] = array_merge($data['notes_interros'], $notes_interro);
                $data['notes_devoirs'] = array_merge($data['notes_devoirs'], $notes_devoir);
            }
        }
        
        // Calculer les statistiques
        $toutes_notes = array_merge($data['notes_interros'], $data['notes_devoirs']);
        
        if (!empty($toutes_notes)) {
            $data['statistiques'] = [
                'moyenne_generale' => array_sum($toutes_notes) / count($toutes_notes),
                'meilleure_note' => max($toutes_notes),
                'pire_note' => min($toutes_notes),
                'nombre_notes' => count($toutes_notes),
                'tendance' => $this->calculerTendance($data['moyennes_eleve'])
            ];
        }
        
        // Générer les recommandations
        $data['recommandations'] = $this->genererRecommandations($data);
        
        return $data;
        
    } catch (\Exception $e) {
        Log::error('Erreur analyse notes élève: ' . $e->getMessage());
        return null;
    }
}

private function calculerTendance($moyennes)
{
    if (count($moyennes) < 2) {
        return 'stable';
    }
    
    $derniere = end($moyennes);
    $precedente = prev($moyennes);
    
    if ($derniere > $precedente + 0.5) {
        return 'progressif';
    } elseif ($derniere < $precedente - 0.5) {
        return 'regressif';
    } else {
        return 'stable';
    }
}

private function genererRecommandations($data)
{
    $recommandations = [];
    $moyenne = $data['statistiques']['moyenne_generale'] ?? 0;
    $tendance = $data['statistiques']['tendance'] ?? 'stable';
    
    if ($moyenne >= 15) {
        $recommandations[] = "Excellentes performances! Continuez à maintenir ce niveau.";
        $recommandations[] = "Envisagez d'aider vos camarades ou d'explorer des sujets plus avancés.";
    } elseif ($moyenne >= 12) {
        $recommandations[] = "Bon travail! Vos résultats sont satisfaisants.";
        $recommandations[] = "Concentrez-vous sur la régularité pour progresser encore.";
    } elseif ($moyenne >= 10) {
        $recommandations[] = "Résultats passables. Essayez de vous exercer davantage.";
        $recommandations[] = "N'hésitez pas à poser des questions en classe.";
    } else {
        $recommandations[] = "Attention nécessaire. Vous devriez revoir les bases.";
        $recommandations[] = "Envisagez un soutien supplémentaire.";
    }
    
    if ($tendance === 'progressif') {
        $recommandations[] = "Félicitations pour votre nette progression!";
    } elseif ($tendance === 'regressif') {
        $recommandations[] = "Vos résultats ont baissé. Identifiez les difficultés et travaillez à les surmonter.";
    }
    
    return $recommandations;
}

// Méthode pour générer les graphiques en base64
private function generateCharts($analyseData)
{
    $charts = [];
    
    // Graphique 1: Évolution des moyennes (élève vs classe)
    if (!empty($analyseData['trimestres'])) {
        $charts['evolution'] = $this->generateEvolutionChart(
            $analyseData['trimestres'],
            $analyseData['moyennes_eleve'],
            $analyseData['moyennes_classe']
        );
    }
    
    // Graphique 2: Répartition des notes
    if (!empty($analyseData['notes_interros']) || !empty($analyseData['notes_devoirs'])) {
        $charts['repartition'] = $this->generateRepartitionChart(
            $analyseData['notes_interros'],
            $analyseData['notes_devoirs']
        );
    }
    
    return $charts;
}

// Méthodes pour générer les images de graphiques (implémentation basique)
private function generateEvolutionChart($trimestres, $moyennesEleve, $moyennesClasse)
{
    // Cette méthode générerait normalement une image de graphique
    // Pour cette démo, nous retournons un placeholder
    return 'data:image/svg+xml;base64,' . base64_encode('
        <svg xmlns="http://www.w3.org/2000/svg" width="400" height="200" viewBox="0 0 400 200">
            <rect width="100%" height="100%" fill="#f8f9fa"/>
            <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-family="Arial" font-size="14">
                Graphique d\'évolution des moyennes
            </text>
            <text x="50%" y="65%" dominant-baseline="middle" text-anchor="middle" font-family="Arial" font-size="12" fill="#6c757d">
                (Trimestres: ' . implode(', ', $trimestres) . ')
            </text>
        </svg>
    ');
}

private function generateRepartitionChart($notesInterros, $notesDevoirs)
{
    // Cette méthode générerait normalement une image de graphique
    return 'data:image/svg+xml;base64,' . base64_encode('
        <svg xmlns="http://www.w3.org/2000/svg" width="400" height="200" viewBox="0 0 400 200">
            <rect width="100%" height="100%" fill="#f8f9fa"/>
            <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-family="Arial" font-size="14">
                Graphique de répartition des notes
            </text>
            <text x="50%" y="65%" dominant-baseline="middle" text-anchor="middle" font-family="Arial" font-size="12" fill="#6c757d">
                (Interros: ' . count($notesInterros) . ', Devoirs: ' . count($notesDevoirs) . ')
            </text>
        </svg>
    ');
}

    public function getMatieresByClasse($classeId)
    {
        try {
            $professeur = Auth::user();
            
            $classe = Classe::with(['matieres' => function($query) use ($professeur) {
                $query->wherePivot('professeur_id', $professeur->id)
                  ->orderBy('pivot_ordre_affichage');
        }])->findOrFail($classeId);
        
        return response()->json([
            'success' => true,
            'matieres' => $classe->matieres
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Erreur lors du chargement des matières'
        ], 500);
    }
}

 /**
     * Afficher le formulaire de demande de code
     */
    public function showForgotPasswordForm()
    {
        return response()->json(['message' => 'Please use the frontend to request password reset.']);
    }

    /**
     * Générer et envoyer le code secret
     */
    public function sendResetCode(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:direction,email'
        ], [
            'email.exists' => 'Aucun compte trouvé avec cette adresse email.'
        ]);

        // Vérifier d'abord si l'utilisateur existe
        $user = Direction::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Utilisateur non trouvé.'], 404);
        }

        // Générer un code à 6 chiffres
        $code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        // Supprimer les anciens codes pour cet email
        PasswordResetCode::where('email', $request->email)->delete();

        // Créer un nouveau code avec expiration (15 minutes)
        PasswordResetCode::create([
            'email' => $request->email,
            'code' => $code,
            'created_at' => now(),
            'expires_at' => now()->addMinutes(15)
        ]);

        try {
            // Envoyer la notification avec le code
            $user->notify(new PasswordResetCodeNotification($code));

            return response()->json([
                'success' => true,
                'message' => 'Code de réinitialisation envoyé avec succès.',
                'email' => $request->email
            ]);
        } catch (\Exception $e) {
            \Log::error('Erreur envoi email: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Erreur lors de l\'envoi du code. Veuillez réessayer.'], 500);
        }
    }

    /**
     * Afficher le formulaire de vérification du code
     */
    public function showVerifyCodeForm()
    {
        return response()->json(['message' => 'Please use the frontend to verify code.']);
    }

    /**
     * Vérifier le code secret
     */
    public function verifyResetCode(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'code' => 'required|string|size:6'
        ]);

        $resetCode = PasswordResetCode::where('email', $request->email)
            ->where('code', $request->code)
            ->where('expires_at', '>', now())
            ->first();

        if (!$resetCode) {
            return response()->json(['success' => false, 'message' => 'Code invalide ou expiré.'], 400);
        }

        // Code valide
        return response()->json([
            'success' => true,
            'message' => 'Code valide.',
            'email' => $request->email,
            'code' => $request->code
        ]);
    }

    /**
     * Afficher le formulaire de réinitialisation
     */
    public function showResetForm(Request $request)
    {
        return response()->json(['message' => 'Please use the frontend to reset password.']);
    }

    /**
     * Réinitialiser le mot de passe
     */
   /**
 * Réinitialiser le mot de passe
 */
/**
 * Réinitialiser le mot de passe (personal_code)
 */
/**
 * Réinitialiser le personal_code (mot de passe)
 */
public function resetPassword(Request $request)
{
    \Log::info('=== DÉBUT RÉINITIALISATION ===');
    \Log::info('Données reçues:', $request->all());

    $request->validate([
        'email' => 'required|email',
        'code' => 'required|string|size:6',
        'personal_code' => ['required', 'confirmed', 'min:6'], // Ajout de confirmed et min
    ], [
        'personal_code.confirmed' => 'La confirmation du code personnel ne correspond pas.',
        'personal_code.min' => 'Le code personnel doit contenir au moins 6 caractères.'
    ]);

    // Vérifier à nouveau le code
    $resetCode = PasswordResetCode::where('email', $request->email)
        ->where('code', $request->code)
        ->where('expires_at', '>', now())
        ->first();

    \Log::info('Code de reset trouvé:', ['exists' => !!$resetCode]);

    if (!$resetCode) {
        \Log::warning('Code invalide ou expiré');
        return response()->json(['success' => false, 'message' => 'Code invalide ou expiré.'], 400);
    }

    // Trouver l'utilisateur
    $user = Professeur::where('email', $request->email)->first();
    \Log::info('Utilisateur trouvé:', ['exists' => !!$user, 'id' => $user?->id]);

    if ($user) {
        // Avant la mise à jour
        \Log::info('Avant mise à jour - personal_code actuel:', ['current_code' => $user->personal_code]);
        
        try {
            // Mettre à jour le personal_code
            $user->update([
                'personal_code' => Hash::make($request->personal_code)
            ]);

            // Recharger l'utilisateur pour vérifier
            $user->refresh();
            \Log::info('Après mise à jour - personal_code nouveau:', ['new_code' => $user->personal_code]);

            // Vérifier si le hash correspond
            $isValid = Hash::check($request->personal_code, $user->personal_code);
            \Log::info('Vérification hash:', ['is_valid' => $isValid]);

            // Supprimer le code utilisé
            PasswordResetCode::where('email', $request->email)->delete();

            \Log::info('=== RÉINITIALISATION RÉUSSIE ===');

            // Rediriger avec un message de succès
            return response()->json([
                'success' => true,
                'message' => 'Code personnel réinitialisé avec succès. Vous pouvez maintenant vous connecter.'
            ]);

        } catch (\Exception $e) {
            \Log::error('Erreur lors de la mise à jour: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Erreur lors de la mise à jour: ' . $e->getMessage()], 500);
        }
    }

    \Log::error('Utilisateur non trouvé');
    return response()->json(['success' => false, 'message' => 'Utilisateur non trouvé.'], 404);
}

    /**
     * Renvoyer un nouveau code
     */
    public function resendCode(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:direction,email'
        ]);

        // Vérifier si l'utilisateur existe
        $user = Direction::where('email', $request->email)->first();
        
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Utilisateur non trouvé.'], 404);
        }

        // Générer un nouveau code
        $code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        // Supprimer les anciens codes
        PasswordResetCode::where('email', $request->email)->delete();

        // Créer le nouveau code
        PasswordResetCode::create([
            'email' => $request->email,
            'code' => $code,
            'created_at' => now(),
            'expires_at' => now()->addMinutes(15)
        ]);

        try {
            // Envoyer la notification
            $user->notify(new PasswordResetCodeNotification($code));

            return response()->json([
                'success' => true,
                'message' => 'Nouveau code envoyé avec succès.'
            ]);
        } catch (\Exception $e) {
            \Log::error('Erreur envoi email: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Erreur lors de l\'envoi du code.'], 500);
        }
    }


}