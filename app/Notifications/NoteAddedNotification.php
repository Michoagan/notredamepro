<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class NoteAddedNotification extends Notification
{
    use Queueable;

    protected $note;

    /**
     * Create a new notification instance.
     */
    public function __construct($note)
    {
        $this->note = $note;
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
        $matiereNom = $this->note->matiere ? $this->note->matiere->nom : 'une matière';
        return [
            'titre' => 'Nouvelle Note Ajoutée',
            'message' => "Une nouvelle note a été enregistrée en {$matiereNom} pour le trimestre {$this->note->trimestre}.",
            'eleve_id' => $this->note->eleve_id,
            'note_id' => $this->note->id,
            'type_notification' => 'note',
        ];
    }
}
