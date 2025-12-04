<?php

namespace App\Controller;

use App\Entity\Book;
use App\Repository\BookRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session\SessionInterface;
use Symfony\Component\Routing\Attribute\Route;

class CartController extends AbstractController
{
    #[Route('/cart', name: 'cart')]
    public function index(SessionInterface $session, BookRepository $bookRepo): Response
    {
        $cart = $session->get('cart', []);
        $cartData = [];
        $total = 0;

        foreach ($cart as $bookId => $quantity) {
            $book = $bookRepo->find($bookId);
            if ($book) {
                $itemTotal = floatval($book->getPrix()) * $quantity;
                $total += $itemTotal;
                $cartData[] = [
                    'book' => $book,
                    'quantity' => $quantity,
                    'total' => $itemTotal,
                ];
            }
        }

        return $this->render('cart/index.html.twig', [
            'cart' => $cartData,
            'total' => $total,
        ]);
    }

    #[Route('/cart/add/{id}', name: 'cart_add')]
    public function add(int $id, SessionInterface $session, BookRepository $bookRepo): Response
    {
        $book = $bookRepo->find($id);
        if (!$book) {
            $this->addFlash('error', 'Livre introuvable.');
            return $this->redirectToRoute('home');
        }

        if ($book->getQuantite() <= 0) {
            $this->addFlash('error', 'Ce livre n\'est plus en stock.');
            return $this->redirectToRoute('home');
        }

        $cart = $session->get('cart', []);
        $currentQuantity = $cart[$id] ?? 0;
        
        if ($currentQuantity >= $book->getQuantite()) {
            $this->addFlash('error', 'Quantité maximale disponible atteinte.');
            return $this->redirectToRoute('cart');
        }

        $cart[$id] = ($cart[$id] ?? 0) + 1;
        $session->set('cart', $cart);

        $this->addFlash('success', 'Livre ajouté au panier.');
        return $this->redirectToRoute('cart');
    }

    #[Route('/cart/remove/{id}', name: 'cart_remove')]
    public function remove(int $id, SessionInterface $session): Response
    {
        $cart = $session->get('cart', []);
        unset($cart[$id]);
        $session->set('cart', $cart);

        $this->addFlash('success', 'Livre retiré du panier.');
        return $this->redirectToRoute('cart');
    }

    #[Route('/cart/update/{id}', name: 'cart_update', methods: ['POST'])]
    public function update(int $id, Request $request, SessionInterface $session, BookRepository $bookRepo): Response
    {
        $quantity = (int) $request->request->get('quantity', 1);
        $book = $bookRepo->find($id);

        if (!$book || $quantity <= 0) {
            $this->addFlash('error', 'Quantité invalide.');
            return $this->redirectToRoute('cart');
        }

        if ($quantity > $book->getQuantite()) {
            $this->addFlash('error', 'Quantité maximale disponible: ' . $book->getQuantite());
            return $this->redirectToRoute('cart');
        }

        $cart = $session->get('cart', []);
        if ($quantity > 0) {
            $cart[$id] = $quantity;
        } else {
            unset($cart[$id]);
        }
        $session->set('cart', $cart);

        $this->addFlash('success', 'Panier mis à jour.');
        return $this->redirectToRoute('cart');
    }
}

