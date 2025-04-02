# DDL - CREATE

La commande `CREATE` permet de créer de nouveaux objets dans la base de données PostgreSQL. Cette note détaille la création des objets les plus couramment utilisés.

## Règles de nommage des objets

Les noms d'objets dans PostgreSQL doivent respecter ces règles :
- Maximum 63 caractères (les noms plus longs sont tronqués)
- Doivent commencer par une lettre (a-z) ou un underscore (_)
- Peuvent contenir des lettres, chiffres, underscores et signes dollar
- Ne sont pas sensibles à la casse par défaut (sauf si entre guillemets)
- Ne doivent pas être des mots réservés

```sql
-- Identifiants standards
CREATE TABLE employe (...);

-- Identifiants avec guillemets (préserve la casse et permet caractères spéciaux)
CREATE TABLE "Employé" (...);
CREATE TABLE "SELECT" (...);  -- Utilise un mot réservé comme nom
```

## CREATE DATABASE

Crée une nouvelle base de données.

```sql
CREATE DATABASE nom_database
    [OWNER = role_name]
    [TEMPLATE = template]
    [ENCODING = encoding]
    [LC_COLLATE = locale]
    [LC_CTYPE = locale]
    [TABLESPACE = tablespace_name]
    [CONNECTION LIMIT = connlimit];
```

Exemple :
```sql
CREATE DATABASE gestion_employes
    OWNER = admin
    ENCODING = 'UTF8'
    LC_COLLATE = 'fr_CA.UTF-8'
    LC_CTYPE = 'fr_CA.UTF-8'
    CONNECTION LIMIT = 100;
```

## CREATE SCHEMA

Crée un nouveau schéma (espace de noms) dans la base de données courante.

```sql
CREATE SCHEMA [IF NOT EXISTS] schema_name [AUTHORIZATION role_name];
```

Exemple :
```sql
CREATE SCHEMA IF NOT EXISTS comptabilite AUTHORIZATION admin;
CREATE SCHEMA ressources_humaines;
```

## CREATE TABLE

Crée une nouvelle table.

```sql
CREATE TABLE [IF NOT EXISTS] table_name (
    column_name data_type [constraints],
    [...]
    [table_constraints]
);
```

Exemple :
```sql
CREATE TABLE employe (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    date_naissance DATE,
    departement INTEGER REFERENCES departement(id),
    salaire NUMERIC(10,2) CHECK(salaire >= 0),
    CONSTRAINT uc_emp_nom_prenom UNIQUE(nom, prenom)
);
```

## CREATE TYPE

### Type énuméré

```sql
CREATE TYPE type_name AS ENUM ('valeur1', 'valeur2', ...);
```

Exemple :
```sql
CREATE TYPE jour_semaine AS ENUM (
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
);
```

### Type domaine

```sql
CREATE DOMAIN domain_name AS data_type
    [DEFAULT expression]
    [constraints];
```

Exemple :
```sql
CREATE DOMAIN email AS TEXT
    CHECK(VALUE ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

CREATE DOMAIN code_postal_ca AS CHAR(7)
    CHECK(VALUE ~ '[A-Z][0-9][A-Z] [0-9][A-Z][0-9]');
```

## CREATE SEQUENCE

Crée un générateur de séquence numérique.

```sql
CREATE SEQUENCE [IF NOT EXISTS] sequence_name
    [INCREMENT BY increment]
    [MINVALUE minvalue | NO MINVALUE]
    [MAXVALUE maxvalue | NO MAXVALUE]
    [START WITH start]
    [CACHE cache]
    [CYCLE | NO CYCLE];
```

Exemple :
```sql
CREATE SEQUENCE employe_id_seq
    INCREMENT BY 1
    START WITH 1000
    NO CYCLE;
```

## CREATE VIEW

Crée une vue, qui est une requête stockée présentée comme une table virtuelle.

```sql
CREATE [OR REPLACE] VIEW view_name AS query;
```

Exemple :
```sql
CREATE VIEW employes_departement AS
    SELECT e.id, e.nom, e.prenom, d.nom AS departement
    FROM employe e
    JOIN departement d ON e.departement = d.id;
```

## CREATE INDEX

Crée un index pour accélérer les requêtes.

```sql
CREATE [UNIQUE] INDEX [IF NOT EXISTS] index_name
ON table_name [USING method]
(column [ASC | DESC] [NULLS {FIRST | LAST}] [, ...]);
```

