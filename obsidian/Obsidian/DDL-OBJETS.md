# DDL - Objets supplémentaires

PostgreSQL propose une grande variété d'objets au-delà des tables et colonnes de base. Cette note présente les objets supplémentaires les plus importants et leur utilisation.

## Base de données (DATABASE)

Une base de données est un conteneur logique qui regroupe des schémas et tous leurs objets (tables, vues, etc.).

### Caractéristiques principales

- Sommet de la hiérarchie des objets dans PostgreSQL
- Isolation complète des autres bases de données
- Nécessite une connexion spécifique (impossible de "basculer" entre bases de données dans une même connexion)
- Possède ses propres paramètres et configurations

### Syntaxe de base

```sql
-- Création d'une base de données
CREATE DATABASE nom_base_de_donnees
    [OWNER = role_name]
    [TEMPLATE = template]
    [ENCODING = encoding]
    [LC_COLLATE = locale]
    [LC_CTYPE = locale]
    [TABLESPACE = tablespace_name]
    [CONNECTION LIMIT = connlimit];

-- Suppression
DROP DATABASE [IF EXISTS] nom_base_de_donnees;

-- Modification
ALTER DATABASE nom_base_de_donnees ...;
```

### Exemple

```sql
CREATE DATABASE gestion_employes
    OWNER = admin
    ENCODING = 'UTF8'
    LC_COLLATE = 'fr_CA.UTF-8'
    LC_CTYPE = 'fr_CA.UTF-8'
    CONNECTION LIMIT = 100;
```

## Schéma (SCHEMA)

Un schéma est un espace de noms qui contient des objets nommés (tables, vues, etc.) au sein d'une base de données.

### Caractéristiques principales

- Permet d'organiser logiquement les objets
- Évite les conflits de noms (tables identiques dans différents schémas)
- Simplifie la gestion des droits d'accès
- Permet d'isoler logiquement différentes parties d'une application

### Syntaxe de base

```sql
-- Création d'un schéma
CREATE SCHEMA [IF NOT EXISTS] nom_schema [AUTHORIZATION role_name];

-- Suppression
DROP SCHEMA [IF EXISTS] nom_schema [CASCADE | RESTRICT];

-- Modification
ALTER SCHEMA nom_schema ...;
```

### Exemple

```sql
-- Création de deux schémas distincts
CREATE SCHEMA comptabilite;
CREATE SCHEMA ressources_humaines;

-- Création d'une table dans un schéma spécifique
CREATE TABLE comptabilite.factures (
    id SERIAL PRIMARY KEY,
    montant NUMERIC(10,2) NOT NULL
);

-- Accès à une table d'un schéma
SELECT * FROM comptabilite.factures;
```

### Schéma de recherche (search_path)

Le paramètre `search_path` définit l'ordre des schémas consultés lorsqu'un objet est référencé sans préfixe de schéma.

```sql
-- Afficher le chemin de recherche actuel
SHOW search_path;

-- Modifier le chemin de recherche
SET search_path TO comptabilite, ressources_humaines, public;
```

Par défaut, le schéma `public` est utilisé si aucun schéma n'est spécifié.

## Vue (VIEW)

Une vue est une requête stockée qui se comporte comme une table virtuelle. Les vues n'ont pas de données propres mais présentent les données des tables sous-jacentes.

### Caractéristiques principales

