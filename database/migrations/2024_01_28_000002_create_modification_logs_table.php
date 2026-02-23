<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('modification_logs', function (Blueprint $table) {
            $table->id();
            // User who made the change (nullable because system can make changes too, or if user deleted)
            $table->string('user_name')->nullable(); 
            $table->string('user_role')->nullable();
            
            $table->string('action'); // e.g., 'create', 'update', 'delete', 'validate'
            $table->string('model');  // e.g., 'Note', 'EmploiDuTemps'
            $table->unsignedBigInteger('model_id')->nullable();
            
            $table->json('changes')->nullable(); // Store before/after or just description
            $table->ipAddress('ip_address')->nullable();
            
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('modification_logs');
    }
};
