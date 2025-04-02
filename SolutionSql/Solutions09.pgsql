-- Série d'exercices 9
-- Insertion, mise à jour et suppression de données 


-- 9.1
-- ----------------------------------------------------------------------------
-- a)
INSERT INTO employe 
    VALUES (911, 'Lapierre', 'Pierre', 'h', 
            '2001-02-03', 25.0, 
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            'Montréal', 123, 0);
-- Oui : tous les champs de la table sont spécifiés dans l'ordre avec des données compatibles.

-- b)
INSERT INTO employe 
    VALUES (912, 'Gravel', 'Pierre', 'h', 
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            '2001-02-03', 25.0, 
            'Montréal', 123, 0);
-- Non : les types des données ne correspondent pas à la l'ordre de la création de la table.

--c)
INSERT INTO employe 
    VALUES (913, 'Laroche', 'Pierre', 'h', 
            DEFAULT, 25.0, 
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            'Montréal', DEFAULT, NULL);
-- Oui : tous les champs de la table sont spécifiés dans l'ordre avec des données compatibles
--       ou avec des valeurs par défauts définies.

--d)
INSERT INTO employe 
    VALUES (914, DEFAULT, 'Pierre', 'h', 
            DEFAULT, DEFAULT, 
            DEFAULT, DEFAULT, DEFAULT, DEFAULT);
-- Non : plusieurs champs utilisent la valeur par défaut alors qu'elle n'est pas définie.

--e)
INSERT INTO employe 
    VALUES (915, 'Concassé', 'Pierre', 'h', 
            '4 février 2003', 25.0, 
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            'Montréal', 123, 0);
-- Non : la date est non conforme.

--f)
INSERT INTO employe 
    VALUES (916, 'Carrière', 'Pierre', 'h', 
            DEFAULT, 25.0, 
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            'Montréal', 123, );
-- Non : le dernier champ est laissé vide.

--g)
INSERT INTO employe 
    VALUES (NULL, 'Lamontagne', 'Pierre', 'h', 
            DEFAULT, 25.0, 
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            'Montréal', 123, NULL);
-- Non : la clé primaire ne peut être nulle.

--h)
INSERT INTO employe (prenom, nom, genre, nas, departement, ville)
    VALUES ('Pierre', 'Larivière', 'h', 918, 
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            'Montréal');
-- Oui : les champs obligatoires sont définis malgré l'ordre qui est mélangé.

--i)
INSERT INTO employe (prenom, nom, genre, nas, departement, ville, salaire)
    VALUES ('Pierre', 'Larocque', 'h', 919, 
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            'Montréal', 40000.0);
-- Non : le salaire ne respecte la définition du type (5, 2).

--j)
INSERT INTO employe (prenom, nom, genre, nas, departement, ville, salaire)
    VALUES ('Pierre', 'Galet', 'h', 920, 
            920, 'Montréal', 25.50);
-- Non : Le département 920 n'existe pas et il y a violation de clé étrangère.

-- ----------------------------------------------------------------------------


-- 9.2
-- ----------------------------------------------------------------------------
INSERT INTO employe 
    VALUES (922, 'Latendresse', 'Marie', 'f', 
            '2001-10-10', 25.0, 
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            'Montréal', 
            (SELECT nas FROM employe WHERE nom = 'Bordeleau' AND prenom = 'Marina'), 
            0);

-- 9.3
-- ----------------------------------------------------------------------------
INSERT INTO employe (prenom, nom, genre, nas, departement, ville, salaire)
    VALUES ('Clément', 'Lajoie', 'h', 930,
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            'Montréal', 22.22);


-- 9.4
-- ----------------------------------------------------------------------------
-- Qu’est-ce qui se passe? 
--   La clé primaire existe déjà. Il est impossible d'ajouter une nouvelle 
--   ligne dont la valeur de la clé primaire existe dans la table.
-- Qu’est-ce qui peut expliquer une telle situation? 
--   De deux choses l'une : 
--     1. un employé s'est trompé et n'a pas donné la bonne clé primaire
--     2. quelqu'un tente de s'insérer une 2e fois dans la bd sous un autre nom.
-- Quelle serait la solution?
--   Questionner les employés impliqués (Lancelot Dupuis et Gaston Laterreur)
--   pour comprendre la nature du problème et certainement obtenir les bons nas. 


-- 9.5
-- ----------------------------------------------------------------------------
UPDATE employe
    SET ville = 'Longueuil'
    WHERE nom = 'Dupuis' AND prenom = 'Lancelot';


-- 9.6
-- ----------------------------------------------------------------------------
UPDATE employe
    SET salaire = salaire * 1.175,
        commission = GREATEST(0.0, commission - 2000.0)
    WHERE commission IS NOT NULL;


-- 9.7
-- ----------------------------------------------------------------------------
-- Il est impossible de faire toutes ces modifications avec une seule requête.
-- Au minimum, 2 requêtes sont nécessaires.
UPDATE employe
    SET departement = (SELECT id FROM departement WHERE nom = 'Recherche et développement'),
        superviseur = (SELECT superviseur FROM employe WHERE nom = 'Pignon' AND prenom = 'François'),
        salaire = 45.00,
        commission = NULL
    WHERE nom = 'Brochant' AND prenom = 'Christine';

UPDATE employe
    SET ville = (SELECT ville FROM departement WHERE nom = 'Recherche et développement')
    WHERE nom = 'Brochant' AND prenom IN ('Christine', 'Pierre');


-- 9.8
-- ----------------------------------------------------------------------------
INSERT INTO departement(nom, ville, superviseur)
    VALUES ('Ressources humaines', 
            'Montréal', 
            (SELECT nas FROM employe WHERE nom = 'Dupuis' AND prenom = 'Lancelot'));


-- 9.9
-- ----------------------------------------------------------------------------
-- Plusieurs solutions possibles, on utilise la stratégie (sous optimale) 
-- d'assigner des valeurs bidons temporaires aux clés étrangères.
INSERT INTO employe 
    VALUES (990, 'LeGuerrier', 'Jean-Marc', 'h', 
            DEFAULT, 55.0, 
            (SELECT id FROM departement WHERE nom = 'Ventes'), 
            'Longueuil', 
            (SELECT nas FROM employe WHERE nom = 'Dupuis' AND prenom = 'Lancelot'), 
            NULL);

INSERT INTO departement(nom, ville, superviseur)
    VALUES ('Formation', 
            'Longueuil', 
            (SELECT nas FROM employe WHERE nom = 'LeGuerrier' AND prenom = 'Jean-Marc'));

UPDATE employe
    SET departement = (SELECT id FROM departement WHERE nom = 'Formation')
    WHERE nom = 'LeGuerrier' and prenom = 'Jean-Marc';


-- 9.10
-- ----------------------------------------------------------------------------
DELETE FROM employe 
    WHERE nom = 'Pignon' AND prenom = 'François';


-- 9.11
-- ----------------------------------------------------------------------------
UPDATE employe
    SET departement = (SELECT id FROM departement WHERE nom = 'Ventes'),
        commission = 0
    WHERE departement = (SELECT id FROM departement WHERE nom = 'Administration');

DELETE FROM departement 
    WHERE nom = 'Administration';


-- SELECT * FROM employe;
-- SELECT * FROM departement;
