<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MouvementStock extends Model
{
    use HasFactory;

    protected $table = 'mouvements_stock';

    protected $fillable = [
        'article_id',
        'type', // 'entree', 'sortie', 'correction', 'vente'
        'quantite',
        'stock_precedent',
        'nouveau_stock',
        'motif',
        'source_type',
        'source_id',
        'auteur_id',
    ];

    public function article()
    {
        return $this->belongsTo(Article::class);
    }

    public function source()
    {
        return $this->morphTo();
    }

    public function auteur()
    {
        return $this->belongsTo(Direction::class, 'auteur_id');
    }
}
