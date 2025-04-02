# DQL - WHERE

La clause `WHERE` permet de filtrer les lignes retournées par une requête en spécifiant une condition.

## Syntaxe de base

```sql
SELECT ...
FROM ...
WHERE condition
```

La clause `WHERE` utilise une expression logique (retournant une valeur booléenne) qui est évaluée pour chaque ligne. Seules les lignes pour lesquelles l'expression est vraie sont incluses dans le résultat.

## Opérateurs de comparaison

- `=` : égalité
- `<>` ou `!=` : différent
- `<` : plus petit que
- `<=` : plus petit ou égal à
- `>` : plus grand que
- `>=` : plus grand ou égal à

Exemples :
```sql
SELECT * FROM employe WHERE salaire >= 25;
SELECT * FROM employe WHERE nom = 'Dupuis';
```

## Opérateurs logiques

- `AND` : et logique
- `OR` : ou logique
- `NOT` : négation logique

Exemple :
```sql
SELECT * FROM employe WHERE nom <> 'Dupuis' AND salaire >= 20;
```

## Opérateur BETWEEN

L'opérateur `BETWEEN` permet de vérifier si une valeur est comprise dans un intervalle (bornes incluses) :

```sql
SELECT nom FROM employe WHERE salaire BETWEEN 10.00 AND 20.00;
```

Équivalent à :
```sql
SELECT nom FROM employe WHERE salaire >= 10.00 AND salaire <= 20.00;
```

## Opérateur IN

L'opérateur `IN` vérifie si une valeur fait partie d'une liste spécifiée :

```sql
SELECT nom FROM employe WHERE departement IN ('ventes', 'r&d');
```

## Opérateur LIKE

L'opérateur `LIKE` permet de rechercher des motifs dans des chaînes de caractères :

- `%` : remplace 0 à n caractères
- `_` : remplace exactement un caractère

```sql
SELECT * FROM employe WHERE nom LIKE 'D%';    -- Noms commençant par D
SELECT * FROM employe WHERE nom LIKE '_upuis'; -- Seconde lettre suivie de 'upuis'
```

L'opérateur `ILIKE` est similaire mais insensible à la casse.

## Expressions régulières

PostgreSQL supporte les expressions régulières avec les opérateurs :
- `~` : correspondance (sensible à la casse)
- `~*` : correspondance (insensible à la casse)
- `!~` : non-correspondance (sensible à la casse)
- `!~*` : non-correspondance (insensible à la casse)

```sql
SELECT * FROM employe WHERE nom ~ '^D.*s$';  -- Commence par D et finit par s
```

## IS NULL / IS NOT NULL

Pour tester si une valeur est nulle ou non :

```sql
SELECT * FROM employe WHERE superviseur IS NULL;        -- Sans superviseur
SELECT * FROM employe WHERE departement IS NOT NULL;    -- Avec département
```

## Liens connexes
- [[DQL-SELECT]] - Structure générale du SELECT
- [[DQL-OPERATEURS]] - Opérateurs et fonctions
- [[DQL-VALEURS-NULLES]] - Gestion des valeurs nulles