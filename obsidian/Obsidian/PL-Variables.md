# PL - Variables et types de données

Les variables sont un élément fondamental de PL/pgSQL permettant de stocker temporairement des valeurs et de manipuler des données au sein d'un bloc procédural.

## Déclaration des variables

Les variables sont déclarées dans la section `DECLARE` d'un bloc PL/pgSQL, avant le début du corps du bloc.

```sql
DO $$
DECLARE
    -- Syntaxe: nom_variable [CONSTANT] type [NOT NULL] [DEFAULT valeur_initiale | := valeur_initiale];
    v_nombre INTEGER;                 -- Non initialisée (NULL par défaut)
    v_texte VARCHAR(50) := 'Hello';   -- Initialisée avec :=
    v_date DATE DEFAULT CURRENT_DATE; -- Initialisée avec DEFAULT
    v_pi CONSTANT NUMERIC := 3.14159; -- Constante (ne peut être modifiée)
    v_required TEXT NOT NULL := '';   -- Ne peut pas être NULL
BEGIN
    -- Corps du bloc
END;
$$;
```

> **Note**: L'opérateur d'assignation en PL/pgSQL est `:=` (et non `=` qui est utilisé pour les comparaisons)

## Types de données disponibles

### Types de base PostgreSQL

Tous les types de données natifs PostgreSQL sont disponibles dans PL/pgSQL:

- **Numériques**: INTEGER, BIGINT, NUMERIC, REAL, DOUBLE PRECISION
- **Caractères**: VARCHAR, CHAR, TEXT
- **Date/Heure**: DATE, TIME, TIMESTAMP, INTERVAL
- **Booléen**: BOOLEAN
- **Types spéciaux**: UUID, JSON, BYTEA, etc.

### Types basés sur des objets existants

PL/pgSQL permet de définir des variables dont le type est basé sur des objets de base de données existants:

#### Type d'une colonne

```sql
DECLARE
    v_nom employe.nom%TYPE; -- Même type que la colonne 'nom' de la table 'employe'
```

Cette méthode est utile car elle s'adapte automatiquement si le type de la colonne change.

#### Type d'une ligne (enregistrement)

```sql
DECLARE
    v_employe employe%ROWTYPE; -- Structure identique à toute la table 'employe'
```

Une variable de type `%ROWTYPE` contient tous les champs de la table ou de la vue correspondante.

### Type RECORD

Le type RECORD est un type générique qui peut contenir un enregistrement de structure variable:

```sql
DECLARE
    v_rec RECORD; -- Structure définie lors de l'assignation
```

À la différence de `%ROWTYPE`, la structure d'un RECORD n'est pas définie à l'avance et sera déterminée lors de l'assignation (par exemple, par un SELECT INTO).

## Assignation de valeurs

### Assignation simple

```sql
DO $$
DECLARE
    v_compteur INTEGER := 0;
BEGIN
    v_compteur := v_compteur + 1;
    RAISE NOTICE 'Compteur: %', v_compteur;
END;
$$;
```

### Assignation depuis une requête SQL

La clause `INTO` permet d'assigner le résultat d'une requête à une ou plusieurs variables:

```sql
DO $$
DECLARE
    v_nom VARCHAR;
    v_salaire NUMERIC;
BEGIN
    -- Assignation de valeurs individuelles
    SELECT nom, salaire INTO v_nom, v_salaire
    FROM employe
    WHERE id = 123;
    
    RAISE NOTICE 'Employé: %, Salaire: %', v_nom, v_salaire;
END;
$$;
```

### Assignation d'un enregistrement complet

```sql
DO $$
DECLARE
    v_emp employe%ROWTYPE;
BEGIN
    -- Assignation d'un enregistrement complet
    SELECT * INTO v_emp
    FROM employe
    WHERE id = 123;
    
    RAISE NOTICE 'Employé: %, Département: %', v_emp.nom, v_emp.departement;
END;
$$;
```

### Assignation avec le résultat d'une opération DML

```sql
DO $$
DECLARE
    v_nouvel_id INTEGER;
BEGIN
    -- Récupération de l'ID généré par l'insertion
    INSERT INTO departement (nom)
    VALUES ('Recherche et Développement')
    RETURNING id INTO v_nouvel_id;
    
    RAISE NOTICE 'Nouveau département créé avec ID: %', v_nouvel_id;
END;
$$;
```

