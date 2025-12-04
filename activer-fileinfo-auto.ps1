# Script automatique pour activer l'extension fileinfo
Write-Host "`n=== ACTIVATION AUTOMATIQUE DE FILEINFO ===" -ForegroundColor Cyan
Write-Host ""

# Fonction pour modifier un fichier php.ini
function Modifier-PhpIni {
    param($chemin)
    
    if (-not (Test-Path $chemin)) {
        return $false
    }
    
    Write-Host "Traitement de: $chemin" -ForegroundColor Yellow
    
    try {
        # Creer une sauvegarde
        $backup = "$chemin.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $chemin $backup -ErrorAction Stop
        Write-Host "  Sauvegarde creee" -ForegroundColor Gray
        
        # Lire le contenu
        $lignes = Get-Content $chemin
        $modifie = $false
        $nouvellesLignes = @()
        
        foreach ($ligne in $lignes) {
            # Si on trouve la ligne commentee, la decommenter
            if ($ligne -match "^\s*;extension=fileinfo\s*$") {
                $nouvelleLigne = $ligne -replace "^\s*;", ""
                $nouvellesLignes += $nouvelleLigne
                $modifie = $true
                Write-Host "  -> Decommente" -ForegroundColor Green
            }
            # Si deja activee, on laisse
            elseif ($ligne -match "^\s*extension=fileinfo\s*$") {
                $nouvellesLignes += $ligne
                Write-Host "  -> Deja activee" -ForegroundColor Blue
                $modifie = $true
            }
            else {
                $nouvellesLignes += $ligne
            }
        }
        
        # Si pas trouvee, chercher la section extensions et ajouter
        if (-not $modifie) {
            Write-Host "  Extension non trouvee, ajout..." -ForegroundColor Yellow
            $nouvellesLignes = @()
            $inseree = $false
            $dansSectionExtensions = $false
            
            foreach ($ligne in $lignes) {
                $nouvellesLignes += $ligne
                
                # Detector la section Windows Extensions
                if ($ligne -match "Windows Extensions" -or $ligne -match "\[.*Extensions\]") {
                    $dansSectionExtensions = $true
                }
                
                # Apres quelques lignes d'extensions, inserer fileinfo
                if ($dansSectionExtensions -and $ligne -match "^\s*;extension=" -and -not $inseree) {
                    $nouvellesLignes += "extension=fileinfo"
                    $inseree = $true
                    $modifie = $true
                    Write-Host "  -> Ajoutee dans la section extensions" -ForegroundColor Green
                }
            }
            
            # Si toujours pas inseree, ajouter a la fin
            if (-not $inseree) {
                $nouvellesLignes += ""
                $nouvellesLignes += "; Fileinfo extension"
                $nouvellesLignes += "extension=fileinfo"
                $modifie = $true
                Write-Host "  -> Ajoutee a la fin du fichier" -ForegroundColor Green
            }
        }
        
        if ($modifie) {
            # Ecrire le nouveau contenu
            $nouvellesLignes | Set-Content $chemin -Encoding UTF8 -ErrorAction Stop
            Write-Host "  Fichier modifie avec succes!" -ForegroundColor Green
            return $true
        }
        
        return $false
    }
    catch {
        Write-Host "  Erreur: $_" -ForegroundColor Red
        return $false
    }
}

# Chercher tous les fichiers php.ini possibles
$fichiersIni = @()

# 1. Via php CLI
try {
    $output = php -r "echo php_ini_loaded_file();" 2>&1
    if ($output -and $output -ne "" -and (Test-Path $output)) {
        $fichiersIni += $output
    }
}
catch {
    # Ignorer les erreurs
}

# 2. Emplacements WAMP courants
$wampPaths = @(
    "C:\wamp64\bin\php\php8.3\php.ini",
    "C:\wamp64\bin\php\php8.2\php.ini",
    "C:\wamp64\bin\php\php8.1\php.ini",
    "C:\wamp64\bin\php\php8.0\php.ini",
    "C:\wamp\bin\php\php8.3\php.ini",
    "C:\wamp\bin\php\php8.2\php.ini"
)

foreach ($path in $wampPaths) {
    if (Test-Path $path) {
        $fichiersIni += $path
    }
}

# 3. Emplacements XAMPP
$xamppPaths = @(
    "C:\xampp\php\php.ini",
    "C:\xampp\apache\bin\php.ini"
)

foreach ($path in $xamppPaths) {
    if (Test-Path $path) {
        $fichiersIni += $path
    }
}

# 4. Chercher dans les dossiers PHP de Scoop
$userProfile = $env:USERPROFILE
$scoopPaths = @(
    "$userProfile\scoop\apps\php\current\php.ini",
    "$userProfile\scoop\apps\php\current\cli\php.ini"
)

foreach ($path in $scoopPaths) {
    if (Test-Path $path) {
        $fichiersIni += $path
    }
}

# Eliminer les doublons
$fichiersIni = $fichiersIni | Select-Object -Unique

Write-Host "Fichiers php.ini trouves:" -ForegroundColor Cyan
foreach ($fichier in $fichiersIni) {
    Write-Host "  - $fichier" -ForegroundColor White
}

if ($fichiersIni.Count -eq 0) {
    Write-Host ""
    Write-Host "Aucun fichier php.ini trouve automatiquement." -ForegroundColor Red
    Write-Host ""
    Write-Host "Veuillez:" -ForegroundColor Yellow
    Write-Host "1. Ouvrir http://localhost:8000/test_phpinfo.php" -ForegroundColor White
    Write-Host "2. Trouver le chemin du fichier php.ini" -ForegroundColor White
    Write-Host "3. Modifier manuellement le fichier" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Modification des fichiers..." -ForegroundColor Cyan
Write-Host ""

$modifications = 0
foreach ($fichier in $fichiersIni) {
    if (Modifier-PhpIni -chemin $fichier) {
        $modifications++
    }
    Write-Host ""
}

if ($modifications -gt 0) {
    Write-Host "=== MODIFICATIONS TERMINEES ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "$modifications fichier(s) modifie(s)" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Redemarrez votre serveur web maintenant!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pour WAMP:" -ForegroundColor Cyan
    Write-Host "  - Clic droit sur l'icone WAMP -> Redemarrer tous les services" -ForegroundColor White
    Write-Host ""
    Write-Host "Pour XAMPP:" -ForegroundColor Cyan
    Write-Host "  - Panneau de controle -> Arreter puis Demarrer Apache" -ForegroundColor White
    Write-Host ""
    Write-Host "Pour le serveur PHP integre:" -ForegroundColor Cyan
    Write-Host "  - Arretez (Ctrl+C) et relancez: php -S localhost:8000 -t public" -ForegroundColor White
    Write-Host ""
    Write-Host "Apres le redemarrage, testez l'upload d'image dans EasyAdmin." -ForegroundColor Cyan
}
else {
    Write-Host "Aucune modification effectuee." -ForegroundColor Yellow
    Write-Host "L'extension fileinfo est peut-etre deja activee ou les fichiers sont proteges." -ForegroundColor Yellow
}

Write-Host ""
