<?php

namespace App\Http\Controllers;

use App\Models\Eleve;
use App\Models\Note;
use App\Models\Classe;
use App\Models\Matiere;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Barryvdh\DomPDF\Facade\Pdf;
use Endroid\QrCode\QrCode;
use Endroid\QrCode\Writer\PngWriter;
use Endroid\QrCode\Color\Color;
use Endroid\QrCode\Encoding\Encoding;
use Endroid\QrCode\ErrorCorrectionLevel;
use Endroid\QrCode\RoundBlockSizeMode;
use Endroid\QrCode\Writer\Result\PngResult;

class BulletinController extends Controller
{
    public function index(Request $request)
    {
        $classeId = $request->input('classe_id');
        $trimestre = $request->input('trimestre', 1);
        $eleveId = $request->input('eleve_id');
        
        $classes = Classe::withCount('eleves')->get();
        $eleves = collect();
        $classe = null;
        $bulletinData = null;
        
        if ($classeId) {
            $classe = Classe::find($classeId);
            $eleves = Eleve::where('classe_id', $classeId)->get();
            
            if ($eleveId) {
                $bulletinData = $this->getBulletinData($eleveId, $trimestre);
            }
        }
        
        return response()->json([
            'success' => true,
            'classes' => $classes, 
            'eleves' => $eleves, 
            'classe' => $classe, 
            'bulletinData' => $bulletinData, 
            'filters' => [
                'classeId' => $classeId, 
                'trimestre' => $trimestre,
                'eleveId' => $eleveId
            ]
        ]);
    }
    
