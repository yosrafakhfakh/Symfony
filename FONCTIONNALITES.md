# Fonctionnalités du Projet Bibliothèque

## Partie Administration (EasyAdmin)

### Accès
- URL : `/admin`
- Rôle requis : `ROLE_ADMIN`
- Interface : EasyAdmin avec menu de navigation

### Entités gérées

#### 1. Livres (Book)
- **Champs** :
  - Titre
  - ISBN (unique)
  - Quantité en stock
  - Prix
  - Date de publication
  - Image (upload)
- **Relations** :
  - Auteur (ManyToOne)
  - Catégorie (ManyToOne)
  - Éditeur (ManyToOne)

#### 2. Auteurs (Author)
- **Champs** :
  - Nom
  - Prénom
- **Relations** :
  - Livres (OneToMany)

#### 3. Catégories (Category)
- **Champs** :
  - Désignation
- **Relations** :
  - Livres (OneToMany)

#### 4. Éditeurs (Publisher)
- **Champs** :
  - Nom
  - Pays
  - Adresse
  - Téléphone
- **Relations** :
  - Livres (OneToMany)

#### 5. Commandes (Order)
- **Champs** :
  - Utilisateur (relation)
  - Montant total
  - Statut (pending, paid, shipped, delivered)
  - Date de commande
  - Date de modification
  - Notes internes
- **Relations** :
  - Items de commande (OneToMany)

#### 6. Utilisateurs (User)
- **Champs** :
  - Email (unique)
  - Mot de passe (hashé)
  - Rôles (array)
  - Nom
  - Prénom
  - Statut actif
  - Date de création
- **Fonctionnalités** :
  - Hashage automatique du mot de passe
  - Gestion des rôles
  - Activation/désactivation

#### 7. Personnel (Staff)
- **Champs** :
  - Nom
  - Prénom
  - Grade

#### 8. Messages (MessengerMessage)
- **Champs** :
  - Contenu
  - Expéditeur
  - Destinataire
  - Date d'envoi

## Partie Utilisateur

### Accès public
- Catalogue de livres
- Recherche et filtres
- Inscription/Connexion

### Accès utilisateur connecté (ROLE_USER)
- Ajout au panier
- Gestion du panier
- Passage de commande
- Paiement
- Suivi des commandes
- Historique des achats

### Pages disponibles

#### 1. Accueil / Catalogue (`/`)
- Affichage de tous les livres
- **Filtres disponibles** :
  - Recherche textuelle (titre, ISBN, auteur)
  - Filtre par catégorie
  - Filtre par auteur
  - Prix maximum
  - Date de publication (à partir de)
- **Actions** :
  - Ajouter au panier (si connecté)
  - Voir les détails

#### 2. Panier (`/cart`)
- Affichage des articles
- Modification des quantités
- Suppression d'articles
- Calcul automatique du total
- Lien vers le checkout

#### 3. Checkout (`/order/checkout`)
- Récapitulatif de la commande
- Informations client
- Confirmation de commande

#### 4. Succès de commande (`/order/success/{id}`)
- Confirmation de la commande
- Option de paiement
- Lien vers les détails

#### 5. Historique (`/order/history`)
- Liste de toutes les commandes
- Statut de chaque commande
- Lien vers les détails

#### 6. Détails de commande (`/order/{id}`)
- Détails complets
- Liste des articles
- Statut et dates
- Option de paiement (si pending)

### Authentification

#### Inscription (`/register`)
- Formulaire d'inscription
- Validation des données
- Création automatique du compte avec `ROLE_USER`

#### Connexion (`/login`)
- Formulaire de connexion
- Gestion des erreurs
- Redirection après connexion

#### Déconnexion (`/logout`)
- Déconnexion sécurisée

## Sécurité

### Rôles
- `ROLE_USER` : Utilisateur standard
- `ROLE_ADMIN` : Administrateur

### Protection des routes
- `/admin/*` : Requiert `ROLE_ADMIN`
- `/order/*`, `/cart/*` : Requiert `ROLE_USER`
- Routes publiques : Catalogue, login, register

### Hashage des mots de passe
- Utilisation de `UserPasswordHasherInterface`
- Algorithme automatique (bcrypt/argon2)

## Fonctionnalités techniques

### Panier
- Stockage en session
- Validation des quantités disponibles
- Mise à jour en temps réel

### Commandes
- Création automatique des OrderItems
- Calcul automatique du total
- Mise à jour du stock
- Gestion des statuts

### Paiement
- Simulation de paiement
- Mise à jour du statut à "paid"
- Prêt pour intégration avec un vrai service (Stripe, PayPal, etc.)

### Images
- Upload dans `public/uploads/images/`
- Support des formats standards
- Génération de noms uniques

## Commandes console utiles

```bash
# Créer un admin
php bin/console app:create-admin

# Créer la base de données
php bin/console doctrine:database:create

# Migrations
php bin/console doctrine:migrations:migrate

# Vider le cache
php bin/console cache:clear
```

