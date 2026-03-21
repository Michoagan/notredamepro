<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Paiement KkiaPay</title>
</head>
<body style="display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f4f6f9; font-family: Arial, sans-serif;">
    
    <div style="text-align: center;">
        <h2 style="color: #032b43;">Initialisation du paiement KkiaPay...</h2>
        <p>Veuillez patienter, le widget de paiement va s'afficher.</p>
        <div id="kkiapay-widget"></div>
    </div>

    <script src="https://cdn.kkiapay.me/k.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            openKkiapayWidget({
                amount: {{ $montant }},
                position: "center",
                callback: "{{ $callbackUrl }}",
                data: "{{ $transactionId }}",
                theme: "#032b43",
                key: "{{ $apiKey }}",
                sandbox: true
            });
        });
    </script>
</body>
</html>
