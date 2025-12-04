# Script pour passer de SQLite à MySQL
# Usage: .\passer-a-mysql.ps1

Write-Host "=== Passage de SQLite à MySQL ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Ce script va vous aider à configurer MySQL pour utiliser phpMyAdmin." -ForegroundColor Yellow
Write-Host ""

# Demander les informations MySQL
$mysqlUser = Read-Host "Nom d'utilisateur MySQL (généralement 'root')"
$mysqlPassword = Read-Host "Mot de passe MySQL" -AsSecureString
$mysqlPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mysqlPassword))
$mysqlDb = Read-Host "Nom de la base de données (ex: bibliotheque)"

Write-Host ""
Write-Host "Configuration de la base de données..." -ForegroundColor Green

# Lire le fichier .env
$envContent = Get-Content .env -Raw

# Remplacer DATABASE_URL
$newLine = "DATABASE_URL=`"mysql://${mysqlUser}:${mysqlPasswordPlain}@127.0.0.1:3306/${mysqlDb}?serverVersion=8.0&charset=utf8mb4`""
$envContent = $envContent -replace 'DATABASE_URL=".*"', $newLine

# Écrire le fichier
Set-Content .env -Value $envContent -NoNewline

Write-Host "✓ Fichier .env mis à jour" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Assurez-vous que WAMP est démarré et MySQL est actif" -ForegroundColor White
Write-Host "2. Créez la base de données dans phpMyAdmin (http://localhost/phpmyadmin)" -ForegroundColor White
Write-Host "   OU exécutez: php bin/console doctrine:database:create" -ForegroundColor White
Write-Host "3. Exécutez les migrations: php bin/console doctrine:migrations:migrate" -ForegroundColor White
Write-Host "4. Accédez à phpMyAdmin: http://localhost/phpmyadmin" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  Note: Vos données SQLite ne seront PAS migrées automatiquement!" -ForegroundColor Red
Write-Host "   Vous devrez recréer vos données dans MySQL." -ForegroundColor Red

