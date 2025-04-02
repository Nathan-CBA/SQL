# DDL - ALTER

La commande `ALTER` permet de modifier la structure des objets existants dans la base de données PostgreSQL sans avoir à les supprimer et les recréer.

## ALTER TABLE

La commande `ALTER TABLE` permet de modifier la structure d'une table existante.

### Ajouter une colonne

```sql
ALTER TABLE nom_table
ADD [COLUMN] nom_colonne type_donnee [contraintes];
```

Exemple :
```sql
ALTER TABLE employe
ADD COLUMN date_fin_contrat DATE;

ALTER TABLE employe
ADD COLUMN commentaires TEXT DEFAULT '';
```

### Supprimer une colonne

```sql
ALTER TABLE nom_table
DROP [COLUMN] nom_colonne [CASCADE | RESTRICT];
```

Exemple :
```sql
ALTER TABLE employe
DROP COLUMN date_fin_contrat;

-- CASCADE supprime aussi tous les objets qui dépendent de cette colonne
ALTER TABLE employe
DROP COLUMN departement CASCADE;
```

### Renommer une colonne

```sql
ALTER TABLE nom_table
RENAME [COLUMN] nom_colonne TO nouveau_nom;
```

Exemple :
```sql
ALTER TABLE employe
RENAME COLUMN adresse TO adresse_postale;
```

### Modifier le type d'une colonne

```sql
ALTER TABLE nom_table
ALTER [COLUMN] nom_colonne TYPE nouveau_type [USING expression];
```

Exemple :
```sql
-- Conversion simple
ALTER TABLE employe
ALTER COLUMN code_postal TYPE VARCHAR(10);

-- Conversion avec expression
ALTER TABLE employe
ALTER COLUMN salaire TYPE NUMERIC(10,2)
USING salaire::NUMERIC(10,2);

-- Conversion avec arrondi
ALTER TABLE employe
ALTER COLUMN prix TYPE INTEGER
USING ROUND(prix);
```

### Modifier ou ajouter une valeur par défaut

```sql
ALTER TABLE nom_table
ALTER [COLUMN] nom_colonne SET DEFAULT expression;
```

Exemple :
```sql
ALTER TABLE employe
ALTER COLUMN statut SET DEFAULT 'actif';

ALTER TABLE employe
ALTER COLUMN date_embauche SET DEFAULT CURRENT_DATE;
```

### Supprimer une valeur par défaut

```sql
ALTER TABLE nom_table
ALTER [COLUMN] nom_colonne DROP DEFAULT;
```

Exemple :
```sql
ALTER TABLE employe
ALTER COLUMN statut DROP DEFAULT;
```

### Définir ou supprimer la contrainte NOT NULL

```sql
-- Ajouter NOT NULL
ALTER TABLE nom_table
ALTER [COLUMN] nom_colonne SET NOT NULL;

-- Supprimer NOT NULL
ALTER TABLE nom_table
ALTER [COLUMN] nom_colonne DROP NOT NULL;
```

Exemple :
```sql
ALTER TABLE employe
ALTER COLUMN date_embauche SET NOT NULL;

ALTER TABLE employe
ALTER COLUMN date_fin_contrat DROP NOT NULL;
```

### Ajouter une contrainte de table

```sql
ALTER TABLE nom_table
ADD CONSTRAINT nom_contrainte type_contrainte (définition);
```

Exemple :
```sql
-- Clé primaire
ALTER TABLE employe
ADD CONSTRAINT pk_employe PRIMARY KEY (id);

-- Clé étrangère
ALTER TABLE employe
ADD CONSTRAINT fk_emp_dep
FOREIGN KEY (departement) REFERENCES departement(id);

-- Unicité
ALTER TABLE employe
ADD CONSTRAINT uc_emp_email UNIQUE (email);

-- Check
ALTER TABLE employe
ADD CONSTRAINT ck_emp_salaire CHECK (salaire >= 0);
```

### Supprimer une contrainte

```sql
ALTER TABLE nom_table
DROP CONSTRAINT nom_contrainte [CASCADE | RESTRICT];
```

Exemple :
```sql
ALTER TABLE employe
DROP CONSTRAINT fk_emp_dep;

-- CASCADE supprime également tous les objets qui dépendent de cette contrainte
ALTER TABLE employe
DROP CONSTRAINT pk_employe CASCADE;
```

### Renommer une table

```sql
ALTER TABLE nom_table
RENAME TO nouveau_nom;
```

Exemple :
```sql
ALTER TABLE employe
RENAME TO personnel;
```

### Changer le schéma d'une table

```sql
ALTER TABLE nom_table
SET SCHEMA nouveau_schema;
```

Exemple :
```sql
ALTER TABLE employe
SET SCHEMA ressources_humaines;
```

## ALTER SEQUENCE

La commande `ALTER SEQUENCE` permet de modifier les paramètres d'une séquence existante.

```sql
ALTER SEQUENCE nom_sequence
[INCREMENT BY nouvel_increment]
[MINVALUE nouvelle_valeur_min | NO MINVALUE]
[MAXVALUE nouvelle_valeur_max | NO MAXVALUE]
[START WITH nouvelle_valeur_debut]
[RESTART [WITH nouvelle_valeur]]
[CACHE nouvelle_valeur_cache]
[CYCLE | NO CYCLE]
[OWNED BY {nom_table.nom_colonne | NONE}];
```

