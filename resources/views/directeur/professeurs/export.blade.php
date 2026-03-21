<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Liste Générale - Professeurs</title>
    <style>
        body { font-family: 'Helvetica', 'Arial', sans-serif; font-size: 13px; color: #333; line-height: 1.4; padding: 20px; }
        .header { margin-bottom: 30px; border-bottom: 2px solid #059669; padding-bottom: 10px; }
        .school-name { font-size: 22px; font-weight: bold; color: #047857; margin: 0; }
        .title { font-size: 18px; font-weight: bold; margin-top: 10px; color: #475569; text-transform: uppercase; }
        .qr-container { text-align: right; margin-top: -60px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 8px; border: 1px solid #cbd5e1; text-align: left; }
        th { background-color: #f1f5f9; color: #334155; font-weight: bold; }
        .footer { text-align: center; font-size: 11px; color: #64748b; margin-top: 40px; border-top: 1px solid #e2e8f0; padding-top: 10px; }
    </style>
</head>
<body>

    <div class="header">
        <h1 class="school-name">COMPLEXE SCOLAIRE NOTRE DAME</h1>
        <div class="title">Liste Officielle des Professeurs</div>
        <p>Effectif Total : {{ $professeurs->count() }} Enseignants</p>
    </div>

    @if(isset($qrCodeImage))
    <div class="qr-container">
        <img src="data:image/png;base64,{{ $qrCodeImage }}" alt="QR Code d'Authentification" style="width: 80px; height: 80px;">
        <div style="font-size: 9px; color: #64748b; margin-top: 5px;">Document Authentifié</div>
    </div>
    @endif

    <table>
        <thead>
            <tr>
                <th>N°</th>
                <th>Nom & Prénoms</th>
                <th>Matière(s)</th>
                <th>Tél.</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            @foreach($professeurs as $index => $professeur)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td><strong>{{ strtoupper($professeur->last_name) }}</strong> {{ $professeur->first_name }}</td>
                <td>
                    @foreach($professeur->matieresEnseignees as $matiere)
                        {{ $matiere->nom }}@if(!$loop->last), @endif
                    @endforeach
                </td>
                <td>{{ $professeur->phone ?? 'N/A' }}</td>
                <td>{{ $professeur->is_active ? 'Actif' : 'Inactif' }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <div class="footer">
        Export généré le {{ $date }} par le système de gestion Notre Dame Pro.<br>
        La présence du code QR dans l'en-tête certifie l'authenticité de cette liste.
    </div>

</body>
</html>
