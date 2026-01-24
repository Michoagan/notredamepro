<?php

namespace App\Http\Controllers;

use App\Models\Eleve;
use App\Models\ParentModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class TuteurController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:255',
            'prenom' => 'required|string|max:255',
            'email' => 'required|email|unique:parents,email',
            'telephone' => 'required|string|unique:parents,telephone|regex:/^[0-9+\s()\-]{10,20}$/',
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
        $elevesAssocies = Eleve::where('email_parent', $request->email)
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
        if (ParentModel::where('email', $request->email)->exists()) {
            return response()->json(['success' => false, 'message' => 'Cet email est déjà utilisé.'], 409);
        }

        try {
            // Créer le compte parent
            $parent = ParentModel::create([
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
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        $credentials = $request->only('email', 'password');
        $remember = $request->has('remember');

        // Vérifier le parent
        $parent = ParentModel::where('email', $request->email)->first();

        // Vérifier si le parent existe et si le mot de passe est correct
        if (! $parent || ! Hash::check($request->password, $parent->password)) {
            return response()->json(['success' => false, 'message' => 'Identifiants incorrects.'], 401);
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

    // Méthode pour traiter la demande de réinitialisation
    public function sendResetLinkEmail(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        // Vérifier que l'email appartient à un parent
        $parent = ParentModel::where('email', $request->email)->first();

        if (! $parent) {
            return response()->json(['success' => false, 'message' => 'Aucun compte parent trouvé avec cet email.'], 404);
        }

        // Générer et enregistrer un token de réinitialisation
        $token = Str::random(60);
        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $request->email],
            ['token' => Hash::make($token), 'created_at' => now()]
        );

        // Envoyer l'email de réinitialisation
        // Mail::to($request->email)->send(new ParentPasswordReset($token));

        return response()->json([
            'success' => true,
            'message' => 'Un lien de réinitialisation a été envoyé à votre adresse email.',
        ]);
    }

    public function dashboard()
    {
        // Récupérer le parent connecté via Sanctum
        $parent = Auth::user();

        // Récupérer les élèves associés à ce parent
        $eleves = Eleve::whereHas('tuteurs', function ($query) use ($parent) {
            $query->where('tuteur_id', $parent->id);
        })->with(['notes' => function ($query) {
            $query->orderBy('created_at', 'desc')->take(3);
        }])->get();

        // Récupérer les notes récentes pour tous les enfants
        $recentNotes = Note::whereIn('eleve_id', $eleves->pluck('id'))
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get();

        // Récupérer les événements à venir
        $evenements = Evenement::where('date', '>=', now())
            ->orderBy('date', 'asc')
            ->take(5)
            ->get();

        return response()->json([
            'success' => true,
            'eleves' => $eleves,
            'recentNotes' => $recentNotes,
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
    //
}
