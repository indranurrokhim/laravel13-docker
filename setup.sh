#!/bin/bash
set -e

echo "=== Laravel Docker Development Setup ==="

echo ""
echo "[1/7] Preparing Laravel environment..."

if [ ! -f "./src/.env" ]; then
    cp ./src/.env.example ./src/.env
    echo "src/.env created from .env.example"
else
    echo "src/.env already exists"
fi

echo ""
echo "[2/7] Starting Docker base services..."

docker compose up -d app db phpmyadmin

echo ""
echo "[3/7] Installing PHP dependencies..."

docker compose exec app composer install

echo ""
echo "[4/7] Generating application key..."

docker compose exec app php artisan key:generate --force

echo ""
echo "[5/7] Running database migrations..."

docker compose exec app php artisan migrate --force

echo ""
echo "[6/7] Installing Node dependencies..."

docker compose run --rm --no-deps vite npm install

echo ""
echo "[7/7] Starting application services..."

docker compose up -d web vite

echo ""
echo "=== Setup selesai ==="
echo "Application : http://localhost:8080"
echo "phpMyAdmin  : http://localhost:8081"
echo "Vite        : http://localhost:5173"