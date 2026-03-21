<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SessionComposition extends Model
{
    protected $fillable = [
        'libelle',
        'trimestre',
        'numero_devoir',
        'cible',
        'classe_id',
    ];

    public function classe()
    {
        return $this->belongsTo(Classe::class, 'classe_id');
    }

    public function horaires()
    {
        return $this->hasMany(HoraireComposition::class, 'session_id');
    }
}
