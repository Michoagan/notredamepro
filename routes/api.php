<?php

use App\Http\Controllers\AdminDirectionController;
use App\Http\Controllers\BulletinController;
use App\Http\Controllers\ClasseController;
use App\Http\Controllers\DirectionController;
use App\Http\Controllers\ConduiteController;
use App\Http\Controllers\EleveController;
use App\Http\Controllers\NoteController;
use App\Http\Controllers\PaiementController;
use App\Http\Controllers\ProfesseurController;
use App\Http\Controllers\SurveillantController;
use App\Http\Controllers\TuteurController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// =============================================
// ROUTES PUBLIQUES (Auth & Public Data)
// =============================================

Route::get('/', function () {
    return response()->json(['message' => 'NDTG API is running']);
});

// Admin Auth (Users Table)
Route::prefix('admin')->group(function () {
    Route::post('/login', [\App\Http\Controllers\AdminAuthController::class, 'login']);
    Route::post('/register', [\App\Http\Controllers\AdminAuthController::class, 'register']);

    Route::middleware('auth:sanctum')->post('/logout', [\App\Http\Controllers\AdminAuthController::class, 'logout']);
});

// Direction Auth
Route::prefix('direction')->group(function () {
    Route::post('/login', [DirectionController::class, 'login']);
    Route::post('/register', [DirectionController::class, 'register']);

    // Password Reset
    Route::post('/forgot-password', [DirectionController::class, 'sendResetCode']);
    Route::post('/verify-code', [DirectionController::class, 'verifyResetCode']);
    Route::post('/reset-password', [DirectionController::class, 'resetPassword']);
    Route::post('/resend-code', [DirectionController::class, 'resendCode']);
});

