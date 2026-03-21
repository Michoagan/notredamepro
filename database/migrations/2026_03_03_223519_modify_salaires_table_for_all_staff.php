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
        Schema::table('direction_users', function (Blueprint $table) {
            $table->decimal('salaire_base', 12, 2)->default(0)->after('is_active');
        });

        Schema::table('salaires', function (Blueprint $table) {
            // Rendre professeur_id nullable
            $table->unsignedBigInteger('professeur_id')->nullable()->change();
            
            // Ajouter direction_user_id
            $table->foreignId('direction_user_id')->nullable()->after('professeur_id')->constrained('direction_users')->nullOnDelete();
            
            // On supprime l'ancien index unique si possible pour Laravel (attention aux contraintes SQL)
            // S'il s'appelle salaires_professeur_id_mois_annee_unique
            $table->dropUnique('salaires_professeur_id_mois_annee_unique');
            
            // On rajoute des index non-uniques ou nouveaux uniques
            $table->unique(['professeur_id', 'mois', 'annee'], 'unique_salaire_prof');
            $table->unique(['direction_user_id', 'mois', 'annee'], 'unique_salaire_direction');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('direction_users', function (Blueprint $table) {
            $table->dropColumn('salaire_base');
        });

        Schema::table('salaires', function (Blueprint $table) {
            $table->dropUnique('unique_salaire_prof');
            $table->dropUnique('unique_salaire_direction');
            
            $table->dropForeign(['direction_user_id']);
            $table->dropColumn('direction_user_id');
            
            $table->unsignedBigInteger('professeur_id')->nullable(false)->change();
            $table->unique(['professeur_id', 'mois', 'annee']);
        });
    }
};
