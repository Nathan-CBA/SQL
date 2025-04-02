# DDL - DROP

La commande `DROP` permet de supprimer des objets de la base de données PostgreSQL.

## Syntaxe de base

La syntaxe générale des commandes DROP est :

```sql
DROP TYPE_OBJET [IF EXISTS] nom_objet [CASCADE | RESTRICT];
```

Où :
- `TYPE_OBJET` est le type d'objet à supprimer (TABLE, DATABASE, VIEW, etc.)
- `IF EXISTS` est une option facultative qui empêche l'erreur si l'objet n'existe pas
- `CASCADE` supprime également tous les objets qui dépendent de l'objet supprimé
- `RESTRICT` (comportement par défaut) empêche la suppression si des objets en dépendent

## DROP TABLE

Supprime une table et généralement toutes les données qu'elle contient.

```sql
DROP TABLE [IF EXISTS] nom_table [, ...] [CASCADE | RESTRICT];
```

Exemples :
```sql
-- Suppression simple
DROP TABLE employe;

-- Suppression seulement si la table existe
DROP TABLE IF EXISTS employe;

-- Suppression de plusieurs tables
DROP TABLE employe, departement, projet;

-- Suppression avec cascade (supprime tous les objets dépendants)
DROP TABLE departement CASCADE;
```

> ⚠️ **Attention** : `DROP TABLE` supprime définitivement la table et toutes ses données sans possibilité de récupération (sauf restauration de sauvegarde).

## DROP DATABASE

Supprime une base de données entière.

```sql
DROP DATABASE [IF EXISTS] nom_database [WITH (FORCE)];
```

Exemple :
```sql
DROP DATABASE IF EXISTS gestion_employes;
```

> ⚠️ **Attention** : Cette commande est extrêmement dangereuse car elle supprime définitivement tous les objets et données de la base de données.

## DROP SCHEMA

Supprime un schéma.

```sql
DROP SCHEMA [IF EXISTS] nom_schema [, ...] [CASCADE | RESTRICT];
```

Exemples :
```sql
-- Suppression simple
DROP SCHEMA ressources_humaines;

-- Suppression avec cascade
DROP SCHEMA IF EXISTS ressources_humaines CASCADE;
```

## DROP SEQUENCE

Supprime une séquence.

```sql
DROP SEQUENCE [IF EXISTS] nom_sequence [, ...] [CASCADE | RESTRICT];
```

Exemple :
```sql
DROP SEQUENCE IF EXISTS employe_id_seq;
```

## DROP TYPE

Supprime un type personnalisé.

```sql
DROP TYPE [IF EXISTS] nom_type [, ...] [CASCADE | RESTRICT];
```

Exemples :
```sql
-- Suppression d'un type énuméré
DROP TYPE jour_semaine;

-- Suppression d'un domaine
DROP TYPE email;
```

## DROP DOMAIN

Supprime un domaine.

```sql
DROP DOMAIN [IF EXISTS] nom_domaine [, ...] [CASCADE | RESTRICT];
```

Exemple :
```sql
DROP DOMAIN IF EXISTS email;
```

## DROP VIEW

Supprime une vue.

```sql
DROP VIEW [IF EXISTS] nom_vue [, ...] [CASCADE | RESTRICT];
```

Exemple :
```sql
DROP VIEW IF EXISTS employe_departement;
```

## DROP INDEX

Supprime un index.

```sql
DROP INDEX [IF EXISTS] nom_index [, ...] [CASCADE | RESTRICT];
```

Exemple :
```sql
DROP INDEX idx_employe_nom;
```

## DROP FUNCTION

Supprime une fonction.

```sql
DROP FUNCTION [IF EXISTS] nom_fonction ([type_argument [, ...]]) [CASCADE | RESTRICT];
```

Exemple :
```sql
DROP FUNCTION calculer_salaire(integer);
```

> **Note** : Vous devez spécifier les types des arguments car PostgreSQL permet la surcharge des fonctions.

## DROP PROCEDURE

Supprime une procédure.

```sql
DROP PROCEDURE [IF EXISTS] nom_procedure ([type_argument [, ...]]) [CASCADE | RESTRICT];
```

Exemple :
```sql
DROP PROCEDURE ajouter_employe(varchar, varchar, integer);
```

## DROP TRIGGER

Supprime un déclencheur (trigger).

