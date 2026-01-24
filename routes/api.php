<?php

use App\Http\Controllers\AdminDirectionController;
use App\Http\Controllers\BulletinController;
use App\Http\Controllers\ClasseController;
use App\Http\Controllers\DirectionController;
use App\Http\Controllers\EleveController;
use App\Http\Controllers\PaiementController;
use App\Http\Controllers\ProfesseurController;
use App\Http\Controllers\SurveillantController;
use App\Http\Controllers\TuteurController;
use App\Http\Controllers\NoteController;
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
});

// Parent Auth (Placeholder - Controller needs validation)
// Route::prefix('parent')->group(function () {
//     Route::post('/login', [AuthParentController::class, 'login']);
//     Route::post('/register', [AuthParentController::class, 'register']);
// });

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

        // Tableaux de bord (JSON expected from controllers)
        Route::get('/censeur', [DirectionController::class, 'censeurDashboard']); // Need to create method if generic closure
        Route::get('/directeur', [DirectionController::class, 'directeurDashboard']); // Need to move closure logic to controller
        // ... (Refer to backup for more closures to move)
    });

    Route::prefix('admin')->group(function () {
        Route::get('/dashboard', [AdminDirectionController::class, 'dashboard']);
        Route::get('/pending-accounts', [AdminDirectionController::class, 'pendingAccounts']);
        Route::get('/all-accounts', [AdminDirectionController::class, 'allAccounts']);
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
        Route::delete('/{classe}', [ClasseController::class, 'destroy']);

        // Matières
        Route::get('/matieres', [App\Http\Controllers\MatiereController::class, 'index']);
        Route::post('/matieres', [App\Http\Controllers\MatiereController::class, 'store']);
        Route::delete('/matieres/{matiere}', [App\Http\Controllers\MatiereController::class, 'destroy']);
    });

    // ====================
    // PROFESSEURS
    // ====================
    Route::prefix('professeurs')->group(function () {
        Route::get('/', [ProfesseurController::class, 'index']);
        Route::put('/', [ProfesseurController::class, 'update']);
        Route::delete('/{id}', [ProfesseurController::class, 'destroy']);

        // Espace Prof (Self)
        Route::get('/dashboard', [ProfesseurController::class, 'dashboard']);
        Route::post('/logout', [ProfesseurController::class, 'logout']);

        Route::get('/presences/eleves/{classe}', [ProfesseurController::class, 'getElevesByClasse']);
        Route::post('/presences', [ProfesseurController::class, 'storePresences']);

        Route::get('/notes', [NoteController::class, 'notes']);
        Route::post('/notes', [NoteController::class, 'storeNotes']);
        Route::get('/analyse-notes', [ProfesseurController::class, 'analyseNotes']);

        Route::get('/cahier-texte', [ProfesseurController::class, 'cahierTexte']);
        Route::post('/cahier-texte', [ProfesseurController::class, 'storeCahierTexte']);
    });

    // ====================
    // SECRETAIRE (ELEVES)
    // ====================
    Route::prefix('secretaire')->group(function () {
        Route::get('/eleves', [EleveController::class, 'index']);
        Route::post('/eleves', [EleveController::class, 'store']);
        Route::put('/eleves/{eleve}', [EleveController::class, 'update']);
        Route::delete('/eleves/{eleve}', [EleveController::class, 'destroy']);
        Route::get('/bulletins', [BulletinController::class, 'index']);
        Route::get('/bulletin/eleve/{eleveId}/{trimestre}', [BulletinController::class, 'generatePDF']); // Returns PDF stream
    });

    // ====================
    // SURVEILLANT
    // ====================
    Route::prefix('surveillant')->group(function () {
        Route::get('/stats', [SurveillantController::class, 'stats']);
        Route::get('/plaintes', [SurveillantController::class, 'historiquePlaintes']);
        Route::post('/plaintes', [SurveillantController::class, 'storePlainte']);
        Route::get('/evenements', [SurveillantController::class, 'evenements']);
        Route::post('/evenements', [SurveillantController::class, 'storeEvenement']);
    });

    // ====================
    // PARENTS
    // ====================
    Route::prefix('parent')->group(function () {
        // Route::post('/logout', [AuthParentController::class, 'logout']);
        Route::get('/dashboard', [TuteurController::class, 'dashboard']);
        Route::get('/eleve/{id}', [TuteurController::class, 'showEleve']);
        Route::get('/notes', [TuteurController::class, 'notes']);

        // Paiements
        Route::get('/paiements', [PaiementController::class, 'index']);
        Route::post('/process-payment', [PaiementController::class, 'processPayment']);
        Route::get('/payment/callback/{method}', [PaiementController::class, 'handleCallback'])->name('parent.payment-callback');
    });
});
