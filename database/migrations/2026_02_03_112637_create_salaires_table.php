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
        Schema::create('salaires', function (Blueprint $table) {
            $table->id();
            $table->foreignId('professeur_id')->constrained('professeurs');
            $table->integer('mois'); // 1-12
            $table->integer('annee');
            
            $table->decimal('heures_travaillees', 8, 2)->default(0);
            $table->decimal('taux_horaire', 10, 2)->default(0);
            
            $table->decimal('montant_base', 12, 2); // Heures * Taux
            $table->decimal('primes', 12, 2)->default(0);
            $table->decimal('retenues', 12, 2)->default(0); // Avances, absences...
            
            $table->decimal('net_a_payer', 12, 2);
            
            $table->enum('statut', ['en_attente', 'paye'])->default('en_attente');
            $table->date('date_paiement')->nullable();
            
            $table->timestamps();
            
            // Un seul salaire par prof par mois
            $table->unique(['professeur_id', 'mois', 'annee']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('salaires');
    }
};
