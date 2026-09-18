#!/bin/bash
set -e

echo "=== Laravel Docker Production Setup ==="

echo ""
echo "[1/6] Preparing environment..."
if [ ! -f "./src/.env" ]; then
    cp ./src/.env.example ./src/.env
    echo ".env created from .env.example"
else
    echo ".env already exists"
fi

echo ""
echo "[2/6] Preparing Docker environment..."
export DB_DATABASE="${DB_DATABASE:-laravel13}"
export DB_USERNAME="${DB_USERNAME:-laravel13}"
export DB_PASSWORD="${DB_PASSWORD:-laravel13}"
export DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-root}"

echo ""
echo "[3/6] Building production image..."
docker compose -f docker-compose.prod.yml build

echo ""
echo "[4/6] Starting production services..."
docker compose -f docker-compose.prod.yml up -d

echo ""
echo "[5/6] Running database migration..."
docker compose -f docker-compose.prod.yml exec app php artisan migrate --force

echo ""
echo "[6/6] Checking services..."
docker compose -f docker-compose.prod.yml ps

echo ""
echo "=== Setup selesai ==="
echo "Application : http://localhost:8080"
echo "phpMyAdmin  : http://localhost:8081"