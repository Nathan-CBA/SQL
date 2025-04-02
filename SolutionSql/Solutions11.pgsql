-- Série d'exercices 11
-- Jointures 


-- 11.1
-- a)
SELECT  emp.nom AS "Nom de l'employé", 
        emp.prenom AS "Prénom de l'employé",
        dep.nom AS "Nom du département"
    FROM employe AS emp, departement as dep
    WHERE emp.departement = dep.id;
-- b)
SELECT  emp.nom AS "Nom de l'employé", 
        emp.prenom AS "Prénom de l'employé",
        dep.nom AS "Nom du département"
    FROM employe AS emp
        INNER JOIN departement as dep
            ON emp.departement = dep.id;


-- 11.2
-- a)
SELECT  emp.nom AS "Nom de l'employé", 
        emp.prenom AS "Prénom de l'employé",
        emp.nas AS "NAS de l'employé",
        emp.ville AS "Ville où réside l'employé",
        dep.ville AS "Ville où travail l'employé"
    FROM employe AS emp, departement as dep
    WHERE emp.departement = dep.id;
-- b)
SELECT  emp.nom AS "Nom de l'employé", 
        emp.prenom AS "Prénom de l'employé",
        emp.nas AS "NAS de l'employé",
        emp.ville AS "Ville où réside l'employé",
        dep.ville AS "Ville où travail l'employé"
    FROM employe AS emp
        INNER JOIN departement as dep
            ON emp.departement = dep.id;


-- 11.3
SELECT  emp.nom AS "Nom de l'employé", 
        emp.prenom AS "Prénom de l'employé",
        emp.nas AS "NAS de l'employé",
        emp.ville AS "Ville où réside l'employé",
        dep.ville AS "Ville où travail l'employé"
    FROM employe AS emp
        INNER JOIN departement as dep
            ON emp.departement = dep.id
    WHERE emp.ville <> dep.ville
    ORDER BY emp.nom, emp.prenom, emp.ville;


-- 11.4
SELECT *
   FROM employe, departement
   WHERE employe.departement = departement.id;

-- inverse l'ordre des colonnes : table departement d'abord.
SELECT *
   FROM departement, employe
   WHERE employe.departement = departement.id;

-- aucun impact.
SELECT *
   FROM employe, departement
   WHERE departement.id = employe.departement;


-- 11.5
-- a)
SELECT  emp.prenom || ' ' || emp.nom AS "Nom de l'employé",
        sup.prenom || ' ' || sup.nom AS "Nom du superviseur"
    FROM employe emp -- AS emp
        INNER JOIN employe sup -- AS sup
            ON emp.superviseur = sup.nas
    ORDER BY emp.date_embauche;
-- b)
SELECT  emp.prenom || ' ' || emp.nom AS "Nom de l'employé",
        sup.prenom || ' ' || sup.nom AS "Nom du superviseur"
    FROM employe AS emp
        LEFT OUTER JOIN employe AS sup
            ON emp.superviseur = sup.nas
    ORDER BY "Nom de l'employé";
-- c) 
SELECT  sup.prenom || ' ' || sup.nom AS "Nom du superviseur",
        emp.prenom || ' ' || emp.nom AS "Nom du supervisé"
    FROM employe AS emp
        INNER JOIN employe AS sup
            ON emp.superviseur = sup.nas
    ORDER BY "Nom du superviseur";
-- d) 
SELECT  sup.prenom || ' ' || sup.nom AS "Nom du superviseur",
        emp.prenom || ' ' || emp.nom AS "Nom du supervisé"
    FROM employe AS emp
        RIGHT JOIN employe AS sup
            ON emp.superviseur = sup.nas
    ORDER BY "Nom du superviseur";
-- e) 
SELECT  COALESCE(emp.prenom || ' ' || emp.nom, '- ne supervise pas -') AS "Employé en tant que supervisé",
        COALESCE(sup.prenom || ' ' || sup.nom, '* Grand patron') AS "Employé en tant que superviseur"
    FROM employe AS emp
        FULL JOIN employe AS sup
            ON emp.superviseur = sup.nas
    ORDER BY "Employé en tant que supervisé";


-- 11.6
SELECT emp.nom, emp.prenom, dep.ville
    FROM employe AS emp
        INNER JOIN departement AS dep
            ON emp.departement = dep.id
    WHERE dep.ville <> 'Montréal'
    ORDER BY emp.nom, emp.prenom;


-- 11.7
SELECT emp.nom, emp.prenom, sup.nom, sup.prenom
    FROM employe AS emp
        INNER JOIN employe AS sup
            ON emp.superviseur = sup.nas
    WHERE emp.departement = sup.departement;


