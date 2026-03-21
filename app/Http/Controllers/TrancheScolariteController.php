<?php

namespace App\Http\Controllers;

use App\Models\TrancheScolarite;
use App\Models\Contribution;
use Illuminate\Http\Request;

class TrancheScolariteController extends Controller
{
    public function index()
    {
        $annee = Contribution::getAnneeScolaireCourante();
        $tranches = TrancheScolarite::where('annee_scolaire', $annee)
            ->orderBy('pourcentage')
            ->get();
            
        return response()->json([
            'success' => true,
            'tranches' => $tranches,
            'annee_scolaire' => $annee
        ]);
    }

    public function storeOrUpdate(Request $request)
    {
        $request->validate([
            'tranches' => 'required|array',
            'tranches.*.id' => 'nullable|exists:tranche_scolarites,id',
            'tranches.*.nom' => 'required|string',
            'tranches.*.pourcentage' => 'required|integer',
            'tranches.*.date_limite' => 'required|date',
        ]);

        $annee = Contribution::getAnneeScolaireCourante();
        $updatedTranches = [];

        foreach ($request->tranches as $trancheData) {
            if (isset($trancheData['id'])) {
                $tranche = TrancheScolarite::find($trancheData['id']);
                $tranche->update([
                    'nom' => $trancheData['nom'],
                    'pourcentage' => $trancheData['pourcentage'],
                    'date_limite' => $trancheData['date_limite'],
                ]);
            } else {
                $tranche = TrancheScolarite::create([
                    'annee_scolaire' => $annee,
                    'nom' => $trancheData['nom'],
                    'pourcentage' => $trancheData['pourcentage'],
                    'date_limite' => $trancheData['date_limite'],
                ]);
            }
            $updatedTranches[] = $tranche;
        }

        return response()->json([
            'success' => true,
            'message' => 'Tranches de scolarité mises à jour',
            'tranches' => $updatedTranches
        ]);
    }
}