```sql
DROP TRIGGER [IF EXISTS] nom_trigger ON nom_table [CASCADE | RESTRICT];
```

Exemple :
```sql
DROP TRIGGER IF EXISTS tr_maj_date_modification ON employe;
```

## TRUNCATE TABLE

Bien que techniquement ce ne soit pas une commande DROP, `TRUNCATE TABLE` est étroitement liée car elle supprime toutes les données d'une table mais préserve sa structure.

```sql
TRUNCATE TABLE [ONLY] nom_table [, ...] [RESTART IDENTITY | CONTINUE IDENTITY] [CASCADE | RESTRICT];
```

Exemples :
```sql
-- Supprimer toutes les lignes
TRUNCATE TABLE employe;

-- Supprimer toutes les lignes et réinitialiser les séquences
TRUNCATE TABLE employe RESTART IDENTITY;

-- Supprimer les données de plusieurs tables
TRUNCATE TABLE employe, departement, projet;
```

Avantages de TRUNCATE par rapport à DELETE :
- Beaucoup plus rapide car il ne traite pas chaque ligne individuellement
- Utilise moins de ressources système
- Réinitialise les compteurs de séquence si RESTART IDENTITY est spécifié

## Option CASCADE et RESTRICT

### CASCADE

L'option `CASCADE` supprime automatiquement tous les objets qui dépendent de l'objet supprimé.

```sql
-- Supprime la table departement et toutes les contraintes de clé étrangère qui y font référence
DROP TABLE departement CASCADE;
```

> ⚠️ **Attention** : L'option CASCADE peut entraîner des suppressions en chaîne non intentionnelles. Utilisez-la avec prudence.

### RESTRICT

L'option `RESTRICT` (comportement par défaut) empêche la suppression de l'objet si d'autres objets en dépendent.

```sql
-- Échoue si des objets dépendent de la table departement
DROP TABLE departement RESTRICT;
```

## Considérations pratiques

1. **Sauvegardes** : Effectuez toujours une sauvegarde avant d'exécuter des commandes DROP sur des objets importants.

2. **Transactions** : Utilisez des transactions pour les suppressions complexes afin de pouvoir annuler en cas de problème.

3. **Privilèges** : L'exécution de commandes DROP nécessite généralement des privilèges élevés.

4. **Vérification des dépendances** : Pour voir quels objets dépendent d'un objet avant de le supprimer, utilisez les fonctions de catalogue PostgreSQL.

5. **Option IF EXISTS** : Utilisez cette option dans les scripts pour éviter les erreurs si l'objet n'existe pas.

6. **Option CASCADE** : Utilisez cette option avec prudence et vérifiez préalablement les dépendances.

## Vérification des dépendances

Avant de supprimer un objet, vous pouvez vérifier les dépendances avec cette requête :

```sql
-- Pour une table
SELECT 
    dependent_ns.nspname AS dependent_schema,
    dependent_view.relname AS dependent_view
FROM pg_depend 
JOIN pg_rewrite ON pg_depend.objid = pg_rewrite.oid 
JOIN pg_class as dependent_view ON pg_rewrite.ev_class = dependent_view.oid 
JOIN pg_class as source_table ON pg_depend.refobjid = source_table.oid 
JOIN pg_namespace dependent_ns ON dependent_ns.oid = dependent_view.relnamespace
JOIN pg_namespace source_ns ON source_ns.oid = source_table.relnamespace
WHERE 
    source_ns.nspname = 'public' AND  -- Schéma de la table
    source_table.relname = 'departement';  -- Nom de la table
```

## Exemple complet

```sql
-- Commencer une transaction
BEGIN;

-- Supprimer les vues dépendantes
DROP VIEW IF EXISTS vue_employe_departement CASCADE;

-- Supprimer les contraintes de clé étrangère
ALTER TABLE employe DROP CONSTRAINT fk_emp_dep;

-- Supprimer un index
DROP INDEX IF EXISTS idx_departement_nom;

-- Supprimer la table
DROP TABLE IF EXISTS departement;

-- Vérifier et valider (ou annuler)
COMMIT;
-- ou ROLLBACK en cas de problème
```

## Liens connexes
- [[DDL-CREATE]] - Création d'objets
- [[DDL-ALTER]] - Modification d'objets
- [[TCL-CONTRAINTES-DIFFEREES]] - Transactions
- [[DEPENDANCES-CIRCULAIRES]] - Gestion des dépendances circulaires