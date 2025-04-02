# DQL - Regroupement et agrégation

La clause `GROUP BY` permet de regrouper les lignes ayant des valeurs identiques dans les colonnes spécifiées, généralement pour effectuer des calculs agrégés sur ces groupes.

## Fonctions d'agrégation

Les fonctions d'agrégation effectuent un calcul sur un ensemble de valeurs et retournent une seule valeur.

- `COUNT(*)` : nombre total de lignes (incluant les valeurs nulles)
- `COUNT(colonne)` : nombre de valeurs non nulles dans la colonne
- `COUNT(DISTINCT colonne)` : nombre de valeurs distinctes non nulles
- `MIN(colonne)` : valeur minimum
- `MAX(colonne)` : valeur maximum
- `SUM(colonne)` : somme des valeurs
- `AVG(colonne)` : moyenne des valeurs

À l'exception de `COUNT(*)`, toutes les fonctions d'agrégation ignorent les valeurs nulles.

Exemple :
```sql
-- Statistiques sur les salaires du département des ventes
SELECT COUNT(*) AS "Nombre",
       MIN(salaire) AS "Salaire minimum",
       MAX(salaire) AS "Salaire maximum",
       SUM(salaire) AS "Masse salariale",
       AVG(salaire) AS "Moyenne des salaires"
FROM employe
WHERE departement = (SELECT id FROM departement WHERE nom = 'Ventes');
```

## GROUP BY

La clause `GROUP BY` permet de regrouper les lignes selon un ou plusieurs critères et d'appliquer des fonctions d'agrégation sur chaque groupe.

```sql
SELECT colonne_de_regroupement, fonction_agregation(colonne)
FROM table
GROUP BY colonne_de_regroupement;
```

Dans une requête avec `GROUP BY`, seuls peuvent apparaître dans la clause `SELECT` :
- Les colonnes utilisées dans le regroupement
- Les résultats des fonctions d'agrégation

Exemple :
```sql
-- Nombre d'employés et statistiques par département
SELECT departement,
       COUNT(salaire),
       MIN(salaire),
       MAX(salaire),
       SUM(salaire),
       AVG(salaire)
FROM employe
WHERE departement IS NOT NULL
GROUP BY departement;
```

## HAVING

La clause `HAVING` permet de filtrer les groupes en appliquant une condition sur les résultats agrégés.

- `WHERE` filtre les lignes avant le regroupement
- `HAVING` filtre les groupes après le regroupement

La clause `HAVING` ne peut être utilisée sans la clause `GROUP BY`.

```sql
SELECT colonne_de_regroupement, fonction_agregation(colonne)
FROM table
GROUP BY colonne_de_regroupement
HAVING condition_sur_agregation;
```

Exemple :
```sql
-- Départements ayant au moins 5 employés
SELECT departement, COUNT(*)
FROM employe
GROUP BY departement
HAVING COUNT(*) >= 5;
```

## Utilisation conjointe WHERE et HAVING

```sql
-- Moyenne salariale des hommes par département supérieure à 35$
-- Retourne seulement les trois départements avec les plus hautes moyennes
SELECT departement, AVG(salaire) AS "Moyenne des salaires"
FROM employe
WHERE genre = 'h'
GROUP BY departement
HAVING AVG(salaire) > 35.0
ORDER BY "Moyenne des salaires" DESC
LIMIT 3;
```

## Fonctions d'agrégation supplémentaires (PostgreSQL)

PostgreSQL propose plusieurs autres fonctions d'agrégation :

- `BOOL_AND(colonne)` : ET logique sur toutes les valeurs
- `BOOL_OR(colonne)` : OU logique sur toutes les valeurs
- `STRING_AGG(colonne, délimiteur)` : concaténation de toutes les chaînes
- `VAR_POP(colonne)` / `VAR_SAMP(colonne)` : variance de la population/échantillon
- `STDDEV_POP(colonne)` / `STDDEV_SAMP(colonne)` : écart-type de la population/échantillon

## Liens connexes
- [[DQL-SELECT]] - Structure générale du SELECT
- [[DQL-WHERE]] - Filtrage avec WHERE
- [[DQL-OPERATEURS]] - Opérateurs et fonctions