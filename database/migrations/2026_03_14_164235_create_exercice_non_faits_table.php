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
        Schema::create('exercice_non_faits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cahier_texte_id')->constrained()->onDelete('cascade');
            $table->foreignId('eleve_id')->constrained()->onDelete('cascade');
            $table->timestamps();

            $table->unique(['cahier_texte_id', 'eleve_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exercice_non_faits');
    }
};
