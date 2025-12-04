# Guide de déploiement rapide

## Préparation avant déploiement

### 1. Optimiser l'application

```bash
# Installer les dépendances de production
composer install --no-dev --optimize-autoloader

# Vider le cache
php bin/console cache:clear --env=prod

# Réchauffer le cache
php bin/console cache:warmup --env=prod

# Créer un utilisateur admin
php bin/console app:create-admin
```

### 2. Créer le fichier .env.production

```env
APP_ENV=prod
APP_DEBUG=false
APP_SECRET=changez_moi_par_une_cle_secrete_aleatoire

DATABASE_URL="mysql://user:password@localhost:3306/bibliotheque?serverVersion=8.0&charset=utf8mb4"
```

### 3. Fichiers à uploader

**À uploader :**
- `config/`
- `public/`
- `src/`
- `templates/`
- `migrations/`
- `composer.json`
- `composer.lock`
- `.env.production` (renommé en `.env`)

**À NE PAS uploader :**
- `vendor/` (sera installé sur le serveur)
- `var/cache/`
- `var/log/`
- `.env.local`
- `.git/`

---

## Déploiement sur hébergement partagé (OVH, Hostinger, etc.)

### Étape 1 : Préparer les fichiers

```bash
# Créer un dossier de déploiement
mkdir deploy
cd deploy

# Copier les fichiers nécessaires
cp -r ../config .
cp -r ../public .
cp -r ../src .
cp -r ../templates .
cp -r ../migrations .
cp ../composer.json .
cp ../composer.lock .
cp ../.env.production .env
```

### Étape 2 : Uploader via FTP

Utilisez FileZilla ou un autre client FTP :
- Hôte : ftp.votre-domaine.com
- Utilisateur : votre_utilisateur
- Mot de passe : votre_mot_de_passe

### Étape 3 : Sur le serveur

```bash
# Installer les dépendances
composer install --no-dev --optimize-autoloader

# Créer les dossiers nécessaires
mkdir -p var/cache var/log public/uploads/images
chmod -R 777 var public/uploads

# Exécuter les migrations
php bin/console doctrine:migrations:migrate --env=prod --no-interaction

# Vider et réchauffer le cache
php bin/console cache:clear --env=prod
php bin/console cache:warmup --env=prod
```

### Étape 4 : Configurer le serveur web

**Pour Apache (.htaccess dans public/) :**
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ index.php [QSA,L]
</IfModule>
```

**Point d'entrée :** `public/index.php`
**Document root :** `public/`

---

## Déploiement sur Heroku (Gratuit)

### Étape 1 : Installer Heroku CLI

Téléchargez depuis : https://devcenter.heroku.com/articles/heroku-cli

### Étape 2 : Créer l'application

```bash
# Se connecter
heroku login

# Créer l'application
heroku create votre-app-biblio

# Ajouter le buildpack PHP
heroku buildpacks:set heroku/php
```

### Étape 3 : Configurer les variables d'environnement

```bash
heroku config:set APP_ENV=prod
heroku config:set APP_DEBUG=false
heroku config:set APP_SECRET=$(php -r "echo bin2hex(random_bytes(32));")
heroku config:set DATABASE_URL="mysql://user:pass@host:3306/dbname"
```

### Étape 4 : Ajouter la base de données

```bash
# Ajouter ClearDB MySQL (gratuit)
heroku addons:create cleardb:ignite
```

### Étape 5 : Créer Procfile

Créez un fichier `Procfile` à la racine :
```
web: heroku-php-apache2 public/
```

### Étape 6 : Déployer

```bash
git init
git add .
git commit -m "Initial commit"
git push heroku main
```

### Étape 7 : Exécuter les migrations

```bash
heroku run php bin/console doctrine:migrations:migrate --no-interaction
```

---

## Déploiement sur VPS (Ubuntu/Debian)

### Étape 1 : Installer les dépendances

```bash
sudo apt update
sudo apt install -y php8.2-fpm php8.2-cli php8.2-mysql php8.2-xml \
    php8.2-mbstring php8.2-curl php8.2-zip php8.2-gd \
    composer nginx mysql-server git
```

### Étape 2 : Cloner le projet

```bash
cd /var/www
sudo git clone https://github.com/votre-repo/symfony_biblio.git
cd symfony_biblio
sudo composer install --no-dev --optimize-autoloader
```

### Étape 3 : Configurer les permissions

```bash
sudo chown -R www-data:www-data /var/www/symfony_biblio
sudo chmod -R 755 /var/www/symfony_biblio
sudo chmod -R 777 /var/www/symfony_biblio/var
sudo chmod -R 777 /var/www/symfony_biblio/public/uploads
```

### Étape 4 : Configurer Nginx

Créez `/etc/nginx/sites-available/symfony_biblio` :

```nginx
server {
    listen 80;
    server_name votre-domaine.com;
    root /var/www/symfony_biblio/public;

    location / {
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        internal;
    }

    location ~ \.php$ {
        return 404;
    }

    error_log /var/log/nginx/symfony_biblio_error.log;
    access_log /var/log/nginx/symfony_biblio_access.log;
}
```

Activer le site :
```bash
sudo ln -s /etc/nginx/sites-available/symfony_biblio /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Étape 5 : Configurer MySQL

```bash
sudo mysql -u root -p
```

```sql
CREATE DATABASE bibliotheque CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'biblio_user'@'localhost' IDENTIFIED BY 'mot_de_passe_securise';
GRANT ALL PRIVILEGES ON bibliotheque.* TO 'biblio_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Étape 6 : Configurer l'application

```bash
cd /var/www/symfony_biblio
cp .env.production .env
# Éditer .env avec vos paramètres
nano .env
```

### Étape 7 : Exécuter les migrations

```bash
php bin/console doctrine:migrations:migrate --env=prod --no-interaction
php bin/console cache:clear --env=prod
php bin/console cache:warmup --env=prod
```

### Étape 8 : SSL avec Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d votre-domaine.com
```

---

## Script de déploiement automatique

Créez `deploy.sh` :

```bash
#!/bin/bash

echo "🚀 Déploiement de l'application..."

# Installer les dépendances
composer install --no-dev --optimize-autoloader

# Vider le cache
php bin/console cache:clear --env=prod

# Réchauffer le cache
php bin/console cache:warmup --env=prod

# Exécuter les migrations
php bin/console doctrine:migrations:migrate --env=prod --no-interaction

# Créer les dossiers nécessaires
mkdir -p var/cache var/log public/uploads/images
chmod -R 777 var public/uploads

echo "✅ Déploiement terminé!"
```

Rendre exécutable :
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## Vérification post-déploiement

1. ✅ L'application est accessible
2. ✅ Les images s'uploadent correctement
3. ✅ La base de données fonctionne
4. ✅ Les migrations sont à jour
5. ✅ Le cache est optimisé
6. ✅ Les logs fonctionnent
7. ✅ SSL est configuré (si nécessaire)

---

## Support

En cas de problème, vérifiez :
- Les logs : `var/log/prod.log`
- Les permissions des fichiers
- La configuration de la base de données
- Les variables d'environnement

