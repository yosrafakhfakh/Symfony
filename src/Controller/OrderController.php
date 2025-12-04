<?php

namespace App\Controller;

use App\Entity\Order;
use App\Entity\OrderItem;
use App\Repository\BookRepository;
use App\Repository\OrderRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session\SessionInterface;
use Symfony\Component\Routing\Attribute\Route;

class OrderController extends AbstractController
{
    #[Route('/order/checkout', name: 'order_checkout')]
    public function checkout(SessionInterface $session, BookRepository $bookRepo): Response
    {
        $this->denyAccessUnlessGranted('ROLE_USER');

        $cart = $session->get('cart', []);
        if (empty($cart)) {
            $this->addFlash('error', 'Votre panier est vide.');
            return $this->redirectToRoute('cart');
        }

        $cartData = [];
        $total = 0;

        foreach ($cart as $bookId => $quantity) {
            $book = $bookRepo->find($bookId);
            if ($book && $book->getQuantite() >= $quantity) {
                $itemTotal = floatval($book->getPrix()) * $quantity;
                $total += $itemTotal;
                $cartData[] = [
                    'book' => $book,
                    'quantity' => $quantity,
                    'total' => $itemTotal,
                ];
            }
        }

        return $this->render('order/checkout.html.twig', [
            'cart' => $cartData,
            'total' => $total,
        ]);
    }

    #[Route('/order/create', name: 'order_create', methods: ['POST'])]
    public function create(Request $request, SessionInterface $session, BookRepository $bookRepo, EntityManagerInterface $em): Response
    {
        $this->denyAccessUnlessGranted('ROLE_USER');

        $cart = $session->get('cart', []);
        if (empty($cart)) {
            $this->addFlash('error', 'Votre panier est vide.');
            return $this->redirectToRoute('cart');
        }

        $order = new Order();
        $order->setUser($this->getUser());
        $order->setStatut('pending');
        $order->setDateCommande(new \DateTime());

        $total = 0;
        foreach ($cart as $bookId => $quantity) {
            $book = $bookRepo->find($bookId);
            if ($book && $book->getQuantite() >= $quantity) {
                $orderItem = new OrderItem();
                $orderItem->setBook($book);
                $orderItem->setQuantite($quantity);
                $orderItem->setPrix($book->getPrix());
                $order->addOrderItem($orderItem);

                $book->setQuantite($book->getQuantite() - $quantity);
                $total += floatval($book->getPrix()) * $quantity;
            }
        }

        $order->setMontantTotal((string) $total);
        $em->persist($order);
        $em->flush();

        $session->remove('cart');
        $this->addFlash('success', 'Commande passée avec succès !');

        return $this->redirectToRoute('order_success', ['id' => $order->getId()]);
    }

    #[Route('/order/success/{id}', name: 'order_success')]
    public function success(int $id, OrderRepository $orderRepo): Response
    {
        $this->denyAccessUnlessGranted('ROLE_USER');

        $order = $orderRepo->find($id);
        if (!$order || $order->getUser() !== $this->getUser()) {
            throw $this->createAccessDeniedException();
        }

        return $this->render('order/success.html.twig', [
            'order' => $order,
        ]);
    }

    #[Route('/order/history', name: 'order_history')]
    public function history(OrderRepository $orderRepo): Response
    {
        $this->denyAccessUnlessGranted('ROLE_USER');

        $orders = $orderRepo->findByUser($this->getUser());

        return $this->render('order/history.html.twig', [
            'orders' => $orders,
        ]);
    }

    #[Route('/order/{id}', name: 'order_show')]
    public function show(int $id, OrderRepository $orderRepo): Response
    {
        $this->denyAccessUnlessGranted('ROLE_USER');

        $order = $orderRepo->find($id);
        if (!$order || ($order->getUser() !== $this->getUser() && !$this->isGranted('ROLE_ADMIN'))) {
            throw $this->createAccessDeniedException();
        }

        return $this->render('order/show.html.twig', [
            'order' => $order,
        ]);
    }

    #[Route('/order/payment/{id}', name: 'order_payment', methods: ['POST'])]
    public function payment(int $id, OrderRepository $orderRepo, EntityManagerInterface $em): Response
    {
        $this->denyAccessUnlessGranted('ROLE_USER');

        $order = $orderRepo->find($id);
        if (!$order || $order->getUser() !== $this->getUser()) {
            throw $this->createAccessDeniedException();
        }

        // Simulate payment processing
        // In a real application, integrate with a payment gateway like Stripe, PayPal, etc.
        $order->setStatut('paid');
        $order->setDateModification(new \DateTime());
        $em->flush();

        $this->addFlash('success', 'Paiement effectué avec succès !');
        return $this->redirectToRoute('order_show', ['id' => $order->getId()]);
    }
}

