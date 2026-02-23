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
        // Sécurité : éviter l'erreur "Duplicate column"
        if (!Schema::hasColumn('classe_matiere', 'volume_horaire')) {
            Schema::table('classe_matiere', function (Blueprint $table) {
                $table->integer('volume_horaire')
                      ->default(2)
                      ->after('coefficient'); // Par défaut 2h
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn('classe_matiere', 'volume_horaire')) {
            Schema::table('classe_matiere', function (Blueprint $table) {
                $table->dropColumn('volume_horaire');
            });
        }
    }
};
