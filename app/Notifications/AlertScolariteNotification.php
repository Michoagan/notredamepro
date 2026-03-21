<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class AlertScolariteNotification extends Notification
{
    use Queueable;

    private $tranche;
    private $montantRequis;
    private $totalPaye;
    private $eleve;
    private $joursRestants;

    /**
     * Create a new notification instance.
     */
    public function __construct($tranche, $montantRequis, $totalPaye, $eleve, $joursRestants)
    {
        $this->tranche = $tranche;
        $this->montantRequis = $montantRequis;
        $this->totalPaye = $totalPaye;
        $this->eleve = $eleve;
        $this->joursRestants = $joursRestants;
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
        $jourJTexte = $this->joursRestants == 0 ? "aujourd'hui" : "dans {$this->joursRestants} jour(s)";
        $message = "Scolarité : La date limite pour le paiement de la Tranche {$this->tranche->pourcentage}% de l'élève {$this->eleve->prenom} est {$jourJTexte}. Veuillez régulariser le montant de " . number_format($this->montantRequis - $this->totalPaye, 0, ',', ' ') . " FCFA restant pour éviter toute interruption.";

        return [
            'type' => 'scolarite',
            'titre' => 'Alerte de Paiement de Scolarité',
            'message' => $message,
            'eleve_id' => $this->eleve->id,
            'tranche_id' => $this->tranche->id,
            'montant_restant' => $this->montantRequis - $this->totalPaye
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

            $jourJTexte = $this->joursRestants == 0 ? "aujourd'hui" : "dans {$this->joursRestants} jour(s)";
            $messageText = "Scolarité : La date limite pour le paiement de la Tranche {$this->tranche->pourcentage}% de l'élève {$this->eleve->prenom} est {$jourJTexte}. Veuillez régulariser le montant de " . number_format($this->montantRequis - $this->totalPaye, 0, ',', ' ') . " FCFA restant pour éviter toute interruption.";

            $messageFCM = \Kreait\Firebase\Messaging\CloudMessage::withTarget('token', $notifiable->fcm_token)
                ->withNotification(\Kreait\Firebase\Messaging\Notification::create('Alerte de Scolarité', $messageText))
                ->withData([
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'type' => 'scolarite',
                    'eleve_id' => (string)$this->eleve->id,
                ]);

            $messaging->send($messageFCM);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Erreur d\'envoi FCM (ScolariteAlert) : ' . $e->getMessage());
        }
    }
}
