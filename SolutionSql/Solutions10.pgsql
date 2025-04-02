-- Série d'exercices 10
-- Fonctions d’agrégation et de regroupement 


-- 10.1
-- ----------------------------------------------------------------------------
SELECT AVG(salaire)
    FROM employe;


-- 10.2
-- ----------------------------------------------------------------------------
SELECT departement, AVG(salaire)
    FROM employe
    GROUP BY departement;


-- 10.3
-- ----------------------------------------------------------------------------
SELECT departement, AVG(salaire), COUNT(*)
    FROM employe
    WHERE departement IN (SELECT departement 
                            FROM employe 
                            GROUP BY departement 
                            HAVING COUNT(*) >= 2)
    GROUP BY departement;


-- 10.4
-- ----------------------------------------------------------------------------
SELECT departement, AVG(salaire)
    FROM employe
    WHERE departement IN (SELECT departement 
                            FROM employe 
                            GROUP BY departement 
                            HAVING MAX(salaire) < 30)
    GROUP BY departement;


-- 10.5
-- ----------------------------------------------------------------------------
SELECT (SELECT id FROM departement WHERE nom = 'Ventes'), AVG(salaire)
    FROM employe
    WHERE departement = (SELECT id FROM departement WHERE nom = 'Ventes');
-- GROUP BY pas nécessaire


-- 10.6
-- ----------------------------------------------------------------------------
SELECT departement, COUNT(*), AVG(salaire)
    FROM employe
    WHERE genre = 'f'
    GROUP BY departement;


-- 10.7
-- ----------------------------------------------------------------------------
SELECT departement, COUNT(*), AVG(salaire)
    FROM employe
    WHERE genre = 'f'
    GROUP BY departement
    ORDER BY AVG(salaire) ASC;


-- 10.8
-- ----------------------------------------------------------------------------
SELECT 'Femmes' AS "Genre", COUNT(*) AS "Nombre", AVG(salaire) AS "Moyenne salariale"
    FROM employe
    WHERE genre = 'f'
    GROUP BY genre
UNION
SELECT 'Hommes' AS "Genre", COUNT(*) AS "Nombre", AVG(salaire) AS "Moyenne salariale"
    FROM employe
    WHERE genre = 'h'
    GROUP BY genre;

-- version b
SELECT  CASE 
            WHEN genre = 'f' THEN 'Femme'
            WHEN genre = 'h' THEN 'Homme' 
        END AS "Genre", 
        COUNT(*) AS "Nombre", AVG(salaire) AS "Moyenne salariale"
    FROM employe
    GROUP BY genre;


-- 10.9
-- ----------------------------------------------------------------------------
SELECT COUNT(*)
    FROM departement;


-- 10.10
-- ----------------------------------------------------------------------------
SELECT departement, AVG(DATE_PART('year', CURRENT_DATE) - DATE_PART('year', date_embauche))
    FROM employe
    GROUP BY departement;


-- 10.11
-- ----------------------------------------------------------------------------
SELECT genre, AVG(DATE_PART('year', CURRENT_DATE) - DATE_PART('year', date_embauche))
    FROM employe
    GROUP BY genre;


-- 10.12
-- ----------------------------------------------------------------------------
SELECT departement, COUNT(*)
    FROM employe
    GROUP BY departement
    ORDER BY COUNT(*) DESC;


-- 10.13
-- ----------------------------------------------------------------------------
SELECT departement, TRUNC(MIN(salaire)), TRUNC(AVG(salaire)), TRUNC(MAX(salaire))
    FROM employe
    WHERE departement IN (SELECT departement 
                            FROM employe 
                            GROUP BY departement 
                            HAVING COUNT(*) > 1)
    GROUP BY departement
    ORDER BY AVG(salaire) DESC;


-- 10.14
-- ----------------------------------------------------------------------------
SELECT departement, genre, COUNT(*)
    FROM employe
    WHERE commission IS NULL
    GROUP BY departement, genre
    ORDER BY departement, genre;


-- 10.15
-- ----------------------------------------------------------------------------
SELECT departement, AVG((salaire * 32 * 52) * 1.25 + (COALESCE(commission, 0.0) * 12) * 1.10)
    FROM employe
    GROUP BY departement
    HAVING AVG((salaire * 32 * 52) * 1.25 + (COALESCE(commission, 0.0) * 12) * 1.10) >= 50000;


-- 10.16
-- ----------------------------------------------------------------------------
SELECT COUNT(DISTINCT superviseur)
    FROM employe;


-- 10.17
-- ----------------------------------------------------------------------------
SELECT superviseur, COUNT(*)
    FROM employe
    WHERE superviseur IS NOT NULL
    GROUP BY superviseur
    ORDER BY COUNT(*) DESC;


-- 10.18
-- ----------------------------------------------------------------------------
SELECT nas, nom, prenom, salaire
    FROM employe
    WHERE salaire > (SELECT AVG(salaire) FROM employe)
    ORDER BY salaire DESC;


-- 10.19
-- ----------------------------------------------------------------------------
SELECT departement, AVG(salaire)
    FROM employe
    WHERE genre = 'h'
    GROUP BY departement
    HAVING AVG(salaire) > (SELECT AVG(salaire) FROM employe WHERE genre = 'f');


-- 10.20
-- ----------------------------------------------------------------------------
SELECT COUNT(*)                                                                     -- retrouve le nombre de département localisée dans la ville (ou les villes) où habitent le plus grand nombre d'employés.
    FROM departement
    WHERE ville IN (
        SELECT ville                                                                -- retrouve la liste des villes qui partagent le nombre maximum d'employé
            FROM employe 
            GROUP BY ville 
            HAVING COUNT(*) = (SELECT MAX("nbr")                                    -- retrouve le nombre maximum d'employé dans la même ville
                                    FROM (SELECT COUNT(*) AS "nbr"                  -- retrouve le nombre d'employé par ville
                                                FROM employe 
                                                GROUP BY ville 
                                                ORDER BY COUNT(*)) AS VillesRecurrentes));
--                                                                    ^-- cet alias de 'table-résultat' est obligatoire pour pouvoir 
--                                                                        l'utiliser dans la clause FROM de la requête externe










SELECT * FROM employe;
SELECT * FROM departement;

SELECT * FROM employe, departement;

SELECT  emp.nom || ', ' || emp.prenom AS "Employé", 
        dep.nom   as "Département", 
        sup_dep.nom || ', ' ||sup_dep.prenom as "Superviseur département"
    FROM employe AS emp
        JOIN departement AS dep
            ON emp.departement = dep.id
        JOIN employe as sup_dep
            ON dep.superviseur = sup_dep.nas;

