<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('notes', function (Blueprint $table) {
            $table->id();
            
            // Notes d'interrogation
            $table->decimal('premier_interro', 4, 2)->nullable();
            $table->decimal('deuxieme_interro', 4, 2)->nullable();
            $table->decimal('troisieme_interro', 4, 2)->nullable();
            $table->decimal('quatrieme_interro', 4, 2)->nullable();
            $table->decimal('moyenne_interro', 4, 2)->nullable();
            
            // Notes de devoir
            $table->decimal('premier_devoir', 4, 2)->nullable();
            $table->decimal('deuxieme_devoir', 4, 2)->nullable();
            
            // Calculs finaux
            $table->decimal('moyenne_trimestrielle', 4, 2)->nullable();
            $table->decimal('coefficient', 3, 1)->default(1.0);
            $table->decimal('moyenne_coefficientee', 4, 2)->nullable();
            
            // Informations de contexte
            $table->integer('trimestre'); // 1, 2 ou 3
            $table->text('commentaire')->nullable();
            
            // Clés étrangères
            $table->foreignId('eleve_id')->constrained()->onDelete('cascade');
            $table->foreignId('classe_id')->constrained()->onDelete('cascade');
            $table->foreignId('professeur_id')->constrained('professeurs')->onDelete('cascade');
            $table->foreignId('matiere_id')->constrained()->onDelete('cascade');
            
            // Contrainte d'unicité
            $table->unique(['eleve_id', 'classe_id', 'matiere_id', 'trimestre']);
            
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('notes');
    }
};