# Script pour activer l'extension fileinfo dans PHP
Write-Host "`n=== ACTIVATION DE L'EXTENSION FILEINFO ===" -ForegroundColor Cyan
Write-Host ""

# Trouver le fichier php.ini
$phpIniOutput = php --ini 2>&1 | Out-String
$phpIniPath = $null

if ($phpIniOutput -match "Loaded Configuration File:\s*(.+)") {
    $phpIniPath = $matches[1].Trim()
}

if (-not $phpIniPath -or $phpIniPath -eq "(none)") {
    Write-Host "Impossible de trouver automatiquement le fichier php.ini" -ForegroundColor Red
    Write-Host ""
    Write-Host "Veuillez trouver manuellement le fichier php.ini dans:" -ForegroundColor Yellow
    Write-Host "  - C:\wamp64\bin\php\php8.x.x\php.ini" -ForegroundColor White
    Write-Host "  - C:\xampp\php\php.ini" -ForegroundColor White
    Write-Host ""
    Write-Host "Puis ouvrez-le et cherchez la ligne:" -ForegroundColor Yellow
    Write-Host "  ;extension=fileinfo" -ForegroundColor White
    Write-Host ""
    Write-Host "Et changez-la en:" -ForegroundColor Yellow
    Write-Host "  extension=fileinfo" -ForegroundColor White
    Write-Host ""
    Write-Host "Ensuite, redemarrez votre serveur web (Apache)" -ForegroundColor Yellow
    exit 1
}

Write-Host "Fichier php.ini trouve: $phpIniPath" -ForegroundColor Green
Write-Host ""

# Verifier si fileinfo est deja active
$phpIniContent = Get-Content $phpIniPath -Raw -ErrorAction SilentlyContinue
if (-not $phpIniContent) {
    Write-Host "Erreur: Impossible de lire le fichier php.ini" -ForegroundColor Red
    exit 1
}

# Creer une sauvegarde
$backupPath = "$phpIniPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
try {
    Copy-Item $phpIniPath $backupPath -ErrorAction Stop
    Write-Host "Sauvegarde creee: $backupPath" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Attention: Impossible de creer une sauvegarde" -ForegroundColor Yellow
    Write-Host ""
}

# Lire le contenu ligne par ligne
$lines = Get-Content $phpIniPath
$modified = $false
$newLines = @()

foreach ($line in $lines) {
    # Chercher la ligne commentee extension=fileinfo
    if ($line -match "^\s*;extension=fileinfo") {
        Write-Host "Ligne trouvee: $line" -ForegroundColor Yellow
        # Decommenter la ligne
        $newLine = $line -replace "^\s*;", ""
        $newLines += $newLine
        $modified = $true
        Write-Host "  -> Decommente: $newLine" -ForegroundColor Green
    }
    # Chercher extension=fileinfo deja activee
    elseif ($line -match "^\s*extension=fileinfo") {
        Write-Host "Extension fileinfo deja activee: $line" -ForegroundColor Green
        $newLines += $line
    }
    else {
        $newLines += $line
    }
}

# Si pas trouvee, ajouter a la fin de la section des extensions
if (-not $modified) {
    Write-Host "Ligne extension=fileinfo non trouvee, ajout a la section des extensions..." -ForegroundColor Yellow
    
    $foundExtensionSection = $false
    $newLines = @()
    $inserted = $false
    
    foreach ($line in $lines) {
        $newLines += $line
        
        # Chercher la section des extensions Windows
        if ($line -match "^\s*;.*Windows Extensions" -and -not $inserted) {
            $foundExtensionSection = $true
        }
        
        # Apres quelques lignes dans la section extensions, ajouter fileinfo
        if ($foundExtensionSection -and $line -match "^\s*;extension=" -and -not $inserted) {
            $newLines += "extension=fileinfo"
            $inserted = $true
            $modified = $true
            Write-Host "  -> Ajoutee: extension=fileinfo" -ForegroundColor Green
        }
    }
    
    # Si toujours pas inseree, ajouter a la fin
    if (-not $inserted) {
        $newLines += ""
        $newLines += "; Fileinfo extension"
        $newLines += "extension=fileinfo"
        $modified = $true
        Write-Host "  -> Ajoutee a la fin du fichier" -ForegroundColor Green
    }
}

if ($modified) {
    # Ecrire le nouveau contenu
    try {
        $newLines | Set-Content $phpIniPath -Encoding UTF8 -ErrorAction Stop
        Write-Host ""
        Write-Host "Fichier php.ini modifie avec succes!" -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANT: Vous devez redemarrer votre serveur web (Apache/Nginx)!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Pour WAMP:" -ForegroundColor Cyan
        Write-Host "  1. Cliquez sur l'icone WAMP dans la barre des taches" -ForegroundColor White
        Write-Host "  2. Cliquez sur 'Redemarrer tous les services'" -ForegroundColor White
        Write-Host ""
        Write-Host "Pour XAMPP:" -ForegroundColor Cyan
        Write-Host "  1. Ouvrez le panneau de controle XAMPP" -ForegroundColor White
        Write-Host "  2. Arretez puis redemarrez Apache" -ForegroundColor White
        Write-Host ""
        Write-Host "Apres le redemarrage, verifiez avec: php -m | Select-String fileinfo" -ForegroundColor Cyan
    } catch {
        Write-Host "Erreur lors de l'ecriture du fichier: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Veuillez modifier manuellement le fichier php.ini" -ForegroundColor Yellow
    }
} else {
    Write-Host "Aucune modification necessaire. L'extension fileinfo est peut-etre deja activee." -ForegroundColor Blue
    Write-Host ""
    Write-Host "Verifiez avec: php -m | Select-String fileinfo" -ForegroundColor Cyan
}

Write-Host ""
