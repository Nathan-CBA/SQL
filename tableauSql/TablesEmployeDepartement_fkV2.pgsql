-- Suppression des tables si elles existent déjà
DROP TABLE IF EXISTS employe_avantage;
DROP TABLE IF EXISTS avantages;
DROP TABLE IF EXISTS participation;
DROP TABLE IF EXISTS projet;
DROP TABLE IF EXISTS employe CASCADE;
DROP TABLE IF EXISTS departement CASCADE;

-- Création des tables
CREATE TABLE departement (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(32) NOT NULL,
    ville VARCHAR(64) NOT NULL,
    superviseur INTEGER NULL
);

CREATE TABLE employe (
    nas INT PRIMARY KEY,
    nom VARCHAR(32) NOT NULL,
    prenom VARCHAR(32) NOT NULL,
    genre CHAR NOT NULL CHECK (genre IN ('f', 'h')),
    date_embauche DATE NOT NULL DEFAULT CURRENT_DATE CHECK(date_embauche >= '2000-01-01'),
    salaire NUMERIC(5,2) NOT NULL DEFAULT 20.0 CHECK(salaire >= 12.5),
    departement INTEGER NULL,  -- NULL autorisé pour les employés sans département
    ville VARCHAR(64) NOT NULL,
    superviseur INT NULL DEFAULT NULL,
    commission NUMERIC(5) NULL DEFAULT NULL
);

CREATE TABLE projet (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(64) NOT NULL,
    budget NUMERIC(10,2) NOT NULL DEFAULT 10000
);

CREATE TABLE participation (
    employe_nas INT NOT NULL,
    projet_id INT NOT NULL,
    role VARCHAR(32) NOT NULL DEFAULT 'Membre',
    heures_travaillees INT NOT NULL DEFAULT 0,
    PRIMARY KEY (employe_nas, projet_id)
);

CREATE TABLE avantages (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(64) NOT NULL
);

CREATE TABLE employe_avantage (
    employe_nas INT NOT NULL,
    avantage_id INT NOT NULL,
    PRIMARY KEY (employe_nas, avantage_id)
);

-- Désactivation temporaire des triggers pour insertion rapide
ALTER TABLE departement DISABLE TRIGGER ALL;
ALTER TABLE employe DISABLE TRIGGER ALL;
ALTER TABLE projet DISABLE TRIGGER ALL;
ALTER TABLE participation DISABLE TRIGGER ALL;
ALTER TABLE avantages DISABLE TRIGGER ALL;
ALTER TABLE employe_avantage DISABLE TRIGGER ALL;

-- Insertion des employés (ajout de Bertrand Maxime, sans département et sans projet)
INSERT INTO employe 
VALUES  
    (111, 'Dupuis', 'Lancelot', 'h', '2000-01-28', 55.00, 1, 'Montréal', NULL, 1500),
    (222, 'Bordeleau', 'Marina', 'f', '2000-05-12', 25.00, 1, 'Montréal', 111, 2500),
    (333, 'Fontaine', 'Bella', 'f', '2000-05-12', 25.00, NULL, 'Montréal', NULL, 0), -- Pas de département
    (444, 'Lebel', 'Bob', 'h', '2000-09-13', 15.00, 2, 'Laval', NULL, NULL),
    (555, 'Tangay', 'Gäétan', 'h', '2001-01-01', 30.50, 4, 'Longueuil', NULL, NULL),
    (666, 'Brochant', 'Pierre', 'h', '2001-12-25', 25.50, NULL, 'Laval', NULL, NULL), -- Pas de département
    (777, 'Brochant', 'Christine', 'f', '2002-02-14', 20.00, 1, 'Laval', NULL, 3000),
    (888, 'Pignon', 'François', 'h', '2002-07-07', 13.13, 4, 'Laval', NULL, NULL),
    (999, 'Leblanc', 'Juste', 'h', '2002-07-08', 30.00, 4, 'Montréal', 555, NULL),
    (123, 'Sasseur', 'Marlène', 'f', '2002-07-08', 15.00, 3, 'Longueuil', NULL, NULL),
    (3030, 'Bertrand', 'Maxime', 'h', '2003-03-15', 18.00, NULL, 'Québec', NULL, NULL), -- Pas de département, pas de projet
    (4040, 'Gagnon', 'Sophie', 'f', '2003-06-21', 21.00, 5, 'Québec', NULL, NULL),
    (5050, 'Pelletier', 'Émile', 'h', '2004-09-10', 28.75, NULL, 'Trois-Rivières', NULL, NULL), -- Pas de département
    (6060, 'Lefebvre', 'Camille', 'f', '2005-11-30', 23.50, 6, 'Trois-Rivières', NULL, NULL),
    (7070, 'Tremblay', 'Lucas', 'h', '2006-04-17', 26.00, NULL, 'Sherbrooke', NULL, NULL), -- Pas de département
    (8080, 'Moreau', 'Chloé', 'f', '2007-08-24', 19.80, 7, 'Sherbrooke', NULL, NULL),
    (9090, 'Roy', 'David', 'h', '2008-12-12', 22.00, NULL, 'Gatineau', NULL, NULL); -- Pas de département

