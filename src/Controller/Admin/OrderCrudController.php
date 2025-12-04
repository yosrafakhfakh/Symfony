<?php

namespace App\Controller\Admin;

use App\Entity\Order;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\AssociationField;
use EasyCorp\Bundle\EasyAdminBundle\Field\MoneyField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextareaField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextField;

class OrderCrudController extends AbstractCrudController
{
    public static function getEntityFqcn(): string
    {
        return Order::class;
    }

    public function configureFields(string $pageName): iterable
    {
        return [
            AssociationField::new('user'),
            MoneyField::new('montantTotal')->setCurrency('EUR'),
            TextField::new('statut'),
            TextField::new('dateCommandeFormatted', 'Date de commande')
                ->formatValue(function ($value, $entity) {
                    if ($entity instanceof Order) {
                        $date = $entity->getDateCommande();
                        return $date ? $date->format('d/m/Y H:i') : '-';
                    }
                    return '-';
                })
                ->hideOnForm(),
            TextField::new('dateModificationFormatted', 'Date de modification')
                ->formatValue(function ($value, $entity) {
                    if ($entity instanceof Order) {
                        $date = $entity->getDateModification();
                        return $date ? $date->format('d/m/Y H:i') : '-';
                    }
                    return '-';
                })
                ->hideOnForm(),
            TextareaField::new('notesInternes'),
        ];
    }
}