// Professeur Auth
Route::prefix('professeur')->group(function () {
    Route::post('/login', [ProfesseurController::class, 'login']);
    Route::post('/inscrit', [ProfesseurController::class, 'store']); // Inscription
    
    // Password/Code Reset
    Route::post('/forgot-code', [ProfesseurController::class, 'forgotCode']);
    Route::post('/reset-code', [ProfesseurController::class, 'resetCode']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::prefix('professeur')->group(function () {
        Route::post('/change-code', [ProfesseurController::class, 'changeCode']);
        Route::get('/mes-paiements', [ProfesseurController::class, 'mesPaiements']);
    });
});

// Parent Auth
Route::prefix('parent')->group(function () {
    Route::post('/login', [TuteurController::class, 'login']);
    Route::post('/register', [TuteurController::class, 'register']);
    
    // Password Reset (Public)
    Route::post('/forgot-password', [TuteurController::class, 'forgotPassword']);
    Route::post('/reset-password', [TuteurController::class, 'resetPassword']);
});

// =============================================
// ROUTES PROTÉGÉES (SANCTUM)
// =============================================

Route::middleware('auth:sanctum')->group(function () {

    // User Info
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // ====================
    // DIRECTION & ADMIN
    // ====================
    Route::prefix('direction')->group(function () {
        Route::post('/logout', [DirectionController::class, 'logout']);

        // Notifications
        Route::get('/notifications', [DirectionController::class, 'notifications']);
        Route::post('/notifications/mark-all-read', [DirectionController::class, 'markAllNotificationsAsRead']);
        Route::post('/notifications/{id}/read', [DirectionController::class, 'markNotificationAsRead']);

        // COMPTABILITÉ & INVENTAIRE
        Route::prefix('comptabilite')->group(function () {
            // Dashboard Comptable
            Route::get('/dashboard', [\App\Http\Controllers\ComptabiliteController::class, 'dashboard']); // Entrées vs Sorties

            // Dépenses (Sorties)
            Route::get('/depenses', [\App\Http\Controllers\ComptabiliteController::class, 'index']);
            Route::post('/depenses', [\App\Http\Controllers\ComptabiliteController::class, 'storeDepense']);

            // Les paiements et ventes ont été déplacés vers le prefix 'caisse'.

            // Salaires
            Route::get('/salaires', [\App\Http\Controllers\ComptabiliteController::class, 'salaires']);
            Route::post('/salaires/generate', [\App\Http\Controllers\ComptabiliteController::class, 'generateSalaires']);
            Route::post('/salaires/{id}/payer', [\App\Http\Controllers\ComptabiliteController::class, 'payerSalaire']);
            
            // Paie Professeurs (Nouveau module basé sur Cahier de Texte)
            Route::get('/paie-professeurs/config', [\App\Http\Controllers\Comptabilite\PaieProfesseurController::class, 'getConfiguration']);
            Route::post('/paie-professeurs/config', [\App\Http\Controllers\Comptabilite\PaieProfesseurController::class, 'saveConfiguration']);
            Route::post('/paie-professeurs/generer', [\App\Http\Controllers\Comptabilite\PaieProfesseurController::class, 'genererPaie']);

            // Tranches de Scolarité
            Route::get('/tranches-scolarite', [\App\Http\Controllers\TrancheScolariteController::class, 'index']);
            Route::post('/tranches-scolarite', [\App\Http\Controllers\TrancheScolariteController::class, 'storeOrUpdate']);

            // Inventaire (Articles & Stock)
            Route::get('/articles', [\App\Http\Controllers\InventaireController::class, 'index']); // Liste articles + stock
            Route::post('/articles', [\App\Http\Controllers\InventaireController::class, 'store']); // Créer article
            Route::put('/articles/{article}', [\App\Http\Controllers\InventaireController::class, 'update']);
            Route::post('/articles/{article}/stock', [\App\Http\Controllers\InventaireController::class, 'addStock']); // Approvisionnement
            Route::post('/articles/{article}/correction', [\App\Http\Controllers\InventaireController::class, 'correctStock']); // Inventaire physique
            Route::get('/articles/{article}/historique', [\App\Http\Controllers\InventaireController::class, 'history']); // Mouvements
        });

        // CAISSE (Trésorerie)
        Route::prefix('caisse')->group(function () {
            // Dashboard Caisse
            Route::get('/dashboard', [\App\Http\Controllers\CaisseController::class, 'dashboard']);

            // Ventes (Autres Recettes)
            Route::post('/ventes', [\App\Http\Controllers\CaisseController::class, 'storeVente']);

            // Paiements Scolarité
            Route::get('/paiements', [\App\Http\Controllers\CaisseController::class, 'indexPaiements']);
            Route::post('/paiements', [\App\Http\Controllers\CaisseController::class, 'storePaiement']);
            Route::get('/paiements/{paiement}/receipt', [\App\Http\Controllers\CaisseController::class, 'downloadReceipt']);
        });

        // Tableaux de bord (JSON expected from controllers)
        Route::get('/censeur', [DirectionController::class, 'censeurDashboard']);
        Route::get('/directeur', [DirectionController::class, 'directeurDashboard']);

        // Settings Update (Direction only)
        Route::post('/settings', [\App\Http\Controllers\SettingsController::class, 'update']);
    });

    // Global Settings (Readable by all authenticated users: Direction, Censeur, Professeur, Secretaire, Parent)
    Route::get('/settings', [\App\Http\Controllers\SettingsController::class, 'index']);

    Route::prefix('admin')->group(function () {
        Route::get('/dashboard', [AdminDirectionController::class, 'dashboard']);
        Route::get('/pending-accounts', [AdminDirectionController::class, 'pendingAccounts']);
        Route::get('/all-accounts', [AdminDirectionController::class, 'allAccounts']);
        Route::post('/users', [AdminDirectionController::class, 'store']); // Create User
        Route::post('/account/{id}/approve', [AdminDirectionController::class, 'approveAccount']);
        Route::post('/account/{id}/reject', [AdminDirectionController::class, 'rejectAccount']);
        Route::post('/account/{id}/toggle-status', [AdminDirectionController::class, 'toggleAccountStatus']);
    });

    // ====================
    // CLASSES & MATIERES
    // ====================
    Route::prefix('classes')->group(function () {
        Route::get('/index', [ClasseController::class, 'index']);
        Route::post('/', [ClasseController::class, 'store']);
        Route::put('/{id}', [ClasseController::class, 'update']);
        Route::get('/{classe}/eleves', [App\Http\Controllers\ProfesseurController::class, 'getElevesByClasse']);
        Route::delete('/{classe}', [ClasseController::class, 'destroy']);

        // Matières
        Route::get('/matieres', [App\Http\Controllers\MatiereController::class, 'index']);
        Route::post('/matieres', [App\Http\Controllers\MatiereController::class, 'store']);
        Route::put('/matieres/{matiere}', [App\Http\Controllers\MatiereController::class, 'update']);
        Route::delete('/matieres/{matiere}', [App\Http\Controllers\MatiereController::class, 'destroy']);
    });

    // ====================
    // PROFESSEURS
    // ====================
    Route::prefix('professeurs')->group(function () {
        Route::get('/', [ProfesseurController::class, 'index']); // Now returns list of professors
        Route::post('/', [ProfesseurController::class, 'store']); // Consistent with other resources
        Route::put('/{professeur}', [ProfesseurController::class, 'update']);
        Route::delete('/{professeur}', [ProfesseurController::class, 'destroy']); // Use model binding

        // Espace Prof (Self)
        Route::prefix('espace')->group(function () {
            Route::get('/dashboard', [ProfesseurController::class, 'dashboard']);
            Route::post('/logout', [ProfesseurController::class, 'logout']);
            Route::get('/emploi-du-temps', [ProfesseurController::class, 'emploiDuTemps']);
        });

        Route::get('/presences/eleves/{classe}', [ProfesseurController::class, 'getElevesByClasse']);
        Route::get('/classes', [ProfesseurController::class, 'mesClasses']); // New route for filtered classes
        Route::get('/classes/{classe}/matieres', [ProfesseurController::class, 'getMatieresByClasse']);
        Route::post('/presences', [ProfesseurController::class, 'storePresences']);
        Route::get('/presences/{classe}', [ProfesseurController::class, 'getPresencesByClasse']); // Added missing route
        
        // Conduites
        Route::get('/classes/{classe}/conduites', [ConduiteController::class, 'index']);
        Route::post('/classes/{classe}/conduites', [ConduiteController::class, 'store']);
    });

    // ====================
    // COMMUNNIQUES
    // ====================
    Route::prefix('communiques')->group(function () {
        Route::get('/', [\App\Http\Controllers\CommuniqueController::class, 'index']);
        Route::post('/', [\App\Http\Controllers\CommuniqueController::class, 'store']);
        Route::put('/{id}', [\App\Http\Controllers\CommuniqueController::class, 'update']);
        Route::delete('/{id}', [\App\Http\Controllers\CommuniqueController::class, 'destroy']);
    });

    Route::get('/notes', [NoteController::class, 'notes']);
    Route::post('/notes', [NoteController::class, 'storeNotes']);
    Route::post('/notes/calculer-moyennes', [NoteController::class, 'calculerMoyennes']);
    Route::get('/analyse-notes', [ProfesseurController::class, 'analyseNotes']);

    Route::get('/cahier-texte', [ProfesseurController::class, 'cahierTexte']);
    Route::post('/cahier-texte', [ProfesseurController::class, 'storeCahierTexte']);
    Route::delete('/cahier-texte/{id}', [ProfesseurController::class, 'destroyCahierTexte']);

    // ====================
    // CENSEUR MODULE
    // ====================
    Route::prefix('censeur')->group(function () {
        Route::get('/dashboard', [\App\Http\Controllers\CenseurController::class, 'dashboard']);
        Route::get('/logs', [\App\Http\Controllers\CenseurController::class, 'getLogs']);

        // Timetable & Programmation
        Route::get('/emplois-du-temps/{classe_id}', [\App\Http\Controllers\CenseurController::class, 'getEmploiDuTemps']);
        Route::post('/emplois-du-temps/{classe_id}', [\App\Http\Controllers\CenseurController::class, 'updateEmploiDuTemps']);
        Route::post('/programmation', [\App\Http\Controllers\CenseurController::class, 'programmation']);
        Route::post('/prof-principal', [\App\Http\Controllers\CenseurController::class, 'setProfPrincipal']);

        // Pédagogie & RH
        Route::get('/contacts', [\App\Http\Controllers\CenseurController::class, 'contacts']);
        Route::get('/cahiers-texte', [\App\Http\Controllers\CenseurController::class, 'cahiersTexte']);

        // Validation
        Route::get('/notes/validation', [\App\Http\Controllers\CenseurController::class, 'getNotesValidationData']);
        Route::post('/notes/validation', [\App\Http\Controllers\CenseurController::class, 'validateNotes']);

        // Compositions (Devoirs)
        Route::get('/session-compositions', [\App\Http\Controllers\SessionCompositionController::class, 'index']);
        Route::post('/session-compositions', [\App\Http\Controllers\SessionCompositionController::class, 'store']);
        Route::delete('/session-compositions/{id}', [\App\Http\Controllers\SessionCompositionController::class, 'destroy']);
    });

    // ====================
    // SECRETAIRE (ELEVES)
    // ====================
    Route::prefix('secretaire')->group(function () {
        Route::get('/eleves', [EleveController::class, 'index']);
        Route::post('/eleves', [EleveController::class, 'store']);
        Route::post('/eleves/import', [EleveController::class, 'import']); // Added import route
        Route::put('/eleves/{eleve}', [EleveController::class, 'update']);
        Route::delete('/eleves/{eleve}', [EleveController::class, 'destroy']);
        Route::get('/bulletins', [BulletinController::class, 'index']);
        Route::get('/bulletin/eleve/{eleveId}/{trimestre}', [BulletinController::class, 'generatePDF']); // Returns PDF stream

        // Evenements (Gérés par le secrétariat)
        Route::get('/evenements', [\App\Http\Controllers\SecretariatController::class, 'evenements']);
        Route::post('/evenements', [\App\Http\Controllers\SecretariatController::class, 'storeEvenement']);
        Route::delete('/evenements/{id}', [\App\Http\Controllers\SecretariatController::class, 'destroyEvenement']);
    });

    // ====================
    // SURVEILLANT
    // ====================
    Route::prefix('surveillant')->group(function () {
        Route::get('/dashboard', [SurveillantController::class, 'dashboard']); // Added dashboard route
        Route::get('/stats', [SurveillantController::class, 'stats']);
        Route::get('/plaintes', [SurveillantController::class, 'historiquePlaintes']);
        Route::post('/plaintes', [SurveillantController::class, 'storePlainte']);
        
        // Surveillance lecture des évenements (optionnel mais utile pour le dashboard)
        Route::get('/evenements', [SurveillantController::class, 'evenements']);

        // Présences
        Route::get('/presences/eleves', [SurveillantController::class, 'getPresencesEleves']);
        Route::get('/presences/professeurs', [SurveillantController::class, 'getPresencesProfesseurs']);
    });

    // ====================
    // PARENTS
    // ====================
    Route::prefix('parent')->group(function () {
        Route::post('/logout', [TuteurController::class, 'logout']);
        Route::post('/change-password', [TuteurController::class, 'changePassword']);
        Route::get('/dashboard', [TuteurController::class, 'dashboard']);
        Route::get('/eleve/{id}', [TuteurController::class, 'showEleve']);
        Route::get('/notes/{eleve_id}', [TuteurController::class, 'getNotes']);
        Route::get('/presences/{eleve_id}', [TuteurController::class, 'getPresences']);
        Route::get('/emploi-du-temps/{eleve_id}', [TuteurController::class, 'emploiDuTemps']);
        Route::get('/convocations/{eleve_id}', [TuteurController::class, 'getConvocations']);
        Route::get('/alertes-scolarite', [TuteurController::class, 'getAlertesScolarite']);
        Route::post('/contact', [TuteurController::class, 'contact']);
        
        // Notifications
        Route::get('/notifications', [TuteurController::class, 'getNotifications']);
        Route::post('/notifications/{id}/read', [TuteurController::class, 'markNotificationAsRead']);

        // Paiements
        Route::get('/paiements', [PaiementController::class, 'index']);
        Route::get('/paiements/{id}/receipt', [PaiementController::class, 'generateReceipt']);
        Route::post('/process-payment', [PaiementController::class, 'processPayment']);
        Route::get('/payment/callback/{method}', [PaiementController::class, 'handleCallback'])->name('parent.payment-callback');
    });
});
