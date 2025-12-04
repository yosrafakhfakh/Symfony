<?php

namespace App\Controller\Admin;

use App\Entity\Book;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\AssociationField;
use EasyCorp\Bundle\EasyAdminBundle\Field\ImageField;
use EasyCorp\Bundle\EasyAdminBundle\Field\IntegerField;
use EasyCorp\Bundle\EasyAdminBundle\Field\MoneyField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextField;

class BookCrudController extends AbstractCrudController
{
    public static function getEntityFqcn(): string
    {
        return Book::class;
    }

    public function configureFields(string $pageName): iterable
    {
        return [
            TextField::new('titre'),
            TextField::new('isbn'),
            IntegerField::new('quantite'),
            MoneyField::new('prix')->setCurrency('EUR'),
            TextField::new('datePublicationFormatted', 'Date de publication')
                ->formatValue(function ($value, $entity) {
                    if ($entity && method_exists($entity, 'getDatePublication')) {
                        $date = $entity->getDatePublication();
                        return $date ? $date->format('d/m/Y') : '-';
                    }
                    return '-';
                })
                ->hideOnForm(),
            ImageField::new('image')
                ->setBasePath('uploads/images/')
                ->setUploadDir('public/uploads/images/')
                ->setUploadedFileNamePattern('[randomhash].[extension]'),
            AssociationField::new('author'),
            AssociationField::new('category'),
            AssociationField::new('publisher'),
        ];
    }
}

