<#
.SYNOPSIS
    Smoke-Test für die AuthCore Identity API.
    Prüft Login, Profil, Benutzernamen-Check und Autocomplete.

.PARAMETER BaseUrl
    Basis-URL des AuthCore-Servers (Standard: http://localhost:5101)

.PARAMETER Email
    Test-Benutzer-E-Mail

.PARAMETER Password
    Test-Benutzer-Passwort

.EXAMPLE
    .\smoke-test.ps1
    .\smoke-test.ps1 -BaseUrl "https://localhost:7157" -Email "user@example.com" -Password "Pw123!"
#>
param(
    [string]$BaseUrl  = "http://localhost:5101",
    [string]$Email    = "demo@example.com",
    [string]$Password = "Demo123!"
)

$ErrorActionPreference = "Stop"
$pass = 0; $fail = 0

function Test-Step([string]$name, [scriptblock]$block) {
    Write-Host -NoNewline "  $name ... "
    try {
        & $block
        Write-Host "✅ OK" -ForegroundColor Green
        $script:pass++
    } catch {
        Write-Host "❌ FAIL: $_" -ForegroundColor Red
        $script:fail++
    }
}

Write-Host "`n🔍 AuthCore API Smoke-Test  ($BaseUrl)`n" -ForegroundColor Cyan

# 1. Login
$token = $null
Test-Step "POST /identity/login" {
    $body = @{ email = $Email; password = $Password } | ConvertTo-Json
    $resp = Invoke-RestMethod "$BaseUrl/identity/login?useCookies=false&useSessionCookies=false" `
        -Method Post -Body $body -ContentType "application/json"
    if (-not $resp.accessToken) { throw "Kein accessToken in Response" }
    $script:token = $resp.accessToken
    Write-Host -NoNewline " [Token: $($resp.accessToken.Substring(0,16))...] " -ForegroundColor DarkGray
}

# 2. Eigenes Profil
Test-Step "GET /api/v1/profile" {
    if (-not $script:token) { throw "Kein Token (Login fehlgeschlagen)" }
    $resp = Invoke-RestMethod "$BaseUrl/api/v1/profile" `
        -Headers @{ Authorization = "Bearer $($script:token)" }
    $profile = $resp.data ?? $resp
    if (-not $profile.publicUsername) { throw "publicUsername fehlt in Response" }
    Write-Host -NoNewline " [User: $($profile.publicUsername)] " -ForegroundColor DarkGray
}

# 3. Benutzernamen-Verfügbarkeit (kein Auth)
Test-Step "GET /api/v1/profile/check-username/test-smoke" {
    $resp = Invoke-RestMethod "$BaseUrl/api/v1/profile/check-username/test-smoke"
    if ($null -eq $resp.available) { throw "Feld 'available' fehlt in Response" }
}

# 4. Städte-Autocomplete (kein Auth)
Test-Step "GET /api/v1/autocomplete/cities?query=Berlin" {
    $resp = Invoke-RestMethod "$BaseUrl/api/v1/autocomplete/cities?query=Berlin"
    if ($resp -isnot [array]) { throw "Erwartetes Array, erhalten: $($resp.GetType().Name)" }
}

# 5. Länderliste (kein Auth)
Test-Step "GET /api/v1/autocomplete/countries" {
    $resp = Invoke-RestMethod "$BaseUrl/api/v1/autocomplete/countries"
    if ($resp -isnot [array] -or $resp.Count -eq 0) { throw "Leere oder ungültige Länderliste" }
}

# 6. Swagger-Spezifikation (Development)
Test-Step "GET /swagger/v1/swagger.json" {
    $resp = Invoke-RestMethod "$BaseUrl/swagger/v1/swagger.json"
    if (-not $resp.info.title) { throw "Swagger-Spec ohne 'info.title'" }
    Write-Host -NoNewline " [API: $($resp.info.title) $($resp.info.version)] " -ForegroundColor DarkGray
}

# Ergebnis
$total = $pass + $fail
Write-Host "`n─────────────────────────────────────────" -ForegroundColor DarkGray
if ($fail -eq 0) {
    Write-Host "✅ Alle $total Tests bestanden.`n" -ForegroundColor Green
} else {
    Write-Host "⚠️  $pass/$total Tests bestanden, $fail fehlgeschlagen.`n" -ForegroundColor Yellow
    exit 1
}
