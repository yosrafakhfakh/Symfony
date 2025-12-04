# Script pour trouver le php.ini utilise par le serveur web
Write-Host "`n=== TROUVER PHP.INI DU SERVEUR WEB ===" -ForegroundColor Cyan
Write-Host ""

# Verifier si le serveur tourne
$testUrl = "http://localhost:8000/test_phpinfo.php"
Write-Host "Tentative de recuperation du php.ini via phpinfo..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri $testUrl -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $content = $response.Content
    
    # Chercher "Loaded Configuration File"
    if ($content -match "Loaded Configuration File</td><td[^>]*>([^<]+)</td>") {
        $phpIniPath = $matches[1].Trim()
        Write-Host "Fichier php.ini trouve: $phpIniPath" -ForegroundColor Green
        Write-Host ""
        
        if (Test-Path $phpIniPath) {
            Write-Host "Le fichier existe!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Voulez-vous modifier ce fichier automatiquement? (O/N)" -ForegroundColor Yellow
            $reponse = Read-Host
            
            if ($reponse -eq "O" -or $reponse -eq "o") {
                # Modifier le fichier
                Write-Host ""
                Write-Host "Modification en cours..." -ForegroundColor Cyan
                
                # Sauvegarde
                $backup = "$phpIniPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                Copy-Item $phpIniPath $backup
                Write-Host "Sauvegarde creee: $backup" -ForegroundColor Gray
                
                # Lire et modifier
                $lignes = Get-Content $phpIniPath
                $nouvellesLignes = @()
                $modifie = $false
                
                foreach ($ligne in $lignes) {
                    if ($ligne -match "^\s*;extension=fileinfo\s*$") {
                        $nouvellesLignes += ($ligne -replace "^\s*;", "")
                        $modifie = $true
                        Write-Host "Extension fileinfo decommente!" -ForegroundColor Green
                    }
                    elseif ($ligne -match "^\s*extension=fileinfo\s*$") {
                        $nouvellesLignes += $ligne
                        $modifie = $true
                        Write-Host "Extension fileinfo deja activee!" -ForegroundColor Blue
                    }
                    else {
                        $nouvellesLignes += $ligne
                    }
                }
                
                if (-not $modifie) {
                    # Ajouter a la fin
                    $nouvellesLignes += ""
                    $nouvellesLignes += "; Fileinfo extension"
                    $nouvellesLignes += "extension=fileinfo"
                    $modifie = $true
                    Write-Host "Extension fileinfo ajoutee!" -ForegroundColor Green
                }
                
                if ($modifie) {
                    $nouvellesLignes | Set-Content $phpIniPath -Encoding UTF8
                    Write-Host ""
                    Write-Host "Fichier modifie avec succes!" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "IMPORTANT: Redemarrez votre serveur web maintenant!" -ForegroundColor Yellow
                }
            }
            else {
                Write-Host ""
                Write-Host "Modification manuelle:" -ForegroundColor Yellow
                Write-Host "1. Ouvrez: $phpIniPath" -ForegroundColor White
                Write-Host "2. Cherchez: ;extension=fileinfo" -ForegroundColor White
                Write-Host "3. Changez en: extension=fileinfo" -ForegroundColor White
                Write-Host "4. Redemarrez le serveur web" -ForegroundColor White
            }
        }
        else {
            Write-Host "Le fichier n'existe pas a cet emplacement." -ForegroundColor Red
        }
    }
    else {
        Write-Host "Impossible de trouver le chemin dans phpinfo." -ForegroundColor Red
        Write-Host ""
        Write-Host "Ouvrez manuellement: http://localhost:8000/test_phpinfo.php" -ForegroundColor Yellow
        Write-Host "Et cherchez 'Loaded Configuration File'" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Impossible de se connecter au serveur web." -ForegroundColor Red
    Write-Host "Assurez-vous que le serveur tourne sur http://localhost:8000" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ou ouvrez manuellement: http://localhost:8000/test_phpinfo.php" -ForegroundColor Yellow
}

Write-Host ""

