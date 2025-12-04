<?php

namespace App\Controller;

use App\Repository\AuthorRepository;
use App\Repository\BookRepository;
use App\Repository\CategoryRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class HomeController extends AbstractController
{
    #[Route('/', name: 'home')]
    public function index(Request $request, BookRepository $bookRepo, CategoryRepository $categoryRepo, AuthorRepository $authorRepo): Response
    {
        $search = $request->query->get('search');
        $authorId = $request->query->get('author') ? (int) $request->query->get('author') : null;
        $categoryId = $request->query->get('category') ? (int) $request->query->get('category') : null;
        $maxPrice = $request->query->get('max_price') ? (float) $request->query->get('max_price') : null;
        $dateFrom = $request->query->get('date_from') ? new \DateTime($request->query->get('date_from')) : null;

        $books = $bookRepo->findByFilters($search, $authorId, $categoryId, $maxPrice, $dateFrom);
        $categories = $categoryRepo->findAll();
        $authors = $authorRepo->findAll();

        return $this->render('home/index.html.twig', [
            'books' => $books,
            'categories' => $categories,
            'authors' => $authors,
            'search' => $search,
            'selectedAuthor' => $authorId,
            'selectedCategory' => $categoryId,
            'selectedMaxPrice' => $maxPrice,
            'selectedDateFrom' => $request->query->get('date_from'),
        ]);
    }
}

