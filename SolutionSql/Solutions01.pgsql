-- Série d'exercices 1
-- Interrogations simples à la base de données


-- 1.1
SELECT * 
    FROM employe;

-- 1.2
SELECT nom, prenom, departement 
    FROM employe;

-- 1.3
SELECT departement, prenom, nom 
    FROM employe;

-- 1.4
SELECT nom, prenom
    FROM employe
    WHERE departement = 'ventes';

-- 1.5
SELECT  nom AS "Nom de l'employé",
        prenom AS "Prénom de l'employé",
        salaire AS "Salaire de l'employé"
    FROM employe
    WHERE salaire > 20.0;

-- 1.6
SELECT nom, prenom
    FROM employe
    WHERE departement = 'ventes' AND salaire > 20.0;

-- 1.7
SELECT nom, prenom
    FROM employe
    WHERE departement = 'r&d' OR (ville = 'Montréal' AND salaire > 25.0);

-- 1.8
-- a)
SELECT nom, prenom, ville
    FROM employe
    WHERE ville = 'Laval' OR ville = 'Longueuil';
-- b)
SELECT nom, prenom, ville
    FROM employe
    WHERE ville IN ('Laval', 'Longueuil');

-- 1.9
SELECT nom, prenom, departement
    FROM employe
    WHERE superviseur = 111;

-- 1.10
-- a)
SELECT nom, prenom, salaire
    FROM employe
    WHERE salaire >= 20.0 AND salaire <= 30.0;
-- b)
SELECT nom, prenom, salaire
    FROM employe
    WHERE salaire BETWEEN 20.0 AND 30.0;

-- 1.11
-- a)
SELECT nom, prenom, salaire
    FROM employe
    WHERE salaire > 20.0 AND salaire < 30.0;
-- b)
-- IMPOSSIBLE

-- 1.12
SELECT nom, prenom
    FROM employe
    WHERE nom BETWEEN 'Lebel' AND 'Tremblay';

-- 1.13
-- a)
SELECT nom
    FROM employe;
-- b)
SELECT DISTINCT nom
    FROM employe;

-- 1.14
SELECT 1;

-- 1.15
SELECT nom, prenom, 'employé'
    FROM employe;

-- 1.16
SELECT nom, prenom, salaire, salaire * 0.05, salaire * 1.05
    FROM employe;

-- 1.17
SELECT nom, prenom, departement
    FROM employe
    WHERE departement NOT IN ('ventes', 'achats');

-- 1.18
SELECT nom, prenom, salaire
    FROM employe
    WHERE salaire NOT BETWEEN 20.0 AND 30.0;

-- 1.19
-- a)
SELECT nom, prenom, salaire
    FROM employe
    WHERE salaire >= 20.0 AND salaire < 30.0;
-- b)
SELECT nom, prenom, salaire
    FROM employe
    WHERE salaire BETWEEN 20.0 AND 30.0 AND salaire <> 30.0;

-- 1.20
SELECT prenom || ' ' || nom || ' travail dans le département : ' || departement || '.' 
            AS "Les employés et leur département"
    FROM employe;
