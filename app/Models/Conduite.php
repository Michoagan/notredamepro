<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Conduite extends Model
{
    protected $fillable = [
        'eleve_id',
        'classe_id',
        'professeur_id',
        'trimestre',
        'note',
        'appreciation',
    ];

    public function eleve()
    {
        return $this->belongsTo(Eleve::class);
    }

    public function classe()
    {
        return $this->belongsTo(Classe::class);
    }

    public function professeur()
    {
        return $this->belongsTo(Professeur::class);
    }
}
