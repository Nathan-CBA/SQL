# DDL - Types de données

PostgreSQL propose une grande variété de types de données. Cette note présente les principaux types et leur utilisation.

## Types numériques

### Entiers
- `SMALLINT` : 2 octets, -32768 à +32767
- `INTEGER` : 4 octets, -2147483648 à +2147483647
- `BIGINT` : 8 octets, -9223372036854775808 à +9223372036854775807

### Numériques à incrément automatique
- `SMALLSERIAL` : équivalent SMALLINT avec auto-incrément
- `SERIAL` : équivalent INTEGER avec auto-incrément
- `BIGSERIAL` : équivalent BIGINT avec auto-incrément

Ces types sont en réalité des raccourcis pour créer une séquence et définir la valeur par défaut de la colonne comme `nextval('sequence_name')`.

```sql
-- Ceci :
CREATE TABLE employe (id SERIAL);

-- Équivaut à :
CREATE SEQUENCE employe_id_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE employe (
    id INTEGER NOT NULL DEFAULT nextval('employe_id_seq')
);
ALTER SEQUENCE employe_id_seq OWNED BY employe.id;
```

### Décimaux
- `DECIMAL(précision, échelle)` : nombre exact à virgule fixe, précision et échelle spécifiées
- `NUMERIC(précision, échelle)` : identique à DECIMAL
  - `précision` : nombre total de chiffres (par défaut, limité par l'implémentation)
  - `échelle` : nombre de chiffres après la virgule (par défaut 0)

### Virgule flottante
- `REAL` : 4 octets, précision de 6 chiffres décimaux (inexact)
- `DOUBLE PRECISION` : 8 octets, précision de 15 chiffres décimaux (inexact)

## Types caractère

- `CHARACTER VARYING(n)` ou `VARCHAR(n)` : chaîne de caractères à longueur variable avec limite maximale de n caractères
- `CHARACTER(n)` ou `CHAR(n)` : chaîne de caractères à longueur fixe de n caractères (complétée par des espaces)
- `TEXT` : chaîne de caractères à longueur variable sans limite de taille

> **Note**: Dans PostgreSQL, `VARCHAR` sans spécification de longueur et `TEXT` sont pratiquement synonymes.

## Types date et heure

- `DATE` : date (sans heure), de 4713 av. J.-C. à 5874897 ap. J.-C.
- `TIME` : heure du jour (sans date)
  - `TIME` : sans fuseau horaire
  - `TIME WITH TIME ZONE` : avec fuseau horaire
- `TIMESTAMP` : date et heure
  - `TIMESTAMP` : sans fuseau horaire
  - `TIMESTAMP WITH TIME ZONE` : avec fuseau horaire
- `INTERVAL` : intervalle de temps

```sql
-- Exemples
SELECT CURRENT_DATE;  -- Date courante
SELECT CURRENT_TIME;  -- Heure courante avec fuseau horaire
SELECT NOW();         -- Timestamp avec fuseau horaire
```

## Type booléen

- `BOOLEAN` : valeur booléenne, peut contenir TRUE, FALSE ou NULL

## Types binaires

- `BYTEA` : données binaires ("byte array")

## Types énumérés

PostgreSQL permet de créer des types énumérés personnalisés :

```sql
-- Création d'un type énuméré
CREATE TYPE jour_semaine AS ENUM (
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi'
);

-- Utilisation
CREATE TABLE evenement (
    id SERIAL PRIMARY KEY,
    jour jour_semaine NOT NULL,
    description TEXT
);

-- Modification d'un type énuméré
ALTER TYPE jour_semaine ADD VALUE 'samedi';
ALTER TYPE jour_semaine RENAME VALUE 'jeudredi' TO 'jeudi';

-- Suppression d'un type énuméré
DROP TYPE jour_semaine CASCADE;
```

> **Note**: La suppression d'une valeur existante d'un type énuméré n'est pas possible.

## Type domaine

Les domaines permettent de créer des types personnalisés basés sur des types existants avec des contraintes supplémentaires :

```sql
-- Création de domaines
CREATE DOMAIN percentage AS NUMERIC(5, 2)
    NOT NULL
    CHECK (VALUE BETWEEN 0.00 AND 100.00);

CREATE DOMAIN email AS TEXT
    CHECK (VALUE ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
           AND LENGTH(TRIM(VALUE)) > 0);

-- Utilisation
CREATE TABLE evaluation (
    id SERIAL PRIMARY KEY,
    score percentage,
    contact email
);
```

## Types géométriques

PostgreSQL propose plusieurs types pour représenter des objets géométriques 2D :

- `POINT` : point (x, y)
- `LINE` : ligne infinie (ax + by + c = 0)
- `LSEG` : segment de ligne ((x₁, y₁), (x₂, y₂))
- `BOX` : rectangle ((x₁, y₁), (x₂, y₂))
- `PATH` : chemin fermé ou ouvert ((x₁, y₁), …, (xₙ, yₙ))
- `POLYGON` : polygone ((x₁, y₁), …, (xₙ, yₙ))
- `CIRCLE` : cercle <(x, y), r>

## Types utilitaires

- `MONEY` : montant monétaire
- `BIT(n)` : chaîne de bits à longueur fixe
- `BIT VARYING(n)` : chaîne de bits à longueur variable jusqu'à n
- `UUID` : identifiant universel unique (Universally Unique Identifier)
- `XML` : données XML
- `JSON` : données JSON
- `JSONB` : données JSON en format binaire (plus efficace pour les requêtes)

## Types réseau

- `INET` : adresse IPv4 ou IPv6 avec ou sans masque de sous-réseau
- `CIDR` : notation CIDR pour les adresses IPv4 ou IPv6
- `MACADDR` : adresse MAC (Media Access Control)

## Tableaux

PostgreSQL permet de définir des colonnes comme tableaux de n'importe quel type :

```sql
-- Tableau à une dimension
CREATE TABLE employe (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100),
    competences TEXT[]
);

-- Insertion avec tableau
INSERT INTO employe (nom, competences)
VALUES ('Dupont', ARRAY['SQL', 'Java', 'Python']);

-- Requête sur tableau
SELECT * FROM employe WHERE 'SQL' = ANY(competences);
```

## Types composés

PostgreSQL permet de créer des types composés (similaires aux structures) :

```sql
-- Création d'un type composé
CREATE TYPE adresse AS (
    rue VARCHAR(100),
    ville VARCHAR(50),
    code_postal VARCHAR(20),
    pays VARCHAR(50)
);

-- Utilisation
CREATE TABLE client (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100),
    adresse_livraison adresse,
    adresse_facturation adresse
);
```

## Liens connexes
- [[DDL-CREATE]] - Création d'objets
- [[DDL-CONTRAINTES]] - Contraintes d'intégrité
- [[DDL-SEQUENCES]] - Séquences