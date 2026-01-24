<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('tuteurs', function (Blueprint $table) {
            $table->id();
            $table->string('nom');
            $table->string('prenom');
            $table->string('email')->unique();
            $table->string('telephone')->unique();
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
        });

        // Table pivot pour la relation many-to-many entre parents et élèves
        Schema::create('eleve_tuteur', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tuteur_id')->constrained()->onDelete('cascade');
            $table->foreignId('eleve_id')->constrained()->onDelete('cascade');
            $table->string('lien_tuteur'); // père, mère, tuteur, etc.
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('tuteurs');
        Schema::dropIfExists('eleve_tuteur');
    }
};