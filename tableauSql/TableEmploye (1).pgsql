
DROP TABLE IF EXISTS employe;



CREATE TABLE employe (
	nas					INT				NOT NULL,
	nom					VARCHAR(32) 	NOT NULL,
	prenom				VARCHAR(32) 	NOT NULL,
	genre				CHAR			NOT NULL,
	date_embauche		DATE			NOT NULL,
	salaire				NUMERIC(5, 2)	NOT NULL,		-- money est disponible avec PostgreSQL
	departement			VARCHAR(16)		NULL,
	ville				VARCHAR(64)		NOT NULL,
	superviseur			INT				NULL,
	commission			NUMERIC(5)		NULL
);



INSERT INTO employe 
	VALUES	(111, 'Dupuis', 'Lancelot', 'h', '2000-01-28', '55.00', NULL, 'Montréal', NULL, 1500),
			(222, 'Bordeleau', 'Marina', 'f', '2000-05-12', '25.00', 'ventes', 'Montréal', 111, 2500),
			(333, 'Fontaine', 'Bella', 'f', '2000-05-12', '25.00', 'ventes', 'Montréal', 222, 0),
			(444, 'Lebel', 'Bob', 'h', '2000-09-13', '15.00', 'achats', 'Laval', 111, NULL),
			(555, 'Tangay', 'Gäétan', 'h', '2001-01-01', '30.50', 'r&d', 'Longueuil', 111, NULL),
			(666, 'Brochant', 'Pierre', 'h', '2001-12-25', '25.50', 'achats', 'Montréal', 222, NULL),
			(777, 'Brochant', 'Christine', 'f', '2002-02-14', '20.00', 'ventes', 'Montréal', 222, 3000),
			(888, 'Pignon', 'François', 'h', '2002-07-07', '13.13', 'r&d', 'Laval', 555, NULL),
			(999, 'Leblanc', 'Juste', 'h', '2002-07-08', '30.00', 'r&d', 'Montréal', 555, NULL),
			(123, 'Sasseur', 'Marlène', 'f', '2002-07-08', '15.00', 'administration', 'Longueuil', 111, NULL),
			(234, 'Bourassa', 'Alex', 'x', '2002-02-05', '19.00', 'achats', 'Longueuil', 222, NULL);

