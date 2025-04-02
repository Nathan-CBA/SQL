# DDL - Contraintes

Les contraintes permettent de définir des règles que les données doivent respecter dans une base de données relationnelle. PostgreSQL propose six types de contraintes principales.

## Vue d'ensemble des contraintes

| Contrainte | Sur une colonne | Sur plusieurs colonnes | Valeur par défaut | Inclut automatiquement |
|------------|-----------------|------------------------|-------------------|------------------------|
| NULL / NOT NULL | Oui | Non | NULL | - |
| DEFAULT | Oui | Non | NULL | - |
| UNIQUE | Oui | Oui | Doublons permis | Crée un INDEX |
| CHECK | Oui | Oui | Aucune vérification | - |
| PRIMARY KEY | Oui | Oui | Pas de clé primaire | NOT NULL + UNIQUE |
| FOREIGN KEY | Oui | Oui | Pas de clé étrangère | - |

## NULL / NOT NULL

Définit si une colonne peut contenir des valeurs NULL (absence de valeur).

```sql
CREATE TABLE employe (
    nom VARCHAR NOT NULL,              -- Ne peut pas être NULL
    date_naissance DATE NULL,          -- Peut être NULL (explicite)
    departement INTEGER,               -- Peut être NULL (implicite)
    commission NUMERIC CONSTRAINT nc_emp_com NOT NULL  -- Avec nom de contrainte
);
```

## DEFAULT

Définit une valeur par défaut pour une colonne si aucune valeur n'est spécifiée lors de l'insertion.

```sql
CREATE TABLE employe (
    nas INTEGER NOT NULL,                      -- Pas de valeur par défaut
    nom VARCHAR,                               -- NULL par défaut
    prenom VARCHAR NULL,                       -- NULL par défaut
    commission NUMERIC DEFAULT NULL,           -- NULL par défaut (explicite)
    courriel VARCHAR DEFAULT 'info@company.com',
    date_embauche DATE DEFAULT CURRENT_DATE,
    statut VARCHAR DEFAULT 'actif' CONSTRAINT dc_emp_stat CHECK (statut IN ('actif', 'inactif'))
);
```

## UNIQUE

Garantit que toutes les valeurs d'une colonne ou d'un groupe de colonnes sont uniques.

```sql
CREATE TABLE employe (
    nas INTEGER UNIQUE,                        -- Contrainte sur une colonne
    nom VARCHAR,
    prenom VARCHAR,
    courriel_entreprise VARCHAR CONSTRAINT uc_emp_ce UNIQUE,  -- Avec nom
    courriel_personnel VARCHAR,
    CONSTRAINT uc_emp_cp UNIQUE(courriel_personnel),          -- Contrainte de table
    CONSTRAINT uc_emp_nom_prenom UNIQUE(nom, prenom)          -- Clé composite
);
```

## CHECK

Vérifie qu'une condition est respectée pour chaque ligne.

```sql
CREATE TABLE employe (
    nas INTEGER CHECK(nas BETWEEN 100000000 AND 999999999),  -- Contrainte directe
    nom VARCHAR CONSTRAINT cc_emp_nom CHECK(LENGTH(nom) > 1),  -- Avec nom
    date_naissance DATE,
    date_embauche DATE,
    salaire NUMERIC(10,2) CHECK(salaire > 0),
    CONSTRAINT cc_emp_date CHECK(date_embauche >= date_naissance + INTERVAL '18 years')  -- Sur plusieurs colonnes
);
```

## PRIMARY KEY

Identifie de manière unique chaque ligne d'une table. Une table ne peut avoir qu'une seule clé primaire.

```sql
-- Clé primaire sur une colonne
CREATE TABLE employe (
    nas INTEGER PRIMARY KEY,  -- Contrainte directe
    nom VARCHAR NOT NULL,
    prenom VARCHAR NOT NULL
);

-- Avec nom de contrainte
CREATE TABLE employe (
    nas INTEGER CONSTRAINT pk_emp PRIMARY KEY,
    nom VARCHAR NOT NULL,
    prenom VARCHAR NOT NULL
);

-- Clé primaire composite
CREATE TABLE employe (
    nom VARCHAR NOT NULL,
    prenom VARCHAR NOT NULL,
    date_naissance DATE NOT NULL,
    CONSTRAINT pk_emp PRIMARY KEY (nom, prenom, date_naissance)
);
```

## FOREIGN KEY (REFERENCES)

Établit une relation entre les données de deux tables en garantissant que les valeurs d'une colonne correspondent à des valeurs existantes dans une autre table.

