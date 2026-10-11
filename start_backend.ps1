# Starts the backend for testing from a phone on the same Wi-Fi.
# Usage (PowerShell, from this folder):   .\start_backend.ps1
# If scripts are blocked:                 powershell -ExecutionPolicy Bypass -File .\start_backend.ps1

$ErrorActionPreference = 'Stop'
$backend = Join-Path $PSScriptRoot 'backend'
Set-Location $backend

if (-not (Test-Path '.venv\Scripts\python.exe')) {
    Write-Host 'Creating Python virtual environment...' -ForegroundColor Cyan
    python -m venv .venv
    & .venv\Scripts\python.exe -m pip install --upgrade pip
    & .venv\Scripts\pip.exe install -r requirements.txt
}

if (-not (Test-Path '.env')) {
    Copy-Item '.env.example' '.env'
    $token = & .venv\Scripts\python.exe -c "import secrets; print(secrets.token_urlsafe(24))"
    (Get-Content '.env') -replace '^APP_TOKEN=.*', "APP_TOKEN=$token" | Set-Content '.env' -Encoding utf8
    Write-Host 'Created backend\.env with a new APP_TOKEN. Put the same token in the app (Settings > Server connection).' -ForegroundColor Yellow
}

$token = (Select-String -Path '.env' -Pattern '^APP_TOKEN=(.*)$').Matches[0].Groups[1].Value
$gemini = (Select-String -Path '.env' -Pattern '^GEMINI_API_KEY=(.+)$')
$ips = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notmatch '^(127\.|169\.254\.)' -and $_.PrefixOrigin -ne 'WellKnown' } |
    Select-Object -ExpandProperty IPAddress

Write-Host ''
Write-Host '=== Factory Carbon backend ===' -ForegroundColor Green
Write-Host 'In the app open  Settings > Server connection  and enter:'
foreach ($ip in $ips) { Write-Host "   Server address:  ${ip}:8000" -ForegroundColor Cyan }
Write-Host "   App token:       $token" -ForegroundColor Cyan
Write-Host '   (Android emulator: 10.0.2.2:8000)'
if (-not $gemini) { Write-Host 'Bill reading is OFF until GEMINI_API_KEY is set in backend\.env (manual entry still works).' -ForegroundColor Yellow }
Write-Host 'If the phone cannot connect: allow Python through Windows Firewall (Private networks).'
Write-Host 'Press Ctrl+C to stop.'
Write-Host ''

& .venv\Scripts\python.exe -m uvicorn --factory app.main:create_default_app --host 0.0.0.0 --port 8000
