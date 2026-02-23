<?php

namespace App\Http\Controllers;

use App\Models\Depense;
use App\Models\Paiement;
use App\Models\Vente;
use App\Models\Article;
use App\Models\LigneVente;
use App\Models\MouvementStock;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ComptabiliteController extends Controller
{
    /**
     * Tableau de bord comptable (Résumé).
     */
    public function dashboard(Request $request)
    {
        // Filtre par date (Mois en cours par défaut)
        $dateStart = $request->input('start_date', now()->startOfMonth()->toDateString());
        $dateEnd = $request->input('end_date', now()->endOfMonth()->toDateString());

        // 1. Entrées
        // Contributions (Paiements scolarité validés)
        $totalScolarite = Paiement::where('statut', 'success')
            ->whereBetween('date_paiement', [$dateStart, $dateEnd])
            ->sum('montant');

        // Ventes (Autres recettes)
        $totalVentes = Vente::whereBetween('date_vente', [$dateStart, $dateEnd])
            ->sum('montant_total');

        $totalEntrees = $totalScolarite + $totalVentes;

        // 2. Sorties
        // Dépenses
        $totalDepenses = Depense::whereBetween('date_depense', [$dateStart, $dateEnd])
            ->sum('montant');

        // 3. Solde
        $solde = $totalEntrees - $totalDepenses;

        return response()->json([
            'period' => [
                'start' => $dateStart,
                'end' => $dateEnd
            ],
            'entrees' => [
                'scolarite' => $totalScolarite,
                'ventes' => $totalVentes,
                'total' => $totalEntrees
            ],
            'sorties' => [
                'depenses' => $totalDepenses,
                'total' => $totalDepenses
            ],
            'solde' => $solde
        ]);
    }

    /**
     * Liste des dépenses
     */
    public function index()
    {
        $depenses = Depense::with('auteur')->latest('date_depense')->get();
        return response()->json($depenses);
    }

    /**
     * Enregistrer une Dépense (Sortie).
     */
    public function storeDepense(Request $request)
    {
        $request->validate([
            'motif' => 'required|string',
            'montant' => 'required|numeric|min:0',
            'categorie' => 'required|in:salaire,achat_materiel,tache,autre',
            'date_depense' => 'required|date',
        ]);

        $depense = Depense::create([
            'motif' => $request->motif,
            'montant' => $request->montant,
            'categorie' => $request->categorie,
            'date_depense' => $request->date_depense,
            'description' => $request->description,
            'auteur_id' => auth()->id(),
            // Gestion bénéficiaire à ajouter si besoin (ex: ID prof)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Dépense enregistrée.',
            'depense' => $depense
        ]);
    }

    /**
     * Enregistrer une Vente (Autre recette : Tenue, Cantine, Vente directe).
     */
    public function storeVente(Request $request)
    {
        $request->validate([
            'items' => 'required|array|min:1',
            'items.*.article_id' => 'required|exists:articles,id',
            'items.*.quantite' => 'required|integer|min:1',
            'eleve_id' => 'nullable|exists:eleves,id',
            'nom_client' => 'nullable|string',
        ]);

        // Calcul total et validation stock
        return DB::transaction(function () use ($request) {
            $total = 0;
            $itemsToProcess = [];

            foreach ($request->items as $itemData) {
                $article = Article::find($itemData['article_id']);
                
                // Vérif stock physique
                if ($article->type === 'physique' && $article->stock_actuel < $itemData['quantite']) {
                    throw new \Exception("Stock insuffisant pour " . $article->designation);
                }

                $prix = $article->prix_unitaire;
                $sousTotal = $prix * $itemData['quantite'];
                $total += $sousTotal;

                $itemsToProcess[] = [
                    'article' => $article,
                    'quantite' => $itemData['quantite'],
                    'prix' => $prix,
                    'sous_total' => $sousTotal
                ];
            }

            // Création Vente
            $vente = Vente::create([
                'reference' => 'VNT-' . date('Ymd') . '-' . Str::upper(Str::random(4)),
                'eleve_id' => $request->eleve_id,
                'nom_client' => $request->nom_client ?? ($request->eleve_id ? null : 'Client Anonyme'),
                'montant_total' => $total,
                'date_vente' => now(),
                'auteur_id' => auth()->id(),
            ]);

            // Création Lignes et Mvt Stock
            foreach ($itemsToProcess as $item) {
                LigneVente::create([
                    'vente_id' => $vente->id,
                    'article_id' => $item['article']->id,
                    'quantite' => $item['quantite'],
                    'prix_unitaire' => $item['prix'],
                    'sous_total' => $item['sous_total'],
                ]);

                // Sortie de Stock si physique
                if ($item['article']->type === 'physique') {
                    $oldStock = $item['article']->stock_actuel;
                    $newStock = $oldStock - $item['quantite'];
                    
                    $item['article']->update(['stock_actuel' => $newStock]);

                    MouvementStock::create([
                        'article_id' => $item['article']->id,
                        'type' => 'vente',
                        'quantite' => $item['quantite'],
                        'stock_precedent' => $oldStock,
                        'nouveau_stock' => $newStock,
                        'motif' => 'Vente ' . $vente->reference,
                        'source_type' => Vente::class,
                        'source_id' => $vente->id,
                        'auteur_id' => auth()->id(),
                    ]);
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Vente enregistrée avec succès.',
                'vente' => $vente->load('lignes.article')
            ]);

        }); // End Transaction
    }
}
