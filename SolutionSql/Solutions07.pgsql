-- Série d'exercices 7
-- Requêtes simples diverses 


-- 7.1
SELECT nom AS "Nom", prenom AS "Prénom"
    FROM employe
    WHERE superviseur = (SELECT nas FROM employe WHERE nom = 'Dupuis' AND prenom = 'Lancelot');

-- 7.2
SELECT nom AS "Nom", prenom AS "Prénom"
    FROM employe
    WHERE departement IN (SELECT id FROM departement WHERE ville IN ('Montréal', 'Longueuil'));

-- 7.3
-- a)
SELECT nom AS "Nom", prenom AS "Prénom"
    FROM employe
    WHERE departement <> (SELECT id FROM departement WHERE nom = 'Ventes')
    ORDER BY nom; 
-- b)
SELECT nom AS "Nom", prenom AS "Prénom"
    FROM employe
    WHERE departement IN (SELECT id FROM departement WHERE nom <> 'Ventes')
    ORDER BY nom;

-- 7.4
-- a)
SELECT nom AS "Nom", prenom AS "Prénom"
    FROM employe
    WHERE   departement = (SELECT id FROM departement WHERE nom = 'Ventes') OR
            departement = (SELECT id FROM departement WHERE nom = 'Achats')
    ORDER BY nom DESC; 
-- b)
SELECT nom AS "Nom", prenom AS "Prénom"
    FROM employe
    WHERE departement IN (SELECT id FROM departement WHERE nom IN ('Ventes', 'Achats'))
    ORDER BY nom DESC; 

-- 7.5
SELECT nom AS "Nom", prenom AS "Prénom", ville AS "Ville"
    FROM employe
    WHERE departement IN (SELECT id FROM departement WHERE ville = 'Montréal')
    ORDER BY ville;

-- 7.6
SELECT nom AS "Nom de département", ville AS "Ville"
    FROM departement
    WHERE ville ILIKE '%o%';

-- 7.7
SELECT nas AS "Numéro d'assurance social", nom AS "Nom", prenom AS "Prénom"
    FROM employe
    WHERE prenom LIKE '__r%';

-- 7.8
SELECT nom AS "Nom de département"
    FROM departement
    WHERE superviseur = (SELECT nas FROM employe WHERE nom = 'Dupuis' AND prenom = 'Lancelot');

-- 7.9
SELECT nom AS "Nom", prenom AS "Prénom", TO_CHAR(date_embauche, 'DD-MM-YY') AS "Date d'embauche"
    FROM employe
    WHERE EXTRACT(MONTH FROM date_embauche) = 7 AND prenom LIKE '%e%'
    ORDER BY date_embauche, nom, prenom;

-- 7.10
SELECT nom AS "Nom", prenom AS "Prénom", salaire * 32 AS "Salaire hebdomadaire", commission AS "Commission"
    FROM employe
    WHERE commission IS NOT NULL AND salaire * 32 > commission
    ORDER BY salaire DESC, nom ASC, prenom ASC;

-- 7.11
SELECT nom AS "Nom", prenom AS "Prénom"
    FROM employe
    WHERE commission IS NOT NULL AND EXTRACT(YEAR FROM date_embauche) = 2000;

-- 7.12
SELECT  nom AS "Nom", 
        prenom AS "Prénom", 
        salaire * 32 AS "Salaire horaire", 
        COALESCE(commission, 0) AS "Commission reçue", 
        date_embauche AS "Date d'embauche"
    FROM employe
    WHERE   departement = (SELECT id FROM departement WHERE nom = 'Ventes') AND
            salaire * 32 * 2 > COALESCE(commission, 0) / 2 AND
            date_embauche > '2000-04-01' AND date_embauche < '2002-04-01'; 

-- 7.13
SELECT  nom AS "Nom", 
        prenom AS "Prénom", 
        TO_CHAR(date_embauche, 'DD/MM/YYYY') AS "Date d'embauche", 
        departement AS "Numéro de département"
    FROM employe
    WHERE superviseur = (SELECT nas FROM employe WHERE nom = 'Dupuis' AND prenom = 'Lancelot')
    ORDER BY date_embauche DESC;

-- 7.14
SELECT  nom AS "Nom", 
        prenom AS "Prénom", 
        salaire * 32 + COALESCE(commission, 0) AS "Salaire hebdomadaire total", 
        CURRENT_DATE - date_embauche AS "Nomre de jours écoulés"
    FROM employe
    WHERE date_embauche > '2000-04-01' AND date_embauche < '2002-04-01'
    ORDER BY "Nomre de jours écoulés" DESC; 

-- 7.15
SELECT nom AS "Nom", prenom AS "Prénom"
    FROM employe
    WHERE   departement IN (SELECT id FROM departement WHERE ville IN ('Montréal', 'Laval')) AND
            superviseur <> (SELECT nas FROM employe WHERE nom = 'Dupuis' AND prenom = 'Lancelot') AND
            superviseur <> (SELECT nas FROM employe WHERE nom = 'Bordeleau' AND prenom = 'Marina');

-- 7.16
SELECT  prenom || ' ' || nom AS "Employé", 
        'gagne' AS "a un", 
        salaire * 32 + COALESCE(commission, 0) AS "gain total ($)"
    FROM employe;

-- 7.17
-- a)
SELECT nom || ', ' || prenom AS "Employé", salaire * 32 * 52 + COALESCE(commission, 0) * 12 AS "Revenu annuel"
    FROM employe
    ORDER BY "Revenu annuel" DESC
    LIMIT 3 OFFSET 0;
-- b)
SELECT nom || ', ' || prenom AS "Employé", salaire * 32 * 52 + COALESCE(commission, 0) * 12 AS "Revenu annuel"
    FROM employe
    ORDER BY "Revenu annuel" ASC
    LIMIT 3 OFFSET 0;
-- une alternative à b puisqu'aucun ordre n'est demandé
SELECT nom || ', ' || prenom AS "Employé", salaire * 32 * 52 + COALESCE(commission, 0) * 12 AS "Revenu annuel"
    FROM employe
    ORDER BY "Revenu annuel" DESC
    LIMIT 3 OFFSET 8; 
    -- attention, cette approche suppose qu'on connaît la taille de la table 
    -- nous verrons bientôt qu'une simple requête permet d'avoir cette information

