#!/bin/bash
set -e

echo "=== Laravel Docker Development Setup ==="

echo ""
echo "[1/9] Detecting host IP..."

VITE_DEV_HOST=$(ip route get 1.1.1.1 | awk '{print $7; exit}')

if [ -z "$VITE_DEV_HOST" ]; then
    echo "ERROR: Could not detect host IP."
    exit 1
fi

echo "Host IP detected: $VITE_DEV_HOST"

if [ -f ".env" ]; then
    if grep -q "^VITE_DEV_HOST=" .env; then
        sed -i "s/^VITE_DEV_HOST=.*/VITE_DEV_HOST=$VITE_DEV_HOST/" .env
    else
        echo "VITE_DEV_HOST=$VITE_DEV_HOST" >> .env
    fi
else
    echo "VITE_DEV_HOST=$VITE_DEV_HOST" > .env
fi

echo ""
echo "[2/9] Preparing Laravel environment..."

if [ ! -f "./src/.env" ]; then
    cp ./src/.env.example ./src/.env
    echo "src/.env created from .env.example"
else
    echo "src/.env already exists"
fi

echo ""
echo "[3/9] Starting Docker base services..."

docker compose up -d app db phpmyadmin

echo ""
echo "[4/9] Installing PHP dependencies..."

docker compose exec app composer install

echo ""
echo "[5/9] Fixing Laravel permissions..."

docker compose exec app chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
docker compose exec app chmod -R ug+rwX /var/www/html/storage /var/www/html/bootstrap/cache

echo ""
echo "[6/9] Generating application key..."

docker compose exec app php artisan key:generate --force

echo ""
echo "[7/9] Running database migrations..."

docker compose exec app php artisan migrate --force

echo ""
echo "[8/9] Installing Node dependencies..."

docker compose run --rm --no-deps vite npm install

echo ""
echo "[9/9] Starting application services..."

docker compose up -d web vite

echo ""
echo "=== Setup selesai ==="
echo "Application : http://$VITE_DEV_HOST:8080"
echo "phpMyAdmin  : http://$VITE_DEV_HOST:8081"
echo "Vite        : http://$VITE_DEV_HOST:5173"