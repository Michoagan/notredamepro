<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class DeleteExpiredEvents extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
     protected $signature = 'events:delete-expired';
    protected $description = 'Supprime automatiquement les événements dont la date de fin est dépassée';
    /**
     * Execute the console command.
     */
    public function handle()
    {
       $now = Carbon::now();
    $expiredEvents = Evenement::where('date_fin', '<', $now)->get();
    
    // Option: Archivage avant suppression
    foreach ($expiredEvents as $event) {
        // Loguer ou archiver l'événement si nécessaire
        \Log::info('Événement expiré supprimé: ' . $event->titre);
    }
    
    $deletedCount = Evenement::where('date_fin', '<', $now)->delete();
    
    $this->info("$deletedCount événements expirés ont été supprimés.");
    
    return 0;
    }
}
