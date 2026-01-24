<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {


    Schema::create('cahier_textes', function (Blueprint $table) {
        $table->id();
        $table->foreignId('classe_id')->constrained()->onDelete('cascade');
        $table->foreignId('professeur_id')->constrained()->onDelete('cascade');
        $table->date('date_cours');
        $table->integer('duree_cours');
        $table->time('heure_debut');
        $table->string('notion_cours');
        $table->text('objectifs');
        $table->text('contenu_cours');
        $table->text('travail_a_faire')->nullable();
        $table->text('observations')->nullable();
        $table->timestamps();
        
        $table->unique(['classe_id', 'date_cours', 'professeur_id']);
    });
}
    

    public function down()
    {
        Schema::dropIfExists('cahier_textes');
    }
};