DROP TABLE temp_employe;

CREATE TEMP TABLE temp_employe (
	nas					INT,				
	nom					VARCHAR(32), 	
	prenom				VARCHAR(32), 	
	genre				CHAR,			
	date_embauche		TEXT,			
	salaire				NUMERIC(5, 2),	
	departement			VARCHAR(64),			
	ville				VARCHAR(64),		
	superviseur			VARCHAR(64),				
	commission			NUMERIC(5)		
);


COPY temp_employe FROM '/temp/exercice_import_nettoyage.csv'
WITH (
 FORMAT CSV,
 HEADER TRUE,
 DELIMITER ',',
 ENCODING 'UTF8'
);

-- CREATE OR REPLACE FUNCTION clean_temp_date_embauche()
-- RETURNS VOID
-- AS $$
-- BEGIN
--     UPDATE temp_employe
--     SET date_embauche = TO_CHAR(TO_DATE(date_embauche, 'DD/MM/YYYY'), 'YYYY-MM-DD')
--     WHERE date_embauche IS NOT NULL;
-- END;
-- $$
-- LANGUAGE plpgsql;

SELECT clean_temp_date_embauche();

SELECT * FROM employe;


-- INSERT INTO employe(nas, nom, prenom, genre, date_embauche, salaire, departement, ville, superviseur, commission)
-- SELECT
-- 	t.nas, 
-- 	t.nom,
-- 	t.prenom,
-- 	t.genre,
-- 	to_date(t.date_embauche, 'YYYY-MM-DD'), 
-- 	t.salaire,
-- 	d.id,
-- 	t.ville,
-- 	e.nas AS superviseur, 
-- 	t.commission
-- FROM temp_employe AS t
-- JOIN departement AS d ON d.nom = t.departement
-- LEFT JOIN employe AS e ON (e.nom || ' ' || e.prenom) = t.superviseur;
	
chicken jonkey 

