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

### Development

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

### Production

```text
Browser
   │
   ▼
 Nginx
   │
   ▼
 PHP-FPM (Laravel)
   │
   ▼
 MariaDB
```

Production does not use the Vite development server.

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

Source code is bind-mounted into the containers, so changes to `src/` are available immediately.

## Laravel

Run Artisan commands inside the `app` container:

```powershell
docker compose exec app php artisan about
docker compose exec app php artisan migrate
docker compose exec app php artisan make:controller ExampleController
docker compose exec app php artisan make:model Example
docker compose exec app php artisan optimize:clear
docker compose exec app php artisan test
```

## Composer

```powershell
docker compose exec app composer install
docker compose exec app composer update
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

```powershell
docker compose run --rm --no-deps vite npm install
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

`.env` is local to each environment and must not be committed.

The repository contains:

```text
src/.env.example
```

For a new developer, `setup.ps1` automatically creates:

```text
src/.env
```

Development database configuration:

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

| Service | Purpose | Development |
|---|---|---|
| app | PHP-FPM + Laravel | Internal |
| web | Nginx | http://localhost:8080 |
| db | MariaDB 11 | Internal |
| vite | Vite development server | http://localhost:5173 |
| phpmyadmin | Database management | http://localhost:8081 |

Nginx forwards PHP requests to:

```text
app:9000
```

## Docker Volumes

Development uses:

```text
db_data
vendor
node_modules
```

Production-style testing additionally uses:

```text
app_code
```

### db_data

Stores MariaDB data.

Removing this volume deletes the database.

### vendor

Stores Composer dependencies inside Docker during development.

### node_modules

Stores Node dependencies inside Docker during development.

### app_code

Production-only shared volume. The `app` container provides the Laravel files and Nginx reads them as read-only.

## Git Workflow

Pull latest source:

```powershell
git pull origin main
```

Start development:

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

If migrations changed:

```powershell
docker compose exec app php artisan migrate
```

Check:

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

```text
src/.env
src/vendor/
src/node_modules/
src/public/build/
```

These are local or generated files.

## Reset Development Environment

Stop containers:

```powershell
docker compose down
```

Remove containers and development volumes:

```powershell
docker compose down -v
```

> Warning: `docker compose down -v` removes the development database.

Then:

```powershell
.\setup.ps1
```

## Troubleshooting

```powershell
docker compose ps
docker compose logs app
docker compose logs web
docker compose logs db
docker compose logs vite
docker compose logs -f
docker compose exec app php artisan optimize:clear
```

After changing the development Dockerfile:

```powershell
docker compose up -d --build
```

## Production (Optional)

Production is optional while the application is still being developed.

Separate files are used:

```text
Development
├── docker-compose.yml
└── docker/php/Dockerfile

Production
├── docker-compose.prod.yml
└── docker/php/Dockerfile.prod
```

### Development vs Production

Development:

```text
Host source
    │
    ▼
Bind mount
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
Production image
    │
    ▼
app container
    │
    └── app_code volume
              │
              ▼
          Nginx container
```

Production does not use:

```text
vite container
npm run dev
host source bind mount
```

Frontend assets are generated during the image build:

```bash
npm run build
```

### Production Build

Build:

```powershell
docker compose -f docker-compose.prod.yml build
```

Start:

```powershell
docker compose -f docker-compose.prod.yml up -d
```

Check:

```powershell
docker compose -f docker-compose.prod.yml ps
```

Application:

```text
http://localhost:8080
```

phpMyAdmin:

```text
http://localhost:8081
```

### Production Migration

When migrations are included in a deployment:

```powershell
docker compose -f docker-compose.prod.yml exec app php artisan migrate --force
```

### Production Update

After source changes have been pushed to Git:

```powershell
git pull origin main
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
```

If required:

```powershell
docker compose -f docker-compose.prod.yml exec app php artisan migrate --force
```

### Local Production Test

Production Compose can be tested locally before Ubuntu deployment:

```powershell
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml ps
```

Stop the test:

```powershell
docker compose -f docker-compose.prod.yml down
```

Do not use `down -v` unless the production-test volumes are intentionally going to be removed.

## Ubuntu Server as Programmer 3 / Deployment-Test Server

For the current learning setup, Ubuntu is treated as a separate machine from the programmers' development environments.

It is **not the primary coding environment**. Its role is to pull the latest code and run/test the Docker deployment.

```text
Programmer 1 / Programmer 2
          │
          ▼
       GitHub
          │
          ▼
   Ubuntu Docker Server
          │
          └── git pull
```

Typical manual update:

```bash
git pull origin main
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml exec app php artisan migrate --force
```

This manual workflow is intentional for now. CI/CD can be added later.

## Production Environment and Secrets

Production credentials must not be committed to Git.

Do not put real production passwords in:

```text
docker-compose.prod.yml
Git repository
README.md
```

The current production Compose test expects these Compose variables:

```text
DB_DATABASE
DB_USERNAME
DB_PASSWORD
DB_ROOT_PASSWORD
```

They must be supplied by the production environment before using the setup on a real server.

Before real production deployment, review production `.env` and secret handling separately.

## Development Notes

This project uses a custom Docker Compose setup instead of Laravel Sail.

Development uses bind mounts so source-code changes are immediately available.

Production uses a separate Compose configuration and production Dockerfile so the application is packaged into a Docker image instead of being mounted from the host.

The production setup is currently optional and intended for learning and deployment testing while application development continues.

## Future Production Improvements

- Separate production `.env` / secret handling
- HTTPS / TLS
- Domain name
- Queue worker
- Laravel Scheduler
- Redis
- Mail service
- Database backup
- Health checks
- CI/CD
- Zero-downtime deployment
- Image version tagging
- Monitoring and logging
