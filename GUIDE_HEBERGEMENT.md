# Guide d'hébergement de l'application Symfony

## Options d'hébergement

### 1. Hébergement partagé (Recommandé pour débuter)

#### Avantages
- Prix abordable (5-15€/mois)
- Facile à configurer
- Support inclus

#### Inconvénients
- Performances limitées
- Moins de contrôle
- Peut nécessiter des ajustements

#### Hébergeurs recommandés
- **OVH** : https://www.ovh.com
- **Hostinger** : https://www.hostinger.fr
- **IONOS** : https://www.ionos.fr
- **Infomaniak** : https://www.infomaniak.com

#### Étapes pour hébergement partagé

1. **Préparer l'application pour la production**
   ```bash
   # Installer les dépendances sans dev
   composer install --no-dev --optimize-autoloader
   
   # Vider le cache
   php bin/console cache:clear --env=prod
   
   # Optimiser le cache
   php bin/console cache:warmup --env=prod
   ```

2. **Configurer l'environnement**
   - Créer un fichier `.env.production` avec vos variables d'environnement
   - Configurer `APP_ENV=prod` et `APP_DEBUG=false`

3. **Uploader les fichiers**
   - Utiliser FTP/SFTP pour transférer les fichiers
   - **Ne pas** uploader : `vendor/`, `var/cache/`, `var/log/`
   - Uploader : `config/`, `public/`, `src/`, `templates/`, `migrations/`

4. **Configurer le serveur web**
   - Point d'entrée : `public/index.php`
   - Document root : `public/`
   - Activer mod_rewrite pour Apache

5. **Configurer la base de données**
   - Créer la base de données via le panneau d'hébergement
   - Mettre à jour `DATABASE_URL` dans `.env.production`
   - Exécuter les migrations : `php bin/console doctrine:migrations:migrate --env=prod`

---

### 2. VPS (Serveur Virtuel Privé)

#### Avantages
- Contrôle total
- Performances meilleures
- Scalable

#### Inconvénients
- Nécessite des compétences techniques
- Gestion serveur requise
- Prix plus élevé (10-50€/mois)

#### Hébergeurs VPS recommandés
- **DigitalOcean** : https://www.digitalocean.com
- **Hetzner** : https://www.hetzner.com
- **OVH VPS** : https://www.ovh.com
- **Scaleway** : https://www.scaleway.com

#### Étapes pour VPS

1. **Configurer le serveur**
   ```bash
   # Mettre à jour le système
   sudo apt update && sudo apt upgrade -y
   
   # Installer PHP, Composer, MySQL, Nginx
   sudo apt install php8.2-fpm php8.2-cli php8.2-mysql php8.2-xml php8.2-mbstring php8.2-curl php8.2-zip composer mysql-server nginx git -y
   ```

2. **Cloner le projet**
   ```bash
   cd /var/www
   git clone https://github.com/votre-repo/symfony_biblio.git
   cd symfony_biblio
   composer install --no-dev --optimize-autoloader
   ```

3. **Configurer les permissions**
   ```bash
   sudo chown -R www-data:www-data /var/www/symfony_biblio
   sudo chmod -R 755 /var/www/symfony_biblio
   sudo chmod -R 777 /var/www/symfony_biblio/var
   ```

