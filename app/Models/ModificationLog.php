<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ModificationLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_name',
        'user_role',
        'action',
        'model',
        'model_id',
        'changes',
        'ip_address'
    ];

    protected $casts = [
        'changes' => 'array',
    ];
}
