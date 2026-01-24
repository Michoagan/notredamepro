<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class AccountRejected extends Notification
{
    use Queueable;

    protected $reason;

    public function __construct($reason)
    {
        $this->reason = $reason;
    }

    public function via($notifiable)
    {
        return ['mail'];
    }

    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject('❌ Votre inscription n\'a pas été approuvée - COLLEGE PRIVE NOTRE DAME DE TOUTES GRACES')
            ->greeting('Bonjour ' . $notifiable->first_name . ',')
            ->line('Nous regrettons de vous informer que votre demande d\'inscription n\'a pas été approuvée.')
            ->line('**Raison :**')
            ->line($this->reason)
            ->line('**Que faire maintenant ?**')
            ->line('- Vous pouvez contacter l\'administration pour plus d\'informations')
            ->line('- Ou soumettre une nouvelle demande avec des informations complémentaires')
            ->line('Si vous pensez qu\'il s\'agit d\'une erreur, n\'hésitez pas à nous contacter.')
            ->action('Contactez l\'administration', 'mailto:admin@college-notredame.com')
            ->salutation('Cordialement,<br>L\'équipe administrative<br>COLLEGE PRIVE NOTRE DAME DE TOUTES GRACES');
    }
}