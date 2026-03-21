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
        return ['database', \App\Channels\FcmChannel::class];
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
        $message = "Une absence a été signalée le {$date}.";

        return [
            'titre' => 'Avis d\'Absence',
            'message' => $message,
            'eleve_id' => $this->presence->eleve_id,
            'presence_id' => $this->presence->id,
            'type_notification' => 'absence',
        ];
    }

    public function toFcm($notifiable)
    {
        if (empty($notifiable->fcm_token)) {
            return;
        }

        try {
            $factory = (new \Kreait\Firebase\Factory)->withServiceAccount(config('services.firebase.credentials'));
            $messaging = $factory->createMessaging();

            $date = \Carbon\Carbon::parse($this->presence->date)->format('d/m/Y');
            $messageText = "Une absence a été signalée le {$date}.";

            $messageFCM = \Kreait\Firebase\Messaging\CloudMessage::withTarget('token', $notifiable->fcm_token)
                ->withNotification(\Kreait\Firebase\Messaging\Notification::create('Avis d\'Absence', $messageText))
                ->withData([
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'type' => 'absence',
                    'eleve_id' => (string)$this->presence->eleve_id,
                    'presence_id' => (string)$this->presence->id,
                ]);

            $messaging->send($messageFCM);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Erreur d\'envoi FCM (AbsenceAdded) : ' . $e->getMessage());
        }
    }
}
