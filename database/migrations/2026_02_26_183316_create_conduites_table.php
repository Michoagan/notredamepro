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
        Schema::create('conduites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('eleve_id')->constrained()->onDelete('cascade');
            $table->foreignId('classe_id')->constrained()->onDelete('cascade');
            $table->foreignId('professeur_id')->constrained('professeurs')->onDelete('cascade');
            $table->integer('trimestre')->comment('1, 2 ou 3');
            $table->decimal('note', 4, 2)->nullable()->comment('Note de conduite sur 20');
            $table->text('appreciation')->nullable()->comment('Appréciation ou commentaire sur la conduite');
            
            // Un élève ne peut avoir qu'une seule note de conduite par trimestre pour sa classe
            $table->unique(['eleve_id', 'classe_id', 'trimestre']);
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('conduites');
    }
};
