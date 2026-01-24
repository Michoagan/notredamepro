<?php

namespace App\Notifications;

use App\Models\Professor;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ProfessorCodeResetNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public $professor;
    public $newCode;

    public function __construct(Professor $professor, $newCode)
    {
        $this->professor = $professor;
        $this->newCode = $newCode;
    }

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Réinitialisation de votre code - École Les Pyramides')
            ->line('Votre code personnel a été réinitialisé.')
            ->line('**Nouveau code :** ' . $this->newCode)
            ->action('Se connecter', url('/professeur/login'))
            ->line('Si vous n\'avez pas demandé cette réinitialisation, veuillez contacter l\'administration.');
    }
}