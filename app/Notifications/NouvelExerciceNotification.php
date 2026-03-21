<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use App\Models\CahierTexte;

class NouvelExerciceNotification extends Notification
{
    use Queueable;

    protected $cahierTexte;

    public function __construct(CahierTexte $cahierTexte)
    {
        $this->cahierTexte = $cahierTexte;
    }

    public function via($notifiable)
    {
        return ['database', \App\Channels\FcmChannel::class];
    }

    public function toDatabase($notifiable)
    {
        $matiereNom = $this->cahierTexte->matiere ? $this->cahierTexte->matiere->nom : 'une matière';
        $message = 'Un travail à faire a été donné pour le ' . \Carbon\Carbon::parse($this->cahierTexte->date_cours)->format('d/m/Y') . '.';
        
        return [
            'type' => 'nouvel_exercice',
            'titre' => 'Nouvel exercice en ' . $matiereNom,
            'message' => $message,
            'cahier_texte_id' => $this->cahierTexte->id,
            'classe_id' => $this->cahierTexte->classe_id,
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

            $matiereNom = $this->cahierTexte->matiere ? $this->cahierTexte->matiere->nom : 'une matière';
            $messageText = 'Un travail à faire a été donné pour le ' . \Carbon\Carbon::parse($this->cahierTexte->date_cours)->format('d/m/Y') . '.';

            $messageFCM = \Kreait\Firebase\Messaging\CloudMessage::withTarget('token', $notifiable->fcm_token)
                ->withNotification(\Kreait\Firebase\Messaging\Notification::create('Nouvel exercice en ' . $matiereNom, $messageText))
                ->withData([
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'type' => 'nouvel_exercice',
                    'cahier_texte_id' => (string)$this->cahierTexte->id,
                ]);

            $messaging->send($messageFCM);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Erreur d\'envoi FCM (NouvelExercice) : ' . $e->getMessage());
        }
    }
}
