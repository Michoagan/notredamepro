<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use App\Models\Evenement;

class NouvelEvenementNotification extends Notification
{
    use Queueable;

    private $evenement;

    /**
     * Create a new notification instance.
     */
    public function __construct(Evenement $evenement)
    {
        $this->evenement = $evenement;
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
        $dateDebut = \Carbon\Carbon::parse($this->evenement->date_debut)->format('d/m/Y');
        $message = "Date à retenir: {$this->evenement->titre} planifié pour le {$dateDebut}.";

        return [
            'type' => 'evenement',
            'titre' => 'Nouvel Événement Scolaire',
            'message' => $message,
            'evenement_id' => $this->evenement->id,
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

            $dateDebut = \Carbon\Carbon::parse($this->evenement->date_debut)->format('d/m/Y');
            $messageText = "Date à retenir: {$this->evenement->titre} planifié pour le {$dateDebut}.";

            $messageFCM = \Kreait\Firebase\Messaging\CloudMessage::withTarget('token', $notifiable->fcm_token)
                ->withNotification(\Kreait\Firebase\Messaging\Notification::create('Nouvel Événement Scolaire', $messageText))
                ->withData([
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'type' => 'evenement',
                    'evenement_id' => (string)$this->evenement->id,
                ]);

            $messaging->send($messageFCM);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Erreur d\'envoi FCM (NouvelEvenement) : ' . $e->getMessage());
        }
    }
}
