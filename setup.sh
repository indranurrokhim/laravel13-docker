#!/bin/bash
set -e

echo "=== Laravel Docker Production Setup ==="

echo ""
echo "[1/7] Preparing environment..."

if [ ! -f "./.env" ]; then
    cat > .env <<'EOF'
APP_KEY=
APP_URL=http://192.168.20.213:8080

DB_ROOT_PASSWORD=root
DB_DATABASE=laravel13
DB_USERNAME=laravel13
DB_PASSWORD=laravel13
EOF
    echo ".env created"
else
    echo ".env already exists"
fi

echo ""
echo "[2/7] Building production image..."

docker compose -f docker-compose.prod.yml build

echo ""
echo "[3/7] Generating Laravel APP_KEY..."

if grep -q "^APP_KEY=$" .env; then
    APP_KEY=$(docker compose -f docker-compose.prod.yml run --rm --no-deps app php artisan key:generate --show)
    sed -i "s|^APP_KEY=.*|APP_KEY=$APP_KEY|" .env
    echo "APP_KEY generated"
else
    echo "APP_KEY already exists"
fi

echo ""
echo "[4/7] Starting database..."

docker compose -f docker-compose.prod.yml up -d db

echo ""
echo "[5/7] Waiting for database..."

until docker compose -f docker-compose.prod.yml exec -T db mariadb-admin ping -h localhost --silent; do
    echo "Database is not ready yet..."
    sleep 2
done

echo "Database is ready."

echo ""
echo "[6/7] Starting application services..."

docker compose -f docker-compose.prod.yml up -d

echo ""
echo "Running database migration..."

docker compose -f docker-compose.prod.yml exec app php artisan migrate --force

echo ""
echo "[7/7] Checking services..."

docker compose -f docker-compose.prod.yml ps

echo ""
echo "=== Setup selesai ==="
echo "Application : http://192.168.20.213:8080"
echo "phpMyAdmin  : http://192.168.20.213:8081"