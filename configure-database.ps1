# Script de configuration de la base de données
# Usage: .\configure-database.ps1

Write-Host "=== Configuration de la base de données ===" -ForegroundColor Cyan
Write-Host ""

# Option 1: SQLite (recommandé pour commencer)
Write-Host "Option 1: SQLite (simple, pas besoin de serveur MySQL)" -ForegroundColor Yellow
Write-Host "Option 2: MySQL (nécessite un serveur MySQL configuré)" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Choisissez une option (1 ou 2)"

if ($choice -eq "1") {
    # Configuration SQLite
    Write-Host ""
    Write-Host "Configuration SQLite..." -ForegroundColor Green
    
    # Lire le fichier .env
    $envContent = Get-Content .env -Raw
    
    # Remplacer la ligne DATABASE_URL
    $newLine = 'DATABASE_URL="sqlite:///%kernel.project_dir%/var/data.db"'
    $envContent = $envContent -replace 'DATABASE_URL=".*"', $newLine
    
    # Écrire le fichier
    Set-Content .env -Value $envContent -NoNewline
    
    Write-Host "✓ Configuration SQLite appliquée!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Prochaines étapes:" -ForegroundColor Cyan
    Write-Host "1. php bin/console doctrine:database:create"
    Write-Host "2. php bin/console doctrine:migrations:migrate"
    
} elseif ($choice -eq "2") {
    # Configuration MySQL
    Write-Host ""
    Write-Host "Configuration MySQL..." -ForegroundColor Green
    Write-Host "Vous aurez besoin de:" -ForegroundColor Yellow
    Write-Host "- Le nom d'utilisateur MySQL"
    Write-Host "- Le mot de passe MySQL"
    Write-Host "- Le nom de la base de données (sera créée si elle n'existe pas)"
    Write-Host ""
    
    $mysqlUser = Read-Host "Nom d'utilisateur MySQL (ex: root)"
    $mysqlPassword = Read-Host "Mot de passe MySQL" -AsSecureString
    $mysqlPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mysqlPassword))
    $mysqlDb = Read-Host "Nom de la base de données (ex: bibliotheque)"
    $mysqlHost = Read-Host "Hôte MySQL (appuyez sur Entrée pour utiliser 127.0.0.1)"
    if ([string]::IsNullOrWhiteSpace($mysqlHost)) {
        $mysqlHost = "127.0.0.1"
    }
    $mysqlPort = Read-Host "Port MySQL (appuyez sur Entrée pour utiliser 3306)"
    if ([string]::IsNullOrWhiteSpace($mysqlPort)) {
        $mysqlPort = "3306"
    }
    
    # Lire le fichier .env
    $envContent = Get-Content .env -Raw
    
    # Construire la nouvelle ligne DATABASE_URL
    $newLine = "DATABASE_URL=`"mysql://${mysqlUser}:${mysqlPasswordPlain}@${mysqlHost}:${mysqlPort}/${mysqlDb}?serverVersion=8.0&charset=utf8mb4`""
    $envContent = $envContent -replace 'DATABASE_URL=".*"', $newLine
    
    # Écrire le fichier
    Set-Content .env -Value $envContent -NoNewline
    
    Write-Host ""
    Write-Host "✓ Configuration MySQL appliquée!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Prochaines étapes:" -ForegroundColor Cyan
    Write-Host "1. Assurez-vous que MySQL est démarré"
    Write-Host "2. php bin/console doctrine:database:create"
    Write-Host "3. php bin/console doctrine:migrations:migrate"
    
} else {
    Write-Host "Option invalide!" -ForegroundColor Red
    exit 1
}

Write-Host ""

