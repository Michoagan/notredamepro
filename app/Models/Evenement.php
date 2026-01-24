<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Evenement extends Model
{
    use HasFactory;

    protected $fillable = [
        'titre',
        'description',
        'date_debut',
        'date_fin',
        'lieu',
        'classes' // Si vous stockez les classes comme JSON
    ];

    protected $casts = [
        'date_debut' => 'datetime',
        'date_fin' => 'datetime',
        'classes' => 'array', // Si vous stockez les IDs des classes dans un champ JSON
    ];

    /**
     * Relation avec les classes (si vous utilisez une table pivot)
     */
    public function classesRelation()
    {
        return $this->belongsToMany(Classe::class, 'evenement_classe', 'evenement_id', 'classe_id');
    }

    /**
     * Accesseur pour obtenir les noms des classes
     */
    public function getClassesNomsAttribute()
    {
        if ($this->classes && count($this->classes) > 0) {
            $classeNoms = Classe::whereIn('id', $this->classes)
                ->pluck('nom')
                ->toArray();
            return implode(', ', $classeNoms);
        }
        
        return 'Toutes les classes';
    }

    /**
     * Scope pour les événements à venir
     */
    public function scopeAVenir($query)
    {
        return $query->where('date_debut', '>=', now())
                    ->orderBy('date_debut', 'asc');
    }

    /**
     * Scope pour les événements passés
     */
    public function scopePasses($query)
    {
        return $query->where('date_fin', '<', now())
                    ->orderBy('date_debut', 'desc');
    }

    /**
     * Vérifie si l'événement est à venir
     */
    public function estAVenir()
    {
        return $this->date_debut->isFuture();
    }

    /**
     * Vérifie si l'événement est en cours
     */
    public function estEnCours()
    {
        $now = now();
        return $now->between($this->date_debut, $this->date_fin);
    }

    /**
     * Vérifie si l'événement est terminé
     */
    public function estTermine()
    {
        return $this->date_fin->isPast();
    }

    /**
     * Formatte la durée de l'événement
     */
    public function getDureeAttribute()
    {
        return $this->date_debut->diffForHumans($this->date_fin, true);
    }

    /**
     * Accesseur pour le statut de l'événement
     */
    public function getStatutAttribute()
    {
        if ($this->estTermine()) {
            return 'terminé';
        } elseif ($this->estEnCours()) {
            return 'en cours';
        } else {
            return 'à venir';
        }
    }

    /**
     * Vérifie si une classe participe à l'événement
     */
    public function classeParticipe($classeId)
    {
        if (empty($this->classes)) {
            return true; // Toutes les classes participent
        }
        
        return in_array($classeId, $this->classes);
    }

    public static function tousEvenements()
    {
        return self::orderBy('date_debut', 'desc')->get();
    }

    /**
     * Récupère les événements à venir
     */
    public static function evenementsAVenir()
    {
        return self::where('date_debut', '>=', now())
                   ->orderBy('date_debut', 'asc')
                   ->get();
    }

    public static function supprimerEvenementsExpires()
    {
        try {
            $maintenant = Carbon::now();
            $evenementsExpires = self::where('date_fin', '<', $maintenant)->get();
            $count = $evenementsExpires->count();
            
            // Supprimer les événements expirés
            foreach ($evenementsExpires as $evenement) {
                $evenement->delete();
            }
            
            // Journaliser la suppression
            if ($count > 0) {
                Log::info("$count événement(s) expiré(s) supprimé(s) automatiquement");
            }
            
            return $count;
            
        } catch (\Exception $e) {
            Log::error('Erreur lors de la suppression des événements expirés: ' . $e->getMessage());
            return 0;
        }
    }

    /**
     * Vérifie si l'événement est expiré
     */
    public function estExpire()
    {
        return $this->date_fin->isPast();
    }

    /**
     * Scope pour les événements non expirés
     */
    public function scopeNonExpires($query)
    {
        return $query->where('date_fin', '>=', Carbon::now());
    }
}