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
        Schema::create('classes', function (Blueprint $table) {
            $table->id();
            $table->string('nom')->unique();
            $table->string('niveau');
            $table->foreignId('professeur_principal_id')->constrained('professeurs')->onDelete('cascade');
            $table->decimal('cout_contribution', 10, 2);
            $table->integer('capacite_max')->default(40);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });


    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {

        Schema::dropIfExists('classes');
    }
};