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
        Schema::create('session_compositions', function (Blueprint $table) {
            $table->id();
            $table->string('libelle');
            $table->integer('trimestre')->default(1);
            $table->integer('numero_devoir')->default(1); // 1 or 2
            $table->boolean('is_global')->default(true);
            $table->foreignId('classe_id')->nullable()->constrained('classes')->nullOnDelete();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('session_compositions');
    }
};
