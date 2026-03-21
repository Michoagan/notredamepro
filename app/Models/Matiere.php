<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Matiere extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'nom',
        'categorie',
        'niveau',
        'cout_horaire',
        'heures_semaine',
        'professeurs_max',
        'description',
        'is_active'
    ];

    protected $casts = [
        'cout_horaire' => 'decimal:2',
        'professeurs_max' => 'integer',
        'heures_semaine' => 'integer',
        'is_active' => 'boolean'
    ];

    /**
     * Relation avec les professeurs
     */
    public function professeurs()
    {
        return $this->belongsToMany(Professeur::class, 'matiere_professeur')
                    ->withTimestamps();
    }

    /**
     * Get the main professor for this subject (if applicable) or the first one.
     * This is needed because ClasseController eager loads 'matieres.professeur'.
     */
    /**
     * Get the main professor for this subject (if applicable) or the first one.
     * This is needed because ClasseController eager loads 'matieres.professeur'.
     */
    public function professeur()
    {
        return $this->belongsToMany(Professeur::class, 'matiere_professeur')
                    ->withTimestamps()
                    ->orderBy('matiere_professeur.created_at', 'desc')
                    ->limit(1);
    }

    /**
     * Relation avec les classes
     */
   public function classes()
{
    return $this->belongsToMany(Classe::class, 'classe_matiere')
                ->withPivot('professeur_id', 'coefficient', 'ordre_affichage')
                ->withTimestamps();
}

    /**
     * Scope pour les matières actives
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope par catégorie
     */
    public function scopeByCategorie($query, $categorie)
    {
        return $query->where('categorie', $categorie);
    }

    /**
     * Scope par niveau
     */
    public function scopeByNiveau($query, $niveau)
    {
        return $query->where('niveau', $niveau);
    }

    /**
     * Accesseur pour le nombre de professeurs
     */
    public function getProfesseursCountAttribute()
    {
        return $this->professeurs()->count();
    }
    public function scopeOrderByName($query)
    {
        return $query->orderBy('nom');
    }
    /**
     * Accesseur pour le coût formaté
     */
    public function getCoutFormattedAttribute()
    {
        return number_format($this->cout_horaire, 0, ',', ' ') . ' FCFA/h';
    }

    /**
     * Vérifier si on peut assigner plus de professeurs
     */
    public function canAssignMoreProfesseurs()
    {
        return $this->professeurs_count < $this->professeurs_max;
    }

    public function presences()
    {
        return $this->hasMany(Presence::class, 'cours');
    }

    public function anciennesEpreuves()
    {
        return $this->hasMany(AncienneEpreuve::class);
    }

    public function notesExamens()
    {
        return $this->hasMany(NoteExamen::class);
    }
}