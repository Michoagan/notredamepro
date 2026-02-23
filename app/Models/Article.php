<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Article extends Model
{
    use HasFactory;

    protected $fillable = [
        'designation',
        'type', // 'physique', 'service'
        'prix_unitaire',
        'stock_actuel',
        'stock_min',
        'est_actif',
    ];

    protected $casts = [
        'est_actif' => 'boolean',
        'prix_unitaire' => 'decimal:2',
    ];

    public function mouvementStocks()
    {
        return $this->hasMany(MouvementStock::class);
    }
}
