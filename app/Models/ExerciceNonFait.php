<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ExerciceNonFait extends Model
{
    use HasFactory;

    protected $fillable = [
        'cahier_texte_id',
        'eleve_id',
    ];

    public function cahierTexte()
    {
        return $this->belongsTo(CahierTexte::class);
    }

    public function eleve()
    {
        return $this->belongsTo(Eleve::class);
    }
}
