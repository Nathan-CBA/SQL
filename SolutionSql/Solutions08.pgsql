
-- -- DDL
-- -- ----------------------------------------------------------------------------
-- ALTER TABLE IF EXISTS employe DROP CONSTRAINT IF EXISTS fk_emp_sup;
-- ALTER TABLE IF EXISTS employe DROP CONSTRAINT IF EXISTS fk_emp_dep;
-- ALTER TABLE IF EXISTS departement DROP CONSTRAINT IF EXISTS fk_dep_sup;
-- DROP TABLE IF EXISTS employe;
-- DROP TABLE IF EXISTS departement;




-- );

-- Create Table pays(
-- 	id			Numeric(3),
-- 	nom			Varchar(64) 		Not Null
	
-- 	CONSTRAINT pays PRIMARY KEY (id)
-- )

-- Create Table employe (
-- 	nas 				Integer, 
-- 	nom					Varchar(64) 	Not Null,
-- 	prenom				Varchar(64) 	Not Null,
-- 	date_embauche		Date			Not Null, 
-- 	date_naissance		Date,
-- 	genre				Char			Not Null, 
-- 	courriel_entreprise	Varchar(64) 	Not Null,
-- 	courriel_presonnel	Varchar(128) 	Not Null,
-- 	salaire_horaire 	Numeric(5,2)	Not Null,
-- 	superviseur			Int

	
-- 	CONSTRAINT employe PRIMARY KEY (nas),
-- 	Constraint employe CHECK( nas BETWEEN 100000000 AND 999999999),
-- 	Constraint employe CHECK( salaire_horaire >= 20.00),
-- 	Constraint employe CHECK( genre in ('f', 'h', 'x')),
	
-- )

-- ALTER TABLE employe ADD CONSTRAINT fk_emp_sup FOREIGN KEY (superviseur) REFERENCES employe(nas)

-- Create Table etudiant(
-- 	id				Numeric(4)		Not Null,
-- 	nom				Varchar(64) 	Not Null,
-- 	prenom			Varchar(64) 	Not Null,
-- 	code_perm		Char(12)		Not Null,
-- 	courriel		Varchar(64),
-- 	programme 	 	NUMERIC(2)		NOT Null,
-- 	date_inscr		Date
	
-- 	CONSTRAINT pk_etu PRIMARY KEY (id),
-- 	CONSTRAINT uc_etu_code_perm UNIQUE (code_perm),
-- 	CONSTRAINT uc_etu_cour UNIQUE (courriel)
-- )

-- Create Table programme(
-- 	id			Numeric(2),
-- 	nom			Varchar(32) NOT Null,
-- 	sigle		Char(3)		NOT null,
-- 	departement	NUMERIC(2)	NOT Null
	
-- 	CONSTRAINT pk_pro PRIMARY KEY (id),
-- 	CONSTRAINT uc_pro_nom UNIQUE (nom),
-- 	CONSTRAINT uc_pro_sigle UNIQUE (sigle)

	
-- -- DDL
-- -- ----------------------------------------------------------------------------
-- ALTER TABLE IF EXISTS employe DROP CONSTRAINT IF EXISTS fk_emp_sup;
-- ALTER TABLE IF EXISTS employe DROP CONSTRAINT IF EXISTS fk_emp_dep;
-- ALTER TABLE IF EXISTS departement DROP CONSTRAINT IF EXISTS fk_dep_sup;
-- DROP TABLE IF EXISTS employe;
-- DROP TABLE IF EXISTS departement;




-- );

-- Create Table pays(
-- 	id			Numeric(3),
-- 	nom			Varchar(64) 		Not Null
	
-- 	CONSTRAINT pays PRIMARY KEY (id)
-- )

-- Create Table employe (
-- 	nas 				Integer, 
-- 	nom					Varchar(64) 	Not Null,
-- 	prenom				Varchar(64) 	Not Null,
-- 	date_embauche		Date			Not Null, 
-- 	date_naissance		Date,
-- 	genre				Char			Not Null, 
-- 	courriel_entreprise	Varchar(64) 	Not Null,
-- 	courriel_presonnel	Varchar(128) 	Not Null,
-- 	salaire_horaire 	Numeric(5,2)	Not Null,
-- 	superviseur			Int

	
-- 	CONSTRAINT employe PRIMARY KEY (nas),
-- 	Constraint employe CHECK( nas BETWEEN 100000000 AND 999999999),
-- 	Constraint employe CHECK( salaire_horaire >= 20.00),
-- 	Constraint employe CHECK( genre in ('f', 'h', 'x')),
	
-- )

-- ALTER TABLE employe ADD CONSTRAINT fk_emp_sup FOREIGN KEY (superviseur) REFERENCES employe(nas)

-- Create Table etudiant(
-- 	id				Numeric(4)		Not Null,
-- 	nom				Varchar(64) 	Not Null,
-- 	prenom			Varchar(64) 	Not Null,
-- 	code_perm		Char(12)		Not Null,
-- 	courriel		Varchar(64),
-- 	programme 	 	NUMERIC(2)		NOT Null,
-- 	date_inscr		Date
	
-- 	CONSTRAINT pk_etu PRIMARY KEY (id),
-- 	CONSTRAINT uc_etu_code_perm UNIQUE (code_perm),
-- 	CONSTRAINT uc_etu_cour UNIQUE (courriel)
-- )

-- Create Table programme(
-- 	id			Numeric(2),
-- 	nom			Varchar(32) NOT Null,
-- 	sigle		Char(3)		NOT null,
-- 	departement	NUMERIC(2)	NOT Null
	
-- 	CONSTRAINT pk_pro PRIMARY KEY (id),
-- 	CONSTRAINT uc_pro_nom UNIQUE (nom),
-- 	CONSTRAINT uc_pro_sigle UNIQUE (sigle)

	
-- )

-- Create Table departement(
-- 	id		Numeric(2),
-- 	nom		Varchar(32) 	Not Null 

-- 	CONSTRAINT PK_depar_id PRIMARY KEY (id),
-- 	CONSTRAINT uc_depar_nom UNIQUE (nom)
-- )

-- ALTER TABLE etudiant ADD CONSTRAINT fk_etu_pro FOREIGN KEY (programme) REFERENCES programme(id)
-- ALTER TABLE programeme ADD CONSTRAINT fk_pro_depart FOREIGN KEY (departement) REFERENCES departement(id)

	

	





-- )

-- Create Table departement(
-- 	id		Numeric(2),
-- 	nom		Varchar(32) 	Not Null 

-- 	CONSTRAINT PK_depar_id PRIMARY KEY (id),
-- 	CONSTRAINT uc_depar_nom UNIQUE (nom)
-- )

-- ALTER TABLE etudiant ADD CONSTRAINT fk_etu_pro FOREIGN KEY (programme) REFERENCES programme(id)
-- ALTER TABLE programeme ADD CONSTRAINT fk_pro_depart FOREIGN KEY (departement) REFERENCES departement(id)

	

	