    private function getBulletinData($eleveId, $trimestre)
    {
        try {
            $eleve = Eleve::with('classe')->findOrFail($eleveId);
            
            $notes = Note::where('eleve_id', $eleveId)
                        ->where('trimestre', $trimestre)
                        ->with('matiere')
                        ->get();
                        
            // Attachement du rang pour chaque matière spécifique
            foreach ($notes as $note) {
                if ($note->moyenne_trimestrielle) {
                    $note->rang_matiere = $this->calculerRangMatiere($eleve->classe_id, $trimestre, $note->matiere_id, $note->moyenne_trimestrielle);
                } else {
                    $note->rang_matiere = '-';
                }
            }
            
            $conduite = \App\Models\Conduite::where('eleve_id', $eleveId)
                        ->where('trimestre', $trimestre)
                        ->first();
            
            $moyenneGenerale = $this->calculerMoyenneGenerale($notes);
            $rang = $this->calculerRang($eleve->classe_id, $trimestre, $moyenneGenerale);
            $statistiques = $this->getStatistiquesClasse($eleve->classe_id, $trimestre);
            
            // Calculer la moyenne annuelle si c'est le 3ème trimestre
            $moyenneAnnuelle = null;
            if ($trimestre == 3) {
                $moyenneAnnuelle = $this->calculerMoyenneAnnuelle($eleveId);
            }
            
            return [
                'success' => true,
                'eleve' => $eleve,
                'notes' => $notes,
                'moyenne_generale' => $moyenneGenerale,
                'moyenne_annuelle' => $moyenneAnnuelle,
                'conduite' => $conduite,
                'rang' => $rang,
                'effectif_classe' => Eleve::where('classe_id', $eleve->classe_id)->count(),
                'minAverage' => $statistiques['min'],
                'maxAverage' => $statistiques['max'],
                'classAverage' => $statistiques['moyenne'],
            ];
            
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Erreur lors du chargement des données: ' . $e->getMessage()
            ];
        }
    }
    
    private function calculerMoyenneGenerale($notes)
    {
        $totalCoefficient = 0;
        $totalMoyenneCoefficientee = 0;
        
        foreach ($notes as $note) {
            if ($note->moyenne_trimestrielle) {
                $totalCoefficient += $note->coefficient;
                $totalMoyenneCoefficientee += $note->moyenne_trimestrielle * $note->coefficient;
            }
        }
        
        return $totalCoefficient > 0 ? $totalMoyenneCoefficientee / $totalCoefficient : 0;
    }
    
    private function calculerMoyenneAnnuelle($eleveId)
    {
        $moyennesTrimestres = Note::where('eleve_id', $eleveId)
            ->select('trimestre', DB::raw('SUM(moyenne_trimestrielle * coefficient) / SUM(coefficient) as moyenne'))
            ->groupBy('trimestre')
            ->get()
            ->pluck('moyenne');
        
        return $moyennesTrimestres->avg();
    }
    
    private function calculerRang($classeId, $trimestre, $moyenneEleve)
    {
        $elevesAvecMoyennes = DB::table('eleves')
            ->leftJoin('notes', function($join) use ($trimestre) {
                $join->on('eleves.id', '=', 'notes.eleve_id')
                     ->where('notes.trimestre', '=', $trimestre);
            })
            ->select('eleves.id', DB::raw('AVG(notes.moyenne_trimestrielle * notes.coefficient) / SUM(notes.coefficient) as moyenne'))
            ->where('eleves.classe_id', $classeId)
            ->groupBy('eleves.id')
            ->orderBy('moyenne', 'DESC')
            ->get();
        
        $rang = 1;
        foreach ($elevesAvecMoyennes as $index => $eleve) {
            if ($eleve->moyenne <= $moyenneEleve) {
                $rang = $index + 1;
                break;
            }
        }
        
        return $rang;
    }
    
    private function getStatistiquesClasse($classeId, $trimestre)
    {
        $moyennes = DB::table('eleves')
            ->leftJoin('notes', function($join) use ($trimestre) {
                $join->on('eleves.id', '=', 'notes.eleve_id')
                     ->where('notes.trimestre', '=', $trimestre);
            })
            ->select(DB::raw('AVG(notes.moyenne_trimestrielle) as moyenne'))
            ->where('eleves.classe_id', $classeId)
            ->groupBy('eleves.id')
            ->get()
            ->pluck('moyenne')
            ->filter();
        
        return [
            'min' => $moyennes->min() ?? 0,
            'max' => $moyennes->max() ?? 0,
            'moyenne' => $moyennes->avg() ?? 0
        ];
    }
    
    private function calculerRangMatiere($classeId, $trimestre, $matiereId, $moyenneMatiereEleve)
    {
        $elevesAvecMoyennes = DB::table('eleves')
            ->join('notes', 'eleves.id', '=', 'notes.eleve_id')
            ->where('notes.trimestre', '=', $trimestre)
            ->where('notes.matiere_id', '=', $matiereId)
            ->where('eleves.classe_id', '=', $classeId)
            ->select('eleves.id', 'notes.moyenne_trimestrielle as moyenne')
            ->orderBy('moyenne', 'DESC')
            ->get();
            
        $rang = 1;
        foreach ($elevesAvecMoyennes as $index => $eleve) {
            if ($eleve->moyenne <= $moyenneMatiereEleve) {
                $rang = $index + 1;
                break;
            }
        }
        
        return $rang;
    }
    
     public function generatePDF($eleveId, $trimestre)
    {
        $bulletinData = $this->getBulletinData($eleveId, $trimestre);
        
        if (!$bulletinData['success']) {
            abort(404, 'Bulletin non trouvé');
        }
        
        $anneeScolaire = \App\Models\Setting::where('key', 'current_annee_scolaire')->value('value') ?? '2025-2026';

        // Générer le QR code localement avec endroid/qr-code
        $qrData = [
            'eleve_id' => $bulletinData['eleve']->id,
            'nom' => $bulletinData['eleve']->nom,
            'prenom' => $bulletinData['eleve']->prenom,
            'classe' => $bulletinData['eleve']->classe->nom,
            'trimestre' => $trimestre,
            'moyenne' => $bulletinData['moyenne_generale'],
            'annee_scolaire' => $anneeScolaire
        ];
        
        $qrText = json_encode($qrData);
        
        // Créer le QR code
        $result = \Endroid\QrCode\Builder\Builder::create()
            ->writer(new PngWriter())
            ->data($qrText)
            ->encoding(new Encoding('UTF-8'))
            ->errorCorrectionLevel(ErrorCorrectionLevel::Low)
            ->size(100)
            ->margin(10)
            ->roundBlockSizeMode(RoundBlockSizeMode::Margin)
            ->foregroundColor(new Color(0, 0, 0))
            ->backgroundColor(new Color(255, 255, 255))
            ->build();
        
        // Convertir en base64 pour l'affichage dans le PDF
        $qrCodeImage = base64_encode($result->getString());
        
        $pdf = Pdf::loadView('pdf.bulletin', [
            'data' => $bulletinData,
            'trimestre' => $trimestre,
            'qrCodeImage' => $qrCodeImage
        ]);
        
        $filename = "bulletin_{$bulletinData['eleve']->nom}_{$bulletinData['eleve']->prenom}_T{$trimestre}.pdf";
        
        return $pdf->download($filename);
    }
}
