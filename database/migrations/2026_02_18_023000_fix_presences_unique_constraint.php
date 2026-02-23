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
        Schema::table('presences', function (Blueprint $table) {
            // Drop the old unique index
            $table->dropUnique(['eleve_id', 'date', 'classe_id']);
            
            // Add the new unique index including cours_id (matiere)
            $table->unique(['eleve_id', 'date', 'classe_id', 'cours_id'], 'presences_unique_cours');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('presences', function (Blueprint $table) {
             $table->dropUnique('presences_unique_cours');
             $table->unique(['eleve_id', 'date', 'classe_id']);
        });
    }
};
