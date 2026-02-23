<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Reçu de Paiement</title>
    <style>
        body { font-family: sans-serif; font-size: 14px; color: #333; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
        .header { width: 100%; border-bottom: 2px solid #2c3e50; padding-bottom: 20px; margin-bottom: 30px; }
        .school-info { text-align: center; }
        .school-name { font-size: 20px; font-weight: bold; text-transform: uppercase; color: #2c3e50; }
        .receipt-title { text-align: center; font-size: 24px; font-weight: bold; margin: 30px 0; text-transform: uppercase; letter-spacing: 2px; }
        
        .info-section { width: 100%; margin-bottom: 40px; }
        .info-section td { padding: 8px; }
        .label { font-weight: bold; width: 150px; color: #555; }
        .value { color: #000; font-weight: bold; }
        
        .amount-box { margin-top: 20px; text-align: center; background-color: #f8f9fa; border: 2px dashed #2c3e50; padding: 20px; font-size: 28px; font-weight: bold; color: #success; }
        
        .footer { margin-top: 60px; text-align: center; font-size: 12px; color: #7f8c8d; border-top: 1px solid #bdc3c7; padding-top: 20px; }
        
        .qr-code { position: absolute; top: 20px; right: 20px; width: 100px; }
        .status-badge { display: inline-block; padding: 5px 15px; background-color: #27ae60; color: white; rounded: 20px; font-weight: bold; text-transform: uppercase; font-size: 16px; margin-top:10px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="school-info">
                <div class="school-name">COMPLEXE SCOLAIRE NOTRE DAME DE GRÂCE</div>
                <div>BP: 1234 Lomé - TOGO | Tél: 90 00 00 00</div>
            </div>
            @if(isset($qrCodeImage))
                <img src="data:image/png;base64, {{ $qrCodeImage }}" class="qr-code" alt="QR Code"/>
            @endif
        </div>

        <div class="receipt-title">REÇU DE SCOLARITÉ</div>

        <table class="info-section">
            <tr>
                <td class="label">Reçu N° :</td>
                <td class="value">REC-{{ str_pad($paiement->id, 6, '0', STR_PAD_LEFT) }}</td>
            </tr>
            <tr>
                <td class="label">Date :</td>
                <td class="value">{{ \Carbon\Carbon::parse($paiement->date_paiement ?? $paiement->created_at)->format('d/m/Y à H:i') }}</td>
            </tr>
            <tr>
                <td class="label">Référence :</td>
                <td class="value">{{ $paiement->reference_externe ?? $paiement->reference }} ({{ strtoupper($paiement->methode) }})</td>
            </tr>
            <tr><td colspan="2"><hr style="border-top:1px solid #eee; margin:15px 0;"></td></tr>
            <tr>
                <td class="label">Élève :</td>
                <td class="value" style="font-size: 16px;">{{ $paiement->eleve->nom }} {{ $paiement->eleve->prenom }}</td>
            </tr>
            <tr>
                <td class="label">Classe :</td>
                <td class="value">{{ $paiement->eleve->classe->nom }}</td>
            </tr>
            @if($paiement->eleve->matricule)
            <tr>
                <td class="label">Matricule :</td>
                <td class="value">{{ $paiement->eleve->matricule }}</td>
            </tr>
            @endif
            <tr><td colspan="2"><hr style="border-top:1px solid #eee; margin:15px 0;"></td></tr>
            <tr>
                <td class="label">Payé par :</td>
                <td class="value">
                    @if($paiement->eleve->tuteurs && $paiement->eleve->tuteurs->isNotEmpty())
                        {{ $paiement->eleve->tuteurs->first()->nom }} {{ $paiement->eleve->tuteurs->first()->prenom }}
                    @else
                        Parent / Tuteur
                    @endif
                </td>
            </tr>
            <tr>
                <td class="label">Motif :</td>
                <td class="value">Frais de scolarité</td>
            </tr>
        </table>

        <div class="amount-box">
            Montant Payé : {{ number_format($paiement->montant, 0, ',', ' ') }} FCFA
            <br>
            <span class="status-badge">PAYÉ</span>
        </div>

        <div style="margin-top: 50px; text-align: right; padding-right: 50px;">
            <p><strong>La Comptabilité</strong></p>
            <p style="font-style: italic; color: #7f8c8d; font-size: 12px;">Document généré électroniquement.</p>
        </div>

        <div class="footer">
            Document généré le {{ $date_generation }} | Toute rature ou surcharge rend ce reçu nul.
        </div>
    </div>
</body>
</html>
