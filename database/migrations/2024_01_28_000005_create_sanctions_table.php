<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('sanctions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('eleve_id')->constrained('eleves')->onDelete('cascade');
            $table->string('type'); // Avertissement, Blâme, Retenue, Exclusion temporaire, Exclusion définitive
            $table->text('motif');
            $table->date('date_incident');
            $table->string('status')->default('En cours'); // En cours, Terminé, Annulé
            $table->string('decision_par')->nullable(); // Nom de la personne ayant sanctionné
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('sanctions');
    }
};
