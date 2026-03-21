<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;

class PaiementReussiNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected $paiement;

    /**
     * Create a new notification instance.
     *
     * @return void
     */
    public function __construct($paiement)
    {
        $this->paiement = $paiement;
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
            'type' => 'paiement_reussi',
            'titre' => 'Paiement Validé',
            'message' => "Le paiement de {$this->paiement->montant} FCFA pour la scolarité de {$this->paiement->eleve->prenom} a été effectué avec succès.",
            'paiement_id' => $this->paiement->id,
            'eleve_id' => $this->paiement->eleve->id,
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
            \Log::warning("PaiementReussiNotification: Tuteur ID {$notifiable->id} n'a pas de device token.");
            return;
        }

        try {
            $factory = (new Factory)
                ->withServiceAccount(config('services.firebase.credentials'));
            
            $messaging = $factory->createMessaging();

            $title = "Paiement Validé ✅";
            $body = "Votre paiement de {$this->paiement->montant} FCFA pour {$this->paiement->eleve->prenom} a bien été reçu. Merci !";

            $message = CloudMessage::withTarget('token', $notifiable->fcm_token)
                ->withNotification(FirebaseNotification::create($title, $body))
                ->withData([
                    'type' => 'paiement',
                    'paiement_id' => (string) $this->paiement->id,
                    'eleve_id' => (string) $this->paiement->eleve->id,
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
                ]);

            $messaging->send($message);
            \Log::info("FCM PaiementReussi envoyé au tuteur ID {$notifiable->id} avec succès.");

        } catch (\Exception $e) {
            \Log::error("Erreur FCM PaiementReussi : " . $e->getMessage());
        }
    }
}