## Portée des variables

La portée d'une variable est limitée au bloc dans lequel elle est déclarée. Les blocs imbriqués peuvent accéder aux variables des blocs parents, mais pas l'inverse.

```sql
DO $$
DECLARE
    v_externe INTEGER := 10;
BEGIN
    RAISE NOTICE 'Externe: %', v_externe;
    
    -- Bloc imbriqué
    DECLARE
        v_interne INTEGER := 20;
    BEGIN
        -- Accès aux variables externe et interne
        RAISE NOTICE 'Externe: %, Interne: %', v_externe, v_interne;
        
        -- Modification de la variable externe
        v_externe := 30;
    END;
    
    -- La variable v_interne n'est pas accessible ici
    RAISE NOTICE 'Externe (modifiée): %', v_externe;
    -- RAISE NOTICE 'Interne: %', v_interne; -- Erreur!
END;
$$;
```

## Manipulation des variables de type %ROWTYPE et RECORD

### Accès aux champs

Pour accéder aux champs d'une variable de type `%ROWTYPE` ou `RECORD`, utilisez la notation point:

```sql
DO $$
DECLARE
    v_emp employe%ROWTYPE;
BEGIN
    SELECT * INTO v_emp FROM employe WHERE id = 123;
    
    -- Accès aux champs individuels
    RAISE NOTICE 'Nom: %', v_emp.nom;
    RAISE NOTICE 'Salaire: %', v_emp.salaire;
    
    -- Modification d'un champ
    v_emp.salaire := v_emp.salaire * 1.1;
    
    -- Utilisation de l'enregistrement modifié
    UPDATE employe SET salaire = v_emp.salaire WHERE id = 123;
END;
$$;
```

### Utilisation du type RECORD

```sql
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    -- Assignation d'une structure au RECORD
    SELECT id, nom, salaire INTO v_rec
    FROM employe
    WHERE departement = 3
    ORDER BY salaire DESC
    LIMIT 1;
    
    RAISE NOTICE 'Employé le mieux payé: % (ID: %), Salaire: %',
        v_rec.nom, v_rec.id, v_rec.salaire;
        
    -- Modification du RECORD
    v_rec.salaire := v_rec.salaire * 0.9;
    
    -- Utilisation du RECORD modifié
    UPDATE employe SET salaire = v_rec.salaire WHERE id = v_rec.id;
END;
$$;
```

## Variables spéciales

PL/pgSQL offre quelques variables spéciales:

- **FOUND**: Booléen qui indique si la dernière opération a trouvé/affecté des lignes
- **TG_**: Variables liées aux triggers (TG_NAME, TG_WHEN, TG_LEVEL, TG_OP, etc.)
- **NEW et OLD**: Enregistrements disponibles dans les fonctions de trigger

```sql
DO $$
DECLARE
    v_emp_id INTEGER := 123;
    v_rec RECORD;
BEGIN
    -- Tentative de trouver un employé
    SELECT * INTO v_rec FROM employe WHERE id = v_emp_id;
    
    -- Vérification si l'employé a été trouvé
    IF FOUND THEN
        RAISE NOTICE 'Employé trouvé: %', v_rec.nom;
    ELSE
        RAISE NOTICE 'Aucun employé avec ID %', v_emp_id;
    END IF;
END;
$$;
```

## Tableaux

PL/pgSQL supporte les tableaux pour tous les types de données PostgreSQL:

```sql
DO $$
DECLARE
    v_nombres INTEGER[] := ARRAY[1, 2, 3, 4, 5];
    v_noms TEXT[] := ARRAY['Alice', 'Bob', 'Charlie'];
    v_matrice INTEGER[][] := ARRAY[[1, 2], [3, 4]];
    v_valeur INTEGER;
BEGIN
    -- Accès aux éléments (les indices commencent à 1)
    v_valeur := v_nombres[3]; -- 3
    
    -- Modification d'un élément
    v_noms[2] := 'Robert';
    
    -- Parcours d'un tableau
    FOR i IN 1..array_length(v_nombres, 1) LOOP
        RAISE NOTICE 'Nombre %: %', i, v_nombres[i];
    END LOOP;
    
    -- Fonctions de tableau
    RAISE NOTICE 'Taille du tableau: %', array_length(v_nombres, 1);
    RAISE NOTICE 'Tableau sous forme de texte: %', array_to_string(v_noms, ', ');
END;
$$;
```

