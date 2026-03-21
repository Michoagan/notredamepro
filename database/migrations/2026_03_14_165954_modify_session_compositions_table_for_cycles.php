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
        Schema::table('session_compositions', function (Blueprint $table) {
            $table->string('cible')->default('toute_lecole')->after('numero_devoir');
            $table->dropColumn('is_global');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('session_compositions', function (Blueprint $table) {
            $table->boolean('is_global')->default(true);
            $table->dropColumn('cible');
        });
    }
};
