# Projet Symfony - Bibliothèque

Application de gestion de bibliothèque avec partie administration (EasyAdmin) et partie utilisateur.

## Fonctionnalités

### Partie Administration (EasyAdmin)
- Gestion complète des entités via EasyAdmin
- Accès sécurisé avec le rôle `ROLE_ADMIN`
- CRUD pour :
  - **Livres** : titre, ISBN, quantité, prix, date de publication, image, relations avec auteur/catégorie/éditeur
  - **Auteurs** : nom, prénom
  - **Catégories** : désignation
  - **Éditeurs** : nom, pays, adresse, téléphone
  - **Commandes** : utilisateur, montant total, statut, dates, notes internes
  - **Utilisateurs** : email, rôles, mot de passe, nom, prénom, statut actif, date de création
  - **Personnel** : nom, prénom, grade
  - **Messages** : contenu, expéditeur, destinataire, date d'envoi

### Partie Utilisateur
- **Catalogue de livres** avec filtres et recherche
- **Panier** pour gérer les articles
- **Commandes** avec suivi du statut
- **Paiement** sécurisé (simulation)
- **Historique des commandes**

## Installation

### Prérequis
- PHP 8.2 ou supérieur
- Composer
- Base de données (MySQL, PostgreSQL, SQLite)

### Étapes d'installation

1. **Cloner le projet** (si nécessaire)
   ```bash
   git clone <repository-url>
   cd symfony_biblio
   ```

2. **Installer les dépendances**
   ```bash
   composer install
   ```

3. **Configurer la base de données**
   
   Modifiez le fichier `.env` et configurez votre `DATABASE_URL` :
   ```env
   DATABASE_URL="mysql://user:password@127.0.0.1:3306/bibliotheque?serverVersion=8.0"
   ```
   
   Ou pour SQLite :
   ```env
   DATABASE_URL="sqlite:///%kernel.project_dir%/var/data.db"
   ```

4. **Créer la base de données et exécuter les migrations**
   ```bash
   php bin/console doctrine:database:create
   php bin/console doctrine:migrations:migrate
   ```

5. **Créer un utilisateur administrateur**
   
   Vous pouvez créer un utilisateur admin via la console :
   ```bash
   php bin/console app:create-admin
   ```
   
   Ou manuellement via EasyAdmin après avoir créé un compte utilisateur normal et lui attribuer le rôle `ROLE_ADMIN`.

## Utilisation

### Démarrer le serveur de développement
```bash
symfony server:start
```
Ou avec PHP :
```bash
php -S localhost:8000 -t public
```

### Accès à l'application
- **Site utilisateur** : http://localhost:8000
- **Administration** : http://localhost:8000/admin

### Créer un utilisateur administrateur manuellement

1. Créez d'abord un compte utilisateur normal via l'interface d'inscription
2. Connectez-vous à la base de données
3. Mettez à jour l'utilisateur pour lui attribuer le rôle `ROLE_ADMIN` :
   ```sql
   UPDATE `user` SET roles = '["ROLE_ADMIN","ROLE_USER"]' WHERE email = 'admin@example.com';
   ```

### Commandes utiles

```bash
# Créer une migration
php bin/console make:migration

# Exécuter les migrations
php bin/console doctrine:migrations:migrate

# Vider le cache
php bin/console cache:clear

# Créer une entité
php bin/console make:entity
```

## Structure du projet

```
symfony_biblio/
├── config/          # Configuration Symfony
├── public/          # Point d'entrée web
├── src/
│   ├── Controller/
│   │   ├── Admin/   # Contrôleurs EasyAdmin
│   │   └── ...      # Contrôleurs utilisateur
│   ├── Entity/      # Entités Doctrine
│   └── Repository/  # Repositories
├── templates/       # Templates Twig
└── var/            # Fichiers temporaires
```

## Sécurité

- Les routes `/admin/*` sont protégées et nécessitent le rôle `ROLE_ADMIN`
- Les utilisateurs doivent être connectés pour accéder au panier et aux commandes
- Les mots de passe sont hashés avec l'algorithme configuré dans `security.yaml`

## Notes importantes

- Les images des livres sont stockées dans `public/uploads/images/`
- Le système de paiement est simulé (à intégrer avec un vrai service de paiement en production)
- Les statuts de commande possibles : `pending`, `paid`, `shipped`, `delivered`

## Développement

Pour contribuer au projet :
1. Créez une branche pour votre fonctionnalité
2. Faites vos modifications
3. Testez localement
4. Créez une pull request

## Licence

Ce projet est sous licence MIT.

