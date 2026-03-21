<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use App\Models\Communique;

class NouveauCommuniqueNotification extends Notification
{
    use Queueable;

    private $communique;

    /**
     * Create a new notification instance.
     */
    public function __construct(Communique $communique)
    {
        $this->communique = $communique;
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
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'type' => 'communique',
            'titre' => 'Nouveau Communiqué',
            'message' => "Un nouveau communiqué est disponible : {$this->communique->titre}",
            'communique_id' => $this->communique->id,
            'cible' => $this->communique->type
        ];
    }

    /**
     * Envoi de la notification Push via Firebase.
     *
     * @param mixed $notifiable
     */
    public function toFcm($notifiable)
    {
        if (empty($notifiable->fcm_token)) {
            return;
        }

        try {
            $factory = (new \Kreait\Firebase\Factory)->withServiceAccount(base_path('firebase_credentials.json'));
            $messaging = $factory->createMessaging();

            $messageText = "Un nouveau communiqué est disponible : {$this->communique->titre}";

            $messageFCM = \Kreait\Firebase\Messaging\CloudMessage::withTarget('token', $notifiable->fcm_token)
                ->withNotification(\Kreait\Firebase\Messaging\Notification::create('Nouveau Communiqué', $messageText))
                ->withData([
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'type' => 'communique',
                    'communique_id' => (string)$this->communique->id,
                ]);

            $messaging->send($messageFCM);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Erreur d\'envoi FCM (NouveauCommunique) : ' . $e->getMessage());
        }
    }
}
