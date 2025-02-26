-- Série d'exercices 5
-- Requêtes avec opérateurs et fonctions manipulant les dates


-- 5.1 
-- a)
SELECT nom, prenom, date_embauche
    FROM employe;
-- b)
SELECT nom, prenom, TO_CHAR(date_embauche, 'YYYY/MM/DD')
    FROM employe;

-- 5.2
-- a)
SELECT nom, prenom, TO_CHAR(date_embauche, 'YYYY/MM/DD')
    FROM employe
    WHERE date_embauche > '2002-04-12';
-- b)
SELECT nom, prenom, TO_CHAR(date_embauche, 'YYYY/MM/DD')
    FROM employe
    WHERE date_embauche > TO_DATE('12|04|02', 'DD|MM|YY');

-- 5.3
SELECT nom, prenom, TO_CHAR(date_embauche, 'DD/MM/YY')
    FROM employe
    WHERE date_embauche BETWEEN TO_DATE('12 04 2001', 'DD MM YYYY') AND TO_DATE('02_05_12', 'YY_MM_DD');

-- 5.4
SELECT nom, prenom, TO_CHAR(date_embauche, 'YYYY/MM/DD')
    FROM employe
    WHERE   (EXTRACT(MONTH FROM date_embauche) = 12 AND EXTRACT(DAY FROM date_embauche) = 25) OR 
            (EXTRACT(MONTH FROM date_embauche) = 2 AND EXTRACT(DAY FROM date_embauche) = 14);

-- 5.5
SELECT  nom, 
        prenom, 
        TO_CHAR(date_embauche, 'YYYY/MM/DD'), 
        --NOW() - date_embauche,
        DATE_PART('year', AGE(NOW(), date_embauche)) AS "Années",
        DATE_PART('month', AGE(NOW(), date_embauche)) AS "Mois",
        DATE_PART('day', AGE(NOW(), date_embauche)) AS "Jour",
        DATE_PART('hour', AGE(NOW(), date_embauche)) AS "Heure",
        DATE_PART('minute', AGE(NOW(), date_embauche)) AS "Minute",
        DATE_PART('second', AGE(NOW(), date_embauche)) AS "Seconde"
    FROM employe;





