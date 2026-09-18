# Laravel 13 Docker

Laravel 13 application running with Docker Compose.

## Stack

- Laravel 13
- PHP 8.4
- PHP-FPM
- Nginx
- MariaDB 11
- Node.js 24
- Vite
- Composer
- npm
- phpMyAdmin

## Architecture

```text
Browser
   │
   ├── http://localhost:8080
   │
   ▼
 Nginx
   │
   ▼
 PHP-FPM (Laravel)
   │
   ▼
 MariaDB

Browser
   │
   └── http://localhost:5173
             │
             ▼
            Vite
```

## Requirements

- Docker Desktop
- Git
- PowerShell

Make sure Docker Desktop is running.

Check:

```powershell
docker --version
docker compose version
git --version
```

## First Setup

Clone the repository:

```powershell
git clone <repository-url>
cd laravel13-docker
```

Run:

```powershell
.\setup.ps1
```

The setup script will:

1. Create `.env` from `.env.example` if it does not exist.
2. Start the base Docker services.
3. Install PHP dependencies with Composer.
4. Generate the Laravel application key.
5. Run database migrations.
6. Install Node dependencies with npm.
7. Start Nginx and Vite.

After setup:

```text
Application : http://localhost:8080
phpMyAdmin  : http://localhost:8081
Vite        : http://localhost:5173
```

## Development

Start all services:

```powershell
docker compose up -d
```

Check containers:

```powershell
docker compose ps
```

Stop containers:

```powershell
docker compose down
```

## Laravel

Run Artisan commands inside the `app` container:

```powershell
docker compose exec app php artisan about
```

Migration:

```powershell
docker compose exec app php artisan migrate
```

Create controller:

```powershell
docker compose exec app php artisan make:controller ExampleController
```

Create model:

```powershell
docker compose exec app php artisan make:model Example
```

Clear cache:

```powershell
docker compose exec app php artisan optimize:clear
```

Run tests:

```powershell
docker compose exec app php artisan test
```

## Composer

Install dependencies:

```powershell
docker compose exec app composer install
```

Update dependencies:

```powershell
docker compose exec app composer update
```

Add a package:

```powershell
docker compose exec app composer require vendor/package
```

Commit these files when dependencies change:

```text
src/composer.json
src/composer.lock
```

Do not commit:

```text
src/vendor/
```

## Node / Vite

Install dependencies:

```powershell
docker compose run --rm --no-deps vite npm install
```

Build frontend assets:

```powershell
docker compose run --rm --no-deps vite npm run build
```

Vite development server:

```text
http://localhost:5173
```

Do not commit:

```text
src/node_modules/
```

## Environment

`.env` is local to each development environment and must not be committed.

The repository contains:

```text
src/.env.example
```

For a new developer, `setup.ps1` automatically creates:

```text
src/.env
```

Database configuration:

```env
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel13
DB_USERNAME=laravel13
DB_PASSWORD=laravel13
```

Inside the Laravel container, the database host is:

```text
db
```

Do not use `localhost` as the database host from inside the container.

## Services

### app

PHP-FPM container running Laravel.

```text
PHP 8.4
Composer
Node.js 24
```

Application source:

```text
/var/www/html
```

### web

Nginx web server.

```text
http://localhost:8080
```

Nginx forwards PHP requests to:

```text
app:9000
```

### db

MariaDB 11.

Laravel connects through:

```text
db:3306
```

Database data is stored in the Docker volume:

```text
db_data
```

### vite

Node.js 24 development server.

```text
http://localhost:5173
```

### phpmyadmin

phpMyAdmin:

```text
http://localhost:8081
```

Database server:

```text
db
```

## Docker Volumes

The project uses named volumes:

```text
db_data
vendor
node_modules
```

### db_data

Stores MariaDB data.

Removing this volume deletes the development database.

### vendor

Stores Composer dependencies inside Docker.

The host does not need:

```text
src/vendor
```

### node_modules

Stores Node dependencies inside Docker.

The host does not need:

```text
src/node_modules
```

## Git Workflow

Pull the latest source:

```powershell
git pull origin main
```

Start services:

```powershell
docker compose up -d
```

If PHP dependencies changed:

```powershell
docker compose exec app composer install
```

If Node dependencies changed:

```powershell
docker compose run --rm --no-deps vite npm install
```

If database migrations changed:

```powershell
docker compose exec app php artisan migrate
```

Check status:

```powershell
git status
```

Commit:

```powershell
git add .
git commit -m "Describe the changes"
git push origin main
```

## Files Not Committed

The following are local or generated files:

```text
src/.env
src/vendor/
src/node_modules/
src/public/build/
```

They are excluded by `.gitignore`.

## Reset Development Environment

Stop and remove containers:

```powershell
docker compose down
```

Remove containers and Docker volumes:

```powershell
docker compose down -v
```

> Warning: `docker compose down -v` removes the development database stored in Docker volumes.

After resetting:

```powershell
.\setup.ps1
```

## Troubleshooting

Container status:

```powershell
docker compose ps
```

Application logs:

```powershell
docker compose logs app
```

Nginx logs:

```powershell
docker compose logs web
```

Database logs:

```powershell
docker compose logs db
```

Vite logs:

```powershell
docker compose logs vite
```

Follow all logs:

```powershell
docker compose logs -f
```

Clear Laravel cache:

```powershell
docker compose exec app php artisan optimize:clear
```

Rebuild the PHP image after changing `docker/php/Dockerfile`:

```powershell
docker compose up -d --build
```

## Development Notes

This project uses a custom Docker Compose setup instead of Laravel Sail.

Development uses bind mounts so source-code changes are immediately available inside the containers.

The planned production environment will use a separate Compose configuration without binding the application source directly from the host.

Development:

```text
Host source
    │
    ▼
Docker bind mount
    │
    ▼
Laravel container
```

Production:

```text
Git repository
    │
    ▼
Docker build
    │
    ▼
Application image
    │
    ▼
Production container
```

Production deployment documentation will be added separately.
