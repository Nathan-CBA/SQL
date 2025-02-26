
DROP TABLE IF EXISTS employe;
DROP TABLE IF EXISTS departement;



CREATE TABLE departement (
	id					SERIAL			NOT NULL,
	nom					VARCHAR(32)		NOT NULL,
	ville				VARCHAR(64)		NOT NULL,
	superviseur			INTEGER			NULL
);

CREATE TABLE employe (
	nas					INT				NOT NULL,
	nom					VARCHAR(32) 	NOT NULL,
	prenom				VARCHAR(32) 	NOT NULL,
	genre				CHAR			NOT NULL,
	date_embauche		DATE			NOT NULL,
	salaire				NUMERIC(5, 2)	NOT NULL,		-- money est disponible avec PostgreSQL
	departement			INTEGER			NOT NULL,
	ville				VARCHAR(64)		NOT NULL,
	superviseur			INT				NULL,
	commission			NUMERIC(5)		NULL
);


INSERT INTO departement(nom, ville, superviseur)
	VALUES 	('Ventes', 'Montréal', 222),
			('Achats', 'Laval', 222),
			('Administration', 'Longueuil', 123),
			('Recherche et développement', 'Montréal', 555);


INSERT INTO employe 
	VALUES	(111, 'Dupuis', 'Lancelot', 'h', '2000-01-28', '55.00', (SELECT id FROM departement WHERE nom = 'Ventes'), 'Montréal', NULL, 1500),
			(222, 'Bordeleau', 'Marina', 'f', '2000-05-12', '25.00', (SELECT id FROM departement WHERE nom = 'Ventes'), 'Montréal', 111, 2500),
			(333, 'Fontaine', 'Bella', 'f', '2000-05-12', '25.00', (SELECT id FROM departement WHERE nom = 'Ventes'), 'Montréal', 222, 0),
			(444, 'Lebel', 'Bob', 'h', '2000-09-13', '15.00', (SELECT id FROM departement WHERE nom = 'Achats'), 'Laval', 111, NULL),
			(555, 'Tangay', 'Gäétan', 'h', '2001-01-01', '30.50', (SELECT id FROM departement WHERE nom = 'Recherche et développement'), 'Longueuil', 111, NULL),
			(666, 'Brochant', 'Pierre', 'h', '2001-12-25', '25.50', (SELECT id FROM departement WHERE nom = 'Achats'), 'Laval', 222, NULL),
			(777, 'Brochant', 'Christine', 'f', '2002-02-14', '20.00', (SELECT id FROM departement WHERE nom = 'Ventes'), 'Laval', 222, 3000),
			(888, 'Pignon', 'François', 'h', '2002-07-07', '13.13', (SELECT id FROM departement WHERE nom = 'Recherche et développement'), 'Laval', 555, NULL),
			(999, 'Leblanc', 'Juste', 'h', '2002-07-08', '30.00', (SELECT id FROM departement WHERE nom = 'Recherche et développement'), 'Montréal', 555, NULL),
			(123, 'Sasseur', 'Marlène', 'f', '2002-07-08', '15.00', (SELECT id FROM departement WHERE nom = 'Administration'), 'Longueuil', 111, NULL);


-- SELECT * FROM departement;
-- SELECT * FROM employe;


