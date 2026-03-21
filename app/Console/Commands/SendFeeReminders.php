<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Eleve;
use App\Models\TrancheScolarite;
use App\Models\Contribution;
use App\Notifications\AlertScolariteNotification;

class SendFeeReminders extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:send-fee-reminders';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Vérifier tous les jours si une tranche de scolarité arrive à échéance (J-14) et envoyer des rappels Firebase aux parents en retard';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info("Début de la vérification des rappels de scolarité...");

        // On prend l'année scolaire courante
        $anneeScolaire = Contribution::getAnneeScolaireCourante();
        $aujourdhui = now()->startOfDay();

        // Trouver les tranches dont la date limite est dans 14 jours ou moins ET >= aujourd'hui
        $tranches = TrancheScolarite::where('annee_scolaire', $anneeScolaire)
            ->where('date_limite', '>=', $aujourdhui)
            ->where('date_limite', '<=', $aujourdhui->copy()->addDays(14))
            ->get();

        if ($tranches->isEmpty()) {
            $this->info("Aucune date limite de tranche de scolarité dans les 14 prochains jours.");
            return;
        }

        $count = 0;

        foreach ($tranches as $tranche) {
            $joursRestants = (int) $aujourdhui->diffInDays(\Carbon\Carbon::parse($tranche->date_limite)->startOfDay(), false);
            $this->info("Tranche trouvée: {$tranche->pourcentage}% (Date limite dans {$joursRestants} jours)");

            // Récupérer toutes les scolarités (par classe) pour cette année
            $contributionsScolarite = Contribution::where('annee_scolaire', $anneeScolaire)
                ->where('type', Contribution::TYPE_SCOLARITE)
                ->get();

            foreach ($contributionsScolarite as $contribution) {
                // Montant requis pour cette classe et cette tranche
                $montantRequis = ($contribution->montant_total * $tranche->pourcentage) / 100;

                // Récupérer les élèves de cette classe
                $eleves = Eleve::where('classe_id', $contribution->classe_id)->with('tuteur')->get();

                foreach ($eleves as $eleve) {
                    // Total payé par cet élève pour cette contribution précise
                    $totalPaye = $eleve->paiementsReussis()
                        ->where('contribution_id', $contribution->id)
                        ->sum('montant');

                    // Si le paiement est incomplet
                    if ($totalPaye < $montantRequis && $eleve->tuteur) {
                        // Envoi de l'alerte
                        $eleve->tuteur->notify(new AlertScolariteNotification(
                            $tranche, 
                            $montantRequis, 
                            $totalPaye, 
                            $eleve, 
                            $joursRestants
                        ));
                        $count++;
                    }
                }
            }
        }

        $this->info("Vérification terminée. {$count} rappel(s) envoyé(s).");
    }
}
