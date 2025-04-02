# DML - INSERT

La commande `INSERT` permet d'ajouter des données dans une table existante.

## Syntaxe de base

```sql
INSERT INTO nom_table [(colonne1 [, colonne2, ...])]
VALUES (valeur1 [, valeur2, ...]) [, (valeur1 [, valeur2, ...]), ...];
```

Ou

```sql
INSERT INTO nom_table [(colonne1 [, colonne2, ...])]
SELECT ...;
```

## Variantes et options

### Insertion sans spécifier les colonnes

Dans ce cas, les valeurs doivent être fournies pour toutes les colonnes, dans l'ordre où elles apparaissent dans la définition de la table.

```sql
INSERT INTO employe 
VALUES (1000, 'Lebel', '2000-01-01', 20.00);
```

### Insertion avec spécification explicite des colonnes

On peut spécifier uniquement les colonnes pour lesquelles on veut fournir des valeurs. Les autres colonnes recevront leur valeur par défaut ou NULL.

```sql
INSERT INTO employe (id, nom, date_embauche, salaire)
VALUES (1001, 'Miron', '2000-01-02', 25.00);
```

### Utilisation de DEFAULT

Le mot-clé `DEFAULT` permet d'insérer explicitement la valeur par défaut définie pour une colonne.

```sql
INSERT INTO employe (id, nom, date_embauche, salaire)
VALUES (DEFAULT, 'Labonté', DEFAULT, 25.00);
```

### Insertion partielle

On peut omettre certaines colonnes si elles acceptent NULL ou ont une valeur par défaut.

```sql
INSERT INTO employe (nom, salaire)
VALUES ('Labonté', 25.00);
```

### Insertions multiples

On peut insérer plusieurs lignes en une seule commande.

```sql
INSERT INTO employe (salaire, nom)
VALUES (25.00, 'Laroche'),
       (DEFAULT, 'Gravel'),
       (35.00, 'Lapierre');
```

### Insertion à partir d'une requête SELECT

On peut insérer le résultat d'une requête SELECT.

```sql
INSERT INTO employe (nom, salaire)
SELECT nom, 25.00 FROM employe WHERE nom LIKE '%a%';
```

## Séquences et champs à auto-incrément

Pour les colonnes de type `SERIAL` (auto-incrément), PostgreSQL gère automatiquement les valeurs via des séquences. Il est préférable de laisser PostgreSQL générer ces valeurs en utilisant `DEFAULT` ou en omettant la colonne.

```sql
INSERT INTO employe (nom, date_embauche, salaire)
VALUES ('Dupont', '2023-01-15', 30.00);
```

## Considérations importantes

1. **Contraintes d'intégrité** : L'insertion échouera si elle viole une contrainte (clé primaire, clé étrangère, valeur unique, etc.).

2. **Colonnes NOT NULL** : Si une colonne est déclarée NOT NULL et n'a pas de valeur par défaut, vous devez fournir une valeur.

3. **Colonnes SERIAL** : Évitez de fournir explicitement des valeurs pour ces colonnes, sauf si vous avez une bonne raison.

4. **Transactions** : Pour des insertions multiples interdépendantes, utilisez des transactions pour garantir que toutes réussissent ou aucune.

## Exemple complet

```sql
-- Création d'une table
CREATE TABLE employe (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(32) NOT NULL,
    date_embauche DATE NOT NULL DEFAULT CURRENT_DATE,
    salaire NUMERIC(5, 2)
);

-- Insertion simple
INSERT INTO employe VALUES (1000, 'Lebel', '2000-01-01', 20.00);

-- Insertion avec colonnes spécifiées
INSERT INTO employe(id, nom, date_embauche, salaire)
VALUES (1001, 'Miron', '2000-01-02', 25.00);

-- Insertion avec valeurs par défaut
INSERT INTO employe(id, nom, date_embauche, salaire)
VALUES (DEFAULT, 'Labonté', DEFAULT, 25.00);

-- Insertion partielle
INSERT INTO employe(nom, salaire)
VALUES ('Labonté', 25.00);

-- Insertions multiples
INSERT INTO employe(salaire, nom)
VALUES (25.00, 'Laroche'),
       (DEFAULT, 'Gravel'),
       (35.00, 'Lapierre');

-- Insertion à partir d'une requête
INSERT INTO employe(nom, salaire)
SELECT nom, 25.00 FROM employe WHERE nom LIKE '%a%';
```

## Liens connexes
- [[DDL-CONTRAINTES]] - Contraintes d'intégrité
- [[DDL-SEQUENCES]] - Séquences
- [[DML-UPDATE]] - Mise à jour de données
- [[TCL-CONTRAINTES-DIFFEREES]] - Transactions