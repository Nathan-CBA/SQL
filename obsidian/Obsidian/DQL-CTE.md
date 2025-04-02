# DQL - Expressions de table commune (CTE)

Les Expressions de Table Commune (ETC ou CTE en anglais pour Common Table Expressions) permettent de définir des sous-requêtes temporaires utilisées dans une requête principale, améliorant la lisibilité et la modularité du code SQL.

## Syntaxe de base

```sql
WITH nom_cte AS (
    requête_sql
) [, nom_cte2 AS (
    requête_sql2
)]
SELECT * FROM nom_cte;
```

La clause `WITH` crée et exécute les requêtes internes avant la requête principale. Les résultats intermédiaires générés sont ensuite supprimés après l'exécution complète.

## Caractéristiques des CTE

- Définissent une table temporaire utilisable uniquement dans la requête principale
- Peuvent être utilisées plusieurs fois dans la requête principale
- Peuvent référencer des CTE définies précédemment dans le même `WITH`
- Améliorent la lisibilité des requêtes complexes
- Peuvent être récursives
- Font partie de la norme SQL (depuis SQL3:1999)

## Exemples de CTE

### Exemple 1 : CTE simple
```sql
WITH employes_informatique AS (
    SELECT id, nom, departement
    FROM employees
    WHERE departement = 'Informatique'
)
SELECT * FROM employes_informatique;
```

### Exemple 2 : CTE avec agrégation
```sql
WITH ventes_par_categorie AS (
    SELECT categorie, SUM(montant) AS total_ventes
    FROM ventes
    GROUP BY categorie
)
SELECT categorie, total_ventes
FROM ventes_par_categorie
WHERE total_ventes > 50000;
```

### Exemple 3 : Multiples CTE
```sql
WITH high_salaries AS (
    SELECT id, name, salary, hire_date
    FROM employees
    WHERE salary > 70000
), 
old_rich_employees AS (
    SELECT id, name, salary, hire_date
    FROM high_salaries
    WHERE EXTRACT(YEAR FROM hire_date) < 2015
)
SELECT id, name, salary
FROM old_rich_employees;
```

### Exemple 4 : CTE avec jointure
```sql
WITH high_salaries AS (
    SELECT id, name, salary, department_id
    FROM employees
    WHERE salary > 70000
), 
large_departments (department_id, employee_count) AS (
    SELECT department_id, COUNT(*) 
    FROM employees
    GROUP BY department_id
    HAVING COUNT(*) > 10
)
SELECT hs.id, hs.name, hs.salary, ld.employee_count
FROM high_salaries hs
JOIN large_departments ld ON hs.department_id = ld.department_id;
```

## CTE récursives

Les CTE récursives permettent de traiter des structures hiérarchiques comme les arbres et les graphes.

### Syntaxe des CTE récursives

```sql
WITH RECURSIVE nom_cte AS (
    -- Partie d'ancrage (requête non récursive)
    requete_initiale
    
    UNION [ALL]
    
    -- Partie récursive
    SELECT ...
    FROM nom_cte
    WHERE condition_arret
)
SELECT * FROM nom_cte;
```

Une CTE récursive comporte :
1. Une partie d'ancrage (cas de base)
2. Une partie récursive qui fait référence à la CTE elle-même
3. Une condition d'arrêt pour éviter les boucles infinies

### Exemple 1 : Série de nombres
```sql
WITH RECURSIVE compteur(n) AS (
    VALUES (1)  -- Partie d'ancrage
    UNION ALL
    SELECT n + 1 FROM compteur WHERE n < 5  -- Partie récursive avec condition d'arrêt
)
SELECT n FROM compteur;  -- Résultat: 1, 2, 3, 4, 5
```

### Exemple 2 : Calcul d'une exponentielle
```sql
WITH RECURSIVE Exponentielle(base, exposant, resultat) AS (
    -- Cas de base: Initialiser les valeurs
    VALUES (3, 5, 1)  -- base=3, exposant=5, résultat initial=1
    UNION ALL
    -- Cas récursif: Multiplier le résultat par la base et décrémenter l'exposant
    SELECT base, exposant - 1, resultat * base
    FROM Exponentielle
    WHERE exposant > 0  -- Condition d'arrêt
)
SELECT resultat FROM Exponentielle WHERE exposant = 0;  -- Résultat: 243 (3^5)
```

### Exemple 3 : Hiérarchie d'employés
```sql
WITH RECURSIVE hierarchie(nas, nom, boss, niveau) AS (
    -- Partie d'ancrage : Sélectionner les employés sans superviseur (niveau 1)
    SELECT nas, nom, '-'::VARCHAR(32) AS boss, 1 AS niveau
    FROM employe
    WHERE superviseur IS NULL
    
    UNION ALL
    
    -- Partie récursive : Trouver les employés supervisés et incrémenter le niveau
    SELECT e.nas, e.nom, h.nom, h.niveau + 1
    FROM employe e
    JOIN hierarchie h ON e.superviseur = h.nas
)
SELECT nas, nom, boss, niveau
FROM hierarchie
ORDER BY niveau, nom;
```

## Liens connexes
- [[DQL-SELECT]] - Structure générale du SELECT
- [[DQL-REQUETES-IMBRIQUEES]] - Requêtes imbriquées et corrélées
- [[DQL-JOINTURES]] - Jointures entre tables