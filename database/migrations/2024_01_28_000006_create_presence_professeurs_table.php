<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('presence_professeurs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('professeur_id')->constrained('professeurs')->onDelete('cascade');
            $table->date('date');
            $table->string('status'); // Présent, Absent, Retard, Excusé
            $table->time('heure_arrivee')->nullable();
            $table->text('observation')->nullable();
            $table->timestamps();
            
            // Un prof ne peut avoir qu'un status par jour (ou on update le même record)
            $table->unique(['professeur_id', 'date']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('presence_professeurs');
    }
};
