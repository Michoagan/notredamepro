<?php

namespace App\Http\Controllers;

use App\Models\Eleve;
use App\Models\Tuteur;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class TuteurController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:255',
            'prenom' => 'required|string|max:255',
            'email' => 'required|email|unique:tuteurs,email',
            'telephone' => 'required|string|unique:tuteurs,telephone|regex:/^[0-9+\s()\-]{10,20}$/',
            'password' => 'required|string|min:8|confirmed|regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/',
        ], [
            'password.regex' => 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial.',
            'telephone.regex' => 'Le format du numéro de téléphone est invalide.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Normaliser le numéro de téléphone
        $telephone = preg_replace('/[^0-9]/', '', $request->telephone);

        // Vérifier si le parent est associé à au moins un élève
        $elevesAssocies = Eleve::where('email', $request->email)
            ->orWhere('telephone_parent', $request->telephone)
            ->orWhere('telephone_parent', $telephone) // Vérifier aussi le format normalisé
            ->get();

        if ($elevesAssocies->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun élève n\'est associé à ces informations. Veuillez vérifier votre email et numéro de téléphone, ou contacter l\'école.',
            ], 404);
        }

        // Vérifier que l'email n'est pas déjà utilisé (double vérification)
        if (Tuteur::where('email', $request->email)->exists()) {
            return response()->json(['success' => false, 'message' => 'Cet email est déjà utilisé.'], 409);
        }

        try {
            // Créer le compte parent
            $parent = Tuteur::create([
                'nom' => Str::title($request->nom),
                'prenom' => Str::title($request->prenom),
                'email' => Str::lower($request->email),
                'telephone' => $telephone,
                'password' => Hash::make($request->password),
            ]);

            // Associer les élèves au parent
            foreach ($elevesAssocies as $eleve) {
                $lienParente = $this->determinerLienParente($eleve, $request->nom);

                // Vérifier si l'association existe déjà
                $existingAssociation = DB::table('eleve_tuteur')
                    ->where('tuteur_id', $parent->id)
                    ->where('eleve_id', $eleve->id)
                    ->first();

                if (! $existingAssociation) {
                    DB::table('eleve_tuteur')->insert([
                        'tuteur_id' => $parent->id,
                        'eleve_id' => $eleve->id,
                        'lien_tuteur' => $lienParente,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }

            // Envoyer un email de confirmation
            // event(new ParentRegistered($parent));

            // Connecter automatiquement le parent (si nécessaire, ou juste renvoyer token)
            // Auth::guard('parent')->login($parent);

            $token = $parent->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Votre compte a été créé avec succès!',
                'access_token' => $token,
                'user' => $parent,
            ], 201);

        } catch (\Exception $e) {
            // Log l'erreur
            \Log::error('Erreur lors de l\'inscription du parent: '.$e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Une erreur s\'est produite lors de la création de votre compte. Veuillez réessayer.',
            ], 500);
        }
    }

    // Traiter la connexion
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string', // Peut être un email ou un téléphone
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        $identifiant = Str::lower($request->email);
        $telephoneFormat = preg_replace('/[^0-9]/', '', $request->email);

        // Vérifier le parent par email ou téléphone
        $parent = Tuteur::where('email', $identifiant)
            ->orWhere('telephone', $telephoneFormat)
            ->orWhere('telephone', $request->email)
            ->first();

        // Vérifier si le parent existe et si le mot de passe est correct
        if (! $parent || ! Hash::check($request->password, $parent->password)) {
            return response()->json(['success' => false, 'message' => 'Identifiant ou mot de passe incorrect.'], 401);
        }

        // Vérifier si le parent est associé à au moins un élève
        $hasStudents = DB::table('eleve_tuteur')
            ->where('tuteur_id', $parent->id)
            ->exists();

        if (! $hasStudents) {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte n\'est associé à aucun élève. Veuillez contacter l\'administration.',
            ], 403);
        }

        $token = $parent->createToken('tuteur_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Connexion réussie',
            'access_token' => $token,
            'user' => $parent,
        ]);
    }

    // Déconnexion
    public function logout(Request $request)
    {
        if ($request->user()) {
            $request->user()->currentAccessToken()->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'Vous avez été déconnecté avec succès.',
        ]);
    }

    // Déterminer le lien de parenté
    private function determinerLienParente(Eleve $eleve, $nomParent)
    {
        // Vérifier d'abord si le lien de parenté est déjà spécifié dans les données de l'élève
        if (! empty($eleve->lien_tuteur)) {
            return $eleve->lien_tuteur;
        }

        // Logique pour déterminer le lien de parenté basée sur le nom
        $nomParent = Str::lower($nomParent);
        $nomParentEleve = Str::lower($eleve->nom_parent);

        if (Str::contains($nomParentEleve, $nomParent)) {
            if (Str::contains($nomParentEleve, ['père', 'papa', 'father', 'dad'])) {
                return 'père';
            } elseif (Str::contains($nomParentEleve, ['mère', 'maman', 'mother', 'mom'])) {
                return 'mère';
            } elseif (Str::contains($nomParentEleve, ['tuteur', 'tutrice', 'guardian'])) {
                return 'tuteur';
            }
        }

        // Par défaut, on utilise "tuteur"
        return 'tuteur';
    }

    // showLinkRequestForm removed

    /**
     * Demande de réinitialisation de mot de passe (Public)
     */
    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $parent = Tuteur::where('email', $request->email)->first();

        if (! $parent) {
            // Pour sécurité, on dit quand même envoyé
            return response()->json([
                'success' => true,
                'message' => 'Si cet email existe, un code de réinitialisation a été envoyé.',
            ]);
        }

        // Générer un code à 6 chiffres
        $code = rand(100000, 999999);

        // Stocker dans password_reset_codes (table commune ou nouvelle)
        \App\Models\PasswordResetCode::updateOrCreate(
            ['email' => $request->email],
            ['code' => $code, 'created_at' => now()]
        );

        // Envoyer l'email de réinitialisation
        // Mail::to($request->email)->send(new ParentPasswordResetCode($code));
        
        // TEMPORAIRE: Log pour démo sans mailer configuré
        \Illuminate\Support\Facades\Log::info("PARENT RESET CODE pour {$parent->email}: $code");

        return response()->json([
            'success' => true,
            'message' => 'Un code de réinitialisation a été envoyé à votre adresse email.',
            'debug_code' => $code, // A RETIRER EN PROD
        ]);
    }

    /**
     * Réinitialiser le mot de passe avec le token (Public)
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'code' => 'required|numeric',
            'password' => 'required|string|min:8|confirmed|regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/',
        ], [
            'password.regex' => 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial.',
        ]);

        $resetEntry = \App\Models\PasswordResetCode::where('email', $request->email)
            ->where('code', $request->code)
            ->first();

        if (! $resetEntry || $resetEntry->created_at->addMinutes(15)->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'Code invalide ou expiré.',
            ], 400);
        }

        $parent = Tuteur::where('email', $request->email)->firstOrFail();
        $parent->password = Hash::make($request->password);
        $parent->save();

        // Supprimer le code utilisé
        $resetEntry->delete();

        return response()->json([
            'success' => true,
            'message' => 'Votre mot de passe a été réinitialisé avec succès. Vous pouvez vous connecter.',
        ]);
    }

    /**
     * Changer le mot de passe (Authentifié)
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required',
            'new_password' => 'required|string|min:8|regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/',
        ], [
            'new_password.regex' => 'Le nouveau mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial.',
        ]);

        $parent = Auth::user();

        if (! Hash::check($request->current_password, $parent->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Le mot de passe actuel est incorrect.',
            ], 400);
        }

        $parent->password = Hash::make($request->new_password);
        $parent->save();

        return response()->json([
            'success' => true,
            'message' => 'Mot de passe modifié avec succès.',
        ]);
    }

    public function dashboard()
    {
        // Récupérer le parent connecté via Sanctum
        $parent = Auth::user();

        // Récupérer les élèves associés à ce parent
        $eleves = Eleve::whereHas('tuteurs', function ($query) use ($parent) {
            $query->where('tuteur_id', $parent->id);
        })->with(['classe'])->get();

        $elevesData = $eleves->map(function ($eleve) {
            // 1. Dernières Notes
            $notes = \App\Models\Note::where('eleve_id', $eleve->id)
                ->with(['matiere'])
                ->orderBy('updated_at', 'desc')
                ->take(3)
                ->get()
                ->map(function ($note) {
                    $type = 'Évaluation';
                    $valeur = 0;
                    if (!is_null($note->deuxieme_devoir)) { $type = 'Devoir 2'; $valeur = $note->deuxieme_devoir; }
                    elseif (!is_null($note->premier_devoir)) { $type = 'Devoir 1'; $valeur = $note->premier_devoir; }
                    elseif (!is_null($note->quatrieme_interro)) { $type = 'Interro 4'; $valeur = $note->quatrieme_interro; }
                    elseif (!is_null($note->troisieme_interro)) { $type = 'Interro 3'; $valeur = $note->troisieme_interro; }
                    elseif (!is_null($note->deuxieme_interro)) { $type = 'Interro 2'; $valeur = $note->deuxieme_interro; }
                    elseif (!is_null($note->premier_interro)) { $type = 'Interro 1'; $valeur = $note->premier_interro; }

                    return [
                        'matiere' => $note->matiere ? $note->matiere->nom : 'Mat. Générale',
                        'type' => $type,
                        'note' => (float)$valeur,
                        'date' => $note->updated_at->format('d M'),
                    ];
                });

            // 2. Présences
            $presences = \App\Models\Presence::where('eleve_id', $eleve->id)->get();
            $totalJours = $presences->count();
            $joursPresents = $presences->where('present', true)->count();
            $tauxPresence = $totalJours > 0 ? ($joursPresents / $totalJours) * 100 : 100;

            // 3. Finances
            $contribution = $eleve->classe ? $eleve->classe->cout_contribution : 0;
            $paiements = \App\Models\Paiement::where('eleve_id', $eleve->id)
                ->where('statut', 'success')
                ->sum('montant');
            $soldeRestant = max(0, $contribution - $paiements);

            // Structure de l'élève
            $eleveArray = $eleve->toArray();
            $eleveArray['classe'] = $eleve->classe;
            $eleveArray['recent_notes'] = $notes;
            $eleveArray['taux_presence'] = round($tauxPresence, 1);
            $eleveArray['solde_restant'] = $soldeRestant;

            return $eleveArray;
        });

        // Récupérer les événements (Communiques) récents
        $evenements = \App\Models\Communique::where('is_published', true)
            ->orderBy('published_at', 'desc')
            ->take(5)
            ->get();

        return response()->json([
            'success' => true,
            'parent' => [ // Envoyer les infos du parent pour l'UI
                'nom' => $parent->nom,
                'prenom' => $parent->prenom,
                'email' => $parent->email,
            ],
            'eleves' => $elevesData,
            'evenements' => $evenements,
        ]);
    }

    public function showEleve($id)
    {
        $parent = Auth::user();

        $eleve = $parent->eleves()->with('classe')->findOrFail($id);

        // Ici, vous pouvez récupérer les notes, absences, etc. de l'élève
        return response()->json([
            'success' => true,
            'eleve' => $eleve,
        ]);
    }

    public function getNotes($id)
    {
        $parent = Auth::user();
        $eleve = $parent->eleves()->with('classe')->findOrFail($id);

        $notes = \App\Models\Note::where('eleve_id', $eleve->id)
            ->with(['matiere', 'professeur'])
            ->orderBy('updated_at', 'desc')
            ->get();

        $progression = [];
        for ($i = 1; $i <= 3; $i++) {
            $notesTrimestre = $notes->where('trimestre', $i);
            $avg = $notesTrimestre->avg('moyenne_trimestrielle');
            $progression[] = $avg ? round($avg, 2) : 0;
        }

        return response()->json([
            'success' => true,
            'eleve' => $eleve,
            'moyenne_generale' => $progression[0] != 0 ? $progression[0] : 0, // Exemple: T1
            'progression' => $progression,
            'recent_notes' => $notes->take(10)->map(function($note) {
                // Heuristique pour déterminer la note récente à afficher
                $type = 'Évaluation';
                $valeur = 0;
                if (!is_null($note->deuxieme_devoir)) { $type = 'Devoir 2'; $valeur = $note->deuxieme_devoir; }
                elseif (!is_null($note->premier_devoir)) { $type = 'Devoir 1'; $valeur = $note->premier_devoir; }
                elseif (!is_null($note->quatrieme_interro)) { $type = 'Interro 4'; $valeur = $note->quatrieme_interro; }
                elseif (!is_null($note->troisieme_interro)) { $type = 'Interro 3'; $valeur = $note->troisieme_interro; }
                elseif (!is_null($note->deuxieme_interro)) { $type = 'Interro 2'; $valeur = $note->deuxieme_interro; }
                elseif (!is_null($note->premier_interro)) { $type = 'Interro 1'; $valeur = $note->premier_interro; }

                return [
                    'matiere' => $note->matiere ? $note->matiere->nom : 'Mat. Générale',
                    'type' => $type,
                    'note' => (float)$valeur,
                    'date' => $note->updated_at->format('d M'),
                    'commentaire' => $note->commentaire,
                ];
            })->values(),
        ]);
    }

    public function contact(Request $request)
    {
        $request->validate([
            'sujet' => 'required|string|max:100',
            'message' => 'required|string|max:1000',
        ]);

        $parent = Auth::user();

        // Enregistrer la plainte ou le message dans la base de données
        // Ou bien l'envoyer par email à l'administration.
        // Ici on simule une réponse de succès. 
        \Illuminate\Support\Facades\Log::info("Message de parent {$parent->id}: {$request->sujet} - {$request->message}");

        return response()->json([
            'success' => true,
            'message' => 'Votre message a bien été envoyé à la direction.',
        ], 201);
    }

    public function getPresences($id)
    {
        $parent = Auth::user();
        $eleve = $parent->eleves()->findOrFail($id);

        $presences = \App\Models\Presence::where('eleve_id', $eleve->id)
            ->with('professeur')
            ->orderBy('date', 'desc')
            ->get();

        $totalJours = $presences->count();
        $joursPresents = $presences->where('present', true)->count();
        $tauxPresence = $totalJours > 0 ? ($joursPresents / $totalJours) * 100 : 100;

        return response()->json([
            'success' => true,
            'eleve' => $eleve,
            'taux_presence' => round($tauxPresence, 1),
            'presences' => $presences->take(15)->map(function($p) {
                return [
                    'date' => \Carbon\Carbon::parse($p->date)->format('Y-m-d'),
                    'present' => $p->present,
                    'motif' => $p->present ? 'Présent' : 'Absent',
                    'matiere' => $p->professeur ? 'Cours avec ' . $p->professeur->nom : 'Cours', // Mock si cours_id non défini
                ];
            })->values(),
        ]);
    }
}
