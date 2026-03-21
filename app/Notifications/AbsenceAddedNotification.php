<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class AbsenceAddedNotification extends Notification
{
    use Queueable;

    protected $presence;

    /**
     * Create a new notification instance.
     */
    public function __construct($presence)
    {
        $this->presence = $presence;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->line('The introduction to the notification.')
            ->action('Notification Action', url('/'))
            ->line('Thank you for using our application!');
    }

    public function toArray(object $notifiable): array
    {
        $date = \Carbon\Carbon::parse($this->presence->date)->format('d/m/Y');
        return [
            'titre' => 'Avis d\'Absence',
            'message' => "Une absence a été signalée le {$date}.",
            'eleve_id' => $this->presence->eleve_id,
            'presence_id' => $this->presence->id,
            'type_notification' => 'absence',
        ];
    }
}
