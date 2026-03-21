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
        Schema::create('paiement_professeurs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('professeur_id')->constrained('professeurs')->onDelete('cascade');
            $table->integer('mois');
            $table->integer('annee');
            $table->decimal('total_heures', 8, 2)->default(0);
            $table->decimal('montant_heures', 10, 2)->default(0);
            $table->decimal('montant_primes', 10, 2)->default(0);
            $table->decimal('montant_total', 10, 2)->default(0);
            $table->enum('statut', ['en_attente', 'paye'])->default('en_attente');
            $table->date('date_paiement')->nullable();
            $table->timestamps();
            
            // Un seul paiement global par mois par prof
            $table->unique(['professeur_id', 'mois', 'annee'], 'paiement_unique_mois_annee');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('paiement_professeurs');
    }
};
