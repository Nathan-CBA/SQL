# DML - Importation et exportation de données

PostgreSQL propose la commande `COPY` pour importer ou exporter efficacement des données entre une table et un fichier externe.

## Commande COPY

La commande `COPY` est beaucoup plus performante que des commandes `INSERT` ou `SELECT` pour traiter de gros volumes de données.

### Syntaxe de base

```sql
COPY table_name [ (column_list) ] 
TO|FROM 'fichier'
[WITH (options)];
```

### Direction
- `COPY ... TO ...` : Exporte des données de la table vers un fichier
- `COPY ... FROM ...` : Importe des données d'un fichier vers la table

### Formats supportés
- `TEXT` : Format texte simple (par défaut). Colonnes séparées par des tabulations, lignes par des retours à la ligne.
- `CSV` : Format texte avec gestion des séparateurs, guillemets, etc.
- `BINARY` : Format binaire propriétaire PostgreSQL (plus rapide mais non lisible manuellement).

### Options principales

- `FORMAT` : Spécifie le format (`TEXT`, `CSV` ou `BINARY`).
- `ENCODING` : Spécifie l'encodage du fichier (exemple : 'UTF8').
- `DELIMITER` : Définit le séparateur de colonnes (un seul caractère, tabulation par défaut pour TEXT, virgule pour CSV).
- `NULL` : Spécifie la chaîne représentant la valeur NULL.
- `HEADER` : Pour CSV, indique si le fichier possède un en-tête de colonnes.
  - `FALSE` : lit la première ligne comme étant des données
  - `TRUE` (par défaut) : ignore la première ligne
  - `MATCH` : vérifie que les noms de colonnes correspondent exactement
- `QUOTE` : Pour CSV, caractère utilisé pour entourer les champs (guillemet " par défaut).

## Exemples

### Importation de données

```sql
-- Importer un fichier CSV avec en-tête
COPY clients FROM '/data/clients.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ',',
    ENCODING 'UTF8'
);

-- Importer uniquement certaines colonnes
COPY clients (nom, email, telephone)
FROM '/data/clients.csv'
WITH (FORMAT CSV, DELIMITER ';');
```

### Exportation de données

```sql
-- Exporter toute une table en CSV
COPY clients TO '/data/export_clients.csv'
WITH (FORMAT CSV, HEADER TRUE);

-- Exporter le résultat d'une requête
COPY (SELECT * FROM clients WHERE ville = 'Montréal')
TO '/data/clients_montreal.csv'
WITH (FORMAT CSV, HEADER TRUE);
```

## Approche classique d'import/export

Pour une meilleure gestion des données importées, il est souvent recommandé d'utiliser une approche en plusieurs étapes, particulièrement pour les migrations de données complexes.

### Étapes recommandées pour l'importation

1. **Créer une table temporaire** (sans contraintes généralement)
2. **Charger les données** dans cette table avec `COPY`
3. **Analyser, transformer et valider** les données
4. **Insérer ou mettre à jour** les tables finales
5. **Supprimer** la table temporaire (optionnel)

### Exemple d'importation en plusieurs étapes

```sql
-- 1. Créer une table temporaire
CREATE TEMP TABLE temp_clients (
    nom TEXT,
    email TEXT,
    telephone TEXT,
    adresse TEXT,
    code_postal TEXT,
    date_inscription TEXT
);

-- 2. Charger les données brutes
COPY temp_clients FROM '/data/clients_raw.csv' WITH (FORMAT CSV, HEADER TRUE);

-- 3. Analyser et transformer les données
-- Insertion dans la table finale avec transformation
INSERT INTO clients (nom, email, telephone, adresse, code_postal, date_inscription)
SELECT 
    TRIM(nom),
    LOWER(email),
    REGEXP_REPLACE(telephone, '[^0-9]', '', 'g'),
    TRIM(adresse),
    UPPER(code_postal),
    TO_DATE(date_inscription, 'DD/MM/YYYY')
FROM temp_clients
WHERE email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'  -- Validation d'email
AND LENGTH(TRIM(nom)) > 0;                                        -- Nom non vide

-- 4. Supprimer la table temporaire
DROP TABLE temp_clients;
```

## Opérations courantes lors de l'importation

Voici les opérations fréquemment effectuées lors de l'importation de données :

- **Adaptation de types** : Conversion entre TEXT et autres types (INTEGER, DATE, BOOLEAN, etc.)
- **Nettoyage des données** : Suppression des espaces, homogénéisation de la casse (TRIM, UPPER, etc.)
- **Filtrage des lignes invalides** : Exclusion de lignes selon des critères définis
- **Validation de format** : Vérification par expressions régulières (emails, codes postaux, etc.)
- **Normalisation des valeurs** : Uniformisation d'énumérations, standardisation
- **Génération de valeurs manquantes** : Calcul de valeurs par défaut, dates de référence
- **Contrôle de doublons** : Détection avec DISTINCT, ROW_NUMBER(), ou jointures
- **Vérification de référentiels** : Jointures avec des tables de référence
- **Création de référentiels** : Insertion en plusieurs étapes pour générer les ID nécessaires

## Considérations de performance

- Pour les très grands volumes de données, désactivez temporairement les index et contraintes
- Utilisez des transactions pour garantir la cohérence
- Considérez le traitement par lots pour les ensembles très volumineux
- Surveillez l'espace disque et la mémoire disponible

## Liens connexes
- [[DDL-OBJETS-TEMPORAIRES]] - Tables temporaires
- [[DML-INSERT]] - Insertion de données
- [[DQL-CTE]] - Common Table Expressions
- [[TCL-CONTRAINTES-DIFFEREES]] - Transactions