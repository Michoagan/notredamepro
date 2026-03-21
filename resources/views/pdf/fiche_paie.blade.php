<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Fiche de Paie</title>
    <style>
        body { font-family: 'Helvetica', 'Arial', sans-serif; font-size: 14px; color: #333; line-height: 1.5; padding: 20px; }
        .header { text-align: center; border-bottom: 2px solid #2563eb; padding-bottom: 20px; margin-bottom: 30px; }
        .school-name { font-size: 24px; font-weight: bold; color: #1e40af; margin: 0; }
        .title { font-size: 20px; font-weight: bold; margin-top: 15px; color: #475569; text-transform: uppercase; letter-spacing: 1px; }
        .info-grid { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        .info-grid td { padding: 8px; border: 1px solid #e2e8f0; }
        .info-grid .label { width: 30%; background-color: #f8fafc; font-weight: bold; color: #475569; }
        .financial-table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        .financial-table th, .financial-table td { padding: 12px; border: 1px solid #cbd5e1; text-align: right; }
        .financial-table th { background-color: #f1f5f9; color: #334155; text-align: left; }
        .financial-table th.right { text-align: right; }
        .financial-table .text-left { text-align: left; }
        .financial-table .total-row td { background-color: #eff6ff; font-weight: bold; font-size: 16px; color: #1e3a8a; }
        .footer { text-align: center; font-size: 12px; color: #64748b; margin-top: 50px; border-top: 1px solid #e2e8f0; padding-top: 20px; }
        .signatures { width: 100%; margin-top: 40px; }
        .signatures td { width: 50%; text-align: center; }
        .signatures .sign-box { border-top: 1px dotted #94a3b8; display: inline-block; width: 200px; padding-top: 10px; margin-top: 60px; }
    </style>
</head>
<body>

    <div class="header">
        <h1 class="school-name">COMPLEXE SCOLAIRE NOTRE DAME</h1>
        <div class="title">FICHE DE PAIE</div>
        <p>Période: <strong>{{ \Carbon\Carbon::createFromDate($salaire->annee, $salaire->mois, 1)->locale('fr')->translatedFormat('F Y') }}</strong></p>
    </div>

    @php
        $isProf = $salaire->professeur_id !== null;
        $employe = $isProf ? $salaire->professeur : $salaire->directionUser;
        $nomComplet = $employe->first_name . ' ' . $employe->last_name;
        $fonction = $isProf ? 'Professeur' : ucfirst($employe->role ?? 'Agent');
    @endphp

    <table class="info-grid">
        <tr>
            <td class="label">Nom et Prénom (s)</td>
            <td><strong>{{ $nomComplet }}</strong></td>
            <td class="label">Statut</td>
            <td>{{ ucfirst($salaire->statut) }}</td>
        </tr>
        <tr>
            <td class="label">Fonction</td>
            <td>{{ $fonction }}</td>
            <td class="label">Date de paiement</td>
            <td>{{ $salaire->date_paiement ? \Carbon\Carbon::parse($salaire->date_paiement)->format('d/m/Y') : 'Non payé' }}</td>
        </tr>
    </table>

    <table class="financial-table">
        <thead>
            <tr>
                <th class="text-left">Désignation</th>
                <th class="right">Base / Taux</th>
                <th class="right">Heures</th>
                <th class="right">Montant (FCFA)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="text-left">{{ $isProf ? 'Rémunération Heures Normales' : 'Salaire de Base Fixe' }}</td>
                <td>{{ number_format($isProf ? $salaire->taux_horaire : $salaire->montant_base, 0, ',', ' ') }}</td>
                <td>{{ $isProf ? $salaire->heures_travaillees : '-' }}</td>
                <td>{{ number_format($salaire->montant_base, 0, ',', ' ') }}</td>
            </tr>
            @if($salaire->primes > 0)
            <tr>
                <td class="text-left">Primes et Indémnités</td>
                <td>-</td>
                <td>-</td>
                <td style="color: green;">+ {{ number_format($salaire->primes, 0, ',', ' ') }}</td>
            </tr>
            @endif
            @if($salaire->retenues > 0)
            <tr>
                <td class="text-left">Retenues (Avances, Absences)</td>
                <td>-</td>
                <td>-</td>
                <td style="color: red;">- {{ number_format($salaire->retenues, 0, ',', ' ') }}</td>
            </tr>
            @endif
            <tr class="total-row">
                <td colspan="3" class="text-left">NET A PAYER</td>
                <td>{{ number_format($salaire->net_a_payer, 0, ',', ' ') }} FCFA</td>
            </tr>
        </tbody>
    </table>

    <table class="signatures">
        <tr>
            <td>
                <strong>Le Comptable</strong><br>
                <div class="sign-box">Signature & Cachet</div>
            </td>
            <td>
                <strong>L'Employé(e)</strong><br>
                <div class="sign-box">Signature</div>
            </td>
        </tr>
    </table>

    <div class="footer">
        Document généré le {{ now()->format('d/m/Y à H:i') }} par le système de gestion de paie Notre Dame Pro.
    </div>

</body>
</html>
