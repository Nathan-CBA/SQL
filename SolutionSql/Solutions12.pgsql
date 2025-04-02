-- Série d'exercices 12
-- Requête corrélée



-- 12.1
-- a) requête non corrélée
SELECT emp.nom, emp.prenom
    FROM employe AS emp
        INNER JOIN employe AS sup
            ON sup.nas = emp.superviseur
    WHERE emp.salaire >= sup.salaire;
-- b) requête corrélée
SELECT emp.nom, emp.prenom
    FROM employe AS emp
    WHERE salaire >= (SELECT salaire
                        FROM employe AS sup
                        WHERE sup.nas = emp.superviseur);



-- 12.2
-- a) requête non corrélée
SELECT nom, prenom
    FROM employe
    WHERE superviseur IN (  SELECT superviseur
                                FROM employe
                                GROUP BY superviseur
                                HAVING COUNT(*) >= 4);
-- b) requête corrélée
SELECT nom, prenom
    FROM employe AS emp
    WHERE (  SELECT COUNT(*)
                FROM employe AS sup
                WHERE sup.superviseur = emp.superviseur) >= 4;



-- 12.3
-- a) requête non corrélée
SELECT nom, prenom
    FROM employe
    WHERE departement IN (  SELECT DISTINCT employe.departement
                                FROM employe
                                WHERE DATE_PART('month', date_embauche) NOT IN (1, 5, 7, 9));
-- b) requête corrélée
SELECT nom, prenom
    FROM employe AS emp
    WHERE ( SELECT COUNT(*)
                FROM employe AS empdep
                WHERE   empdep.departement = emp.departement AND
                        DATE_PART('month', date_embauche) NOT IN (1, 5, 7, 9 )) >= 1;
-- b2) requête corrélée utilisant l'opérateur EXISTS
SELECT nom, prenom
    FROM employe AS emp
    WHERE EXISTS(SELECT empdep.departement
                        FROM employe AS empdep
                        WHERE   empdep.departement = emp.departement AND
                                DATE_PART('month', date_embauche) NOT IN (1, 5, 7, 9 ));



-- 12.4
SELECT nom, prenom
    FROM employe AS emp
    WHERE salaire <= (SELECT AVG(salaire) - STDDEV(salaire)
                        FROM employe AS empdep
                        WHERE empdep.departement = emp.departement);



-- 12.5
SELECT nom, prenom
    FROM employe AS emp
    WHERE salaire >= (SELECT AVG(salaire)
                        FROM employe AS empdep
                        WHERE empdep.departement = emp.departement) 
        AND
        (SELECT COUNT(*)
            FROM employe AS depemp
            WHERE depemp.departement = emp.departement) > 2;



-- 12.6
SELECT nom, prenom, salaire
    FROM employe AS emp
    WHERE salaire >=ALL(    SELECT salaire 
                                FROM employe AS empdep
                                WHERE empdep.departement = emp.departement);



-- 12.7
SELECT nom
    FROM departement
    WHERE EXISTS(SELECT nas 
                    FROM employe
                    WHERE genre = 'h' AND
                        employe.departement = departement.id);





SELECT * FROM employe;
SELECT * FROM departement;