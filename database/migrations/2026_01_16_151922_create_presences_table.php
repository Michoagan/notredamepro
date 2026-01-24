<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('presences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('eleve_id')->constrained()->onDelete('cascade');
            $table->foreignId('classe_id')->constrained()->onDelete('cascade');
            $table->foreignId('professeur_id')->constrained()->onDelete('cascade');
            $table->date('date');
            $table->boolean('present')->default(true);
            $table->text('remarque')->nullable();
            $table->timestamps();
             $table->foreignId('cours_id')->after('date')->constrained('matieres')->onDelete('cascade');
            
            $table->unique(['eleve_id', 'date', 'classe_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('presences');
    }
};