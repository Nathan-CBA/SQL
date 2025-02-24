-- Série d'exercices 8
-- Création, suppression et modification de tables 


-- 8.1
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS pays;
CREATE TABLE pays (
    id      NUMERIC(3),
    nom     VARCHAR(64)     NOT NULL,

    CONSTRAINT pk_pays PRIMARY KEY (id)
);
-- ----------------------------------------------------------------------------



-- 8.2
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS employe;
CREATE TABLE employe (
    nas                     INTEGER,
    nom                     VARCHAR(64)     NOT NULL,
    prenom                  VARCHAR(64)     NOT NULL,
    date_embauche           DATE            NOT NULL,
    date_naissance          DATE,
    genre                   CHAR            NOT NULL, -- on devrait utiliser un ENUM ici - mais on démontre l'utilisation d'une contrainte de validation
    courriel_entreprise     VARCHAR(64)     NOT NULL,
    courriel_presonnel      VARCHAR(128),
    salaire_horaire         NUMERIC(5, 2)   NOT NULL,
    superviseur             INTEGER,

    CONSTRAINT pk_employe PRIMARY KEY (nas),

    CONSTRAINT cc_emp_nas CHECK(nas BETWEEN 100000000 AND 999999999),
    CONSTRAINT cc_emp_genre CHECK(genre IN ('f', 'h', 'x')),
    CONSTRAINT cc_emp_sal CHECK(salaire_horaire >= 20.0)
);

ALTER TABLE employe ADD CONSTRAINT fk_emp_sup FOREIGN KEY (superviseur) REFERENCES employe(nas);
-- ----------------------------------------------------------------------------



-- 8.3
-- ----------------------------------------------------------------------------
ALTER TABLE IF EXISTS programme DROP CONSTRAINT fk_prog_dep;
ALTER TABLE IF EXISTS etudiant DROP CONSTRAINT fk_etu_prog;

DROP TABLE IF EXISTS departement;
DROP TABLE IF EXISTS programme;
DROP TABLE IF EXISTS etudiant;

CREATE TABLE etudiant (
    id                      NUMERIC(4),
    nom                     VARCHAR(64)     NOT NULL,
    prenom                  VARCHAR(64)     NOT NULL,
    code_perm               CHAR(12)        NOT NULL,
    courriel                VARCHAR(128),
    programme               NUMERIC(2)      NOT NULL,
    date_inscr              DATE,

    CONSTRAINT pk_etu PRIMARY KEY (id),
    CONSTRAINT uc_etu_code_perm UNIQUE (code_perm),
    CONSTRAINT uc_etu_courriel UNIQUE (courriel)
);

CREATE TABLE programme (
    id                      NUMERIC(2),
    nom                     VARCHAR(32)     NOT NULL,
    sigle                   CHAR(3)         NOT NULL,
    departement             NUMERIC(2)      NOT NULL,

    CONSTRAINT pk_prog PRIMARY KEY (id),
    CONSTRAINT uc_prog_nom UNIQUE (nom),
    CONSTRAINT uc_prog_sigle UNIQUE (sigle)
);

CREATE TABLE departement (
    id                      NUMERIC(2),
    nom                     VARCHAR(32)     NOT NULL,

    CONSTRAINT pk_dep PRIMARY KEY (id),
    CONSTRAINT uc_dep_nom UNIQUE (nom)
);

ALTER TABLE etudiant ADD CONSTRAINT fk_etu_prog FOREIGN KEY (programme) REFERENCES programme(id);
ALTER TABLE programme ADD CONSTRAINT fk_prog_dep FOREIGN KEY (departement) REFERENCES departement(id);
-- ----------------------------------------------------------------------------



-- 8.4
-- ----------------------------------------------------------------------------
ALTER TABLE IF EXISTS programme DROP CONSTRAINT IF EXISTS fk_prog_etu;
ALTER TABLE IF EXISTS programme DROP CONSTRAINT IF EXISTS fk_prog_dep;
ALTER TABLE IF EXISTS etudiant DROP CONSTRAINT IF EXISTS fk_etu_prog;

