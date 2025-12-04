<?php

namespace App\Repository;

use App\Entity\Book;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Book>
 */
class BookRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Book::class);
    }

    public function findByFilters(?string $search = null, ?int $authorId = null, ?int $categoryId = null, ?float $maxPrice = null, ?\DateTimeInterface $dateFrom = null)
    {
        $qb = $this->createQueryBuilder('b')
            ->leftJoin('b.author', 'a')
            ->leftJoin('b.category', 'c');

        if ($search) {
            $qb->andWhere('b.titre LIKE :search OR b.isbn LIKE :search OR a.nom LIKE :search OR a.prenom LIKE :search')
                ->setParameter('search', '%' . $search . '%');
        }

        if ($authorId) {
            $qb->andWhere('a.id = :authorId')
                ->setParameter('authorId', $authorId);
        }

        if ($categoryId) {
            $qb->andWhere('c.id = :categoryId')
                ->setParameter('categoryId', $categoryId);
        }

        if ($maxPrice) {
            $qb->andWhere('b.prix <= :maxPrice')
                ->setParameter('maxPrice', $maxPrice);
        }

        if ($dateFrom) {
            $qb->andWhere('b.datePublication >= :dateFrom')
                ->setParameter('dateFrom', $dateFrom);
        }

        return $qb->getQuery()->getResult();
    }
}

