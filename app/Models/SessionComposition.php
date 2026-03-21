<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SessionComposition extends Model
{
    protected $fillable = [
        'libelle',
        'trimestre',
        'numero_devoir',
        'is_global',
        'classe_id',
    ];

    protected $casts = [
        'is_global' => 'boolean',
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
