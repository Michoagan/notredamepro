<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Bulletin de Notes</title>
    <style>
        body { font-family: sans-serif; font-size: 12px; }
        .header { width: 100%; border-bottom: 2px solid #000; padding-bottom: 20px; margin-bottom: 30px; }
        .logo { width: 100px; height: auto; float: left; }
        .school-info { text-align: center; }
        .school-name { font-size: 18px; font-weight: bold; text-transform: uppercase; }
        .bulletin-title { text-align: center; font-size: 16px; font-weight: bold; margin: 20px 0; text-transform: uppercase; background-color: #eee; padding: 10px; }
        
        .student-info { width: 100%; margin-bottom: 30px; }
        .student-info td { padding: 5px; }
        .label { font-weight: bold; width: 150px; }
        
        table.grades { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        table.grades th, table.grades td { border: 1px solid #000; padding: 8px; text-align: center; }
        table.grades th { background-color: #f0f0f0; }
        .subject-col { text-align: left; font-weight: bold; width: 30%; }
        
        .summary { width: 100%; margin-top: 20px; border: 2px solid #000; padding: 10px; }
        .summary-col { width: 33%; text-align: center; vertical-align: top; }
        .average-box { font-size: 14px; font-weight: bold; margin-bottom: 10px; }
        
        .footer { position: fixed; bottom: 0; width: 100%; text-align: center; font-size: 10px; border-top: 1px solid #ccc; padding-top: 10px; }
        
        .signatures { margin-top: 50px; width: 100%; }
        .sig-box { width: 33%; float: left; text-align: center; height: 100px; }
        .qr-code { position: absolute; top: 20px; right: 20px; width: 80px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="school-info">
            <div class="school-name">COMPLEXE SCOLAIRE NOTRE DAME DE GRÂCE</div>
            <div>BP: 1234 Lomé - TOGO | Tél: 90 00 00 00</div>
            <div>Année Scolaire: 2025-2026</div>
        </div>
        @if(isset($qrCodeImage))
            <img src="data:image/png;base64, {{ $qrCodeImage }}" class="qr-code" alt="QR Code"/>
        @endif
    </div>

    <div class="bulletin-title">Bulletin du {{ $trimestre }}{{ $trimestre == 1 ? 'er' : 'ème' }} Trimestre</div>

    <table class="student-info">
        <tr>
            <td class="label">Nom & Prénoms:</td>
            <td colspan="3">{{ $data['eleve']->nom }} {{ $data['eleve']->prenom }}</td>
        </tr>
        <tr>
            <td class="label">Classe:</td>
            <td>{{ $data['eleve']->classe->nom }}</td>
            <td class="label">Matricule:</td>
            <td>{{ $data['eleve']->matricule }}</td>
        </tr>
         <tr>
            <td class="label">Effectif:</td>
            <td>{{ $data['effectif_classe'] }} élèves</td>
        </tr>
    </table>

    <table class="grades">
        <thead>
            <tr>
                <th>Matière</th>
                <th>Coeff.</th>
                <th>Moyenne</th>
                <th>Moyenne Pondérée</th>
                <th>Rang</th>
                <th>Appréciation</th>
                <th>Professeur</th>
            </tr>
        </thead>
        <tbody>
            @php $totalCoeff = 0; $totalPoints = 0; @endphp
            @foreach($data['notes'] as $note)
                <tr>
                    <td class="subject-col">{{ $note->matiere->nom }}</td>
                    <td>{{ $note->coefficient }}</td>
                    <td>{{ number_format($note->moyenne_trimestrielle, 2) }}</td>
                    <td>{{ number_format($note->moyenne_trimestrielle * $note->coefficient, 2) }}</td>
                    <td>{{ $note->rang ?? '-' }}</td>
                    <td>{{ $note->appreciation }}</td>
                    <td>-</td>
                </tr>
                @php 
                    $totalCoeff += $note->coefficient; 
                    $totalPoints += ($note->moyenne_trimestrielle * $note->coefficient);
                @endphp
            @endforeach
            <tr style="font-weight: bold; background-color: #f9f9f9;">
                <td style="text-align: right;">TOTAL</td>
                <td>{{ $totalCoeff }}</td>
                <td>-</td>
                <td>{{ number_format($totalPoints, 2) }}</td>
                <td colspan="3"></td>
            </tr>
        </tbody>
    </table>

    <table class="summary">
        <tr>
            <td class="summary-col">
                <div class="average-box">Moyenne Trimestrielle</div>
                <div style="font-size: 24px;">{{ number_format($data['moyenne_generale'], 2) }} / 20</div>
                <div style="margin-top: 10px;">Rang: <strong>{{ $data['rang'] }}<sup>{{ $data['rang'] == 1 ? 'er' : 'ème' }}</sup></strong> / {{ $data['effectif_classe'] }}</div>
            </td>
            <td class="summary-col">
                <div class="average-box">Statistiques Classe</div>
                <div>Moyenne Min: {{ number_format($data['minAverage'], 2) }}</div>
                <div>Moyenne Max: {{ number_format($data['maxAverage'], 2) }}</div>
                <div>Moyenne Classe: {{ number_format($data['classAverage'], 2) }}</div>
            </td>
            <td class="summary-col">
                <div class="average-box">Décision du Conseil</div>
                <div style="margin-top: 10px; font-style: italic;">
                    @if($data['moyenne_generale'] >= 10)
                        Travail Satisfaisant.
                    @else
                        Doit faire des efforts.
                    @endif
                </div>
            </td>
        </tr>
    </table>

    <div class="signatures">
        <div class="sig-box">
            <div>Le Parent</div>
        </div>
        <div class="sig-box">
            <div>Le Titulaire</div>
        </div>
        <div class="sig-box">
            <div>Le Directeur</div>
        </div>
    </div>

    <div class="footer">
        Bulletin généré le {{ date('d/m/Y à H:i') }} | Complexe Scolaire Notre Dame de Grâce
    </div>
</body>
</html>
