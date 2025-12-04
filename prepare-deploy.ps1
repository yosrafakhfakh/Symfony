# Script de préparation au déploiement
Write-Host "`n=== PREPARATION AU DEPLOIEMENT ===" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Composer est installé
if (-not (Get-Command composer -ErrorAction SilentlyContinue)) {
    Write-Host "Erreur: Composer n'est pas installe!" -ForegroundColor Red
    exit 1
}

Write-Host "[1/5] Installation des dependances de production..." -ForegroundColor Yellow
composer install --no-dev --optimize-autoloader
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de l'installation des dependances" -ForegroundColor Red
    exit 1
}
Write-Host "  OK" -ForegroundColor Green

Write-Host "`n[2/5] Vider le cache..." -ForegroundColor Yellow
php bin/console cache:clear --env=prod --no-debug
Write-Host "  OK" -ForegroundColor Green

Write-Host "`n[3/5] Rechauffer le cache..." -ForegroundColor Yellow
php bin/console cache:warmup --env=prod
Write-Host "  OK" -ForegroundColor Green

Write-Host "`n[4/5] Verification des fichiers..." -ForegroundColor Yellow

# Vérifier que .env.production existe
if (-not (Test-Path ".env.production")) {
    Write-Host "  ATTENTION: .env.production n'existe pas!" -ForegroundColor Yellow
    Write-Host "  Creation d'un fichier .env.production exemple..." -ForegroundColor Yellow
    
    $envContent = @"
APP_ENV=prod
APP_DEBUG=false
APP_SECRET=changez_moi_par_une_cle_secrete_aleatoire

DATABASE_URL="mysql://user:password@127.0.0.1:3306/bibliotheque?serverVersion=8.0&charset=utf8mb4"
"@
    Set-Content -Path ".env.production" -Value $envContent
    Write-Host "  Fichier .env.production cree. MODIFIEZ-LE avec vos parametres!" -ForegroundColor Yellow
}

# Vérifier que les dossiers nécessaires existent
$folders = @("public/uploads/images", "var/cache", "var/log")
foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "  Dossier cree: $folder" -ForegroundColor Gray
    }
}

Write-Host "  OK" -ForegroundColor Green

Write-Host "`n[5/5] Creation de la liste des fichiers a uploader..." -ForegroundColor Yellow

# Créer un fichier avec la liste des fichiers à uploader
$filesToUpload = @"
FICHIERS A UPLOADER:
===================

Dossiers:
- config/
- public/
- src/
- templates/
- migrations/
- var/ (vide, mais le dossier doit exister)

Fichiers:
- composer.json
- composer.lock
- .env.production (renommez-le en .env sur le serveur)

FICHIERS A NE PAS UPLOADER:
===========================
- vendor/ (sera installe sur le serveur avec: composer install --no-dev)
- var/cache/ (sera recree automatiquement)
- var/log/ (sera recree automatiquement)
- .env.local
- .git/
- node_modules/
- tests/

COMMANDES A EXECUTER SUR LE SERVEUR:
====================================
1. composer install --no-dev --optimize-autoloader
2. php bin/console doctrine:migrations:migrate --env=prod --no-interaction
3. php bin/console cache:clear --env=prod
4. php bin/console cache:warmup --env=prod
5. chmod -R 777 var public/uploads
"@

Set-Content -Path "DEPLOY_INSTRUCTIONS.txt" -Value $filesToUpload
Write-Host "  Fichier DEPLOY_INSTRUCTIONS.txt cree" -ForegroundColor Green

Write-Host "`n=== PREPARATION TERMINEE ===" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines etapes:" -ForegroundColor Cyan
Write-Host "1. Modifiez .env.production avec vos parametres de production" -ForegroundColor White
Write-Host "2. Consultez DEPLOY_INSTRUCTIONS.txt pour la liste des fichiers" -ForegroundColor White
Write-Host "3. Consultez DEPLOY.md pour les instructions de deploiement" -ForegroundColor White
Write-Host "4. Consultez GUIDE_HEBERGEMENT.md pour choisir votre hebergeur" -ForegroundColor White
Write-Host ""