-- 11.8
SELECT  emp.prenom || ' ' || emp.nom AS "Employé", 
        sup.prenom || ' ' || sup.nom AS "Superviseur", 
        dep.nom AS "Département"
    FROM employe AS emp 
        INNER JOIN employe AS sup
            ON emp.superviseur = sup.nas
        INNER JOIN departement AS dep
            ON emp.departement = dep.id
    WHERE emp.departement = sup.departement;


-- 11.9
SELECT  emp.prenom || ' ' || emp.nom AS "Employé", 
        depemp.nom AS "Département de l'employé",
        sup.prenom || ' ' || sup.nom AS "Superviseur", 
        depsup.nom AS "Département du superviseur"
    FROM employe AS emp 
        INNER JOIN employe AS sup
            ON emp.superviseur = sup.nas
        INNER JOIN departement AS depemp
            ON emp.departement = depemp.id
        INNER JOIN departement AS depsup
            ON sup.departement = depsup.id
    WHERE emp.departement <> sup.departement;


-- 11.10
SELECT  emp2.prenom || ' ' || emp2.nom ||
        ' fait ' || 
        emp2.salaire - emp1.salaire || 
        '$ de plus que ' ||
        emp1.prenom || ' ' || emp1.nom || '.' AS "Différence salariale"
    FROM employe AS emp1
        CROSS JOIN employe AS emp2
    WHERE emp2.salaire > emp1.salaire
    ORDER BY emp2.salaire - emp1.salaire DESC;


-- 11.11
SELECT  emp.prenom || ' ' || emp.nom AS "Employé",
        sup.prenom || ' ' || sup.nom AS "Superviseur", 
        supsup.prenom || ' ' || supsup.nom AS "Superviseur du superviseur"
    FROM employe AS emp 
        INNER JOIN employe AS sup
            ON emp.superviseur = sup.nas
        INNER JOIN employe AS supsup
            ON sup.superviseur = supsup.nas
    ORDER BY "Employé";


-- 11.12
SELECT  emp.prenom || ' ' || emp.nom AS "Employé",
        emp.ville AS "Ville résidence employé",
        sup.prenom || ' ' || sup.nom AS "Superviseur", 
        depsup.ville AS "Ville de travail du sup.",
        supsup.prenom || ' ' || supsup.nom AS "Superviseur du superviseur",
        depsupsup.ville AS "Ville de travail du sup. sup."
    FROM employe AS emp 
        INNER JOIN employe AS sup
            ON emp.superviseur = sup.nas
        INNER JOIN employe AS supsup
            ON sup.superviseur = supsup.nas
        INNER JOIN departement AS depsup
            ON sup.departement = depsup.id
        INNER JOIN departement AS depsupsup
            ON supsup.departement = depsupsup.id
    ORDER BY "Employé";


-- 11.13
SELECT  emp.prenom || ' ' || emp.nom AS "Employé",
        dep.nom AS "Département",
        emp.ville AS "Ville"
    FROM employe AS emp
        INNER JOIN departement as dep
            ON emp.ville = dep.ville
    ORDER BY emp.ville;


-- 11.14
SELECT  dep.nom AS "Département",
        emp.prenom || ' ' || emp.nom AS "Superviseur",
        emp.ville AS "Ville où habite le superviseur"
    FROM departement AS dep
        INNER JOIN employe as emp
            ON dep.superviseur = emp.nas
    ORDER BY dep.nom;


-- 11.15
SELECT  emp.prenom || ' ' || emp.nom AS "Employé",
        supemp.prenom || ' ' || supemp.nom AS "Superviseur de l'employé",
        dep.nom AS "Département",
        supdep.prenom || ' ' || supdep.nom AS "Superviseur du département"
    FROM employe AS emp
        INNER JOIN employe as supemp
            ON emp.superviseur = supemp.nas
        INNER JOIN departement as dep
            ON emp.departement = dep.id
        INNER JOIN employe as supdep
            ON dep.superviseur = supdep.nas
    ORDER BY dep.nom;


-- 11.16
SELECT departement.nom AS "Département", COUNT(*) AS "Nombre d'employés"
    FROM employe
        INNER JOIN departement
            ON employe.departement = departement.id
    GROUP BY departement.nom;


-- 11.17
SELECT  sup.prenom || ' ' || sup.nom AS "Employé", 
        COUNT(emp.nom) AS "Nombre d'employé supervisé"
    FROM employe AS emp
        RIGHT JOIN employe AS sup
            ON emp.superviseur = sup.nas
    GROUP BY sup.nom, sup.prenom
    ORDER BY "Nombre d'employé supervisé", sup.nom, sup.prenom;




SELECT * FROM employe; 
SELECT * FROM departement;