## Types composites

Vous pouvez créer des types composites personnalisés et les utiliser dans PL/pgSQL:

```sql
-- Création d'un type composé
CREATE TYPE adresse AS (
    rue VARCHAR(100),
    ville VARCHAR(50),
    code_postal VARCHAR(10)
);

DO $$
DECLARE
    v_adresse adresse;
BEGIN
    -- Assignation de valeurs
    v_adresse := ROW('123 Rue Principale', 'Montréal', 'H1A 1A1');
    
    -- Accès aux champs
    RAISE NOTICE 'Ville: %', v_adresse.ville;
    
    -- Modification
    v_adresse.code_postal := 'H2B 2B2';
END;
$$;
```

## Bonnes pratiques

1. **Convention de nommage**: Utilisez un préfixe pour les variables (v_, p_ pour les paramètres, etc.)

2. **Initialisation**: Initialisez toujours vos variables avec des valeurs par défaut

3. **NOT NULL**: Utilisez NOT NULL pour les variables qui ne devraient jamais être NULL

4. **%TYPE et %ROWTYPE**: Privilégiez leur utilisation pour garantir la cohérence des types

5. **Réutilisation des variables**: Évitez de réutiliser la même variable pour différentes finalités

6. **Documentation**: Commentez les variables complexes ou non évidentes

7. **Portée minimale**: Déclarez les variables dans le bloc le plus interne possible

## Exemples complexes

### Calcul d'une série mathématique

```sql
DO $$
DECLARE
    pi_value DOUBLE PRECISION := 0.0;
    terme DOUBLE PRECISION;
    signe INTEGER := 1;
BEGIN
    -- Calcul de π avec la série de Leibniz: π = 4 * (1 - 1/3 + 1/5 - 1/7 + ...)
    FOR i IN 0..1000 LOOP
        terme := signe * 1.0 / (2.0 * i + 1.0);
        pi_value := pi_value + terme;
        signe := -signe; -- Alternance du signe
    END LOOP;
    
    pi_value := 4.0 * pi_value;
    
    RAISE NOTICE 'Approximation de π: %', pi_value;
    RAISE NOTICE 'Valeur réelle de π: %', pi();
    RAISE NOTICE 'Différence: %', ABS(pi_value - pi());
END;
$$;
```

### Traitement complexe avec enregistrements

```sql
DO $$
DECLARE
    r_dept RECORD;
    r_emp RECORD;
    v_total_salaire NUMERIC := 0;
    v_avg_salaire NUMERIC := 0;
    v_count INTEGER := 0;
BEGIN
    -- Parcours des départements
    FOR r_dept IN SELECT id, nom FROM departement LOOP
        RAISE NOTICE 'Département: %', r_dept.nom;
        
        -- Réinitialisation des compteurs pour chaque département
        v_total_salaire := 0;
        v_count := 0;
        
        -- Parcours des employés du département
        FOR r_emp IN SELECT id, nom, salaire FROM employe WHERE departement = r_dept.id LOOP
            RAISE NOTICE '  Employé: %, Salaire: %', r_emp.nom, r_emp.salaire;
            
            -- Accumulation des statistiques
            v_total_salaire := v_total_salaire + r_emp.salaire;
            v_count := v_count + 1;
        END LOOP;
        
        -- Calcul du salaire moyen pour ce département
        IF v_count > 0 THEN
            v_avg_salaire := v_total_salaire / v_count;
            RAISE NOTICE 'Salaire moyen pour %: % (% employés)', 
                r_dept.nom, v_avg_salaire, v_count;
        ELSE
            RAISE NOTICE 'Aucun employé dans le département %', r_dept.nom;
        END IF;
    END LOOP;
END;
$$;
```

## Liens connexes
- [[PL-INTRODUCTION]] - Introduction à PL/pgSQL
- [[PL-CONTROLE]] - Structures de contrôle
- [[PL-CURSEUR]] - Utilisation des curseurs
- [[PL-EXCEPTIONS]] - Gestion des exceptions
- [[DDL-TYPES]] - Types de données PostgreSQL