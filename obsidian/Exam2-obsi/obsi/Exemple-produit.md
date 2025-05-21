CREATE TABLE produit (
    id SERIAL,
    nom VARCHAR(32),
    prix DOUBLE PRECISION,

    CONSTRAINT pk_produit PRIMARY KEY (id)
);

CREATE TABLE historique_prix_produit(
    id SERIAL,
    produit_id INTEGER NOT NULL,
    ancien_prix DOUBLE PRECISION,
    nouveau_prix DOUBLE PRECISION,
    date_modification TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_histo_prix PRIMARY KEY(id)
);

ALTER TABLE historique_prix_produit
    ADD CONSTRAINT fk_histo_prix
        FOREIGN KEY (produit_id) REFERENCES produit(id);

INSERT INTO produit (nom, prix) VALUES
    ('sac', 20),
    ('valise', 45),
    ('porte-monnaie', 10),
    ('boîte', 5);
    
CREATE OR REPLACE FUNCTION log_prix_produit_changes()
RETURNS TRIGGER AS $
BEGIN
    IF OLD.prix IS DISTINCT FROM NEW.prix THEN
        INSERT INTO historique_prix_produit(produit_id, ancien_prix, nouveau_prix)
        VALUES (OLD.id, OLD.prix, NEW.prix);
    END IF;
    RETURN NEW;
END;
$ LANGUAGE plpgsql;

CREATE TRIGGER log_produit_prix_update
BEFORE UPDATE OF prix ON produit
FOR EACH ROW
EXECUTE FUNCTION log_prix_produit_changes();

SELECT * FROM produit;
SELECT * FROM historique_prix_produit;

UPDATE produit
SET prix = 21 WHERE nom = 'sac';