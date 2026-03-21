<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ConvocationRappelNotification extends Notification
{
    use Queueable;

    private $session;
    private $eleve;
    private $joursRestants;
    private $isLocked;

    /**
     * Create a new notification instance.
     */
    public function __construct($session, $eleve, $joursRestants, $isLocked)
    {
        $this->session = $session;
        $this->eleve = $eleve;
        $this->joursRestants = $joursRestants;
        $this->isLocked = $isLocked;
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
        $jourJTexte = $this->joursRestants == 0 ? "Aujourd'hui" : "Dans {$this->joursRestants} jour(s)";
        $message = "Composition ({$this->session->libelle}) pour {$this->eleve->prenom} {$jourJTexte}.";
        
        if ($this->isLocked) {
            $message .= " Attention: La scolarité n'est pas à jour. Veuillez régulariser pour obtenir la convocation.";
        } else {
            $message .= " La convocation est disponible au téléchargement.";
        }

        return [
            'type' => 'examen',
            'titre' => 'Rappel de Composition',
            'message' => $message,
            'eleve_id' => $this->eleve->id,
            'session_id' => $this->session->id,
            'is_locked' => $this->isLocked
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

            $jourJTexte = $this->joursRestants == 0 ? "Aujourd'hui" : "Dans {$this->joursRestants} jour(s)";
            $messageText = "Composition ({$this->session->libelle}) pour {$this->eleve->prenom} {$jourJTexte}.";
            
            if ($this->isLocked) {
                $messageText .= " Attention: La scolarité n'est pas à jour. Veuillez régulariser pour obtenir la convocation.";
            } else {
                $messageText .= " La convocation est disponible au téléchargement.";
            }

            $messageFCM = \Kreait\Firebase\Messaging\CloudMessage::withTarget('token', $notifiable->fcm_token)
                ->withNotification(\Kreait\Firebase\Messaging\Notification::create('Rappel de Composition', $messageText))
                ->withData([
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'type' => 'examen',
                    'eleve_id' => (string)$this->eleve->id,
                    'session_id' => (string)$this->session->id,
                ]);

            $messaging->send($messageFCM);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Erreur d\'envoi FCM (Convocation) : ' . $e->getMessage());
        }
    }
}