4. **Configurer Nginx**
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
       }
       
       location ~ \.php$ {
           return 404;
       }
   }
   ```

5. **Configurer SSL (Let's Encrypt)**
   ```bash
   sudo apt install certbot python3-certbot-nginx -y
   sudo certbot --nginx -d votre-domaine.com
   ```

---

### 3. Platform as a Service (PaaS) - Le plus simple

#### Avantages
- Configuration automatique
- Scalabilité automatique
- Gestion simplifiée

#### Inconvénients
- Prix plus élevé
- Moins de contrôle

#### Plateformes recommandées

##### Heroku (Gratuit pour débuter)
1. Installer Heroku CLI : https://devcenter.heroku.com/articles/heroku-cli
2. Créer un compte : https://www.heroku.com
3. Déployer :
   ```bash
   heroku login
   heroku create votre-app
   heroku config:set APP_ENV=prod
   heroku config:set DATABASE_URL="mysql://..."
   git push heroku main
   ```

##### Platform.sh
- Site : https://platform.sh
- Support Symfony natif
- Configuration via `.platform.app.yaml`

##### SymfonyCloud
- Site : https://symfony.com/cloud
- Optimisé pour Symfony
- Déploiement en un clic

---

### 4. Docker (Pour tous les environnements)

#### Créer un Dockerfile

```dockerfile
FROM php:8.2-fpm

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail
WORKDIR /var/www

# Copier les fichiers
COPY . .

# Installer les dépendances
RUN composer install --no-dev --optimize-autoloader

# Configurer les permissions
RUN chown -R www-data:www-data /var/www

EXPOSE 9000
CMD ["php-fpm"]
```

#### docker-compose.yml

```yaml
version: '3.8'

services:
  php:
    build: .
    volumes:
      - .:/var/www
    networks:
      - symfony

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - .:/var/www
      - ./docker/nginx.conf:/etc/nginx/conf.d/default.conf
    networks:
      - symfony

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: bibliotheque
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - symfony

volumes:
  mysql_data:

networks:
  symfony:
```

---

## Checklist avant déploiement

### Sécurité
- [ ] `APP_ENV=prod` et `APP_DEBUG=false`
- [ ] `APP_SECRET` généré et unique
- [ ] Mots de passe de base de données sécurisés
- [ ] Permissions de fichiers correctes (755 pour dossiers, 644 pour fichiers)
- [ ] `.env` non commité dans Git

### Performance
- [ ] Cache optimisé : `php bin/console cache:warmup --env=prod`
- [ ] Autoloader optimisé : `composer dump-autoload --optimize --classmap-authoritative`
- [ ] Opcache activé dans PHP
- [ ] Images optimisées

### Base de données
- [ ] Migrations exécutées : `php bin/console doctrine:migrations:migrate --env=prod`
- [ ] Backup de la base de données configuré
- [ ] Indexes créés si nécessaire

### Fichiers
- [ ] Dossier `public/uploads/images/` créé et accessible en écriture
- [ ] Logs configurés : `var/log/prod.log`
- [ ] Cache configuré : `var/cache/prod/`

---

## Commandes utiles pour la production

```bash
# Installer les dépendances (sans dev)
composer install --no-dev --optimize-autoloader

# Vider et réchauffer le cache
php bin/console cache:clear --env=prod --no-debug
php bin/console cache:warmup --env=prod

# Exécuter les migrations
php bin/console doctrine:migrations:migrate --env=prod --no-interaction

# Créer un utilisateur admin
php bin/console app:create-admin --env=prod

# Vérifier la configuration
php bin/console debug:container --env=prod
```

---

## Configuration .env.production

```env
APP_ENV=prod
APP_DEBUG=false
APP_SECRET=votre_secret_aleatoire_ici

DATABASE_URL="mysql://user:password@127.0.0.1:3306/bibliotheque?serverVersion=8.0&charset=utf8mb4"

# Mailer (si nécessaire)
MAILER_DSN=smtp://user:pass@smtp.example.com:587
```

---

## Support et ressources

- Documentation Symfony : https://symfony.com/doc/current/deployment.html
- Guide OVH : https://docs.ovh.com/fr/hosting/
- Guide Heroku : https://devcenter.heroku.com/articles/getting-started-with-php

---

## Recommandation

Pour débuter, je recommande :
1. **Hébergement partagé** (OVH, Hostinger) si vous voulez quelque chose de simple
2. **Heroku** si vous voulez tester gratuitement
3. **VPS** si vous avez des compétences techniques et besoin de contrôle

