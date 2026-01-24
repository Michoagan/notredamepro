<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class AccountApproved extends Notification
{
    use Queueable;

    public function __construct()
    {
        //
    }

    public function via($notifiable)
    {
        return ['mail'];
    }

    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject('🎉 Votre compte a été approuvé - COLLEGE PRIVE NOTRE DAME DE TOUTES GRACES')
            ->greeting('Bonjour ' . $notifiable->first_name . ' !')
            ->line('Nous avons le plaisir de vous informer que votre compte a été approuvé avec succès.')
            ->line('**Détails de votre compte :**')
            ->line('- **Nom :** ' . $notifiable->first_name . ' ' . $notifiable->last_name)
            ->line('- **Rôle :** ' . ucfirst($notifiable->role))
            ->line('- **Email :** ' . $notifiable->email)
            ->action('Accéder à mon compte', route('direction.login'))
            ->line('Vous pouvez maintenant vous connecter à votre espace personnel.')
            ->line('Si vous avez oublié votre mot de passe, utilisez la fonction "Mot de passe oublié".')
            ->salutation('Cordialement,<br>L\'équipe administrative<br>COLLEGE PRIVE NOTRE DAME DE TOUTES GRACES');
    }
}