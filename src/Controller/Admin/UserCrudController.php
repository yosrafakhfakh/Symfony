<?php

namespace App\Controller\Admin;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\ArrayField;
use EasyCorp\Bundle\EasyAdminBundle\Field\BooleanField;
use EasyCorp\Bundle\EasyAdminBundle\Field\EmailField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextField;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Form\Extension\Core\Type\PasswordType;

class UserCrudController extends AbstractCrudController
{
    public function __construct(
        private UserPasswordHasherInterface $passwordHasher
    ) {
    }

    public static function getEntityFqcn(): string
    {
        return User::class;
    }

    public function configureFields(string $pageName): iterable
    {
        return [
            EmailField::new('email'),
            TextField::new('password')
                ->setFormType(PasswordType::class)
                ->onlyOnForms()
                ->setRequired($pageName === 'new'),
            ArrayField::new('roles'),
            TextField::new('nom'),
            TextField::new('prenom'),
            BooleanField::new('isActive'),
            TextField::new('dateCreation', 'Date de création')
                ->formatValue(function ($value, $entity) {
                    // Ce champ n'existe pas dans l'entité, donc $value sera null
                    // On récupère la valeur depuis l'entité
                    if ($entity instanceof User) {
                        $date = $entity->getCreatedAt();
                        return $date ? $date->format('d/m/Y H:i') : '-';
                    }
                    return '-';
                })
                ->onlyOnIndex()
                ->hideOnForm(),
        ];
    }

    public function persistEntity($entityManager, $entityInstance): void
    {
        if ($entityInstance instanceof User && $entityInstance->getPassword()) {
            $hashedPassword = $this->passwordHasher->hashPassword($entityInstance, $entityInstance->getPassword());
            $entityInstance->setPassword($hashedPassword);
        }
        parent::persistEntity($entityManager, $entityInstance);
    }

    public function updateEntity(EntityManagerInterface $entityManager, $entityInstance): void
    {
        if ($entityInstance instanceof User) {
            $plainPassword = $entityInstance->getPassword();
            // If password is empty or looks like a hash (starts with $), keep the existing one
            if (empty($plainPassword) || str_starts_with($plainPassword, '$')) {
                $existingUser = $entityManager->getRepository(User::class)->find($entityInstance->getId());
                if ($existingUser) {
                    $entityInstance->setPassword($existingUser->getPassword());
                }
            } else {
                // New password provided, hash it
                $hashedPassword = $this->passwordHasher->hashPassword($entityInstance, $plainPassword);
                $entityInstance->setPassword($hashedPassword);
            }
        }
        parent::updateEntity($entityManager, $entityInstance);
    }
}

