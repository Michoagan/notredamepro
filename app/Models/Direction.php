<?php

namespace App\Models;

use Illuminate\Contracts\Auth\CanResetPassword;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class Direction extends Authenticatable implements CanResetPassword
{
    use HasFactory, \Laravel\Sanctum\HasApiTokens, Notifiable, SoftDeletes;

    protected $table = 'direction_users';

    protected $fillable = [
        'last_name',
        'first_name',
        'gender',
        'birth_date',
        'role',
        'email',
        'phone',
        'password',
        'is_active',           // Assurez-vous que ces champs sont présents
        'approved_by_admin',    // dans le $fillable
        'approved_at',
        'approved_by',
        'admin_notes',
    ];

    protected $casts = [
        'birth_date' => 'date',
        'approved_at' => 'datetime',
        'is_active' => 'boolean',
        'approved_by_admin' => 'boolean',
        'email_verified_at' => 'datetime',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Route pour les notifications par email
     */
    public function routeNotificationForMail()
    {
        return $this->email;
    }

    /**
     * Get the user's full name.
     */
    public function getFullNameAttribute(): string
    {
        return "{$this->first_name} {$this->last_name}";
    }

    /**
     * Check if user is a director
     */
    public function isDirecteur(): bool
    {
        return $this->role === 'directeur';
    }

    /**
     * Check if user is a censeur
     */
    public function isCenseur(): bool
    {
        return $this->role === 'censeur';
    }

    /**
     * Check if user is a surveillant
     */
    public function isSurveillant(): bool
    {
        return $this->role === 'surveillant';
    }

    /**
     * Check if user is from secretariat
     */
    public function isSecretariat(): bool
    {
        return $this->role === 'secretariat';
    }

    /**
     * Check if user is a comptable
     */
    public function isComptable(): bool
    {
        return $this->role === 'comptable';
    }

    public function getEmailForPasswordReset()
    {
        return $this->email;
    }

    /**
     * Send the password reset notification.
     */
    public function sendPasswordResetCodeNotification($code)
    {
        $this->notify(new \App\Notifications\PasswordResetCodeNotification($code));
    }
}
