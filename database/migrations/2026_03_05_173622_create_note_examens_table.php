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
        Schema::create('note_examens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('eleve_id')->constrained()->onDelete('cascade');
            $table->foreignId('classe_id')->constrained()->onDelete('cascade');
            $table->foreignId('matiere_id')->nullable()->constrained()->onDelete('cascade'); // NULL = Moyenne Générale
            $table->string('type_examen'); // 'Examen Blanc' ou 'Examen National'
            $table->decimal('valeur', 8, 2)->nullable(); // Note sur 20
            $table->string('annee_scolaire'); // '2023-2024'
            $table->timestamps();
            
            // Un élève ne peut pas avoir deux fois la même note pour le même examen, même matière, même année
            $table->unique(['eleve_id', 'type_examen', 'matiere_id', 'annee_scolaire'], 'unique_note_examen');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('note_examens');
    }
};
