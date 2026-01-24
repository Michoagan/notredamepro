<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class PasswordResetCodeNotification extends Notification
{
    use Queueable;

    public $code;

    public function __construct($code)
    {
        $this->code = $code;
    }

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Code de réinitialisation de mot de passe - Plateforme Direction')
            ->greeting('Bonjour ' . $notifiable->first_name . ' !')
            ->line('Vous avez demandé à réinitialiser votre mot de passe.')
            ->line('Utilisez le code de vérification suivant :')
            ->line('## **' . $this->code . '**')
            ->line('Ce code est valable pendant **15 minutes**.')
            ->line('Si vous n\'avez pas demandé cette réinitialisation, veuillez ignorer cet email.')
            ->salutation('Cordialement,<br>L\'équipe de la Plateforme Direction');
    }

    public function toArray(object $notifiable): array
    {
        return [
            'code' => $this->code,
        ];
    }
}