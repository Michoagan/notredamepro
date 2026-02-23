<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CahierTexte extends Model
{
    protected $fillable = [
        'classe_id',
        'professeur_id',
        'matiere_id',
        'date_cours',
        'duree_cours',
        'heure_debut',
        'notion_cours',
        'objectifs',
        'contenu_cours',
        'travail_a_faire',
        'observations'
    ];

    protected $casts = [
        'date_cours' => 'date',
    ];
    
    public function classe()
    {
        return $this->belongsTo(Classe::class);
    }
    
    public function professeur()
    {
        return $this->belongsTo(Professeur::class);
    }

    public function matiere()
    {
        return $this->belongsTo(Matiere::class);
    }

     protected function dateCours(): Attribute
    {
        return Attribute::make(
            get: fn ($value) => \Carbon\Carbon::parse($value),
        );
    }
}

