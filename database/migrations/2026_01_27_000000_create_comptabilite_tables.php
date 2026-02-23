<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Dépenses (Sorties : Salaires, Achats, etc.)
        Schema::create('depenses', function (Blueprint $table) {
            $table->id();
            $table->string('motif'); // Ex: Salaire Prof X, Achat Craie
            $table->decimal('montant', 12, 2);
            $table->date('date_depense');
            $table->enum('categorie', ['salaire', 'achat_materiel', 'tache', 'autre']);
            $table->text('description')->nullable();
            
            // Qui a enregistré la dépense ?
            $table->foreignId('auteur_id')->nullable()->constrained('direction_users')->nullOnDelete();
            
            // Bénéficiaire optionnel (ex: Professeur pour salaire)
            $table->nullableMorphs('beneficiaire'); // beneficiaire_type, beneficiaire_id
            
            $table->timestamps();
        });

        // 2. Articles (Inventaire & Choses à vendre : Tenues, Tricots, Cantine...)
        Schema::create('articles', function (Blueprint $table) {
            $table->id();
            $table->string('designation'); // Ex: Tenue Garçon Taille M, Tricot, Repas Cantine
            $table->string('type')->default('physique'); // 'physique' (stockable) ou 'service' (frais divers)
            $table->decimal('prix_unitaire', 10, 2);
            $table->integer('stock_actuel')->default(0);
            $table->integer('stock_min')->default(5); // Seuil alerte
            $table->boolean('est_actif')->default(true);
            $table->timestamps();
        });

        // 3. Ventes (Autres Frais : Entrées Indépendantes des contributions scolaires)
        Schema::create('ventes', function (Blueprint $table) {
            $table->id();
            $table->string('reference')->unique(); // Reçu #
            
            // Client (Peut être un élève ou anonyme)
            $table->foreignId('eleve_id')->nullable()->constrained('eleves')->nullOnDelete();
            $table->string('nom_client')->nullable(); // Si pas élève
            
            $table->decimal('montant_total', 10, 2);
            $table->dateTime('date_vente');
            
            // Qui a fait la vente ?
            $table->foreignId('auteur_id')->nullable()->constrained('direction_users')->nullOnDelete();
            
            $table->timestamps();
        });

        // Détails de la vente (Ligne de commande)
        Schema::create('ligne_ventes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vente_id')->constrained('ventes')->cascadeOnDelete();
            $table->foreignId('article_id')->constrained('articles');
            $table->integer('quantite');
            $table->decimal('prix_unitaire', 10, 2); // Prix au moment de la vente
            $table->decimal('sous_total', 10, 2);
            $table->timestamps();
        });

        // 4. Mouvements de Stock (Inventaire : Entrées/Sorties détaillées)
        Schema::create('mouvements_stock', function (Blueprint $table) {
            $table->id();
            $table->foreignId('article_id')->constrained('articles')->cascadeOnDelete();
            $table->enum('type', ['entree', 'sortie', 'correction', 'vente']);
            $table->integer('quantite'); // Positif
            $table->integer('stock_precedent');
            $table->integer('nouveau_stock');
            $table->string('motif')->nullable(); // Ex: Approvisionnement, Vente #Ref, Perte
            
            // Lien optionnel avec une dépense (si achat de stock) ou vente
            $table->nullableMorphs('source'); // source_type, source_id (Depense, Vente)
            
            $table->foreignId('auteur_id')->nullable()->constrained('direction_users')->nullOnDelete();
            
            $table->timestamps();
        });

        // 5. Modification Paiements (Scolarité)
        Schema::table('paiements', function (Blueprint $table) {
            // Qui a encaissé l'argent (pour espèces)
            $table->foreignId('auteur_id')->nullable()->constrained('direction_users')->nullOnDelete()->after('statut');
            // Observation
            $table->text('observation')->nullable()->after('erreur');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('paiements', function (Blueprint $table) {
            $table->dropForeign(['auteur_id']);
            $table->dropColumn(['auteur_id', 'observation']);
        });

        Schema::dropIfExists('mouvements_stock');
        Schema::dropIfExists('ligne_ventes');
        Schema::dropIfExists('ventes');
        Schema::dropIfExists('articles');
        Schema::dropIfExists('depenses');
    }
};
