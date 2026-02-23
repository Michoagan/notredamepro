<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sanction extends Model
{
    use HasFactory;

    protected $fillable = [
        'eleve_id',
        'type',
        'motif',
        'date_incident',
        'status',
        'decision_par'
    ];

    public function eleve()
    {
        return $this->belongsTo(Eleve::class);
    }
}