Exemples :
```sql
-- Modifier l'incrément
ALTER SEQUENCE employe_id_seq INCREMENT BY 10;

-- Redémarrer la séquence
ALTER SEQUENCE employe_id_seq RESTART WITH 1000;

-- Définir une propriété OWNED BY
ALTER SEQUENCE employe_id_seq OWNED BY employe.id;
```

## ALTER TYPE

### Modifier un type énuméré

```sql
-- Ajouter une valeur
ALTER TYPE nom_type ADD VALUE 'nouvelle_valeur' [BEFORE | AFTER 'valeur_existante'];

-- Renommer un type
ALTER TYPE nom_type RENAME TO nouveau_nom;

-- Renommer une valeur d'énumération
ALTER TYPE nom_type RENAME VALUE 'ancienne_valeur' TO 'nouvelle_valeur';
```

Exemples :
```sql
-- Ajouter une valeur
ALTER TYPE jour_semaine ADD VALUE 'samedi' AFTER 'vendredi';
ALTER TYPE jour_semaine ADD VALUE 'dimanche' AFTER 'samedi';

-- Renommer un type
ALTER TYPE jour_semaine RENAME TO jours_de_la_semaine;

-- Renommer une valeur
ALTER TYPE jour_semaine RENAME VALUE 'lundi' TO 'monday';
```

> **Note** : Il n'est pas possible de supprimer une valeur d'un type énuméré.

### Modifier un domaine

```sql
-- Ajouter une contrainte
ALTER DOMAIN nom_domaine ADD CONSTRAINT nom_contrainte CHECK (expression);

-- Supprimer une contrainte
ALTER DOMAIN nom_domaine DROP CONSTRAINT nom_contrainte;

-- Renommer un domaine
ALTER DOMAIN nom_domaine RENAME TO nouveau_nom;

-- Modifier la valeur par défaut
ALTER DOMAIN nom_domaine SET DEFAULT expression;
ALTER DOMAIN nom_domaine DROP DEFAULT;

-- Modifier NOT NULL
ALTER DOMAIN nom_domaine SET NOT NULL;
ALTER DOMAIN nom_domaine DROP NOT NULL;
```

Exemples :
```sql
-- Ajouter une contrainte à un domaine
ALTER DOMAIN email 
ADD CONSTRAINT ck_email_valide 
CHECK (VALUE ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Renommer un domaine
ALTER DOMAIN percentage RENAME TO pourcentage;

-- Modifier la valeur par défaut
ALTER DOMAIN pourcentage SET DEFAULT 0;
```

## ALTER VIEW

```sql
-- Renommer une vue
ALTER VIEW nom_vue RENAME TO nouveau_nom;

-- Modifier une vue
ALTER VIEW nom_vue ALTER COLUMN nom_colonne SET DEFAULT expression;

-- Remplacer une vue
CREATE OR REPLACE VIEW nom_vue AS nouvelle_requête;
```

Exemple :
```sql
-- Renommer une vue
ALTER VIEW employes_departement RENAME TO personnel_departement;

-- Remplacer une vue
CREATE OR REPLACE VIEW employes_departement AS
SELECT e.id, e.nom, e.prenom, d.nom AS departement, e.salaire
FROM employe e
JOIN departement d ON e.departement = d.id;
```

## ALTER DATABASE

```sql
ALTER DATABASE nom_base_de_donnees
[RENAME TO nouveau_nom]
[OWNER TO nouveau_proprietaire]
[SET parametre TO valeur | FROM config | TO DEFAULT]
[RESET parametre | ALL];
```

Exemple :
```sql
-- Renommer une base de données
ALTER DATABASE gestion_employes RENAME TO ressources_humaines;

-- Changer le propriétaire
ALTER DATABASE ressources_humaines OWNER TO admin;

-- Modifier des paramètres
ALTER DATABASE ressources_humaines SET timezone TO 'America/Montreal';
```

## ALTER SCHEMA

```sql
-- Renommer un schéma
ALTER SCHEMA nom_schema RENAME TO nouveau_nom;

-- Changer le propriétaire
ALTER SCHEMA nom_schema OWNER TO nouveau_proprietaire;
```

Exemple :
```sql
-- Renommer un schéma
ALTER SCHEMA ressources_humaines RENAME TO rh;

-- Changer le propriétaire
ALTER SCHEMA rh OWNER TO responsable_rh;
```

## ALTER INDEX

```sql
-- Renommer un index
ALTER INDEX nom_index RENAME TO nouveau_nom;

-- Déplacer un index vers un autre tablespace
ALTER INDEX nom_index SET TABLESPACE nouveau_tablespace;
```

Exemple :
```sql
-- Renommer un index
ALTER INDEX idx_employe_nom RENAME TO idx_emp_nom;
```

## Considérations pratiques

1. **Transactions** : Utilisez des transactions pour les modifications importantes qui doivent être atomiques.

2. **Impact sur les performances** : Certaines opérations ALTER peuvent être coûteuses et verrouiller la table. Pour les tables volumineuses, envisagez des approches alternatives ou des fenêtres de maintenance.

3. **Compatibilité descendante** : Assurez-vous que les modifications ne cassent pas les applications existantes.

4. **Tests** : Testez les modifications sur un environnement de test avant de les appliquer en production.

5. **Privilèges** : L'exécution d'un ALTER peut nécessiter des privilèges spécifiques.

## Liens connexes
- [[DDL-CREATE]] - Création d'objets
- [[DDL-DROP]] - Suppression d'objets
- [[DDL-TYPES]] - Types de données
- [[DDL-CONTRAINTES]] - Contraintes d'intégrité
- [[DDL-SEQUENCES]] - Séquences