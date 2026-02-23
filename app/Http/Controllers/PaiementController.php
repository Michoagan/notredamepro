<?php

namespace App\Http\Controllers;

use App\Models\Eleve;
use App\Models\Paiement;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;
use Barryvdh\DomPDF\Facade\Pdf;
use Endroid\QrCode\QrCode;
use Endroid\QrCode\Writer\PngWriter;
use Endroid\QrCode\Color\Color;
use Endroid\QrCode\Encoding\Encoding;
use Endroid\QrCode\ErrorCorrectionLevel;
use Endroid\QrCode\RoundBlockSizeMode;

class PaiementController extends Controller
{
    public function index(Request $request)
    {
        $parent = \Illuminate\Support\Facades\Auth::user();

        if (! $parent instanceof \App\Models\Tuteur) {
            return response()->json(['error' => 'Non autorisé'], 403);
        }

        $eleves = $parent->eleves;

        $eleve = null;
        $classe = null;
        $contribution = null;
        $paiements = collect();

        if ($request->has('eleve_id')) {
            $eleve = $eleves->where('id', $request->eleve_id)->first();

            if ($eleve) {
                $classe = $eleve->classe;
                if ($classe) {
                    // Récupération du coût depuis la classe
                    $contribution = $classe->cout_contribution;
                    $paiements = Paiement::where('eleve_id', $eleve->id)->get();
                }
            }
        }

        return response()->json([
            'success' => true,
            'parent' => $parent,
            'eleves' => $eleves,
            'eleve' => $eleve,
            'classe' => $classe,
            'contribution' => $contribution,
            'paiements' => $paiements,
        ]);
    }

