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
        Schema::create('taux_horaires', function (Blueprint $table) {
            $table->id();
            $table->foreignId('professeur_id')->constrained('professeurs')->onDelete('cascade');
            $table->foreignId('classe_id')->nullable()->constrained('classes')->onDelete('cascade');
            $table->decimal('taux_horaire', 10, 2)->default(0);
            $table->decimal('prime_mensuelle', 10, 2)->default(0);
            $table->timestamps();
            
            // Un prof ne peut avoir qu'un seul taux spécifique par classe
            $table->unique(['professeur_id', 'classe_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('taux_horaires');
    }
};
