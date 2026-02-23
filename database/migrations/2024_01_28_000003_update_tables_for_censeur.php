<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        // Update Notes table for validation
        Schema::table('notes', function (Blueprint $table) {
            $table->boolean('is_validated')->default(false);
            $table->timestamp('validated_at')->nullable();
            $table->string('validated_by')->nullable(); // Store name/role of validator
        });

        // Update Classe_Matiere pivot table for volume horaire
        Schema::table('classe_matiere', function (Blueprint $table) {
            $table->integer('volume_horaire')->default(0)->after('coefficient'); // Hours per year/semester
        });
    }

    public function down()
    {
        Schema::table('notes', function (Blueprint $table) {
            $table->dropColumn(['is_validated', 'validated_at', 'validated_by']);
        });

        Schema::table('classe_matiere', function (Blueprint $table) {
            $table->dropColumn('volume_horaire');
        });
    }
};
