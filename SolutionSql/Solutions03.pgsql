-- Série d'exercices 3
-- Requêtes avec opérateurs et fonctions mathématiques


-- 3.1
SELECT  2.0 * PI(), 
        PI(), 
        PI() / 2.0;

-- 3.2
SELECT  RANDOM() AS "[0, 1[",
        RANDOM() * 100.0 AS "[0, 100[",
        RANDOM() * 2.0 - 1.0 AS "[-1, 1[",
        RANDOM() * 1500.0 - 1000.0 AS "[-1000, 500[";

-- 3.3
SELECT  id AS "Identifiant",
        cx AS "Centre x",
        cy AS "Centre y",
        rayon AS "Rayon",
        2 * PI() * rayon AS "Périmètre",
        PI() * rayon^2.0 AS "Aire"
    FROM cercle;

-- 3.4
SELECT  id AS "Identifiant",
        x1 + (x2 - x1) / 2.0 AS "Point milieu x",
        y1 + (y2 - y1) / 2.0 AS "Point milieu y",
        (x2 + x1) / 2.0 AS "Point milieu x",
        (y2 + y1) / 2.0 AS "Point milieu y",
        (y2 - y1) / (x2 - x1) AS "Pente",
        SQRT((x2 - x1)^2 + (y2 - y1)^2) AS "Longueur"
    FROM ligne;

-- 3.5
SELECT  id AS "Identifiant",
        dx AS "Delta x",
        dy AS "Delta y",
        DEGREES(ATAN2(dy, dx)) AS "Orientation en degrés",
        |/(dx^2 + dy^2) AS "Longueur",
        SQRT(dx^2 + dy^2) = 1.0 AS "Unitaire?"
    FROM vecteur;

-- 3.6
-- 