-- Insertion des départements (les 4 premiers avec un superviseur)
INSERT INTO departement(nom, ville, superviseur)
VALUES 
    ('Ventes', 'Montréal', 111),  -- Superviseur : Dupuis Lancelot
    ('Achats', 'Laval', 222),  -- Superviseur : Bordeleau Marina
    ('Administration', 'Longueuil', 333),  -- Superviseur : Fontaine Bella
    ('Recherche et développement', 'Montréal', 444),  -- Superviseur : Lebel Bob
    ('Informatique', 'Québec', NULL), -- Aucun employé, aucun superviseur
    ('Logistique', 'Trois-Rivières', NULL), -- Aucun employé, aucun superviseur
    ('Juridique', 'Sherbrooke', NULL); -- Aucun employé, aucun superviseur

-- Insertion des projets
INSERT INTO projet (nom, budget) VALUES 
    ('Développement Web', 50000),
    ('Refonte Système', 75000),
    ('Innovation IA', 120000),
    ('Expansion Marché', 30000);

-- Insertion des participations (quel employé travaille sur quel projet)
INSERT INTO participation (employe_nas, projet_id, role, heures_travaillees) VALUES
    (111, 1, 'Développeur', 120),
    (111, 2, 'Architecte logiciel', 130),
    (111, 3, 'Lead Développeur', 140),
    (111, 4, 'Consultant technique', 150),
    (222, 1, 'Chef de projet', 200),
    (222, 3, 'Chef de projet', 180),
    (333, 2, 'Analyste', 80),
    (444, 3, 'Ingénieur IA', 150),
    (555, 4, 'Consultant', 100),
    (666, 2, 'Développeur', 160),
    (777, 1, 'Designer', 140),
    (888, 3, 'Chercheur', 110);


-- Insertion des avantages sociaux
INSERT INTO avantages (nom) VALUES 
    ('Assurance Santé'),
    ('Prime de Performance'),
    ('Transport Remboursé'),
    ('Formation Continue');

-- Insertion des relations Employé ↔ Avantages
INSERT INTO employe_avantage (employe_nas, avantage_id) VALUES
    (111, 1),
    (111, 2),
    (222, 1),
    (333, 3),
    (444, 1),
    (555, 4),
    (666, 2),
    (777, 3),
    (888, 4);

-- Réactivation des triggers après insertion
ALTER TABLE departement ENABLE TRIGGER ALL;
ALTER TABLE employe ENABLE TRIGGER ALL;
ALTER TABLE projet ENABLE TRIGGER ALL;
ALTER TABLE participation ENABLE TRIGGER ALL;
ALTER TABLE avantages ENABLE TRIGGER ALL;
ALTER TABLE employe_avantage ENABLE TRIGGER ALL;

-- Ajout des contraintes de clés étrangères après l'insertion des données
ALTER TABLE departement
    ADD CONSTRAINT fk_dep_sup FOREIGN KEY (superviseur) REFERENCES employe(nas);

ALTER TABLE employe 
    ADD CONSTRAINT fk_emp_dep FOREIGN KEY (departement) REFERENCES departement(id),
    ADD CONSTRAINT fk_emp_sup FOREIGN KEY (superviseur) REFERENCES employe(nas);

ALTER TABLE participation
    ADD CONSTRAINT fk_part_emp FOREIGN KEY (employe_nas) REFERENCES employe(nas) ON DELETE CASCADE,
    ADD CONSTRAINT fk_part_proj FOREIGN KEY (projet_id) REFERENCES projet(id) ON DELETE CASCADE;

ALTER TABLE employe_avantage
    ADD CONSTRAINT fk_emp_av FOREIGN KEY (employe_nas) REFERENCES employe(nas) ON DELETE CASCADE,
    ADD CONSTRAINT fk_av_emp FOREIGN KEY (avantage_id) REFERENCES avantages(id) ON DELETE CASCADE;

-- Vérification des données
-- SELECT * FROM departement;
-- SELECT * FROM employe;
-- SELECT * FROM projet;
-- SELECT * FROM participation;
-- SELECT * FROM avantages;
-- SELECT * FROM employe_avantage;
