<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Models\AncienneEpreuve;
use Illuminate\Support\Facades\Storage;

class SecretaireEpreuveController extends Controller
{
    public function index()
    {
        $epreuves = AncienneEpreuve::with(['matiere', 'classe'])->latest()->get();
        return response()->json($epreuves);
    }

    public function store(Request $request)
    {
        $request->validate([
            'titre' => 'nullable|string|max:255',
            'matiere_id' => 'required|exists:matieres,id',
            'classe_id' => 'required|exists:classes,id',
            'annee' => 'required|string',
            'type' => 'required|string',
            'fichier' => 'required|file|mimes:pdf,doc,docx|max:10000'
        ]);

        $path = $request->file('fichier')->store('anciennes_epreuves', 'public');

        $epreuve = AncienneEpreuve::create([
            'titre' => $request->titre,
            'matiere_id' => $request->matiere_id,
            'classe_id' => $request->classe_id,
            'annee' => $request->annee,
            'type' => $request->type,
            'file_path' => $path
        ]);

        return response()->json([
            'message' => 'Épreuve ajoutée avec succès',
            'epreuve' => $epreuve->load(['matiere', 'classe'])
        ]);
    }

    public function destroy($id)
    {
        $epreuve = AncienneEpreuve::findOrFail($id);
        
        if (Storage::disk('public')->exists($epreuve->file_path)) {
            Storage::disk('public')->delete($epreuve->file_path);
        }

        $epreuve->delete();

        return response()->json(['message' => 'Épreuve supprimée avec succès']);
    }
}
