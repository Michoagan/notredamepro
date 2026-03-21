<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PaiementProfesseur extends Model
{
    protected $fillable = [
        'professeur_id',
        'mois',
        'annee',
        'total_heures',
        'montant_heures',
        'montant_primes',
        'montant_total',
        'statut',
        'date_paiement',
    ];

    public function professeur()
    {
        return $this->belongsTo(Professeur::class);
    }
}
