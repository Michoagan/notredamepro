<?php
$ch = curl_init('http://localhost:8000/api/professeurs/espace/emploi-du-temps');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, true);
$response = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
echo "HTTP Status Code: " . $httpcode . "\n";
echo "Response:\n" . $response;
curl_close($ch);
