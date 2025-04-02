# DQL - Opérateurs et fonctions

SQL dispose d'un riche ensemble d'opérateurs et de fonctions pour manipuler différents types de données.

## Opérateurs de comparaison et logiques

### Opérateurs de comparaison
- `=` : égalité
- `<>` ou `!=` : différent
- `<` : inférieur à
- `<=` : inférieur ou égal à
- `>` : supérieur à
- `>=` : supérieur ou égal à

### Opérateurs logiques
- `AND` : et logique
- `OR` : ou logique
- `NOT` : négation logique

## Opérateurs sur les listes

### BETWEEN
```sql
-- Salaires entre 10 et 20 (bornes incluses)
SELECT nom FROM employe WHERE salaire BETWEEN 10.00 AND 20.00;
```

### IN
```sql
-- Départements spécifiques
SELECT nom FROM employe WHERE departement IN ('ventes', 'r&d');
```

### ANY / SOME
Retourne vrai si au moins une valeur respecte la condition :
```sql
-- Salaire supérieur à au moins une valeur de la liste
SELECT nom FROM employe WHERE salaire > ANY(SELECT salaire FROM employe WHERE nom LIKE 'B%');
```

### ALL
Retourne vrai si toutes les valeurs respectent la condition :
```sql
-- Salaire supérieur ou égal à tous les employés du département des ventes
SELECT nom FROM employe 
WHERE salaire >= ALL(SELECT salaire FROM employe WHERE departement = 
                    (SELECT id FROM departement WHERE nom = 'Ventes'));
```

### EXISTS
Retourne vrai s'il existe au moins une ligne dans la sous-requête :
```sql
-- Départements ayant au moins un employé embauché après juin 2002
SELECT nom FROM departement AS dep
WHERE EXISTS(SELECT 1 FROM employe AS emp
             WHERE date_embauche > '2002-06-01' AND emp.departement = dep.id);
```

## Opérateurs mathématiques

- `-` : négation (-5)
- `+`, `-`, `*`, `/` : opérations arithmétiques de base
- `%` : modulo
- `^` : exponentielle (5^2 = 25)
- `|/`, `||/` : racine carrée et cubique
- `@` : valeur absolue (@-5 = 5)

## Fonctions mathématiques

- `abs(x)`, `sign(x)` : valeur absolue et signe
- `floor(x)`, `ceil(x)`, `round(x[, p])`, `trunc(x[, p])` : arrondissement
- `power(x, y)`, `exp(x)` : puissance et exponentielle
- `log(x)`, `log10(x)`, `ln(x)` : logarithmes
- `sqrt(x)`, `cbrt(x)` : racines carrée et cubique
- `random()`, `setseed(x)` : nombres aléatoires
- `pi()`, `sin(x)`, `cos(x)`, `tan(x)` : fonctions trigonométriques

## Fonctions pour chaînes de caractères

### Opérateurs
- `||` : concaténation de chaînes

### Fonctions
- `ascii(c)`, `chr(i)` : conversion ASCII/caractère
- `lower(s)`, `upper(s)`, `initcap(s)` : changement de casse
- `length(s)` : nombre de caractères
- `substring(s, p[, n])` : extraction de sous-chaîne
- `trim(s)`, `ltrim(s)`, `rtrim(s)` : suppression d'espaces
- `replace(s, from, to)` : remplacement
- `position(substr in str)` : recherche de position

### LIKE
L'opérateur `LIKE` permet la recherche de motifs :
- `%` : remplace zéro à plusieurs caractères
- `_` : remplace exactement un caractère

```sql
SELECT * FROM employe WHERE nom LIKE 'D%';    -- Noms commençant par D
SELECT * FROM employe WHERE nom LIKE '_upuis'; -- Un caractère quelconque suivi de 'upuis'
```

L'opérateur `ILIKE` est similaire mais insensible à la casse.

### Expressions régulières
PostgreSQL supporte les expressions régulières avec les opérateurs :
- `~` : correspondance (sensible à la casse)
- `~*` : correspondance (insensible à la casse)
- `!~`, `!~*` : non-correspondance

```sql
SELECT * FROM employe WHERE nom ~ '^D.*s$';  -- Commence par D et finit par s
```

## Fonctions de date et heure

### Fonctions pour obtenir la date/heure actuelle
- `current_date` : date courante
- `current_time` : heure courante (avec fuseau horaire)
- `current_timestamp` : date et heure courantes (avec fuseau horaire)
- `now()` : date et heure courantes

### Manipulation de dates
- `date_part(partie, date)`, `extract(partie FROM date)` : extraction d'une partie
- `age(timestamp, timestamp)` : calcul d'intervalle
- `make_date(année, mois, jour)` : construction d'une date

## Formatage et conversion

### Formatage
- `to_char(valeur, format)` : conversion en chaîne formatée
- `to_number(chaîne, format)` : conversion en nombre
- `to_date(chaîne, format)` : conversion en date
- `to_timestamp(chaîne, format)` : conversion en timestamp

Exemples :
```sql
SELECT to_char(1234567.89, '9,999,999.99');           -- '1,234,567.89'
SELECT to_char(CURRENT_DATE, 'DD Mon YYYY');          -- '28 Oct 2023'
SELECT to_number(' $1,234.56', 'L9,999.99');          -- 1234.56
SELECT to_date('2023-10-27', 'YYYY-MM-DD');           -- date: 2023-10-27
```

### Conversion de types
- `CAST(expression AS type)` : conversion standard SQL
- `expression::type` : conversion style PostgreSQL

```sql
SELECT CAST('0.75' AS NUMERIC);  -- Syntaxe SQL
SELECT '0.75'::NUMERIC;          -- Syntaxe PostgreSQL
```

## Gestion des valeurs nulles

### Opérateurs pour les valeurs nulles
- `IS NULL` : teste si une valeur est nulle
- `IS NOT NULL` : teste si une valeur n'est pas nulle
- `IS DISTINCT FROM` : comparaison considérant les valeurs nulles
- `IS NOT DISTINCT FROM` : égalité considérant les valeurs nulles

### Fonctions pour les valeurs nulles
- `NULLIF(arg1, arg2)` : retourne NULL si arg1 = arg2, sinon arg1
- `COALESCE(arg1, arg2, ...)` : retourne la première valeur non nulle

Exemples :
```sql
SELECT 1.0 / NULLIF(valeur, 0.0) AS Inverse FROM data;  -- Évite division par zéro
SELECT COALESCE(departement, '-') FROM employe;          -- Remplace NULL par '-'
```

## Liens connexes
- [[DQL-SELECT]] - Structure générale du SELECT
- [[DQL-WHERE]] - Filtrage avec WHERE
- [[DQL-VALEURS-NULLES]] - Gestion des valeurs nulles