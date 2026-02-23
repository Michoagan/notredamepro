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
        Schema::table('classe_matiere', function (Blueprint $table) {
            $table->integer('ordre_affichage')->default(0);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('classe_matiere', function (Blueprint $table) {
            $table->dropColumn('ordre_affichage');
        });
    }
};
