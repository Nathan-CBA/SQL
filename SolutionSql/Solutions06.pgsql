-- Série d'exercices 6
-- Requêtes avec opérateurs et fonctions manipulant les valeurs nulles


-- 6.1
-- Seule la version 3 est satisfaisante.

-- 6.2
SELECT nom, prenom
    FROM employe
    WHERE commission IS NULL;

-- 6.3
SELECT nom, prenom
    FROM employe
    WHERE commission IS NOT NULL;

-- 6.4
-- a)
SELECT nom, prenom, commission
    FROM employe
    WHERE commission < 2000.0;
-- b)
SELECT nom, prenom, COALESCE(commission, 0.0) AS "Commission"
    FROM employe
    WHERE COALESCE(commission, 0.0) < 2000.0;

-- 6.5
SELECT nom, prenom, 32.0 * salaire + COALESCE(commission, 0.0)
    FROM employe
    WHERE 32.0 * salaire + COALESCE(commission, 0.0) > 2000.0;

-- 6.6
SELECT nom, prenom
    FROM employe
    WHERE superviseur IS NULL;

-- 6.7
SELECT nom, prenom, COALESCE(superviseur, 0)
    FROM employe;

-- 6.8
SELECT nom, prenom, NULLIF(ville, 'Laval')
    FROM employe;

