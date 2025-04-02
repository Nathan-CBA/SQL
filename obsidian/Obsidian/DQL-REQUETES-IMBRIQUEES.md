# DQL - Requêtes imbriquées et corrélées

Les requêtes imbriquées (ou sous-requêtes) permettent d'utiliser le résultat d'une requête à l'intérieur d'une autre requête. Elles améliorent la lisibilité et permettent de réaliser des opérations complexes.

## Requêtes imbriquées non corrélées

Une requête non corrélée est une sous-requête qui peut être exécutée indépendamment de la requête externe. Elle est exécutée une seule fois, et son résultat est utilisé par la requête externe.

```sql
SELECT nom, prenom
FROM employe
WHERE departement = (SELECT id FROM departement WHERE nom = 'Ventes');
```

Dans cet exemple, la sous-requête `(SELECT id FROM departement WHERE nom = 'Ventes')` est exécutée une seule fois pour trouver l'ID du département des ventes, puis ce résultat est utilisé dans la requête principale.

## Requêtes imbriquées corrélées

Une requête corrélée est une sous-requête qui fait référence à une colonne de la requête externe. Elle est exécutée pour chaque ligne de la requête externe.

```sql
-- Trouver les employés dont leur superviseur est également
-- le superviseur de leur département
SELECT nom, prenom
FROM employe
WHERE superviseur = (
    SELECT departement.superviseur
    FROM departement
    WHERE departement.id = employe.departement  -- Référence à la requête externe
);
```

Dans cet exemple, la sous-requête fait référence à `employe.departement`, qui provient de la requête externe. La sous-requête est donc exécutée pour chaque ligne de la table employe.

Autres exemples :

```sql
-- Employés qui gagnent le plus petit salaire de leur département
SELECT nom, prenom
FROM employe AS emp
WHERE salaire = (
    SELECT MIN(es.salaire)
    FROM employe AS es
    WHERE es.departement = emp.departement  -- Référence à la requête externe
);

-- Employés qui gagnent au moins la moyenne salariale de leur département
-- et qui sont en minorité de genre dans leur département
SELECT nom, prenom
FROM employe AS emp
WHERE salaire >= (
    SELECT AVG(es.salaire)
    FROM employe AS es
    WHERE es.departement = emp.departement
)
AND genre = (
    SELECT eg.genre
    FROM employe AS eg
    WHERE eg.departement = emp.departement
    GROUP BY eg.genre
    ORDER BY COUNT(*) ASC
    LIMIT 1
);
```

## Opérateurs ensemblistes

Les opérateurs ensemblistes permettent de comparer une valeur à un ensemble de valeurs retourné par une sous-requête.

### ANY / SOME

Retourne vrai si au moins une valeur dans l'ensemble satisfait la condition.

```sql
-- Employés ayant un salaire supérieur à au moins un employé
-- dont le nom commence par 'B'
SELECT nom, prenom
FROM employe
WHERE salaire > ANY (
    SELECT salaire
    FROM employe
    WHERE nom LIKE 'B%'
);
```

Équivalence :
```
a > ANY(x1, x2, x3) ≡ a > x1 OR a > x2 OR a > x3
```

### ALL

Retourne vrai si toutes les valeurs dans l'ensemble satisfont la condition.

```sql
-- Employés ayant un salaire supérieur ou égal à tous les employés
-- du département des ventes
SELECT nom, prenom
FROM employe
WHERE salaire >= ALL (
    SELECT salaire
    FROM employe
    WHERE departement = (SELECT id FROM departement WHERE nom = 'Ventes')
);
```

Équivalence :
```
a > ALL(x1, x2, x3) ≡ a > x1 AND a > x2 AND a > x3
```

### EXISTS

Retourne vrai s'il existe au moins une ligne dans le résultat de la sous-requête.

```sql
-- Départements ayant au moins un employé embauché après juin 2002
SELECT nom
FROM departement AS dep
WHERE EXISTS (
    SELECT 1
    FROM employe AS emp
    WHERE date_embauche > '2002-06-01' AND emp.departement = dep.id
);
```

### IN

Équivalent à `= ANY`, vérifie si une valeur existe dans l'ensemble.

```sql
-- Employés travaillant dans le département des ventes ou des achats
SELECT nom, prenom
FROM employe
WHERE departement IN (
    SELECT id
    FROM departement
    WHERE nom IN ('Ventes', 'Achats')
);
```

### NOT IN

Équivalent à `<> ALL`, vérifie si une valeur n'existe pas dans l'ensemble.

```sql
-- Employés ne travaillant pas dans les départements de Montréal
SELECT nom, prenom
FROM employe
WHERE departement NOT IN (
    SELECT id
    FROM departement
    WHERE ville = 'Montréal'
);
```

## Combinaisons de requêtes

Il est possible de combiner les résultats de plusieurs requêtes en un seul ensemble de résultats.

### UNION / UNION ALL

Combine les résultats de deux requêtes.
- `UNION` élimine les doublons
- `UNION ALL` conserve tous les résultats, y compris les doublons

```sql
-- Liste de tous les noms et prénoms des employés
SELECT nom FROM employe
UNION
SELECT prenom FROM employe;
```

### INTERSECT

Retourne les lignes qui sont présentes dans les deux requêtes.

```sql
-- Employés qui sont à la fois superviseurs d'autres employés
-- et superviseurs de département
SELECT id FROM employe WHERE id IN (SELECT superviseur FROM employe)
INTERSECT
SELECT superviseur FROM departement;
```

### EXCEPT (ou MINUS)

Retourne les lignes de la première requête qui ne sont pas présentes dans la deuxième.

```sql
-- Départements sans employés
SELECT id FROM departement
EXCEPT
SELECT departement FROM employe WHERE departement IS NOT NULL;
```

## Liens connexes
- [[DQL-SELECT]] - Structure générale du SELECT
- [[DQL-WHERE]] - Filtrage avec WHERE
- [[DQL-CTE]] - Expressions de table commune