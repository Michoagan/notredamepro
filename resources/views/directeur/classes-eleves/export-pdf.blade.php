<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Liste des Élèves - {{ $classe->nom }}</title>
    <style>
        body { font-family: 'Helvetica', 'Arial', sans-serif; font-size: 13px; color: #333; line-height: 1.4; padding: 20px; }
        .header { margin-bottom: 30px; border-bottom: 2px solid #1e3a8a; padding-bottom: 10px; }
        .school-name { font-size: 22px; font-weight: bold; color: #1e40af; margin: 0; }
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
        <div class="title">Liste Officielle des Élèves</div>
        <p>Classe : <strong>{{ $classe->nom }}</strong> | Effectif : {{ $eleves->count() }}</p>
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
                <th>Matricule</th>
                <th>Nom & Prénoms</th>
                <th>Date de Naissance</th>
                <th>Sexe</th>
            </tr>
        </thead>
        <tbody>
            @foreach($eleves as $index => $eleve)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>{{ $eleve->matricule }}</td>
                <td><strong>{{ $eleve->nom }}</strong> {{ $eleve->prenom }}</td>
                <td>{{ \Carbon\Carbon::parse($eleve->date_naissance)->format('d/m/Y') }}</td>
                <td>{{ $eleve->sexe }}</td>
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
