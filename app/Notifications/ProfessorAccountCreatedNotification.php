<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ProfessorAccountCreatedNotification extends Notification
{
    use Queueable;

    public $professeur;

    public $personalCode;

    /**
     * Create a new notification instance.
     */
    public function __construct($professeur, $personalCode)
    {
        $this->professeur = $professeur;
        $this->personalCode = $personalCode; // Code en clair
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Votre compte professeur a été créé - Plateforme Éducative')
            ->greeting('Bonjour '.$this->professeur->first_name.' '.$this->professeur->last_name.' !')
            ->line('Votre compte professeur a été créé avec succès sur notre plateforme.')
            ->line('Voici vos informations de connexion :')
            ->line('**Email :** '.$this->professeur->email)
            ->line('**Code personnel :** '.$this->personalCode) // Code en clair affiché ici
            ->line('**Matière :** '.$this->professeur->matiere)
            ->action('Se connecter', url('/professeur/login'))
            ->line('Nous vous recommandons de changer votre code personnel après votre première connexion.')
            ->line('Si vous n\'avez pas demandé la création de ce compte, veuillez ignorer cet email.')
            ->salutation('Cordialement,<br>L\'équipe de la Plateforme Éducative');
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        return [
            'professeur_id' => $this->professeur->id,
            'personal_code' => $this->personalCode,
        ];
    }
}
