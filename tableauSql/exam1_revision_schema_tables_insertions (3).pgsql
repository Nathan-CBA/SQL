-- Schema pour dbdiagram

-- Table utilisateurs {
--   id integer [primary key]
--   prenom varchar
--   nom varchar 
-- }

-- Table photos {
--   id integer [primary key]
--   url varchar
--   photographe int [not null, ref: > utilisateurs.id]
--   categorie_id int [null, ref: > categories.id]
-- }

-- Table categories {
--   id integer [primary key]
--   nom varchar
-- }

-- Table likes {
--   id integer [primary key]
--   utilisateur_id int [not null, ref: > utilisateurs.id]
--   photo_id int [not null, ref: > photos.id]
-- }


-- Suppression des tables existantes dans l'ordre inverse des dépendances
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS photos;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS utilisateurs;

-- Création de la table utilisateurs
CREATE TABLE utilisateurs (
    id INTEGER PRIMARY KEY,
    prenom VARCHAR(50),
    nom VARCHAR(50)
);

-- Création de la table categories
CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    nom VARCHAR(50)
);

-- Création de la table photos
CREATE TABLE photos (
    id INTEGER PRIMARY KEY,
    url VARCHAR(255),
    photographe INTEGER NOT NULL,
    categorie_id INTEGER,
    CONSTRAINT fk_photographe FOREIGN KEY (photographe)
        REFERENCES utilisateurs(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_categorie FOREIGN KEY (categorie_id)
        REFERENCES categories(id)
        ON DELETE SET NULL
);

-- Création de la table likes
CREATE TABLE likes (
    id INTEGER PRIMARY KEY,
    utilisateur_id INTEGER NOT NULL,
    photo_id INTEGER NOT NULL,
    CONSTRAINT fk_like_utilisateur FOREIGN KEY (utilisateur_id)
        REFERENCES utilisateurs(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_like_photo FOREIGN KEY (photo_id)
        REFERENCES photos(id)
        ON DELETE CASCADE
);

-----------------------------------------------------------
-- Insertion des données
-----------------------------------------------------------

-- Insertion dans utilisateurs
INSERT INTO utilisateurs (id, prenom, nom) VALUES
    (1, 'Alice', 'Dupont'),
    (2, 'Bob', 'Martin'),
    (3, 'Charlie', 'Durand'),
    (4, 'David', 'Moreau'),
    (5, 'Eva', 'Leclerc'),
    (6, 'Franck', 'Giraud');

-- Insertion dans categories
INSERT INTO categories (id, nom) VALUES
    (1, 'Paysage'),
    (2, 'Portrait'),
    (3, 'Abstrait'),
    (4, 'Nature'),
    (5, 'Urbain'),
    (6, 'Noir et Blanc');

-- Insertion dans photos (certaines photos n'ont pas de catégorie associée, donc categorie_id = NULL)
INSERT INTO photos (id, url, photographe, categorie_id) VALUES
    (1, 'http://example.com/photo1.jpg', 1, 1),      -- Alice, Paysage
    (2, 'http://example.com/photo2.jpg', 2, NULL),     -- Bob, sans catégorie
    (3, 'http://example.com/photo3.jpg', 3, 2),         -- Charlie, Portrait
    (4, 'http://example.com/photo4.jpg', 1, NULL),     -- Alice, sans catégorie
    (5, 'http://example.com/photo5.jpg', 2, 3),         -- Bob, Abstrait
    (6, 'http://example.com/photo6.jpg', 4, 4),         -- David, Nature
    (7, 'http://example.com/photo7.jpg', 5, 5),         -- Eva, Urbain
    (8, 'http://example.com/photo8.jpg', 6, NULL),      -- Franck, sans catégorie
    (9, 'http://example.com/photo9.jpg', 1, 6),         -- Alice, Noir et Blanc
    (10, 'http://example.com/photo10.jpg', 3, 2),       -- Charlie, Portrait
    (11, 'http://example.com/photo11.jpg', 2, NULL),    -- Bob, sans catégorie
    (12, 'http://example.com/photo12.jpg', 4, 1),       -- David, Paysage
    (13, 'http://example.com/photo13.jpg', 5, 3),       -- Eva, Abstrait
    (14, 'http://example.com/photo14.jpg', 6, 5);       -- Franck, Urbain

-- Insertion dans likes
INSERT INTO likes (id, utilisateur_id, photo_id) VALUES
    (1, 1, 3),
    (2, 2, 1),
    (3, 3, 2),
    (4, 1, 5),
    (5, 2, 3),
    (6, 3, 6),
    (7, 3, 7),
    (8, 5, 8),
    (9, 1, 9),
    (10, 1, 10),
    (11, 2, 11),
    (12, 3, 12),
    (13, 2, 13),
    (14, 5, 14);