DROP TABLE IF EXISTS departement;
DROP TABLE IF EXISTS programme;
DROP TABLE IF EXISTS etudiant;

CREATE TABLE etudiant (
    id                      NUMERIC(4),
    nom                     VARCHAR(64)     NOT NULL,
    prenom                  VARCHAR(64)     NOT NULL,
    code_perm               CHAR(12)        NOT NULL,
    courriel                VARCHAR(128),
    programme               NUMERIC(2)      NOT NULL,
    date_inscr              DATE,
    moyenne                 NUMERIC(4, 3),
    courriel_etu            VARCHAR(128)    NOT NULL,

    CONSTRAINT pk_etu PRIMARY KEY (id),
    CONSTRAINT uc_etu_code_perm UNIQUE (code_perm),
    CONSTRAINT uc_etu_courriel UNIQUE (courriel),
    CONSTRAINT cc_date_inscr CHECK(date_inscr BETWEEN '2010-01-01' AND '2019-12-31'),
    CONSTRAINT cc_moy CHECK(moyenne BETWEEN 0.00 AND 1.00),
    -- condition optionnelle pour ceux qui veulent explorer les regex
    CONSTRAINT cc_courriel_etu CHECK(courriel_etu ~* '^[a-zA-Z]+_[a-zA-Z]+_[0-9]{3}@monecole.qc.ca$')
    -- ------
);

CREATE TABLE programme (
    id                      NUMERIC(2),
    nom                     VARCHAR(32)     NOT NULL,
    sigle                   CHAR(3)         NOT NULL,
    departement             NUMERIC(2)      NOT NULL,
    representant            NUMERIC(4),

    CONSTRAINT pk_prog PRIMARY KEY (id),
    CONSTRAINT uc_prog_nom UNIQUE (nom),
    CONSTRAINT uc_prog_sigle UNIQUE (sigle)
);

CREATE TABLE departement (
    id                      NUMERIC(2),
    nom                     VARCHAR(32)     NOT NULL,

    CONSTRAINT pk_dep PRIMARY KEY (id),
    CONSTRAINT uc_dep_nom UNIQUE (nom)
);

ALTER TABLE etudiant 
    ADD CONSTRAINT fk_etu_prog FOREIGN KEY (programme) REFERENCES programme(id);
ALTER TABLE programme 
    ADD CONSTRAINT fk_prog_dep FOREIGN KEY (departement) REFERENCES departement(id),
    ADD CONSTRAINT fk_prog_etu FOREIGN KEY (representant) REFERENCES etudiant(id);
-- ----------------------------------------------------------------------------



-- 8.5
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS adresse;
CREATE TABLE adresse (
    id                  INTEGER,
    no_civique          VARCHAR(6)          NOT NULL,
    no_appartement      VARCHAR(6),
    rue                 VARCHAR(32)         NOT NULL,
    ville               VARCHAR(32)         NOT NULL,
    province            VARCHAR(32)         NOT NULL DEFAULT 'Québec',
    pays                VARCHAR(32)         NOT NULL DEFAULT 'Canada',
    code_postal         CHAR(6)             NOT NULL,

    CONSTRAINT pk_adresse PRIMARY KEY (id),
    CONSTRAINT uc_adresse UNIQUE (no_civique, no_appartement, rue, ville, province, pays, code_postal)
);

ALTER TABLE etudiant 
    ADD COLUMN adresse_cour INTEGER 
        CONSTRAINT fk_etu_adcour REFERENCES adresse(id) ON DELETE SET NULL,
    ADD COLUMN adresse_ref INTEGER 
        CONSTRAINT fk_etu_adref REFERENCES adresse(id) ON DELETE SET NULL;
ALTER TABLE departement 
    ADD COLUMN adresse_dep INTEGER NOT NULL 
        CONSTRAINT fk_dep_ad REFERENCES adresse(id) ON DELETE SET NULL;

ALTER TABLE departement ADD COLUMN secretariat CHAR(8) NOT NULL 
    CONSTRAINT cc_dep_sec CHECK(secretariat ~ '^[A-Z][0-9]{2}-[0-9]{4}$'); -- pour ceux qui veulent pratiquer les regex
-- ----------------------------------------------------------------------------


