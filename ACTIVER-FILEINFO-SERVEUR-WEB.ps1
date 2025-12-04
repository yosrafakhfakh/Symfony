# Script pour activer fileinfo dans le php.ini du serveur web
Write-Host "`n=== ACTIVATION FILEINFO DANS LE SERVEUR WEB ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Le fichier php.ini CLI est deja configure (extension=fileinfo activee)" -ForegroundColor Green
Write-Host "Mais le serveur web (Apache/WAMP) utilise probablement un autre php.ini!" -ForegroundColor Yellow
Write-Host ""

# Creer un script PHP pour trouver le php.ini du serveur web
$scriptPhp = @"
<?php
echo "Loaded Configuration File: " . php_ini_loaded_file() . "\n";
echo "Scan this dir for additional .ini files: " . php_ini_scanned_files() . "\n";
"@

$scriptPhp | Out-File -FilePath "public/find_phpini.php" -Encoding UTF8

Write-Host "Fichier de detection cree: public/find_phpini.php" -ForegroundColor Green
Write-Host ""
Write-Host "ETAPES SUIVANTES:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Assurez-vous que votre serveur web tourne" -ForegroundColor White
Write-Host "2. Ouvrez dans votre navigateur: http://localhost:8000/find_phpini.php" -ForegroundColor Cyan
Write-Host "   OU: http://localhost:8000/test_phpinfo.php" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Notez le chemin du fichier php.ini affiche (Loaded Configuration File)" -ForegroundColor White
Write-Host ""
Write-Host "4. Ouvrez ce fichier php.ini avec un editeur de texte" -ForegroundColor White
Write-Host ""
Write-Host "5. Cherchez la ligne: ;extension=fileinfo" -ForegroundColor White
Write-Host "   (Utilisez Ctrl+F pour rechercher)" -ForegroundColor Gray
Write-Host ""
Write-Host "6. Supprimez le point-virgule pour obtenir: extension=fileinfo" -ForegroundColor White
Write-Host ""
Write-Host "7. Si la ligne n'existe pas, ajoutez-la dans la section [Dynamic Extensions]:" -ForegroundColor White
Write-Host "   extension=fileinfo" -ForegroundColor Gray
Write-Host ""
Write-Host "8. Enregistrez le fichier" -ForegroundColor White
Write-Host ""
Write-Host "9. Redemarrez votre serveur web:" -ForegroundColor White
Write-Host "   - WAMP: Clic droit sur l'icone -> Redemarrer tous les services" -ForegroundColor Gray
Write-Host "   - XAMPP: Arreter puis Demarrer Apache" -ForegroundColor Gray
Write-Host "   - Serveur PHP integre: Arretez (Ctrl+C) et relancez" -ForegroundColor Gray
Write-Host ""
Write-Host "10. Testez l'upload d'image dans EasyAdmin" -ForegroundColor White
Write-Host ""

# Essayer de trouver automatiquement via phpinfo si le serveur tourne
Write-Host "Tentative de detection automatique..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/find_phpini.php" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
    if ($response.Content -match "Loaded Configuration File:\s*(.+)") {
        $phpIniWeb = $matches[1].Trim()
        Write-Host ""
        Write-Host "FICHIER PHP.INI DU SERVEUR WEB TROUVE:" -ForegroundColor Green
        Write-Host "  $phpIniWeb" -ForegroundColor Cyan
        Write-Host ""
        
        if (Test-Path $phpIniWeb) {
            Write-Host "Le fichier existe! Voulez-vous le modifier automatiquement? (O/N)" -ForegroundColor Yellow
            $reponse = Read-Host
            
            if ($reponse -eq "O" -or $reponse -eq "o") {
                # Sauvegarde
                $backup = "$phpIniWeb.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                Copy-Item $phpIniWeb $backup
                Write-Host "Sauvegarde creee: $backup" -ForegroundColor Gray
                
                # Lire et modifier
                $lignes = Get-Content $phpIniWeb
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
                    # Ajouter dans la section Dynamic Extensions
                    $nouvellesLignes = @()
                    $inseree = $false
                    foreach ($ligne in $lignes) {
                        $nouvellesLignes += $ligne
                        if ($ligne -match "Dynamic Extensions" -and -not $inseree) {
                            $nouvellesLignes += "extension=fileinfo"
                            $inseree = $true
                            $modifie = $true
                            Write-Host "Extension fileinfo ajoutee!" -ForegroundColor Green
                        }
                    }
                    
                    if (-not $inseree) {
                        $nouvellesLignes += ""
                        $nouvellesLignes += "; Fileinfo extension"
                        $nouvellesLignes += "extension=fileinfo"
                        $modifie = $true
                    }
                }
                
                if ($modifie) {
                    try {
                        $nouvellesLignes | Set-Content $phpIniWeb -Encoding UTF8
                        Write-Host ""
                        Write-Host "Fichier modifie avec succes!" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "IMPORTANT: Redemarrez votre serveur web maintenant!" -ForegroundColor Yellow
                    }
                    catch {
                        Write-Host ""
                        Write-Host "Erreur: Impossible d'ecrire le fichier (droits insuffisants?)" -ForegroundColor Red
                        Write-Host "Modifiez manuellement le fichier: $phpIniWeb" -ForegroundColor Yellow
                    }
                }
            }
        }
    }
}
catch {
    Write-Host "Le serveur web ne repond pas ou n'est pas accessible." -ForegroundColor Yellow
    Write-Host "Suivez les etapes manuelles ci-dessus." -ForegroundColor White
}

Write-Host ""

