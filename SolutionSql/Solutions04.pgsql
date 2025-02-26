-- Série d'exercices 4
-- Requêtes avec opérateurs et fonctions manipulant les chaînes de caractères


-- 4.1
SELECT prenom || ' ' || nom AS "Employé du département de R&D"
    FROM employe
    WHERE departement = 'r&d';

-- 4.2
SELECT UPPER(LEFT(prenom, 1)) || '. ' || nom || ', habitant à ' || UPPER(ville) || ' travail dans le département nommé ' || UPPER(departement) || '.'
    FROM employe;

-- 4.3
SELECT SUBSTR(LOWER(prenom), 1, 2) || '_' || LOWER(nom) || '@abc_xyz.com' 
    FROM employe;

-- 4.4
SELECT nom, prenom, departement, ville
    FROM employe
    WHERE LENGTH(ville) > 5 AND departement LIKE '%d%';

-- 4.5
SELECT nom, prenom
    FROM employe
    WHERE nom ILIKE '%b%' OR prenom ILIKE '%b%';
-- une petite variante intéressante
SELECT nom, prenom
    FROM employe
    WHERE (nom || prenom) ILIKE '%b%';

-- 4.6
SELECT LPAD(LPAD(nom || '~~> ' || prenom, 30, '~'), 45, '-')
    FROM employe;

-- 4.7
SELECT  prenom || ' ' || nom AS "Employé", 
        37.5 + 27.75 * (LENGTH(nom) - 1) + 29.25 + 25.0 * (LENGTH(prenom) - 1) AS "Coût"
    FROM employe;

-- 4.8
SELECT  prenom || ' ' || nom, 
        INITCAP(REVERSE(LOWER(prenom))) || ' ' || INITCAP(REVERSE(LOWER(nom))), 
        (prenom || ' ' || nom) = (INITCAP(REVERSE(LOWER(prenom))) || ' ' || INITCAP(REVERSE(LOWER(nom))))
    FROM employe;




