<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Vente extends Model
{
    use HasFactory;

    protected $fillable = [
        'reference',
        'eleve_id',
        'nom_client',
        'montant_total',
        'date_vente',
        'auteur_id',
    ];

    protected $casts = [
        'date_vente' => 'datetime',
        'montant_total' => 'decimal:2',
    ];

    public function auteur()
    {
        return $this->belongsTo(Direction::class, 'auteur_id');
    }

    public function eleve()
    {
        return $this->belongsTo(Eleve::class);
    }

    public function lignes()
    {
        return $this->hasMany(LigneVente::class);
    }
}
