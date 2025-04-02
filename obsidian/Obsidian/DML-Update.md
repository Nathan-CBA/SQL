# DML - UPDATE

La commande `UPDATE` permet de modifier les données existantes dans une table.

## Syntaxe de base

```sql
UPDATE nom_table
SET colonne1 = valeur1 [, colonne2 = valeur2, ...]
[WHERE condition];
```

Si la clause `WHERE` est omise, la mise à jour s'applique à toutes les lignes de la table.

## Exemples simples

### Mise à jour de toutes les lignes

```sql
-- Augmentation de 5% pour tous les employés
UPDATE employe
SET salaire = salaire * 1.05;
```

### Mise à jour avec condition

```sql
-- Mettre le salaire de l'employé ayant l'id 1 à 50.0
UPDATE employe
SET salaire = 50.00
WHERE id = 1;
```

### Mise à jour de plusieurs colonnes

```sql
-- Mettre en majuscule tous les noms et augmenter de 5$ le salaire
-- des employés ayant la lettre 'a' dans leur nom
UPDATE employe
SET nom = UPPER(nom),
    salaire = salaire + 5.00
WHERE nom LIKE '%a%';
```

## UPDATE avec FROM (PostgreSQL)

PostgreSQL propose une extension à la syntaxe standard permettant d'utiliser des données d'autres tables pour la mise à jour.

```sql
UPDATE nom_table_cible
SET colonne = { expr | DEFAULT | table_source.colonne } [, …]
FROM nom_table_source1 [, nom_table_source2, ...]
WHERE join_condition [AND selection_condition];
```

Exemples :

```sql
-- Les employés déménagent dans la même ville que leur département
UPDATE employee
SET city = department.city
FROM department
WHERE employee.dept_id = department.id;

-- Les employés sont assignés au département de leur superviseur
UPDATE employee AS emp
SET dept_id = department.id
FROM employee AS sup, department AS dep
WHERE emp.supervisor_id = sup.id 
  AND sup.dept_id = department.id
  AND emp.supervisor_id IS NOT NULL 
  AND sup.dept_id IS NOT NULL;
```

## UPDATE avec CTE (Common Table Expressions)

On peut utiliser une CTE pour effectuer des mises à jour plus complexes ou basées sur des calculs préalables.

```sql
-- Met à jour les salaires d'employés spécifiques en utilisant un pré-calcul
WITH updated_salaries AS (
    SELECT emp_id, salaire * 1.1 AS new_salary
    FROM employés
    WHERE dept_id = 10
)
UPDATE employes
SET salaire = new_salary
FROM updated_salaries
WHERE employés.emp_id = updated_salaries.emp_id;
```

## Valeurs spéciales

### DEFAULT

Le mot-clé `DEFAULT` permet de réinitialiser une colonne à sa valeur par défaut :

```sql
UPDATE employe
SET date_embauche = DEFAULT
WHERE id = 5;
```

### NULL

On peut mettre une valeur à NULL (si la colonne accepte les valeurs nulles) :

```sql
UPDATE employe
SET superviseur = NULL
WHERE id = 3;
```

## Considérations importantes

1. **Clause WHERE** : Soyez très attentif à cette clause. Sans elle, toutes les lignes sont mises à jour, ce qui est rarement l'intention.

2. **Contraintes d'intégrité** : La mise à jour échouera si elle viole une contrainte (clé étrangère, valeur unique, etc.).

3. **Performances** : Pour des mises à jour massives, pensez à désactiver temporairement les contraintes et index, puis à les réactiver.

4. **Transactions** : Pour des mises à jour multiples interdépendantes, utilisez des transactions pour garantir que toutes réussissent ou aucune.

5. **Colonnes référencées** : Si une colonne est référencée par une clé étrangère, la mise à jour peut échouer ou nécessiter une cascade.

## Exemple complet

```sql
BEGIN;

-- Augmentation de salaire générale
UPDATE employe
SET salaire = salaire * 1.02;

-- Augmentation supplémentaire pour les seniors
UPDATE employe
SET salaire = salaire * 1.03
WHERE date_embauche < CURRENT_DATE - INTERVAL '5 years';

-- Mise à jour des départements des employés juniors pour qu'ils suivent leur superviseur
UPDATE employe AS emp
SET departement = sup.departement
FROM employe AS sup
WHERE emp.superviseur = sup.id
AND emp.date_embauche > CURRENT_DATE - INTERVAL '1 year';

COMMIT;
```

## Liens connexes
- [[DML-INSERT]] - Insertion de données
- [[DML-Delete]] - Suppression de données
- [[DQL-WHERE]] - Filtrage avec WHERE
- [[DQL-CTE]] - Expressions de table commune
- [[TCL-CONTRAINTES-DIFFEREES]] - Transactions