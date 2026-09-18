#!/bin/bash
set -e

echo "=== Laravel Docker Development Setup ==="

echo ""
echo "[1/8] Preparing Laravel environment..."

if [ ! -f "./src/.env" ]; then
    cp ./src/.env.example ./src/.env
    echo "src/.env created from .env.example"
else
    echo "src/.env already exists"
fi

echo ""
echo "[2/8] Starting Docker base services..."

docker compose up -d app db phpmyadmin

echo ""
echo "[3/8] Installing PHP dependencies..."

docker compose exec app composer install

echo ""
echo "[4/8] Fixing Laravel permissions..."

docker compose exec app chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
docker compose exec app chmod -R ug+rwX /var/www/html/storage /var/www/html/bootstrap/cache

echo ""
echo "[5/8] Generating application key..."

docker compose exec app php artisan key:generate --force

echo ""
echo "[6/8] Running database migrations..."

docker compose exec app php artisan migrate --force

echo ""
echo "[7/8] Installing Node dependencies..."

docker compose run --rm --no-deps vite npm install

echo ""
echo "[8/8] Starting application services..."

docker compose up -d web vite

echo ""
echo "=== Setup selesai ==="
echo "Application : http://localhost:8080"
echo "phpMyAdmin  : http://localhost:8081"
echo "Vite        : http://localhost:5173"