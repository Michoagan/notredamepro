<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use App\Models\CahierTexte;
use App\Models\Eleve;

class ExerciceNonFaitNotification extends Notification
{
    use Queueable;

    protected $cahierTexte;
    protected $eleve;

    public function __construct(Eleve $eleve, ?CahierTexte $cahierTexte = null)
    {
        $this->eleve = $eleve;
        $this->cahierTexte = $cahierTexte;
    }

    public function via($notifiable)
    {
        return ['database', \App\Channels\FcmChannel::class];
    }

    public function toDatabase($notifiable)
    {
        if ($this->cahierTexte) {
            $matiereNom = $this->cahierTexte->matiere ? $this->cahierTexte->matiere->nom : 'une matière';
            $message = $this->eleve->prenom . ' n\'a pas fait son exercice de ' . $matiereNom . ' (donné le ' . \Carbon\Carbon::parse($this->cahierTexte->date_cours)->format('d/m/Y') . ').';
        } else {
            $message = $this->eleve->prenom . ' n\'a pas fait son exercice aujourd\'hui.';
        }
        
        return [
            'type' => 'exercice_non_fait',
            'titre' => 'Exercice non fait : ' . $this->eleve->prenom,
            'message' => $message,
            'cahier_texte_id' => $this->cahierTexte ? $this->cahierTexte->id : null,
            'eleve_id' => $this->eleve->id,
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

            if ($this->cahierTexte) {
                $matiereNom = $this->cahierTexte->matiere ? $this->cahierTexte->matiere->nom : 'une matière';
                $messageText = $this->eleve->prenom . ' n\'a pas fait son exercice de ' . $matiereNom . ' (donné le ' . \Carbon\Carbon::parse($this->cahierTexte->date_cours)->format('d/m/Y') . ').';
            } else {
                $messageText = $this->eleve->prenom . ' n\'a pas fait son exercice aujourd\'hui.';
            }

            $messageFCM = \Kreait\Firebase\Messaging\CloudMessage::withTarget('token', $notifiable->fcm_token)
                ->withNotification(\Kreait\Firebase\Messaging\Notification::create('Exercice non fait : ' . $this->eleve->prenom, $messageText))
                ->withData([
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'type' => 'exercice_non_fait',
                    'eleve_id' => (string)$this->eleve->id,
                    'cahier_texte_id' => $this->cahierTexte ? (string)$this->cahierTexte->id : '',
                ]);

            $messaging->send($messageFCM);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Erreur d\'envoi FCM (ExerciceNonFait) : ' . $e->getMessage());
        }
    }
}