```sql
-- Références à d'autres tables
CREATE TABLE departement (
    id INTEGER PRIMARY KEY,
    nom VARCHAR NOT NULL
);

CREATE TABLE employe (
    nas INTEGER PRIMARY KEY,
    nom VARCHAR NOT NULL,
    departement INTEGER REFERENCES departement(id),  -- Référence simple
    superviseur INTEGER CONSTRAINT fk_emp_sup REFERENCES employe(nas)  -- Auto-référence
);

-- Clé étrangère composite
CREATE TABLE employe_projet (
    employe INTEGER,
    projet INTEGER,
    CONSTRAINT pk_emp_pro PRIMARY KEY (employe, projet),
    CONSTRAINT fk_emp_pro_emp FOREIGN KEY (employe) REFERENCES employe(nas),
    CONSTRAINT fk_emp_pro_pro FOREIGN KEY (projet) REFERENCES projet(id)
);
```

### Actions sur suppression et mise à jour

Les contraintes de clé étrangère peuvent spécifier des actions à effectuer lorsque la ligne référencée est modifiée ou supprimée :

```sql
CREATE TABLE employe (
    nas INTEGER PRIMARY KEY,
    departement INTEGER REFERENCES departement(id)
        ON DELETE CASCADE        -- Supprime l'employé si son département est supprimé
        ON UPDATE CASCADE,       -- Met à jour l'ID du département si celui-ci est modifié
    
    superviseur INTEGER REFERENCES employe(nas)
        ON DELETE SET NULL       -- Met à NULL si le superviseur est supprimé
        ON UPDATE NO ACTION      -- Empêche la modification de l'ID du superviseur
);
```

Options disponibles :
- `NO ACTION` : Empêche l'opération (défaut)
- `RESTRICT` : Similaire à NO ACTION mais vérifié immédiatement
- `CASCADE` : Propage l'action (suppression ou modification)
- `SET NULL` : Met la référence à NULL
- `SET DEFAULT` : Met la référence à sa valeur par défaut

## Ajout, modification et suppression de contraintes

Vous pouvez ajouter, modifier ou supprimer des contraintes après la création d'une table :

```sql
-- Ajout de contrainte
ALTER TABLE employe
ADD CONSTRAINT fk_emp_dep FOREIGN KEY (departement) REFERENCES departement(id);

ALTER TABLE employe
ADD CONSTRAINT ck_emp_sal CHECK (salaire > 0);

-- Suppression de contrainte
ALTER TABLE employe
DROP CONSTRAINT fk_emp_dep;

-- Modification (nécessite suppression puis ajout)
ALTER TABLE employe
DROP CONSTRAINT ck_emp_sal,
ADD CONSTRAINT ck_emp_sal CHECK (salaire >= 0);
```

## Contraintes différées

Les contraintes de clé étrangère peuvent être définies comme "différables", c'est-à-dire que leur vérification peut être reportée à la fin de la transaction, ce qui facilite la gestion des dépendances circulaires.

```sql
-- Création d'une contrainte différable
ALTER TABLE employe
ADD CONSTRAINT fk_emp_dep
FOREIGN KEY (departement) REFERENCES departement(id)
DEFERRABLE INITIALLY IMMEDIATE;  -- Différable mais vérifiée immédiatement par défaut

-- Modification du mode de vérification dans une transaction
BEGIN;
SET CONSTRAINTS fk_emp_dep DEFERRED;  -- Vérification reportée à la fin
-- Opérations...
COMMIT;  -- Vérification des contraintes à ce moment
```

Pour plus de détails, voir [[TCL-CONTRAINTES-DIFFEREES]].

## Considérations pratiques

1. **Performance** : Les contraintes peuvent avoir un impact sur les performances, particulièrement pour les opérations d'insertion et de mise à jour en masse.

2. **Dépendances circulaires** : Les clés étrangères peuvent créer des dépendances circulaires qui compliquent l'insertion initiale des données. Les contraintes différables peuvent aider à résoudre ce problème.

3. **Modifications en cascade** : Utilisez avec prudence les options CASCADE, qui peuvent entraîner des suppressions ou modifications en chaîne non intentionnelles.

4. **Indexation** : Les contraintes UNIQUE et PRIMARY KEY créent automatiquement des index, mais pas les contraintes FOREIGN KEY. Envisagez de créer manuellement des index sur les colonnes de clé étrangère fréquemment utilisées dans les jointures.

## Liens connexes
- [[DDL-CREATE]] - Création d'objets
- [[DDL-ALTER]] - Modification d'objets
- [[DDL-TYPES]] - Types de données
- [[TCL-CONTRAINTES-DIFFEREES]] - Contraintes différées
- [[DEPENDANCES-CIRCULAIRES]] - Gestion des dépendances circulaires