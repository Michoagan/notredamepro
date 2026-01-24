<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('professeurs', function (Blueprint $table) {
            $table->id();
            $table->string('last_name');
            $table->string('first_name');
            $table->enum('gender', ['M', 'F']);
            $table->date('birth_date');
            $table->string('email')->unique();
            $table->string('phone');
            $table->string('matiere');
            $table->string('photo')->nullable();
            $table->string('personal_code')->unique();
            $table->boolean('is_active')->default(true);
            $table->softDeletes();
            $table->timestamps();

            $table->index('matiere');
            $table->index('personal_code');
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('professeurs');
    }
};