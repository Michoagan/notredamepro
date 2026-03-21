$body = @{
    email = "marsben200@gmail.com"
    password = "MITCH1059"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8000/api/professeur/login" -Method Post -Body $body -ContentType "application/json"
$token = $response.token

Write-Host "Token: $token"

$endpoints = @(
    "/api/professeurs/espace/dashboard"
    "/api/professeurs/classes"
    "/api/professeurs/espace/emploi-du-temps"
    "/api/notes"
    "/api/cahier-texte"
)

foreach ($endpoint in $endpoints) {
    Write-Host "`n--- GET $endpoint ---"
    try {
        $res = Invoke-RestMethod -Uri "http://localhost:8000$endpoint" -Method Get -Headers @{ Authorization = "Bearer $token"; Accept = "application/json" }
        Write-Host "SUCCESS:"
        $res | ConvertTo-Json -Depth 2 | Out-String | Write-Host
    } catch {
        Write-Host "ERROR:"
        $_.Exception.Response.StatusCode
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.ReadToEnd()
    }
}
