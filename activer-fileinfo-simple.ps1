# Script simple pour activer fileinfo
Write-Host "`n=== ACTIVATION DE L'EXTENSION FILEINFO ===" -ForegroundColor Cyan
Write-Host ""

# Trouver le fichier php.ini CLI
$phpIniCli = php -r "echo php_ini_loaded_file();" 2>&1
Write-Host "Fichier php.ini CLI: $phpIniCli" -ForegroundColor Yellow
Write-Host ""

# Verifier si fileinfo est deja active
$modules = php -m 2>&1 | Out-String
if ($modules -match "fileinfo") {
    Write-Host "Extension fileinfo est DEJA activee dans PHP CLI" -ForegroundColor Green
} else {
    Write-Host "Extension fileinfo n'est PAS activee dans PHP CLI" -ForegroundColor Red
}

Write-Host ""
Write-Host "IMPORTANT: Le serveur web peut utiliser un autre fichier php.ini!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Pour trouver le fichier php.ini utilise par le serveur web:" -ForegroundColor Cyan
Write-Host "  1. Ouvrez http://localhost:8000/test_phpinfo.php dans votre navigateur" -ForegroundColor White
Write-Host "  2. Cherchez 'Loaded Configuration File' dans la page" -ForegroundColor White
Write-Host "  3. Ouvrez ce fichier php.ini et cherchez: ;extension=fileinfo" -ForegroundColor White
Write-Host "  4. Changez-le en: extension=fileinfo" -ForegroundColor White
Write-Host "  5. Redemarrez Apache (WAMP/XAMPP)" -ForegroundColor White
Write-Host ""

# Creer le fichier de test
$testFile = "public/test_phpinfo.php"
if (-not (Test-Path $testFile)) {
    Set-Content -Path $testFile -Value "<?php phpinfo(); ?>"
    Write-Host "Fichier de test cree: $testFile" -ForegroundColor Green
} else {
    Write-Host "Fichier de test existe deja: $testFile" -ForegroundColor Blue
}

Write-Host ""
