# Guide de Gestion de la Base de Données

## Situation Actuelle

Votre projet utilise **SQLite** (fichier : `var/data.db`)

⚠️ **Important** : phpMyAdmin ne fonctionne **PAS** avec SQLite. phpMyAdmin est uniquement pour MySQL/MariaDB.

## Options pour Visualiser/Gérer SQLite

### Option 1 : Utiliser DB Browser for SQLite (Recommandé - Gratuit)

1. **Télécharger** : https://sqlitebrowser.org/
2. **Installer** l'application
3. **Ouvrir** votre fichier : `C:\Users\yosra\OneDrive\Bureau\symfony_biblio\var\data.db`
4. Vous pourrez voir toutes les tables, données, et exécuter des requêtes SQL

### Option 2 : Utiliser une Extension VS Code

1. Installer l'extension **SQLite Viewer** ou **SQLite** dans VS Code
2. Ouvrir le fichier `var/data.db` dans VS Code
3. Visualiser les données directement dans l'éditeur

### Option 3 : Utiliser SQLiteStudio (Gratuit)

1. **Télécharger** : https://sqlitestudio.pl/
2. **Installer** l'application
3. **Ouvrir** votre fichier de base de données

### Option 4 : Utiliser la ligne de commande SQLite

```powershell
# Installer SQLite (si pas déjà installé)
# Puis dans PowerShell :
sqlite3 var/data.db

# Commandes utiles :
.tables          # Voir toutes les tables
.schema user      # Voir la structure de la table user
SELECT * FROM user;  # Voir tous les utilisateurs
.quit            # Quitter
```

## Option 5 : Passer à MySQL (pour utiliser phpMyAdmin)

Si vous voulez absolument utiliser phpMyAdmin, vous devez passer à MySQL :

### Étapes pour passer à MySQL :

1. **Modifier le fichier `.env`** :
   ```env
   DATABASE_URL="mysql://root:@127.0.0.1:3306/bibliotheque?serverVersion=8.0&charset=utf8mb4"
   ```
   (Remplacez `root` et le mot de passe par vos identifiants MySQL)

2. **Créer la base de données dans MySQL** :
   ```powershell
   php bin/console doctrine:database:create
   ```

3. **Exécuter les migrations** :
   ```powershell
   php bin/console doctrine:migrations:migrate
   ```

4. **Accéder à phpMyAdmin** :
   - Ouvrir WAMP
   - Aller sur http://localhost/phpmyadmin
   - Sélectionner la base `bibliotheque`

## Comparaison SQLite vs MySQL

| Caractéristique | SQLite | MySQL |
|----------------|--------|-------|
| Type | Fichier | Serveur |
| phpMyAdmin | ❌ Non | ✅ Oui |
| Installation | ✅ Inclus | ⚠️ Nécessite WAMP |
| Performance | ✅ Rapide | ✅ Rapide |
| Simplicité | ✅ Très simple | ⚠️ Plus complexe |

## Recommandation

Pour un projet de développement, **SQLite est parfait** car :
- Pas besoin de serveur
- Fichier unique facile à sauvegarder
- Fonctionne partout

Utilisez **DB Browser for SQLite** pour visualiser vos données - c'est l'équivalent de phpMyAdmin pour SQLite.

