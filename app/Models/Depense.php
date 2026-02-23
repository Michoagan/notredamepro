<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Depense extends Model
{
    use HasFactory;

    protected $fillable = [
        'motif',
        'montant',
        'date_depense',
        'categorie', // 'salaire', 'achat_materiel', 'tache', 'autre'
        'description',
        'auteur_id',
        'beneficiaire_type',
        'beneficiaire_id',
    ];

    protected $casts = [
        'date_depense' => 'date',
        'montant' => 'decimal:2',
    ];

    public function auteur()
    {
        return $this->belongsTo(Direction::class, 'auteur_id');
    }

    public function beneficiaire()
    {
        return $this->morphTo();
    }
}
