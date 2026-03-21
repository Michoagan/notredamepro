<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TauxHoraire extends Model
{
    protected $fillable = [
        'professeur_id',
        'classe_id',
        'taux_horaire',
        'prime_mensuelle',
    ];

    public function professeur()
    {
        return $this->belongsTo(Professeur::class);
    }

    public function classe()
    {
        return $this->belongsTo(Classe::class);
    }
}
