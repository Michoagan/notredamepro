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
        Schema::create('matieres', function (Blueprint $table) {
            $table->id();
            $table->string('nom')->unique();
            $table->text('description')->nullable();
            $table->string('categorie')->nullable();
            $table->integer('coefficient_defaut')->default(1);
            $table->string('couleur')->default('#1a5276');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // Table pivot pour la relation entre classes et matières
        Schema::create('classe_matiere', function (Blueprint $table) {
            $table->id();
            $table->foreignId('classe_id')->constrained()->onDelete('cascade');
            $table->foreignId('matiere_id')->constrained()->onDelete('cascade');
            $table->integer('coefficient')->default(1);
            $table->foreignId('professeur_id')->nullable()->constrained('professeurs')->onDelete('set null');
            $table->timestamps();
            
            $table->unique(['classe_id', 'matiere_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('classe_matiere');
        Schema::dropIfExists('matieres');
    }
};
