Write-Host "=== Laravel Docker Setup ===" -ForegroundColor Cyan

Write-Host "`n[1/3] Starting Docker containers..."
docker compose up -d

Write-Host "`n[2/3] Installing PHP dependencies..."
docker compose exec app composer install

Write-Host "`n[3/3] Installing Node dependencies..."
docker compose exec vite npm install

Write-Host "`n=== Setup selesai ===" -ForegroundColor Green
Write-Host "Application : http://localhost:8080"
Write-Host "phpMyAdmin  : http://localhost:8081"
Write-Host "Vite        : http://localhost:5173"