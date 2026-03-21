<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Reçu de Paiement - {{ $paiement->reference }}</title>
    <style>
        body {
            font-family: 'Helvetica', 'Arial', sans-serif;
            color: #333;
            margin: 0;
            padding: 20px;
            font-size: 14px;
        }
        .header {
            width: 100%;
            border-bottom: 2px solid #1a237e;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .header table {
            width: 100%;
        }
        .school-info {
            text-align: left;
        }
        .school-name {
            font-size: 24px;
            font-weight: bold;
            color: #1a237e;
            margin: 0 0 5px 0;
        }
        .receipt-title {
            text-align: right;
            color: #555;
        }
        .receipt-title h1 {
            margin: 0 0 5px 0;
            font-size: 28px;
            color: #d32f2f;
            text-transform: uppercase;
        }
        
        .details-section {
            width: 100%;
            margin-bottom: 30px;
        }
        .details-section td {
            vertical-align: top;
            width: 50%;
        }
        .box {
            border: 1px solid #eee;
            border-radius: 5px;
            padding: 15px;
            background-color: #f9f9f9;
        }
        .box h3 {
            margin-top: 0;
            margin-bottom: 10px;
            color: #1a237e;
            font-size: 16px;
            border-bottom: 1px solid #ddd;
            padding-bottom: 5px;
        }
        .info-row {
            margin-bottom: 5px;
        }
        .info-label {
            font-weight: bold;
            display: inline-block;
            width: 120px;
        }
        
        .transaction-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 40px;
        }
        .transaction-table th {
            background-color: #1a237e;
            color: white;
            padding: 12px;
            text-align: left;
        }
        .transaction-table td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }
        .amount-col {
            text-align: right;
        }
        
        .total-section {
            width: 100%;
            text-align: right;
            font-size: 18px;
        }
        .total-amount {
            font-size: 24px;
            font-weight: bold;
            color: #1a237e;
        }
        
        .footer {
            margin-top: 50px;
            text-align: center;
            font-size: 12px;
            color: #777;
            border-top: 1px solid #eee;
            padding-top: 20px;
        }
        .signature-area {
            margin-top: 50px;
            width: 100%;
        }
        .signature-box {
            float: right;
            width: 200px;
            text-align: center;
        }
        .signature-line {
            border-bottom: 1px solid #333;
            margin-bottom: 5px;
            height: 50px;
        }
    </style>
</head>
<body>

    <div class="header">
        <table>
            <tr>
                <td class="school-info">
                    <h2 class="school-name">C.S. NOTRE DAME DE TOUTES GRÂCES</h2>
                    <p>
                        Quartier Ayelawadje, Cotonou<br>
                        Tél: +229 97 00 00 00<br>
                        Email: contact@ndtg.bj
                    </p>
                </td>
                <td class="receipt-title">
                    <h1>REÇU</h1>
                    <p>
                        <strong>Réf:</strong> {{ $paiement->reference }}<br>
                        <strong>Date:</strong> {{ \Carbon\Carbon::parse($paiement->date_paiement)->format('d/m/Y') }}<br>
                        <strong>Heure:</strong> {{ \Carbon\Carbon::parse($paiement->date_paiement)->format('H:i') }}
                    </p>
                </td>
            </tr>
        </table>
    </div>

    <table class="details-section">
        <tr>
            <td style="padding-right: 10px;">
                <div class="box">
                    <h3>Informations Élève</h3>
                    <div class="info-row"><span class="info-label">Matricule:</span> {{ $paiement->eleve->matricule }}</div>
                    <div class="info-row"><span class="info-label">Nom complet:</span> {{ $paiement->eleve->nom }} {{ $paiement->eleve->prenom }}</div>
                    <div class="info-row"><span class="info-label">Classe:</span> {{ $paiement->eleve->classe->nom ?? 'N/A' }}</div>
                    <div class="info-row"><span class="info-label">Parent/Tuteur:</span> {{ $paiement->eleve->nom_parent ?? 'N/A' }}</div>
                </div>
            </td>
            <td style="padding-left: 10px;">
                <div class="box">
                    <h3>Détails du Paiement</h3>
                    <div class="info-row"><span class="info-label">Mode:</span> {{ ucfirst($paiement->methode) }}</div>
                    <div class="info-row"><span class="info-label">Statut:</span> <span style="color: green; font-weight: bold;">PAYÉ</span></div>
                    <div class="info-row"><span class="info-label">Caissier(ère):</span> Direction/Comptabilité</div>
                </div>
            </td>
        </tr>
    </table>

    <table class="transaction-table">
        <thead>
            <tr>
                <th>Désignation</th>
                <th>Année Scolaire</th>
                <th class="amount-col">Montant</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>{{ $paiement->contribution->description ?? 'Scolarité (Frais de scolarité)' }}</td>
                <td>{{ $paiement->contribution->annee_scolaire ?? 'Scolaire en cours' }}</td>
                <td class="amount-col">{{ number_format($paiement->montant, 0, ',', ' ') }} FCFA</td>
            </tr>
        </tbody>
    </table>

    <div class="total-section">
        <p>Montant Total Versé: <span class="total-amount">{{ number_format($paiement->montant, 0, ',', ' ') }} FCFA</span></p>
    </div>

    <div class="signature-area">
        @if(isset($qrCodeImage))
        <div style="float: left; width: 100px; text-align: center;">
            <img src="data:image/png;base64,{{ $qrCodeImage }}" alt="QR Code" style="width: 100px; height: 100px;">
            <div style="font-size: 8px; color: #777; margin-top: 5px;">Document Authentifié</div>
        </div>
        @endif
        
        <div class="signature-box">
            <div class="signature-line"></div>
            <strong>La Caisse / Direction</strong>
        </div>
        <div style="clear: both;"></div>
    </div>

    <div class="footer">
        <p>Ce reçu est généré électroniquement par le système de gestion financière.<br>
        Merci de le conserver précieusement. Il vous servira de preuve de paiement.</p>
    </div>

</body>
</html>
