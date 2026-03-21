<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class SendExamReminders extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:send-exam-reminders';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Envoie des rappels quotidiens aux parents pour les compositions à venir (J-14)';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Démarrage de l\'envoi des rappels de compositions...');
        $aujourdhui = now()->startOfDay();
        $limite = now()->addDays(14)->endOfDay();

        // Trouver les sessions avec des horaires dans les 14 prochains jours
        $sessions = \App\Models\SessionComposition::with(['horaires', 'classe'])
            ->whereHas('horaires', function ($query) use ($aujourdhui, $limite) {
                $query->whereBetween('date_composition', [$aujourdhui, $limite]);
            })
            ->get();

        $annee = \App\Models\Contribution::getAnneeScolaireCourante();
        $tranches = \App\Models\TrancheScolarite::where('annee_scolaire', $annee)
            ->orderBy('pourcentage')
            ->get();

        $notificationsEnvoyees = 0;

        foreach ($sessions as $session) {
            $premierExamen = $session->horaires->min('date_composition');
            $dateExam = \Carbon\Carbon::parse($premierExamen)->startOfDay();
            $joursRestants = $aujourdhui->diffInDays($dateExam, false);

            if ($joursRestants < 0 || $joursRestants > 14) {
                continue;
            }

            // Récupérer les élèves concernés
            $elevesQuery = \App\Models\Eleve::with(['tuteurs', 'classe']);
            
            if ($session->cible === 'toute_lecole') {
                // Tous les élèves
            } elseif ($session->cible === 'classe') {
                $elevesQuery->where('classe_id', $session->classe_id);
            } else {
                // Cycle
                $eleves = $elevesQuery->get()->filter(function ($eleve) use ($session) {
                    $nomClasse = strtolower($eleve->classe->nom ?? '');
                    $isPremierCycle = \Illuminate\Support\Str::contains($nomClasse, ['6', '5', '4', '3', 'sixi', 'cinq', 'quatr', 'trois']);
                    $isSecondCycle = \Illuminate\Support\Str::contains($nomClasse, ['2n', '1er', 'tle', 'second', 'premi', 'term']);
                    
                    if ($session->cible === '1er_cycle') return $isPremierCycle;
                    if ($session->cible === '2nd_cycle') return $isSecondCycle;
                    return false;
                });
                $elevesQuery = null; // We already filtered
            }

            $eleves = $elevesQuery ? $elevesQuery->get() : $eleves;

            $trancheIndex = $session->trimestre - 1;
            $trancheRequise = $tranches[$trancheIndex] ?? null;

            foreach ($eleves as $eleve) {
                $coutTotal = $eleve->classe->cout_contribution ?? 50000;
                $contributionScolarite = \App\Models\Contribution::where('classe_id', $eleve->classe_id)
                    ->where('annee_scolaire', $annee)
                    ->where('type', \App\Models\Contribution::TYPE_SCOLARITE)
                    ->first();
                if ($contributionScolarite) {
                    $coutTotal = $contributionScolarite->montant_total;
                }

                $totalPaye = \App\Models\Paiement::where('eleve_id', $eleve->id)
                    ->where('statut', 'success')
                    ->sum('montant');

                $isLocked = false;
                if ($trancheRequise) {
                    $montantRequis = ($coutTotal * $trancheRequise->pourcentage) / 100;
                    if ($totalPaye < $montantRequis) {
                        $isLocked = true;
                    }
                }

                foreach ($eleve->tuteurs as $tuteur) {
                    $tuteur->notify(new \App\Notifications\ConvocationRappelNotification(
                        $session, $eleve, (int)$joursRestants, $isLocked
                    ));
                    $notificationsEnvoyees++;
                }
            }
        }

        $this->info("Rappels terminés. $notificationsEnvoyees notification(s) envoyée(s).");
    }
}
