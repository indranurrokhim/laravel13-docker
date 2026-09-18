$ErrorActionPreference = "Stop"

Write-Host "=== Laravel Docker Development Setup ===" -ForegroundColor Cyan

Write-Host "`n[1/9] Detecting host IP..."

$VITE_DEV_HOST = (Get-NetIPConfiguration |
    Where-Object { $_.IPv4DefaultGateway -and $_.IPv4Address } |
    Select-Object -First 1).IPv4Address.IPAddress

if (-not $VITE_DEV_HOST) {
    Write-Host "ERROR: Could not detect host IP." -ForegroundColor Red
    exit 1
}

Write-Host "Host IP detected: $VITE_DEV_HOST"

if (Test-Path ".\.env") {
    $envContent = Get-Content ".\.env"

    if ($envContent -match "^VITE_DEV_HOST=") {
        $envContent = $envContent -replace "^VITE_DEV_HOST=.*", "VITE_DEV_HOST=$VITE_DEV_HOST"
        $envContent | Set-Content ".\.env"
    } else {
        Add-Content ".\.env" "VITE_DEV_HOST=$VITE_DEV_HOST"
    }
} else {
    "VITE_DEV_HOST=$VITE_DEV_HOST" | Set-Content ".\.env"
}

Write-Host "`n[2/9] Preparing Laravel environment..."

if (-not (Test-Path ".\src\.env")) {
    Copy-Item ".\src\.env.example" ".\src\.env"
    Write-Host "src/.env created from .env.example"
} else {
    Write-Host "src/.env already exists"
}

Write-Host "`n[3/9] Starting Docker base services..."

docker compose up -d app db phpmyadmin

Write-Host "`n[4/9] Installing PHP dependencies..."

docker compose exec app composer install

Write-Host "`n[5/9] Fixing Laravel permissions..."

docker compose exec app chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
docker compose exec app chmod -R ug+rwX /var/www/html/storage /var/www/html/bootstrap/cache

Write-Host "`n[6/9] Generating application key..."

docker compose exec app php artisan key:generate --force

Write-Host "`n[7/9] Running database migrations..."

docker compose exec app php artisan migrate --force

Write-Host "`n[8/9] Installing Node dependencies..."

docker compose run --rm --no-deps vite npm install

Write-Host "`n[9/9] Starting application services..."

docker compose up -d web vite

Write-Host "`n=== Setup selesai ===" -ForegroundColor Green
Write-Host "Application : http://$VITE_DEV_HOST`:8080"
Write-Host "phpMyAdmin  : http://$VITE_DEV_HOST`:8081"
Write-Host "Vite        : http://$VITE_DEV_HOST`:5173"