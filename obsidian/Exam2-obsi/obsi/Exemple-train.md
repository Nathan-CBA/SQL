DROP TABLE IF EXISTS flotte_wagon CASCADE;
DROP TABLE IF EXISTS modele_wagon CASCADE;
DROP SEQUENCE IF EXISTS num_wagon;
DROP SEQUENCE IF EXISTS num_fabricant;

CREATE TABLE modele_wagon (
    id SERIAL,
    modele VARCHAR(32),

    CONSTRAINT pk_modele_wagon PRIMARY KEY (id)
);

CREATE TABLE flotte_wagon (
    id SERIAL,
    modele INTEGER NOT NULL,
    num_serie_fabricant VARCHAR(32) NOT NULL,
    num_serie_org VARCHAR(32) NOT NULL,
    date_creation TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_flotte_wagon PRIMARY KEY(id)
);

ALTER TABLE flotte_wagon
    ADD CONSTRAINT fk_wagon_modele
        FOREIGN KEY (modele) REFERENCES modele_wagon(id);
        
CREATE SEQUENCE num_wagon START 5000 INCREMENT 2;
CREATE SEQUENCE num_fabricant START 1000;

CREATE OR REPLACE FUNCTION genere_serie_fab(p_modele TEXT)
RETURNS TEXT
AS $-$
DECLARE
    v_serie TEXT;
BEGIN
    SELECT 'DX-' ||
        UPPER(SUBSTRING(p_modele, 1, 2)) || '-' ||
        TO_CHAR(CURRENT_DATE, 'YYDD') || '-' ||
        LPAD(nextval('num_fabricant')::TEXT, 6, '0')
    INTO v_serie;
    
    RETURN v_serie;
END;
$-$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION genere_num_serie_org_trigger()
RETURNS TRIGGER AS $-$
BEGIN
    NEW.num_serie_org := 'STM-' || LPAD(nextval('num_wagon')::TEXT, 8, '1');
    IF NEW.num_serie_org IS NULL THEN
        RAISE EXCEPTION 'Failed to generate num_serie_org';
    END IF;
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error generating num_serie_org';
END;
$- LANGUAGE plpgsql;

CREATE TRIGGER set_num_serie_org_on_insert
BEFORE INSERT ON flotte_wagon
FOR EACH ROW
EXECUTE PROCEDURE genere_num_serie_org_trigger();



CREATE OR REPLACE PROCEDURE inserer_wagons_proc(p_modele TEXT, p_nombre_insertions INTEGER)
AS $
DECLARE
    i INTEGER;
    modele_id INTEGER;
BEGIN
    SELECT id INTO modele_id
    FROM modele_wagon
    WHERE modele = p_modele;
    
    IF modele_id IS NULL THEN
        RAISE EXCEPTION 'Le modele "%" n''existe pas dans la table modele_wagon.', p_modele;
    ELSE
        FOR i IN 1..p_nombre_insertions LOOP
            INSERT INTO flotte_wagon (modele, num_serie_fabricant, num_serie_org)
            VALUES (modele_id, genere_serie_fab(p_modele), NULL);
    END LOOP;
    
        RAISE NOTICE '% wagon(s) de modèle "%" ont été inséré(s).', p_nombre_insertions, p_modele;
    END IF;
END;
$ LANGUAGE plpgsql;

INSERT INTO modele_wagon (modele) VALUES
    ('Bombardier'),
    ('Alstom'),
    ('Siemens');
    
    
TRUNCATE flotte_wagon;

CALL inserer_wagons_proc('Alstom', 10);

SELECT * FROM flotte_wagon;