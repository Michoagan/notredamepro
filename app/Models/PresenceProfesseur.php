<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PresenceProfesseur extends Model
{
    use HasFactory;

    protected $fillable = [
        'professeur_id',
        'date',
        'status',
        'heure_arrivee',
        'observation'
    ];

    public function professeur()
    {
        return $this->belongsTo(Professeur::class);
    }
}
