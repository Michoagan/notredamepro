<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\MouvementStock;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InventaireController extends Controller
{
    /**
     * Liste des articles (et stock actuel).
     */
    public function index()
    {
        $articles = Article::orderBy('designation')->get();
        return response()->json($articles);
    }

    /**
     * Créer un nouvel article.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'designation' => 'required|string|max:255',
            'type' => 'required|in:physique,service',
            'prix_unitaire' => 'required|numeric|min:0',
            'stock_min' => 'integer|min:0',
        ]);

        $article = Article::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Article créé avec succès.',
            'article' => $article
        ]);
    }

    /**
     * Mettre à jour un article.
     */
    public function update(Request $request, Article $article)
    {
        $validated = $request->validate([
            'designation' => 'string|max:255',
            'prix_unitaire' => 'numeric|min:0',
            'stock_min' => 'integer|min:0',
        ]);

        $article->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Article mis à jour.',
            'article' => $article
        ]);
    }

    /**
     * Ajouter du stock (Approvisionnement).
     */
    public function addStock(Request $request, Article $article)
    {
        $request->validate([
            'quantite' => 'required|integer|min:1',
            'motif' => 'required|string',
        ]);

        if ($article->type !== 'physique') {
            return response()->json(['message' => 'Impossible de gérer le stock pour un service.'], 400);
        }

        DB::transaction(function () use ($request, $article) {
            $oldStock = $article->stock_actuel;
            $newStock = $oldStock + $request->quantite;

            $article->update(['stock_actuel' => $newStock]);

            MouvementStock::create([
                'article_id' => $article->id,
                'type' => 'entree',
                'quantite' => $request->quantite,
                'stock_precedent' => $oldStock,
                'nouveau_stock' => $newStock,
                'motif' => $request->motif,
                'auteur_id' => auth()->id(), // Utilisateur connecté (Direction)
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Stock ajouté avec succès.',
            'stock_actuel' => $article->fresh()->stock_actuel
        ]);
    }

    /**
     * Corriger le stock (Inventaire physique).
     */
    public function correctStock(Request $request, Article $article)
    {
        $request->validate([
            'stock_reel' => 'required|integer|min:0',
            'motif' => 'required|string',
        ]);

        if ($article->type !== 'physique') {
            return response()->json(['message' => 'Impossible de gérer le stock pour un service.'], 400);
        }

        DB::transaction(function () use ($request, $article) {
            $oldStock = $article->stock_actuel;
            $diff = $request->stock_reel - $oldStock;

            if ($diff === 0) return;

            $article->update(['stock_actuel' => $request->stock_reel]);

            MouvementStock::create([
                'article_id' => $article->id,
                'type' => 'correction',
                'quantite' => abs($diff), // On stocke la valeur absolue
                'stock_precedent' => $oldStock,
                'nouveau_stock' => $request->stock_reel,
                'motif' => $request->motif . ' (Correction: ' . ($diff > 0 ? '+' : '') . $diff . ')',
                'auteur_id' => auth()->id(),
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Stock corrigé.',
            'stock_actuel' => $article->fresh()->stock_actuel
        ]);
    }

    /**
     * Historique des mouvements pour un article.
     */
    public function history(Article $article)
    {
        $mouvements = $article->mouvementStocks()->with('auteur')->latest()->get();
        return response()->json($mouvements);
    }
}
