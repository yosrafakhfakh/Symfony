# Script complet pour activer fileinfo partout
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ACTIVATION COMPLETE DE FILEINFO" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Etape 1: Verifier PHP CLI
Write-Host "[1/3] Verification PHP CLI..." -ForegroundColor Yellow
$modules = php -m 2>&1 | Out-String
if ($modules -match "fileinfo") {
    Write-Host "  OK - Extension fileinfo activee dans PHP CLI" -ForegroundColor Green
} else {
    Write-Host "  ATTENTION - Extension fileinfo non activee dans PHP CLI" -ForegroundColor Red
    Write-Host "  Execution du script d'activation..." -ForegroundColor Yellow
    & .\activer-fileinfo-auto.ps1
}

Write-Host ""

# Etape 2: Trouver et modifier php.ini du serveur web
Write-Host "[2/3] Recherche du php.ini du serveur web..." -ForegroundColor Yellow

# Essayer de recuperer via phpinfo
$phpIniWeb = $null
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/test_phpinfo.php" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
    if ($response.Content -match 'Loaded Configuration File</td><td[^>]*>([^<]+)</td>') {
        $phpIniWeb = $matches[1].Trim()
    }
} catch {
    # Ignorer les erreurs
}

if ($phpIniWeb -and (Test-Path $phpIniWeb)) {
    Write-Host "  Fichier trouve: $phpIniWeb" -ForegroundColor Green
    
    # Verifier si deja active
    $content = Get-Content $phpIniWeb -Raw
    if ($content -match "^\s*extension=fileinfo\s*$" -or $content -match "extension=fileinfo") {
        Write-Host "  OK - Extension deja activee dans le serveur web" -ForegroundColor Green
    } else {
        Write-Host "  Modification necessaire..." -ForegroundColor Yellow
        
        # Sauvegarde
        $backup = "$phpIniWeb.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $phpIniWeb $backup -ErrorAction SilentlyContinue
        
        # Modifier
        $lignes = Get-Content $phpIniWeb
        $nouvellesLignes = @()
        $modifie = $false
        
        foreach ($ligne in $lignes) {
            if ($ligne -match "^\s*;extension=fileinfo\s*$") {
                $nouvellesLignes += ($ligne -replace "^\s*;", "")
                $modifie = $true
            } else {
                $nouvellesLignes += $ligne
            }
        }
        
        if (-not $modifie) {
            $nouvellesLignes += ""
            $nouvellesLignes += "; Fileinfo extension"
            $nouvellesLignes += "extension=fileinfo"
            $modifie = $true
        }
        
        if ($modifie) {
            try {
                $nouvellesLignes | Set-Content $phpIniWeb -Encoding UTF8
                Write-Host "  OK - Fichier modifie avec succes!" -ForegroundColor Green
            } catch {
                Write-Host "  ERREUR - Impossible de modifier (droits insuffisants?)" -ForegroundColor Red
                Write-Host "  Modifiez manuellement: $phpIniWeb" -ForegroundColor Yellow
            }
        }
    }
} else {
    Write-Host "  ATTENTION - Impossible de trouver automatiquement le php.ini du serveur web" -ForegroundColor Yellow
    Write-Host "  Ouvrez: http://localhost:8000/test_phpinfo.php" -ForegroundColor Cyan
    Write-Host "  Et cherchez 'Loaded Configuration File'" -ForegroundColor Cyan
}

Write-Host ""

# Etape 3: Instructions finales
Write-Host "[3/3] Instructions finales" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT: Redemarrez votre serveur web!" -ForegroundColor Red
Write-Host ""
Write-Host "Si vous utilisez le serveur PHP integre:" -ForegroundColor Cyan
Write-Host "  1. Arretez le serveur (Ctrl+C dans le terminal)" -ForegroundColor White
Write-Host "  2. Relancez: php -S localhost:8000 -t public" -ForegroundColor White
Write-Host ""
Write-Host "Si vous utilisez WAMP:" -ForegroundColor Cyan
Write-Host "  - Clic droit sur l'icone WAMP -> Redemarrer tous les services" -ForegroundColor White
Write-Host ""
Write-Host "Si vous utilisez XAMPP:" -ForegroundColor Cyan
Write-Host "  - Panneau de controle -> Arreter puis Demarrer Apache" -ForegroundColor White
Write-Host ""
Write-Host "Apres le redemarrage, testez l'upload d'image dans EasyAdmin!" -ForegroundColor Green
Write-Host ""

