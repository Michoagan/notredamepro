<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Plainte extends Model
{
    use HasFactory;

    protected $fillable = [
        'eleve_id',
        'classe_id',
        'surveillant_id',
        'type_plainte',
        'date_plainte',
        'details',
        'sanction',
        'statut'
    ];

    protected $casts = [
        'date_plainte' => 'date'
    ];

    public function eleve()
    {
        return $this->belongsTo(Eleve::class);
    }

    public function classe()
    {
        return $this->belongsTo(Classe::class);
    }

    public function surveillant()
    {
        return $this->belongsTo(Direction::class, 'surveillant_id');
    }
}