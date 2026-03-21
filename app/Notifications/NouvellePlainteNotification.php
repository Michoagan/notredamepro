<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;

class NouvellePlainteNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected $plainte;

    /**
     * Create a new notification instance.
     *
     * @return void
     */
    public function __construct($plainte)
    {
        $this->plainte = $plainte;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        return ['database', \App\Channels\FcmChannel::class];
    }

    /**
     * Get the array representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function toDatabase($notifiable)
    {
        return [
            'type' => 'plainte',
            'titre' => 'Nouvelle observation disciplinaire',
            'message' => "Une plainte/observation ({$this->plainte->type_plainte}) a été enregistrée pour {$this->plainte->eleve->prenom}.",
            'plainte_id' => $this->plainte->id,
            'eleve_id' => $this->plainte->eleve->id,
            'date' => now()->toDateTimeString(),
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
            \Log::warning("NouvellePlainteNotification: Tuteur ID {$notifiable->id} n'a pas de device token.");
            return;
        }

        try {
            $factory = (new Factory)
                ->withServiceAccount(config('services.firebase.credentials'));
            
            $messaging = $factory->createMessaging();

            $title = "Alerte Discipline ⚠️";
            // ucfirst pour majuscule (ex : retard -> Retard)
            $typeFormatted = ucfirst($this->plainte->type_plainte);
            $body = "Une observation de type '{$typeFormatted}' a été enregistrée pour {$this->plainte->eleve->prenom}.";

            $message = CloudMessage::withTarget('token', $notifiable->fcm_token)
                ->withNotification(FirebaseNotification::create($title, $body))
                ->withData([
                    'type' => 'plainte',
                    'plainte_id' => (string) $this->plainte->id,
                    'eleve_id' => (string) $this->plainte->eleve->id,
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
                ]);

            $messaging->send($message);
            \Log::info("FCM NouvellePlainte envoyé au tuteur ID {$notifiable->id} avec succès.");

        } catch (\Exception $e) {
            \Log::error("Erreur FCM NouvellePlainte : " . $e->getMessage());
        }
    }
}
