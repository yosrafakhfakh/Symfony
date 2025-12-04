# Guide : Activer l'extension fileinfo dans PHP

## Problème
L'erreur `Unable to guess the MIME type as no guessers are available (have you enabled the php_fileinfo extension?)` indique que l'extension PHP `fileinfo` n'est pas activée.

## Solution

### Étape 1 : Trouver le fichier php.ini

**Méthode 1 : Via la ligne de commande**
```powershell
php --ini
```

**Méthode 2 : Emplacements courants**
- **WAMP** : `C:\wamp64\bin\php\php8.x.x\php.ini`
- **XAMPP** : `C:\xampp\php\php.ini`
- **PHP standalone** : Vérifiez le chemin affiché par `php --ini`

### Étape 2 : Modifier php.ini

1. Ouvrez le fichier `php.ini` avec un éditeur de texte (Notepad++, VS Code, etc.)
2. Recherchez la ligne suivante (utilisez Ctrl+F) :
   ```
   ;extension=fileinfo
   ```
3. Supprimez le point-virgule `;` au début pour décommenter la ligne :
   ```
   extension=fileinfo
   ```
4. Si la ligne n'existe pas, ajoutez-la dans la section des extensions Windows :
   ```
   ; Windows Extensions
   extension=fileinfo
   ```
5. Enregistrez le fichier

### Étape 3 : Redémarrer le serveur web

**Pour WAMP :**
1. Cliquez sur l'icône WAMP dans la barre des tâches
2. Cliquez sur "Redémarrer tous les services"

**Pour XAMPP :**
1. Ouvrez le panneau de contrôle XAMPP
2. Cliquez sur "Stop" pour Apache
3. Attendez quelques secondes
4. Cliquez sur "Start" pour Apache

**Pour un serveur PHP intégré (php -S) :**
- Arrêtez le serveur (Ctrl+C) et relancez-le

### Étape 4 : Vérifier l'activation

Exécutez cette commande pour vérifier que l'extension est bien chargée :
```powershell
php -m | Select-String fileinfo
```

Vous devriez voir `fileinfo` dans la liste.

### Alternative : Vérifier via phpinfo()

Créez un fichier `test_fileinfo.php` dans le dossier `public` :
```php
<?php
phpinfo();
```

Puis ouvrez `http://localhost:8000/test_fileinfo.php` dans votre navigateur et cherchez "fileinfo". Si vous voyez une section "fileinfo", l'extension est activée.

## Si le problème persiste

1. Vérifiez que vous modifiez le bon fichier `php.ini` (celui utilisé par votre serveur web, pas celui de la CLI)
2. Assurez-vous que le fichier `php_fileinfo.dll` existe dans le dossier `ext` de PHP
3. Vérifiez les permissions d'écriture sur le fichier `php.ini`
4. Redémarrez complètement votre ordinateur si nécessaire

## Note importante

Si vous utilisez WAMP/XAMPP, il peut y avoir deux fichiers `php.ini` :
- Un pour la ligne de commande (CLI)
- Un pour le serveur web (Apache)

Assurez-vous de modifier celui utilisé par Apache. Vous pouvez vérifier quel fichier est utilisé en créant un fichier `phpinfo.php` dans votre projet et en l'ouvrant dans le navigateur.

