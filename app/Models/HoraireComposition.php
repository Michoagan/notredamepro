<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HoraireComposition extends Model
{
    protected $fillable = [
        'session_id',
        'matiere_id',
        'date_composition',
        'heure_debut',
        'heure_fin',
    ];

    protected $casts = [
        'date_composition' => 'date',
    ];

    public function session()
    {
        return $this->belongsTo(SessionComposition::class, 'session_id');
    }

    public function matiere()
    {
        return $this->belongsTo(Matiere::class, 'matiere_id');
    }
}
