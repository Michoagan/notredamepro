<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Classe;
use App\Models\Matiere;

class AncienneEpreuve extends Model
{
    use HasFactory;

    protected $fillable = [
        'titre',
        'matiere_id',
        'classe_id',
        'annee',
        'type',
        'file_path',
    ];

    public function classe()
    {
        return $this->belongsTo(Classe::class);
    }

    public function matiere()
    {
        return $this->belongsTo(Matiere::class);
    }
}
