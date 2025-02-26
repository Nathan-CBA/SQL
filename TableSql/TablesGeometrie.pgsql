-- Cet exercice n'utilise pas les primitives 
-- géométriques disponibles avec PostgreSQL.

DROP TABLE IF EXISTS vecteur;
DROP TABLE IF EXISTS cercle;
DROP TABLE IF EXISTS ligne;


CREATE TABLE ligne (
    id      SERIAL,
    x1      DOUBLE PRECISION,
    y1      DOUBLE PRECISION,
    x2      DOUBLE PRECISION,
    y2      DOUBLE PRECISION
);

CREATE TABLE cercle (
    id      SERIAL,
    cx      DOUBLE PRECISION,
    cy      DOUBLE PRECISION,
    rayon   DOUBLE PRECISION
);

CREATE TABLE vecteur (
    id      SERIAL,
    dx      DOUBLE PRECISION,
    dy      DOUBLE PRECISION
);




INSERT INTO ligne(x1, y1, x2, y2)
    VALUES  (0.0, 0.0, 1.0, 0.0),
            (0.0, 0.0, 0.5, 0.5),
            (0.70710678118654752440084436210485, 0.70710678118654752440084436210485, 1.4142135623730950488016887242097, 1.4142135623730950488016887242097),
            (-1.0, 1.0, 1.0, -0.5);

INSERT INTO cercle(cx, cy, rayon)
    VALUES (0.0, 0.0, 10.0),
            (5.0, -5.0, 0.5641895835478),
            (1.0, 1.0, 1.0);

INSERT INTO vecteur(dx, dy)
    VALUES  (0.0, 0.0),
            (1.0, 0.0),
            (0.70710678118654752440084436210485, 0.70710678118654752440084436210485),
            (3.0, -4.0);

