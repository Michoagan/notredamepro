<?php

use App\Http\Controllers\AdminDirectionController;
use App\Http\Controllers\Auth\AuthParentController;
use App\Http\Controllers\BulletinController;
use App\Http\Controllers\ClasseController;
use App\Http\Controllers\DirecteurController;
use App\Http\Controllers\DirectionController;
use App\Http\Controllers\EleveController;
use App\Http\Controllers\PaiementController;
use App\Http\Controllers\ProfesseurController;
use App\Http\Controllers\SurveillantController;
use App\Http\Controllers\TuteurController;
use App\Models\Classe;
use App\Models\Eleve;
use App\Models\Matiere;
use App\Models\Paiement;
use App\Models\Professeur;
use Carbon\Carbon;
use Illuminate\Support\Facades\Route;

// Route d'accueil
Route::get('/', function () {
    return view('welcome');
});

// =============================================
// ROUTES PUBLIQUES (Sans authentification)
// =============================================

// Authentification Direction
Route::prefix('direction')->name('direction.')->group(function () {
    Route::get('/inscrit', [DirectionController::class, 'inscrit'])->name('inscrit');
    Route::post('/register', [DirectionController::class, 'register'])->name('register');
    Route::get('/login', [DirectionController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [DirectionController::class, 'login'])->name('login.submit');
    Route::get('/pending', [DirectionController::class, 'pending'])->name('pending');
});

// Authentification Professeurs (publique)
Route::prefix('professeur')->name('professeur.')->group(function () {
    Route::get('/inscrit', [ProfesseurController::class, 'create'])->name('inscrit');
    Route::post('/inscrit', [ProfesseurController::class, 'store'])->name('store');
    Route::get('/login', [ProfesseurController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [ProfesseurController::class, 'login'])->name('login.submit');
});

// Authentification Parents
Route::prefix('parent')->name('parent.')->group(function () {
    Route::get('register', [AuthParentController::class, 'showRegisterForm'])->name('register');
    Route::post('register', [AuthParentController::class, 'register'])->name('register.submit');
    Route::get('login', [AuthParentController::class, 'showLoginForm'])->name('login');
    Route::post('login', [AuthParentController::class, 'login'])->name('login.submit');
});

// =============================================
// ROUTES PROTÉGÉES DIRECTION
// =============================================

Route::middleware(['auth:direction'])->group(function () {

    // Déconnexion
    Route::post('/direction/logout', [DirectionController::class, 'logout'])->name('direction.logout');

    // Tableaux de bord par rôle
    Route::get('/censeur', function () {
        $matieres = Matiere::all();
        $classes = Classe::all();
        $professeurs = Professeur::all();
        $eleves = Eleve::all();

        return view('direction.censeur', compact('professeurs', 'classes', 'matieres', 'eleves'));
    })->name('direction.censeur');

    Route::get('/directeur', function () {
        $totalEleves = Eleve::count();
        $totalClasses = Classe::where('is_active', true)->count();
        $totalProfesseurs = Professeur::where('is_active', true)->count();
        $derniersEleves = Eleve::with('classe')->orderBy('created_at', 'desc')->limit(5)->get();
        $derniersProfesseurs = Professeur::orderBy('created_at', 'desc')->limit(5)->get();
        $repartitionSexe = [
            'garcons' => Eleve::where('sexe', 'M')->count(),
            'filles' => Eleve::where('sexe', 'F')->count(),
        ];
        $labels = Classe::where('is_active', true)->pluck('nom');
        $elevesParClasse = Classe::withCount('eleves')->where('is_active', true)->pluck('eleves_count');
        $debutMois = Carbon::now()->startOfMonth();
        $finMois = Carbon::now()->endOfMonth();
        $revenusMois = Paiement::where('statut', 'réussi')
            ->whereBetween('date_paiement', [$debutMois, $finMois])
            ->sum('montant');
        $derniersPaiements = Paiement::with('eleve.classe')
            ->orderBy('date_paiement', 'desc')
            ->limit(5)
            ->get();
        $garcons = Eleve::where('sexe', 'M')->count();
        $filles = Eleve::where('sexe', 'F')->count();

        return view('direction.directeur', compact(
            'totalEleves', 'totalClasses', 'totalProfesseurs',
            'derniersEleves', 'derniersProfesseurs', 'repartitionSexe',
            'labels', 'elevesParClasse', 'revenusMois', 'derniersPaiements',
            'garcons', 'filles'
        ));
    })->name('direction.directeur');

    Route::get('/secretaire', function () {
        $classes = Classe::withCount('eleves')->get();

        return view('direction.secretaire', compact('classes'));
    })->name('direction.secretaire');

    Route::get('/comptable', function () {
        return view('direction.comptable');
    })->name('direction.comptable');

    Route::get('/surveillant', [SurveillantController::class, 'dashboard'])->name('direction.surveillant');

    // =============================================
    // ADMINISTRATION (Rôle admin)
    // =============================================

    Route::prefix('admin')->name('admin.')->group(function () {
        Route::get('/dashboard', [AdminDirectionController::class, 'dashboard'])->name('dashboard');
        Route::get('/pending-accounts', [AdminDirectionController::class, 'pendingAccounts'])->name('pending.accounts');
        Route::get('/all-accounts', [AdminDirectionController::class, 'allAccounts'])->name('all.accounts');
        Route::get('/account/{id}', [AdminDirectionController::class, 'showAccount'])->name('account.details');
        Route::post('/account/{id}/approve', [AdminDirectionController::class, 'approveAccount'])->name('approve.account');
        Route::post('/account/{id}/reject', [AdminDirectionController::class, 'rejectAccount'])->name('reject.account');
        Route::post('/account/{id}/toggle-status', [AdminDirectionController::class, 'toggleAccountStatus'])->name('toggle.account.status');
        Route::post('/account/{id}/update', [AdminDirectionController::class, 'updateAccount'])->name('update.account');
    });

    // =============================================
    // GESTION DES CLASSES ET MATIÈRES
    // =============================================

    Route::prefix('classes')->name('classes.')->group(function () {
        Route::get('/inscrit', [ClasseController::class, 'create'])->name('inscrit');
        Route::post('/inscrit', [ClasseController::class, 'store'])->name('store');
        Route::get('/index', [ClasseController::class, 'index'])->name('index');
        Route::get('/{id}/edit', [ClasseController::class, 'edit'])->name('edit');
        Route::put('/{id}', [ClasseController::class, 'update'])->name('update');
        Route::delete('/{id}', [ClasseController::class, 'destroyClasse'])->name('destroy');

        // Matières
        Route::get('/matiere', [ClasseController::class, 'matiere'])->name('matiere');
        Route::post('/matieres', [ClasseController::class, 'storeMatiere'])->name('matieres.store');
        Route::get('/matieres', [ClasseController::class, 'indexMatiere'])->name('matieres.index');
        Route::delete('/matieres/{matiere}', [ClasseController::class, 'destroy'])->name('matieres.destroy');
    });

    // =============================================
    // GESTION DES PROFESSEURS
    // =============================================

    Route::prefix('professeurs')->name('professeurs.')->group(function () {
        Route::get('/index', [ProfesseurController::class, 'index'])->name('index');
        Route::get('/edit', [ProfesseurController::class, 'edit'])->name('edit');
        Route::put('/', [ProfesseurController::class, 'update'])->name('update');
        Route::patch('/', [ProfesseurController::class, 'update']);
        // Route::delete('/{id}', [ProfesseurController::class, 'destroy'])->name('destroy');
    });

    // =============================================
    // SECRÉTARIAT (Gestion des élèves)
    // =============================================

    Route::prefix('secretaire')->name('secretaire.')->group(function () {
        // Élèves
        Route::get('/eleves', [EleveController::class, 'index'])->name('eleves.index');
        Route::get('/eleves/create', [EleveController::class, 'create'])->name('eleves.create');
        Route::post('/eleves', [EleveController::class, 'store'])->name('eleves.store');
        Route::post('/eleves/import', [EleveController::class, 'import'])->name('eleves.import');
        Route::get('/eleves/export-template', [EleveController::class, 'exportTemplate'])->name('eleves.export-template');
        Route::get('/eleves/classe/{classeId}', [EleveController::class, 'byClasse'])->name('eleves.byClasse');
        Route::get('/eleves/{eleve}/edit', [EleveController::class, 'edit'])->name('eleves.edit');
        Route::put('/eleves/{eleve}', [EleveController::class, 'update'])->name('eleves.update');
        Route::delete('/eleves/{eleve}', [EleveController::class, 'destroy'])->name('eleves.destroy');

        // Bulletins
        Route::get('/resultats', [BulletinController::class, 'index'])->name('resultats');
        Route::get('/bulletin/eleve/{eleveId}/{trimestre}', [BulletinController::class, 'generatePDF'])->name('bulletin.pdf');
        Route::get('/bulletins', [BulletinController::class, 'index'])->name('bulletins');
    });

    // =============================================
    // SURVEILLANT
    // =============================================

    Route::prefix('surveillant')->name('surveillant.')->group(function () {
        Route::get('/stats', [SurveillantController::class, 'stats'])->name('stats');
        Route::get('/plaintes/recentes', [SurveillantController::class, 'plaintesRecent'])->name('plaintes.recentes');
        Route::post('/plaintes/store', [SurveillantController::class, 'storePlainte'])->name('plaintes.store');
        Route::get('/plaintes/historique', [SurveillantController::class, 'historiquePlaintes'])->name('plaintes.historique');
        Route::post('/evenements/store', [SurveillantController::class, 'storeEvenement'])->name('evenements.store');
        Route::get('/evenements', [SurveillantController::class, 'evenements'])->name('evenements');
        Route::get('/evenements/prochains', [SurveillantController::class, 'evenementsProchains'])->name('evenements.prochains');
        Route::get('/classes/{classe}/eleves', [SurveillantController::class, 'getElevesByClasse'])->name('classes.eleves');
        Route::delete('/evenements/{evenement}', [SurveillantController::class, 'destroy'])->name('evenements.destroy');
    });

    // =============================================
    // DIRECTEUR (Fonctions avancées)
    // =============================================

    Route::prefix('directeur')->name('directeur.')->group(function () {
        // Classes et élèves
        Route::get('/classes-eleves', [DirecteurController::class, 'classesEleves'])->name('classes-eleves.index');
        Route::get('/classes-eleves/classe/{classe}', [DirecteurController::class, 'getElevesByClasse'])->name('classes-eleves.classe');
        Route::get('/classes-eleves/eleve/{eleve}', [DirecteurController::class, 'getEleveDetails'])->name('classes-eleves.eleve');
        Route::get('/classes-eleves/export/{classe}', [DirecteurController::class, 'exportEleves'])->name('classes-eleves.export');
        Route::get('/classes-eleves/search', [DirecteurController::class, 'searchEleves'])->name('classes-eleves.search');

        // Statistiques
        Route::get('/stats', [DirecteurController::class, 'getStats'])->name('stats');

        // Gestion des notes
        Route::get('/notes', [DirecteurController::class, 'gestionNotes'])->name('notes.index');
        Route::get('/notes/export', [DirecteurController::class, 'exportNotes'])->name('notes.export');
        Route::get('/notes/stats', [DirecteurController::class, 'statsNotes'])->name('notes.stats');
        Route::get('/notes/{note}', [DirecteurController::class, 'detailNote'])->name('notes.detail');

        // Gestion des professeurs
        Route::get('/professeurs', [DirecteurController::class, 'gestionProfesseurs'])->name('professeurs.index');
        Route::get('/professeurs/{professeur}', [DirecteurController::class, 'detailProfesseur'])->name('professeurs.detail');
        Route::post('/professeurs/{professeur}/toggle', [DirecteurController::class, 'toggleProfesseur'])->name('professeurs.toggle');
        Route::get('/professeurs/export', [DirecteurController::class, 'exportProfesseurs'])->name('professeurs.export');
        Route::get('/professeurs/export-pdf', [DirecteurController::class, 'exportProfesseursPdf'])->name('professeurs.export.pdf');

        // Cahiers de texte
        Route::get('/cahiers-texte/{cahier}', [DirecteurController::class, 'detailCahierTexte'])->name('cahiers.detail');
    });
});

// =============================================
// ROUTES PROTÉGÉES PROFESSEURS
// =============================================

Route::middleware(['auth:professeur'])->prefix('professeur')->name('professeur.')->group(function () {
    // Déconnexion
    Route::post('/logout', [ProfesseurController::class, 'logout'])->name('logout');

    // Tableau de bord
    Route::get('/dashboard', [ProfesseurController::class, 'dashboard'])->name('dashboard');

    // Présences
    Route::get('/presences', [ProfesseurController::class, 'presences'])->name('presences');
    Route::get('/presences/eleves/{classe}', [ProfesseurController::class, 'getElevesByClasse'])->name('presences.eleves');
    Route::get('/presences/du-jour/{classe}', [ProfesseurController::class, 'getPresencesDuJour'])->name('presences.du-jour');
    Route::post('/presences/marquer', [ProfesseurController::class, 'marquerPresences'])->name('presences.marquer');
    Route::post('/presences', [ProfesseurController::class, 'storePresences'])->name('presences.store');

    // Notes
    Route::get('/notes', [ProfesseurController::class, 'notes'])->name('notes');
    Route::post('/notes', [ProfesseurController::class, 'storeNotes'])->name('notes.store');
    Route::get('/notes/calcul', [ProfesseurController::class, 'calculerMoyennes'])->name('notes.calcul');
    Route::get('/moyennes-ajax', [ProfesseurController::class, 'getMoyennesAjax'])->name('moyennes.ajax');
    Route::get('/moyennes/pdf', [ProfesseurController::class, 'generateMoyennesPDF'])->name('moyennes.pdf');
    Route::get('/analyse-notes', [ProfesseurController::class, 'analyseNotes'])->name('analyse-notes');

    // Matières
    Route::get('/matieres-par-classe/{classe}', [ProfesseurController::class, 'matieresParClasse'])->name('matieres.par.classe');
    Route::get('/get-matieres-classe/{classeId}', [ProfesseurController::class, 'getMatieresByClasse'])->name('get-matieres-classe');
    Route::get('/get-eleves-classe/{classeId}', [ProfesseurController::class, 'getElevesByClasse'])->name('get-eleves-classe');

    // Cahier de texte
    Route::get('/cahier-texte', [ProfesseurController::class, 'cahierTexte'])->name('cahier-texte');
    Route::post('/cahier-texte', [ProfesseurController::class, 'storeCahierTexte'])->name('cahier-texte.store');
    Route::delete('/cahier-texte/{id}', [ProfesseurController::class, 'destroyCahierTexte'])->name('cahier-texte.destroy');
});

// =============================================
// ROUTES PROTÉGÉES PARENTS/TUTEURS
// =============================================

Route::middleware(['auth:tuteurs'])->prefix('parent')->name('parent.')->group(function () {
    // Déconnexion
    Route::post('/logout', [AuthParentController::class, 'logout'])->name('logout');

    // Tableau de bord
    Route::get('/dashboard', [TuteurController::class, 'dashboard'])->name('dashboard');
    Route::get('/eleve/{id}', [TuteurController::class, 'showEleve'])->name('eleve.show');

    // Notes
    Route::get('/notes', [TuteurController::class, 'notes'])->name('notes.index');
    Route::get('/notes-graph', [TuteurController::class, 'notesGraph'])->name('notes.graph');

    // Professeurs
    Route::get('/professeurs', [TuteurController::class, 'professeurs'])->name('professeurs');

    // Paiements
    Route::get('/paiements', [PaiementController::class, 'index'])->name('paiements');
    Route::post('/process-payment', [PaiementController::class, 'processPayment'])->name('process-payment');
    Route::get('/payment-callback/{method}', [PaiementController::class, 'handleCallback'])->name('payment-callback');
    Route::get('/receipt/{id}', [PaiementController::class, 'generateReceipt'])->name('receipt');
    Route::get('/check-payment-status/{id}', [PaiementController::class, 'checkPaymentStatus'])->name('check-payment-status');
});

// =============================================
// ROUTES D'API ET TESTS
// =============================================

Route::get('/test-fedapay', [PaiementController::class, 'testFedaPayConnection']);

// Resource route (à garder si nécessaire)
Route::resource('professeurs', ProfesseurController::class);

// Dans routes/web.php
Route::middleware(['auth:direction'])->prefix('direction')->name('direction.')->group(function () {
    Route::get('/notifications', [DirectionController::class, 'notifications'])->name('notifications');
    Route::post('/notifications/mark-all-read', [DirectionController::class, 'markAllNotificationsAsRead'])->name('notifications.markAllRead');
    Route::post('/notifications/{id}/read', [DirectionController::class, 'markNotificationAsRead'])->name('notifications.markAsRead');
});

Route::prefix('admin')->name('admin.')->group(function () {
    // ... autres routes

    Route::get('/all-accounts', [AdminDirectionController::class, 'allAccounts'])->name('all.accounts');
    Route::post('/account/{id}/toggle-status', [AdminDirectionController::class, 'toggleAccountStatus'])->name('toggle.account.status');
    Route::post('/account/{id}/update', [AdminDirectionController::class, 'updateAccount'])->name('update.account');
});

// Routes de réinitialisation de mot de passe pour Direction
Route::prefix('direction')->group(function () {
    Route::get('/forgot-password', [DirectionController::class, 'showForgotPasswordForm'])
        ->name('direction.password.request');

    Route::post('/forgot-password', [DirectionController::class, 'sendResetLinkEmail'])
        ->name('direction.password.email');

    Route::get('/reset-password/{token}', [DirectionController::class, 'showResetForm'])
        ->name('direction.password.reset');

    Route::post('/reset-password', [DirectionController::class, 'reset'])
        ->name('direction.password.update');
});

// Routes de réinitialisation par code secret
Route::prefix('direction')->group(function () {
    // Demande de code
    Route::get('/forgot-password', [DirectionController::class, 'showForgotPasswordForm'])
        ->name('direction.password.request');

    Route::post('/forgot-password', [DirectionController::class, 'sendResetCode'])
        ->name('direction.password.code');

    // Vérification du code
    Route::get('/verify-code', [DirectionController::class, 'showVerifyCodeForm'])
        ->name('direction.password.verify');

    Route::post('/verify-code', [DirectionController::class, 'verifyResetCode'])
        ->name('direction.password.verify.submit');

    // Renvoyer le code
    Route::post('/resend-code', [DirectionController::class, 'resendCode'])
        ->name('direction.password.resend');

    // Réinitialisation
    Route::get('/reset-password', [DirectionController::class, 'showResetForm'])
        ->name('direction.password.reset');

    Route::post('/reset-password', [DirectionController::class, 'resetPassword'])
        ->name('direction.password.update');
});