Exemple :
```sql
-- Index simple
CREATE INDEX idx_employe_nom ON employe(nom);

-- Index composé
CREATE INDEX idx_employe_dep_sal ON employe(departement, salaire DESC);

-- Index d'expression
CREATE INDEX idx_employe_upper_nom ON employe(UPPER(nom));
```

## CREATE FUNCTION

Crée une fonction SQL.

```sql
CREATE [OR REPLACE] FUNCTION function_name ([argument_name data_type [, ...]])
RETURNS return_type
LANGUAGE lang_name
AS $$
    -- définition de la fonction
$$;
```

Exemple :
```sql
CREATE OR REPLACE FUNCTION id_departement(nom_departement VARCHAR)
RETURNS INTEGER
LANGUAGE SQL
AS $$
    SELECT id FROM departement WHERE nom = nom_departement;
$$;
```

## CREATE PROCEDURE

Crée une procédure stockée.

```sql
CREATE [OR REPLACE] PROCEDURE procedure_name ([argument_name data_type [, ...]])
LANGUAGE lang_name
AS $$
    -- définition de la procédure
$$;
```

Exemple :
```sql
CREATE OR REPLACE PROCEDURE ajouter_employe(
    p_nom VARCHAR, 
    p_prenom VARCHAR, 
    p_departement VARCHAR
)
LANGUAGE SQL
AS $$
    INSERT INTO employe(nom, prenom, departement)
    VALUES(p_nom, p_prenom, (SELECT id FROM departement WHERE nom = p_departement));
$$;
```

## CREATE TRIGGER

Crée un déclencheur (trigger).

```sql
CREATE TRIGGER trigger_name
{BEFORE | AFTER | INSTEAD OF} {event [OR ...]}
ON table_name
[FOR [EACH] {ROW | STATEMENT}]
[WHEN (condition)]
EXECUTE PROCEDURE function_name(arguments);
```

Exemple :
```sql
CREATE TRIGGER maj_date_modification
BEFORE UPDATE ON employe
FOR EACH ROW
EXECUTE PROCEDURE update_date_modification();
```

## Considérations sur la création d'objets

### Gestion des dépendances circulaires

Lorsque deux tables ont des références circulaires, il est préférable de créer les tables d'abord sans les contraintes, puis d'ajouter les contraintes après la création de toutes les tables.

```sql
-- 1. Créer les tables sans contraintes de clé étrangère
CREATE TABLE departement (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    responsable INTEGER NULL
);

CREATE TABLE employe (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    departement INTEGER NULL,
    superviseur INTEGER NULL
);

-- 2. Ajouter les contraintes après la création des tables
ALTER TABLE departement
ADD CONSTRAINT fk_dep_resp FOREIGN KEY (responsable) REFERENCES employe(id);

ALTER TABLE employe
ADD CONSTRAINT fk_emp_dep FOREIGN KEY (departement) REFERENCES departement(id);

ALTER TABLE employe
ADD CONSTRAINT fk_emp_sup FOREIGN KEY (superviseur) REFERENCES employe(id);
```

### Utilisation de IF NOT EXISTS

L'option `IF NOT EXISTS` est utile dans les scripts qui peuvent être exécutés plusieurs fois, car elle empêche les erreurs si l'objet existe déjà.

```sql
CREATE TABLE IF NOT EXISTS employe (...);
CREATE INDEX IF NOT EXISTS idx_employe_nom ON employe(nom);
```

### Nommage des contraintes

Il est recommandé de nommer explicitement les contraintes pour faciliter leur gestion ultérieure.

```sql
-- Convention de nommage : 
-- type_contrainte_table_colonne
CREATE TABLE employe (
    id SERIAL,
    email VARCHAR(100),
    CONSTRAINT pk_employe_id PRIMARY KEY (id),
    CONSTRAINT uq_employe_email UNIQUE (email)
);
```

## Liens connexes
- [[DDL-ALTER]] - Modification d'objets
- [[DDL-DROP]] - Suppression d'objets
- [[DDL-TYPES]] - Types de données
- [[DDL-CONTRAINTES]] - Contraintes d'intégrité
- [[DDL-SEQUENCES]] - Séquences
- [[DDL-OBJETS]] - Objets supplémentaires