    public function processPayment(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1000',
            'payment_method' => 'required|in:kkiapay,fedapay',
            'eleve_id' => 'required|exists:eleves,id',
            'montant_total' => 'required|numeric',
        ]);

        // Calculer le solde restant
        $eleve = Eleve::find($request->eleve_id);
        $totalPaye = Paiement::where('eleve_id', $eleve->id)->where('statut', 'success')->sum('montant');
        $soldeRestant = $request->montant_total - $totalPaye;

        // Vérifier que le montant ne dépasse pas le solde restant
        if ($request->amount > $soldeRestant) {
            return response()->json(['success' => false, 'message' => 'Le montant saisi dépasse le solde restant.'], 400);
        }

        // Créer une transaction en attente
        $transaction = Paiement::create([
            'reference' => 'PYR-'.date('Y').'-'.Str::random(6),
            'eleve_id' => $request->eleve_id,
            'montant' => $request->amount,
            'methode' => $request->payment_method,
            'statut' => 'pending',
            'date_paiement' => now(),
        ]);

        // Rediriger selon la méthode de paiement
        if ($request->payment_method === 'kkiapay') {
            return $this->processKkiaPay($transaction);
        } else {
            return $this->processFedapay($transaction);
        }
    }

    private function processKkiaPay($transaction)
    {
        // Configuration KkiaPay
        $apiKey = env('KKIAPAY_PUBLIC_KEY', 'c67683ac89ca27a988244dac8415d4e6d8a82511');
        $callbackUrl = route('parent.payment-callback', ['method' => 'kkiapay']);

        // Stocker l'ID de transaction en session pour la vérification après paiement
        session(['kkiapay_transaction_id' => $transaction->id]);

        // Retourner les infos pour que le frontend lance le paiement
        return response()->json([
            'success' => true,
            'payment_url' => null, // KkiaPay est souvent intégré via JS, on renvoie les clés
            'kkiapay_config' => [
                'public_key' => $apiKey,
                'amount' => $transaction->montant,
                'transactionId' => $transaction->id,
                'callbackUrl' => $callbackUrl,
                'theme' => 'green', // Exemple
            ],
            'message' => 'Initialisation KkiaPay réussie',
        ]);
    }

    private function processFedapay($transaction)
    {
        try {
            // Configuration de Fedapay
            \Fedapay\Fedapay::setApiKey(env('FEDAPAY_SECRET_KEY'));
            \Fedapay\Fedapay::setEnvironment(env('FEDAPAY_ENVIRONMENT', 'sandbox'));

            // Créer une transaction Fedapay
            $fedapayTransaction = \Fedapay\Transaction::create([
                'description' => 'Paiement contribution scolaire - '.$transaction->eleve->prenom.' '.$transaction->eleve->nom,
                'amount' => $transaction->montant,
                'currency' => ['iso' => 'XOF'],
                'callback_url' => route('parent.payment-callback', ['method' => 'fedapay']),
                'customer' => [
                    'firstname' => $transaction->eleve->parent->prenom,
                    'lastname' => $transaction->eleve->parent->nom,
                    'email' => $transaction->eleve->parent->email,
                    'phone_number' => $transaction->eleve->parent->telephone,
                ],
            ]);

            // Mettre à jour la transaction avec la référence Fedapay
            $transaction->update(['reference_externe' => $fedapayTransaction->id]);

            // Retourner l'URL de paiement pour redirection côté frontend
            return response()->json([
                'success' => true,
                'payment_url' => $fedapayTransaction->generateToken()->url,
                'transaction_id' => $transaction->id,
            ]);

        } catch (\Exception $e) {
            // Gérer l'erreur
            $transaction->update(['statut' => 'failed', 'erreur' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'initialisation du paiement: '.$e->getMessage(),
            ], 500);
        }
    }

    public function handleCallback(Request $request, $method)
    {
        if ($method === 'kkiapay') {
            return $this->handleKkiaPayCallback($request);
        } elseif ($method === 'fedapay') {
            return $this->handleFedapayCallback($request);
        }

        return response()->json(['success' => false, 'message' => 'Méthode de paiement non reconnue.'], 400);
    }

    private function handleKkiaPayCallback(Request $request)
    {
        $transactionId = $request->input('transactionId');
        $status = $request->input('status');

        // Récupérer l'ID de transaction depuis la session ou les paramètres
        $localTransactionId = session('kkiapay_transaction_id', $transactionId);

        $transaction = Paiement::find($localTransactionId);

        if (! $transaction) {
            return response()->json(['success' => false, 'message' => 'Transaction non trouvée.'], 404);
        }

        if ($status === 'success') {
            // Mettre à jour le statut de la transaction
            $transaction->update([
                'statut' => 'success',
                'reference_externe' => $transactionId,
                'date_paiement' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Paiement effectué avec succès!',
                'receipt_id' => $transaction->id,
            ]);
        } else {
            $transaction->update(['statut' => 'failed']);

            return response()->json(['success' => false, 'message' => 'Le paiement a échoué.'], 400);
        }
    }

    private function handleFedapayCallback(Request $request)
    {
        $transactionId = $request->input('transaction_id');

        if (! $transactionId) {
            return response()->json(['success' => false, 'message' => 'Transaction ID manquant.'], 400);
        }

        try {
            // Récupérer la transaction Fedapay
            \Fedapay\Fedapay::setApiKey(env('FEDAPAY_SECRET_KEY'));
            $fedapayTransaction = \Fedapay\Transaction::retrieve($transactionId);

            // Trouver la transaction dans notre base
            $transaction = Paiement::where('reference_externe', $transactionId)->first();

            if (! $transaction) {
                return response()->json(['success' => false, 'message' => 'Transaction non trouvée.'], 404);
            }

            if ($fedapayTransaction->status === 'approved') {
                $transaction->update([
                    'statut' => 'success',
                    'date_paiement' => now(),
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Paiement effectué avec succès!',
                    'receipt_id' => $transaction->id,
                ]);
            } else {
                $transaction->update(['statut' => 'failed']);

                return response()->json(['success' => false, 'message' => 'Le paiement a échoué.'], 400);
            }

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Erreur lors du traitement du paiement: '.$e->getMessage()], 500);
        }
    }

    public function generateReceipt($id)
    {
        $paiement = Paiement::with(['eleve', 'eleve.classe', 'eleve.tuteurs'])->findOrFail($id);

        if ($paiement->statut !== 'success') {
            return response()->json(['success' => false, 'message' => 'Le reçu n\'est disponible que pour les paiements réussis.'], 400);
        }

        // Generate QR code locally via endroid/qr-code
        $qrData = [
            'recu_id' => $paiement->id,
            'reference' => $paiement->reference_externe ?? $paiement->reference,
            'eleve' => $paiement->eleve->nom . ' ' . $paiement->eleve->prenom,
            'montant' => $paiement->montant,
            'date' => $paiement->date_paiement ? \Carbon\Carbon::parse($paiement->date_paiement)->format('d/m/Y H:i') : null,
            'statut' => 'Payé'
        ];

        $qrText = json_encode($qrData);

        // QR Code config
        $qrCode = QrCode::create($qrText)
            ->setEncoding(new Encoding('UTF-8'))
            ->setErrorCorrectionLevel(ErrorCorrectionLevel::Low)
            ->setSize(100)
            ->setMargin(10)
            ->setRoundBlockSizeMode(RoundBlockSizeMode::Margin)
            ->setForegroundColor(new Color(0, 0, 0))
            ->setBackgroundColor(new Color(255, 255, 255));

        $writer = new PngWriter();
        $qrCodeResult = $writer->write($qrCode);
        $qrCodeImage = base64_encode($qrCodeResult->getString());

        $pdf = Pdf::loadView('pdf.receipt', [
            'paiement' => $paiement,
            'qrCodeImage' => $qrCodeImage,
            'date_generation' => now()->format('d/m/Y H:i:s')
        ]);

        $filename = "recu_paiement_{$paiement->id}_{$paiement->eleve->nom}.pdf";

        return $pdf->download($filename);
    }

    // Méthode pour vérifier manuellement le statut d'un paiement
    public function checkPaymentStatus($id)
    {
        $paiement = Paiement::findOrFail($id);

        if ($paiement->methode === 'fedapay' && $paiement->reference_externe) {
            try {
                \Fedapay\Fedapay::setApiKey(env('FEDAPAY_SECRET_KEY'));
                $fedapayTransaction = \Fedapay\Transaction::retrieve($paiement->reference_externe);

                if ($fedapayTransaction->status === 'approved' && $paiement->statut !== 'success') {
                    $paiement->update([
                        'statut' => 'success',
                        'date_paiement' => now(),
                    ]);

                    return response()->json(['success' => true, 'message' => 'Paiement vérifié et confirmé avec succès!']);
                }
            } catch (\Exception $e) {
                return response()->json(['success' => false, 'message' => 'Erreur lors de la vérification: '.$e->getMessage()], 500);
            }
        }

        return response()->json(['success' => true, 'message' => 'Statut du paiement: '.$paiement->statut]);
    }
}
