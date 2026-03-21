<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TrancheScolarite extends Model
{
    use HasFactory;

    protected $fillable = [
        'nom',
        'pourcentage',
        'date_limite',
        'annee_scolaire',
    ];

    protected $casts = [
        'date_limite' => 'date',
        'pourcentage' => 'integer',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($tranche) {
            if (empty($tranche->annee_scolaire)) {
                $tranche->annee_scolaire = Contribution::getAnneeScolaireCourante();
            }
        });
    }
}
