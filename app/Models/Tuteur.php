<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

use Illuminate\Database\Eloquent\Relations\HasManyThrough;


class Tuteur extends Authenticatable
{
    use HasFactory, Notifiable, \Laravel\Sanctum\HasApiTokens;

    protected $table = 'tuteurs';

    protected $fillable = [
        'nom',
        'prenom',
        'email',
        'telephone',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts()
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function eleves()
    {
        return $this->belongsToMany(Eleve::class, 'eleve_tuteur')
                    ->withPivot('lien_tuteur')
                    ->withTimestamps();
    }

    public function getFullNameAttribute()
    {
        return "{$this->prenom} {$this->nom}";
    }

     public function paiements(): HasManyThrough
    {
        return $this->hasManyThrough(
            Paiement::class,
            Eleve::class,
            'parent_id', // Clé étrangère sur la table eleves
            'eleve_id', // Clé étrangère sur la table paiements
            'id', // Clé locale sur la table parents
            'id' // Clé locale sur la table eleves
        );
    }

    /**
     * Obtenir les paiements réussis.
     */
    public function paiementsReussis()
    {
        return $this->paiements()->where('statut', Paiement::STATUT_REUSSI);
    }

    /**
     * Obtenir le total des paiements effectués.
     */
    public function getTotalPaiementsAttribute()
    {
        return $this->paiementsReussis()->sum('montant');
    }

    /**
     * Obtenir l'historique des paiements groupés par mois.
     */
    public function getPaiementsParMois()
    {
        return $this->paiementsReussis()
            ->selectRaw('YEAR(date_paiement) as annee, MONTH(date_paiement) as mois, SUM(montant) as total')
            ->groupBy('annee', 'mois')
            ->orderBy('annee', 'desc')
            ->orderBy('mois', 'desc')
            ->get();
    }
}