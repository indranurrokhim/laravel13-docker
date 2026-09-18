$ErrorActionPreference = "Stop"

Write-Host "=== Laravel Docker Setup ===" -ForegroundColor Cyan

Write-Host "`n[1/7] Preparing environment..."
if (-not (Test-Path ".\src\.env")) {
    Copy-Item ".\src\.env.example" ".\src\.env"
    Write-Host ".env created from .env.example"
} else {
    Write-Host ".env already exists"
}

Write-Host "`n[2/7] Starting Docker base services..."
docker compose up -d app db phpmyadmin

Write-Host "`n[3/7] Installing PHP dependencies..."
docker compose exec app composer install

Write-Host "`n[4/7] Generating application key..."
docker compose exec app php artisan key:generate --force

Write-Host "`n[5/7] Running database migrations..."
docker compose exec app php artisan migrate --force

Write-Host "`n[6/7] Installing Node dependencies..."
docker compose run --rm --no-deps vite npm install

Write-Host "`n[7/7] Starting application services..."
docker compose up -d web vite

Write-Host "`n=== Setup selesai ===" -ForegroundColor Green
Write-Host "Application : http://localhost:8080"
Write-Host "phpMyAdmin  : http://localhost:8081"
Write-Host "Vite        : http://localhost:5173"