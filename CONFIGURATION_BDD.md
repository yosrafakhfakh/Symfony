# Configuration de la Base de Données

## Problème rencontré

Vous avez essayé d'exécuter `DATABASE_URL=...` directement dans PowerShell, mais cela ne fonctionne pas. La variable `DATABASE_URL` doit être configurée dans le fichier `.env`.

## Solution rapide : SQLite (Recommandé)

**SQLite est plus simple** car il ne nécessite pas de serveur MySQL installé et configuré.

### Étapes :

1. **Ouvrez le fichier `.env`** dans votre éditeur de texte

2. **Trouvez la ligne** qui commence par `DATABASE_URL=`

3. **Remplacez-la par** :
   ```env
   DATABASE_URL="sqlite:///%kernel.project_dir%/var/data.db"
   ```

4. **Assurez-vous que les autres lignes DATABASE_URL sont commentées** (avec `#` au début)

5. **Exécutez les commandes** :
   ```powershell
   php bin/console doctrine:database:create
   php bin/console doctrine:migrations:migrate
   ```

## Solution alternative : MySQL

Si vous préférez utiliser MySQL, vous devez :

1. **Avoir MySQL installé et démarré**

2. **Ouvrir le fichier `.env`**

3. **Modifier la ligne DATABASE_URL** avec vos VRAIS identifiants :
   ```env
   DATABASE_URL="mysql://VOTRE_USER:VOTRE_PASSWORD@127.0.0.1:3306/bibliotheque?serverVersion=8.0&charset=utf8mb4"
   ```
   
   Remplacez :
   - `VOTRE_USER` par votre nom d'utilisateur MySQL (souvent `root`)
   - `VOTRE_PASSWORD` par votre mot de passe MySQL
   - `bibliotheque` par le nom de la base de données souhaitée

4. **Exécutez les commandes** :
   ```powershell
   php bin/console doctrine:database:create
   php bin/console doctrine:migrations:migrate
   ```

## Utiliser le script automatique

Vous pouvez aussi utiliser le script PowerShell que j'ai créé :

```powershell
.\configure-database.ps1
```

Ce script vous guidera étape par étape.

## Exemple de fichier .env correct

### Pour SQLite :
```env
# DATABASE_URL="mysql://app:!ChangeMe!@127.0.0.1:3306/app?serverVersion=8.0.32&charset=utf8mb4"
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data.db"
```

### Pour MySQL :
```env
DATABASE_URL="mysql://root:monMotDePasse@127.0.0.1:3306/bibliotheque?serverVersion=8.0&charset=utf8mb4"
# DATABASE_URL="sqlite:///%kernel.project_dir%/var/data.db"
```

## Vérification

Après avoir configuré la base de données, testez la connexion :

```powershell
php bin/console doctrine:database:create
```

Si vous voyez un message de succès, la configuration est correcte !

