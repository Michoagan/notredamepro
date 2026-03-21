<!DOCTYPE html>
<html>
<head>
    <title>Reçu de Paiement</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            color: #333;
            line-height: 1.6;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #0056b3;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .header h2 {
            color: #0056b3;
            margin: 0;
        }
        .content {
            margin-bottom: 20px;
        }
        .footer {
            font-size: 0.9em;
            color: #777;
            text-align: center;
            border-top: 1px solid #ddd;
            padding-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Notre Dame de Toutes Grâces</h2>
            <p>Confirmation de Paiement</p>
        </div>
        
        <div class="content">
            <p>Bonjour {{ $paiement->eleve->nom_parent ?? 'Cher parent' }},</p>
            
            <p>Nous vous confirmons la bonne réception de votre paiement de <strong>{{ number_format($paiement->montant, 0, ',', ' ') }} FCFA</strong> pour la scolarité de <strong>{{ $paiement->eleve->prenom }} {{ $paiement->eleve->nom }}</strong>.</p>
            
            <p>Détails de la transaction :</p>
            <ul>
                <li><strong>Référence :</strong> {{ $paiement->reference }}</li>
                <li><strong>Date :</strong> {{ $paiement->date_paiement->format('d/m/Y à H:i') }}</li>
                <li><strong>Méthode :</strong> {{ ucfirst($paiement->methode) }}</li>
                <li><strong>Motif :</strong> {{ $paiement->contribution->description ?? 'Scolarité' }}</li>
            </ul>
            
            <p>Veuillez trouver ci-joint votre reçu officiel au format PDF.</p>
            
            <p>Nous vous remercions de votre confiance.</p>
        </div>
        
        <div class="footer">
            <p>Ceci est un email automatique, merci de ne pas y répondre.</p>
            <p>&copy; {{ date('Y') }} Complexe Scolaire Notre Dame de Toutes Grâces.</p>
        </div>
    </div>
</body>
</html>