- Simplification des requêtes complexes
- Abstraction des données (masquage de la complexité)
- Contrôle des accès (sécurité)
- Cohérence des données (garantit que les mêmes critères sont toujours appliqués)
- Maintenance facilitée (modification d'une seule vue plutôt que de plusieurs requêtes)

### Syntaxe de base

```sql
-- Création d'une vue
CREATE [OR REPLACE] VIEW nom_vue AS requête;

-- Suppression
DROP VIEW [IF EXISTS] nom_vue [CASCADE | RESTRICT];

-- Modification
ALTER VIEW [IF EXISTS] nom_vue ...;
```

### Exemple

```sql
-- Vue qui combine des données de plusieurs tables
CREATE VIEW vue_employe_departement AS
SELECT e.id, e.nom, e.prenom, d.nom AS departement, e.salaire
FROM employe e
JOIN departement d ON e.departement = d.id;

-- Utilisation de la vue
SELECT * FROM vue_employe_departement
WHERE departement = 'Ventes';
```

### Vues matérialisées

Une vue matérialisée est comme une vue, mais elle stocke physiquement les résultats de la requête, ce qui améliore les performances pour les requêtes complexes.

```sql
-- Création d'une vue matérialisée
CREATE MATERIALIZED VIEW nom_vue AS requête;

-- Rafraîchissement des données
REFRESH MATERIALIZED VIEW nom_vue;
```

## Index (INDEX)

Un index est une structure de données qui améliore la vitesse des opérations de recherche dans une table.

### Caractéristiques principales

- Accélère les recherches et les jointures
- Améliore les performances des requêtes avec clauses `WHERE` et `ORDER BY`
- Garantit l'unicité des valeurs (pour les index UNIQUE)
- Consomme de l'espace disque supplémentaire
- Peut ralentir les opérations d'écriture (INSERT, UPDATE, DELETE)

### Types d'index dans PostgreSQL

- **B-tree** (par défaut) : Adapté à la plupart des scénarios
- **Hash** : Optimisé pour les comparaisons d'égalité exacte
- **GiST** (Generalized Search Tree) : Pour les données géométriques, textuelles, etc.
- **GIN** (Generalized Inverted Index) : Pour les données composites (tableaux, JSON)
- **BRIN** (Block Range Index) : Pour les très grandes tables avec des données ordonnées naturellement
- **SP-GiST** (Space-Partitioned GiST) : Pour les partitionnements non équilibrés

### Syntaxe de base

```sql
-- Création d'un index
CREATE [UNIQUE] INDEX [nom_index]
ON table_name [USING method]
(colonne [ASC | DESC] [NULLS {FIRST | LAST}] [, ...]);

-- Suppression
DROP INDEX [IF EXISTS] nom_index [CASCADE | RESTRICT];

-- Modification
ALTER INDEX [IF EXISTS] nom_index ...;
```

### Exemples

```sql
-- Index B-tree simple
CREATE INDEX idx_employe_nom ON employe(nom);

-- Index unique
CREATE UNIQUE INDEX idx_employe_email ON employe(email);

-- Index sur plusieurs colonnes
CREATE INDEX idx_employe_dept_nom ON employe(departement, nom);

-- Index d'expression (fonctionnel)
CREATE INDEX idx_employe_nom_upper ON employe(UPPER(nom));

-- Index partiel
CREATE INDEX idx_facture_impayee ON facture(date_echeance)
WHERE statut = 'impayée';
```

### Gestion des index

```sql
-- Reconstruire un index
REINDEX INDEX nom_index;

-- Analyser les statistiques pour optimiser l'utilisation des index
ANALYZE table_name;
```

## Objets temporaires

Les objets temporaires dans PostgreSQL existent uniquement pendant la durée de la session ou de la transaction.

### Caractéristiques principales

- Visibles uniquement par la session qui les a créés
- Supprimés automatiquement à la fin de la session/transaction
- Utiles pour les calculs intermédiaires, l'importation de données, etc.
- Ne nécessitent pas de nettoyage manuel

### Types d'objets temporaires

#### Tables temporaires

```sql
-- Création d'une table temporaire
CREATE TEMP TABLE nom_table (
    colonne1 type1,
    colonne2 type2,
    ...
);
```

La table sera automatiquement supprimée à la fin de la session ou de la transaction (selon la configuration).

#### Vues temporaires

```sql
-- Création d'une vue temporaire
CREATE TEMP VIEW nom_vue AS
SELECT * FROM table WHERE condition;
```

#### Séquences temporaires

```sql
-- Création d'une séquence temporaire
CREATE TEMP SEQUENCE temp_seq;
```

### Exemple d'utilisation

```sql
-- Scénario: Import de données CSV
CREATE TEMP TABLE import_temp (
    nom VARCHAR,
    prenom VARCHAR,
    email VARCHAR,
    departement VARCHAR
);

-- Import des données brutes
COPY import_temp FROM '/tmp/employes.csv' WITH CSV HEADER;

-- Transformation et insertion dans la table permanente
INSERT INTO employe (nom, prenom, email, departement_id)
SELECT 
    i.nom, 
    i.prenom, 
    i.email,
    (SELECT id FROM departement WHERE nom = i.departement)
FROM import_temp i;

-- La table import_temp sera automatiquement supprimée à la fin de la session
```

## Tablespace

Un tablespace est un emplacement physique sur disque où PostgreSQL stocke les données des objets de la base de données.

### Caractéristiques principales

- Permet de distribuer les données sur différents disques
- Optimise les performances en fonction des périphériques de stockage
- Facilite la gestion de l'espace disque
- Simplifie les migrations et les sauvegardes

### Syntaxe de base

```sql
-- Création d'un tablespace
CREATE TABLESPACE nom_tablespace
LOCATION '/chemin/vers/repertoire';

-- Suppression
DROP TABLESPACE nom_tablespace;

-- Modification
ALTER TABLESPACE nom_tablespace ...;
```

### Exemple

```sql
-- Création d'un tablespace pour les données fréquemment accédées
CREATE TABLESPACE espace_rapide
LOCATION '/mnt/ssd/postgresql_data';

-- Création d'une table dans ce tablespace
CREATE TABLE transactions_recentes (
    id SERIAL PRIMARY KEY,
    montant NUMERIC(10,2),
    date TIMESTAMP
) TABLESPACE espace_rapide;
```

## Rôles et privilèges

Les rôles (users et groups) définissent les permissions d'accès aux objets de la base de données.

### Caractéristiques principales

- Gestion centralisée des permissions
- Héritage des privilèges (un rôle peut hériter d'un autre)
- Sécurisation des données
- Support de plusieurs niveaux d'accès

### Syntaxe de base

```sql
-- Création d'un rôle
CREATE ROLE nom_role [OPTIONS];

-- Suppression
DROP ROLE [IF EXISTS] nom_role;

-- Modification
ALTER ROLE nom_role ...;

-- Attribution de privilèges
GRANT privilege ON objet TO role;

-- Révocation de privilèges
REVOKE privilege ON objet FROM role;
```

### Exemple

```sql
-- Création d'un rôle pour les comptables
CREATE ROLE comptable;

-- Attribution de privilèges de lecture sur le schéma comptabilité
GRANT USAGE ON SCHEMA comptabilite TO comptable;
GRANT SELECT ON ALL TABLES IN SCHEMA comptabilite TO comptable;

-- Création d'un utilisateur spécifique qui hérite du rôle comptable
CREATE ROLE alice LOGIN PASSWORD 'mot_de_passe' IN ROLE comptable;
```

## Extensions

Les extensions permettent d'ajouter des fonctionnalités supplémentaires à PostgreSQL.

### Caractéristiques principales

- Modules additionnels pour étendre les fonctionnalités
- Installation facile via la commande CREATE EXTENSION
- Diversité de fonctionnalités (géospatiales, analytiques, etc.)
- Développées par la communauté ou des fournisseurs tiers

### Syntaxe de base

```sql
-- Installation d'une extension
CREATE EXTENSION nom_extension;

-- Désinstallation
DROP EXTENSION [IF EXISTS] nom_extension [CASCADE | RESTRICT];

-- Mise à jour
ALTER EXTENSION nom_extension UPDATE;
```

### Extensions populaires

- **PostGIS** : Fonctionnalités géographiques et géospatiales
- **pg_stat_statements** : Statistiques détaillées sur les requêtes exécutées
- **hstore** : Stockage de paires clé-valeur
- **pgcrypto** : Fonctions cryptographiques
- **uuid-ossp** : Génération d'identifiants universellement uniques (UUID)
- **pg_trgm** : Recherche de similarité textuelle avec trigrammes

### Exemple

```sql
-- Installation de PostGIS
CREATE EXTENSION postgis;

-- Utilisation de fonctionnalités géospatiales
CREATE TABLE points_interet (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100),
    position GEOMETRY(Point, 4326)
);

-- Requête spatiale
SELECT nom 
FROM points_interet
WHERE ST_DWithin(
    position, 
    ST_SetSRID(ST_MakePoint(-73.55, 45.50), 4326), 
    1000
);
```

## Objets de partitionnement

Le partitionnement divise une grande table en morceaux plus petits et plus faciles à gérer, tout en les présentant comme une seule table logique.

### Caractéristiques principales

- Améliore les performances des requêtes sur de très grandes tables
- Facilite la maintenance (suppression de partitions entières)
- Permet une distribution optimisée des données
- Simplifie la gestion des données historiques

### Types de partitionnement

- **Par plage (RANGE)** : Partition selon une plage de valeurs (dates, identifiants, etc.)
- **Par liste (LIST)** : Partition selon une liste de valeurs discrètes
- **Par hachage (HASH)** : Distribution uniforme basée sur une fonction de hachage

### Syntaxe de base

```sql
-- Création d'une table partitionnée
CREATE TABLE nom_table (colonnes)
PARTITION BY RANGE|LIST|HASH (colonne);

-- Création d'une partition
CREATE TABLE nom_partition
PARTITION OF nom_table
FOR VALUES FROM/IN/WITH (valeurs);
```

### Exemple de partitionnement par plage

```sql
-- Table partitionnée par date
CREATE TABLE journal_transactions (
    id SERIAL,
    date_transaction DATE NOT NULL,
    montant NUMERIC(10,2),
    description TEXT
) PARTITION BY RANGE (date_transaction);

-- Créer des partitions mensuelles
CREATE TABLE journal_transactions_2023_01 PARTITION OF journal_transactions
    FOR VALUES FROM ('2023-01-01') TO ('2023-02-01');
    
CREATE TABLE journal_transactions_2023_02 PARTITION OF journal_transactions
    FOR VALUES FROM ('2023-02-01') TO ('2023-03-01');

-- Et ainsi de suite...
```

## Liens connexes
- [[DDL-CREATE]] - Création d'objets
- [[DDL-ALTER]] - Modification d'objets
- [[DDL-DROP]] - Suppression d'objets
- [[DDL-SEQUENCES]] - Séquences