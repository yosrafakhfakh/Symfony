<?php

namespace App\Controller\Admin;

use App\Entity\MessengerMessage;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextareaField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextField;

class MessengerMessageCrudController extends AbstractCrudController
{
    public static function getEntityFqcn(): string
    {
        return MessengerMessage::class;
    }

    public function configureFields(string $pageName): iterable
    {
        return [
            TextareaField::new('contenu'),
            TextField::new('expediteur'),
            TextField::new('destinataire'),
            TextField::new('dateEnvoiFormatted', 'Date d\'envoi')
                ->formatValue(function ($value, $entity) {
                    if ($entity instanceof MessengerMessage) {
                        $date = $entity->getDateEnvoi();
                        return $date ? $date->format('d/m/Y H:i') : '-';
                    }
                    return '-';
                })
                ->hideOnForm(),
        ];
    }
}

