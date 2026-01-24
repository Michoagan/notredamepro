<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
   // database/migrations/2023_01_01_create_contributions_table.php
public function up()
{
    Schema::create('contributions', function (Blueprint $table) {
        $table->id();
        $table->foreignId('classe_id')->constrained()->onDelete('cascade');
        $table->string('annee_scolaire', 9);
        $table->string('type', 20);
        $table->decimal('montant_total', 10, 2);
        $table->decimal('montant_paye', 10, 2)->default(0);
        $table->text('description')->nullable();
        $table->date('date_limite')->nullable();
        $table->boolean('est_obligatoire')->default(true);
        $table->timestamps();

        $table->index(['classe_id', 'annee_scolaire']);
    });


// database/migrations/2023_01_01_create_paiements_table.php

    Schema::create('paiements', function (Blueprint $table) {
        $table->id();
        $table->string('reference')->unique();
        $table->foreignId('eleve_id')->constrained()->onDelete('cascade');
        $table->foreignId('contribution_id')->constrained()->onDelete('cascade');
        $table->decimal('montant', 10, 2);
        $table->enum('methode', ['kkiapay', 'fedapay', 'especes']);
        $table->enum('statut', ['pending', 'success', 'failed', 'cancelled'])->default('pending');
        $table->string('reference_externe')->nullable();
        $table->text('erreur')->nullable();
        $table->text('details_paiement')->nullable();
        $table->dateTime('date_paiement')->nullable();
        $table->timestamps();

        $table->index(['eleve_id', 'contribution_id']);
        $table->index('reference');
        $table->index('statut');
    });
}
    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('paiements');
         Schema::dropIfExists('contributions');
    }
};
