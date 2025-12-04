<?php

namespace App\Controller\Admin;

use App\Entity\Author;
use App\Entity\Book;
use App\Entity\Category;
use App\Entity\MessengerMessage;
use App\Entity\Order;
use App\Entity\Publisher;
use App\Entity\Staff;
use App\Entity\User;
use App\Repository\AuthorRepository;
use App\Repository\BookRepository;
use App\Repository\CategoryRepository;
use App\Repository\OrderRepository;
use App\Repository\PublisherRepository;
use App\Repository\UserRepository;
use EasyCorp\Bundle\EasyAdminBundle\Attribute\AdminDashboard;
use EasyCorp\Bundle\EasyAdminBundle\Config\Dashboard;
use EasyCorp\Bundle\EasyAdminBundle\Config\MenuItem;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractDashboardController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[AdminDashboard(routePath: '/admin', routeName: 'admin')]
class DashboardController extends AbstractDashboardController
{
    public function __construct(
        private BookRepository $bookRepo,
        private AuthorRepository $authorRepo,
        private PublisherRepository $publisherRepo,
        private CategoryRepository $categoryRepo,
        private OrderRepository $orderRepo,
        private UserRepository $userRepo
    ) {
    }

    #[Route('/admin', name: 'admin')]
    public function index(): Response
    {
        // Récupérer les statistiques
        $stats = [
            'totalBooks' => $this->bookRepo->count([]),
            'totalAuthors' => $this->authorRepo->count([]),
            'totalPublishers' => $this->publisherRepo->count([]),
            'totalCategories' => $this->categoryRepo->count([]),
            'totalOrders' => $this->orderRepo->count([]),
            'totalUsers' => $this->userRepo->count([]),
            'pendingOrders' => $this->orderRepo->count(['statut' => 'pending']),
            'paidOrders' => $this->orderRepo->count(['statut' => 'paid']),
        ];

        // Statistiques par catégorie
        $categories = $this->categoryRepo->findAll();
        $categoryStats = [];
        foreach ($categories as $category) {
            $categoryStats[] = [
                'name' => $category->getDesignation(),
                'count' => count($category->getBooks()),
            ];
        }

        // Livres récents
        $recentBooks = $this->bookRepo->findBy([], ['id' => 'DESC'], 5);

        // Calcul du stock total
        $totalStock = 0;
        $allBooks = $this->bookRepo->findAll();
        foreach ($allBooks as $book) {
            $totalStock += $book->getQuantite();
        }
        $stats['totalStock'] = $totalStock;

        return $this->render('admin/dashboard.html.twig', [
            'stats' => $stats,
            'categoryStats' => $categoryStats,
            'recentBooks' => $recentBooks,
        ]);
    }

    public function configureDashboard(): Dashboard
    {
        return Dashboard::new()
            ->setTitle('Bibliothèque - Administration')
            ->setFaviconPath('favicon.ico')
            ->setTranslationDomain('admin')
            ->renderContentMaximized(); // Afficher le contenu maximisé
    }

    public function configureMenuItems(): iterable
    {
        yield MenuItem::linkToDashboard('Dashboard', 'fa fa-home');
        yield MenuItem::section('Gestion des Livres');
        yield MenuItem::linkToCrud('Livres', 'fa fa-book', Book::class);
        yield MenuItem::linkToCrud('Auteurs', 'fa fa-user', Author::class);
        yield MenuItem::linkToCrud('Catégories', 'fa fa-tags', Category::class);
        yield MenuItem::linkToCrud('Éditeurs', 'fa fa-building', Publisher::class);
        yield MenuItem::section('Gestion des Commandes');
        yield MenuItem::linkToCrud('Commandes', 'fa fa-shopping-cart', Order::class);
        yield MenuItem::section('Gestion des Utilisateurs');
        yield MenuItem::linkToCrud('Utilisateurs', 'fa fa-users', User::class);
        yield MenuItem::linkToCrud('Personnel', 'fa fa-user-tie', Staff::class);
        yield MenuItem::section('Messages');
        yield MenuItem::linkToCrud('Messages', 'fa fa-envelope', MessengerMessage::class);
        yield MenuItem::section('Navigation');
        yield MenuItem::linkToRoute('Retour au site', 'fa fa-arrow-left', 'home');
        yield MenuItem::linkToLogout('Déconnexion', 'fa fa-sign-out');
    }
}

