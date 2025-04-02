# Langages d'exploitation des bases de données (420-C42)

  

## Partie 5: DQL I - Introduction aux requêtes de consultation

  

### 1. Principes fondamentaux de SELECT

  

- La clause SELECT est la seule clause du DQL (souvent classée dans le groupe DML)

- Une requête SELECT retourne toujours:

  - Une erreur si la requête est erronée ou refusée

  - Sinon, un résultat sous forme de table avec colonne(s) et ligne(s)

- Le résultat d'une requête est toujours un ensemble de lignes et de colonnes (table)

  

#### Requête SELECT simple

```sql

-- Sélection de constantes

SELECT 0;

SELECT 'Bonjour';

SELECT '2000-01-01';

  

-- Opérations arithmétiques

SELECT 2 * 3, 3 * 2;

  

-- Concaténation de chaînes

SELECT 'Hello' || ' world';

  

-- Opérations sur les dates

SELECT DATE('2000-01-01') + '1';

  

-- Fonctions

SELECT RANDOM();

SELECT UPPER('déjà');

SELECT NOW();

  

-- Combinaisons d'expressions

SELECT 100, 'Bonsoir', SQRT(81) + SIN(RANDOM()), EXTRACT(YEAR FROM NOW());

```

  

### 2. Clause FROM

  

- La clause FROM spécifie la table source des données

- L'utilisation de SELECT avec FROM retourne n lignes (où n = nombre de tuples dans la table)

- La clause SELECT identifie les colonnes désirées:

  - `*` sélectionne toutes les colonnes

  - On peut spécifier les colonnes par leur nom

  - On peut appliquer des opérations et fonctions aux données

  

```sql

SELECT * FROM employe;

SELECT nom, prenom, salaire FROM employe;

SELECT nom, NOW() - date_embauche FROM employe;

SELECT salaire, ROUND(salaire * 1.10, 2) FROM employe;

```

  

### 3. Alias (AS)

  

- Les alias permettent de renommer les colonnes de sortie

- Syntaxe avec AS (recommandée) ou simplement avec un espace

- L'alias devient le titre de la colonne dans le résultat

- Utiliser des guillemets si l'alias contient des espaces ou caractères spéciaux

  

```sql

SELECT salaire AS Salaire,

       ROUND(salaire * 1.10, 2) "Nouveau salaire"

FROM employe;

```

  

### 4. Clause WHERE

  

- La clause WHERE filtre les lignes selon une condition logique

- La ligne est gardée si la condition est vraie, sinon elle est exclue

- Les conditions peuvent être formées avec:

  - Opérateurs de comparaison: `=`, `<>`, `<`, `<=`, `>`, `>=`

  - Opérateurs logiques: `AND`, `OR`, `NOT`

  - Recherche dans liste: `IN`

  - Recherche dans intervalle: `BETWEEN`

  - Recherche dans chaîne: `LIKE`

  - Test de valeur nulle: `IS NULL`

  

```sql

SELECT * FROM employe WHERE salaire >= 25;

SELECT * FROM employe WHERE nom = 'Dupuis';

SELECT * FROM employe WHERE nom <> 'Dupuis' AND salaire >= 20;

SELECT nom, prenom FROM employe WHERE date_embauche < '2002-01-01';

```

  

### 5. SELECT DISTINCT

  

- Permet d'éliminer les doublons du résultat

- Utile pour obtenir des listes de valeurs uniques

  

```sql

-- Peut contenir des doublons

SELECT departement FROM employe;

  

-- Sans doublons

SELECT DISTINCT departement FROM employe;

```

  

### 6. Opérateurs et fonctions

  

#### Opérateurs de comparaison et logiques

- Comparaisons: `=`, `<>` ou `!=`, `<`, `<=`, `>`, `>=`

- Logiques: `AND`, `OR`, `NOT`

  

#### Opérateur BETWEEN

- Simplifie la vérification d'un intervalle avec bornes inclusives

```sql

SELECT nom FROM employe WHERE salaire BETWEEN 10.00 AND 20.00;

-- Équivalent à:

SELECT nom FROM employe WHERE salaire >= 10.00 AND salaire <= 20.00;

```

  

#### Opérateurs sur les listes

- `ANY`/`SOME`: vrai si au moins une valeur respecte la condition

```sql

SELECT * FROM employe WHERE xyz >= ANY(VALUES (12), (5), (74));

-- Équivalent à:

SELECT * FROM employe WHERE xyz >= 12 OR xyz >= 5 OR xyz >= 74;

```

  

- `ALL`: vrai si toutes les valeurs respectent la condition

```sql

SELECT * FROM employe WHERE xyz >= ALL(VALUES (12), (5), (74));

-- Équivalent à:

SELECT * FROM employe WHERE xyz >= 12 AND xyz >= 5 AND xyz >= 74;

```

  

- `IN`: vérifie si une valeur existe dans la liste (équivalent à `= ANY`)

- `NOT IN`: vérifie si une valeur n'existe pas dans la liste (équivalent à `<> ALL`)

```sql

SELECT nom FROM employe WHERE departement IN ('ventes', 'r&d');

```

  

#### Opérateurs mathématiques

- `-` (négation), `+`, `-`, `*`, `/` (arithmétiques), `%` (modulo), `^` (exponentiel)

- `|/`, `||/` (racines carrée et cubique), `@` (valeur absolue)

- Opérateurs bit à bit: `&`, `|`, `#`, `~`, `<<`, `>>`

  

#### Fonctions mathématiques

- `abs`, `sign`, `floor`, `ceil`, `round`, `trunc`

- `gcd`, `lcm`, `power`, `exp`, `log`, `log10`, `ln`

- `sqrt`, `cbrt`, `degrees`, `radians`

- `random`, `setseed`, `pi`, fonctions trigonométriques

  

#### Opérateurs et fonctions pour chaînes de caractères

- Concaténation: `||`

- Fonctions: `ascii`, `chr`, `lower`, `upper`, `initcap`, `concat`

- Longueur: `char_length`, `length`

- Manipulation: `overlay`, `translate`, `replace`, `position`, `strpos`

- Extraction: `substr`, `left`, `right`

- Espacement: `trim`, `ltrim`, `rtrim`, `lpad`, `rpad`

- Expressions régulières: `substring`, `regexp_...`

  

#### Opérateur LIKE

- Utilisé pour la recherche de motifs dans les chaînes

- `_` : substitution d'un caractère quelconque

- `%` : substitution de 0 à n caractères quelconques

- `ILIKE` pour recherche insensible à la casse

```sql

SELECT 'Gaston' LIKE 'Gaston';  -- vrai

SELECT 'Gaston' LIKE 'G_ston';  -- vrai

SELECT 'Gaston' LIKE 'ga%on';   -- faux

SELECT 'Gaston' ILIKE 'g%';     -- vrai

```

  

#### Expressions régulières

- Opérateurs: `~` (correspondance), `!~` (non correspondance)

- `~*`, `!~*` pour recherche insensible à la casse

- Fonctions: `regexp_replace`, `regexp_match(es)`

  

#### Opérateurs et fonctions pour dates/heures

- Opérateurs: `+`, `-`, `*`, `/`

- Fonctions: `current_date`, `current_time`, `current_timestamp`, etc.

- Extraction: `date_part`, `extract`

- Construction: `make_date`

- Calcul: `age`

  

#### Formatage (entrée/sortie)

- Conversion type → chaîne: `to_char`

- Conversion chaîne → type: `to_number`, `to_date`, `to_timestamp`

```sql

SELECT to_char(1234567.89, '9,999,999.99');              -- 1,234,567.89

SELECT to_char(CURRENT_DATE, 'DD Mon YYYY');             -- Ex: 28 Oct 2025

SELECT to_number(' $1,234.56', 'L9,999.99');             -- 1234.56

SELECT to_date('2023-10-27', 'YYYY-MM-DD');              -- 2023-10-27

```

  

#### Conversion de types

- Conversion implicite

- Conversion explicite:

  - Opérateur CAST (standard SQL)

  - Opérateur :: (style PostgreSQL)

  - Notation avec type

```sql

SELECT ROUND(0.75);                             -- Implicite

SELECT ROUND(CAST('0.75' AS NUMERIC));          -- Explicite avec CAST

SELECT ROUND('0.75'::NUMERIC);                  -- Explicite avec ::

SELECT ROUND(NUMERIC '0.75');                   -- Explicite avec notation type

```

  

### 7. Valeurs nulles

  

- Une valeur nulle peut représenter: une valeur inconnue, ou un sens spécifique au contexte

- Comportement avec opérateurs:

  - `5 + NULL` → NULL

  - `TRUE AND NULL` → NULL

  - `TRUE OR NULL` → TRUE

- Opérateurs spécifiques pour les NULL:

  - `IS NULL` / `IS NOT NULL`

  - `IS DISTINCT FROM` / `IS NOT DISTINCT FROM`

- Fonctions pour traiter les NULL:

  - `NULLIF(arg1, arg2)`: retourne NULL si arg1 = arg2, sinon arg1

  - `COALESCE(arg1, arg2, ...)`: retourne la première valeur non nulle

```sql

SELECT 1.0 / NULLIF(value, 0.0) AS Inverse FROM data;

SELECT prenom || ' ' || nom FROM employe WHERE departement IS NULL;

SELECT prenom || ' ' || nom, COALESCE(departement, '-') FROM employe;

```

  

### 8. ORDER BY

  

- L'ordre des résultats d'une requête sans ORDER BY est arbitraire

- La clause ORDER BY permet de trier selon un ou plusieurs critères

- Options de tri:

  - `ASC` (croissant, défaut) / `DESC` (décroissant)

  - `NULLS FIRST` / `NULLS LAST` (position des valeurs nulles)

- Possibilité d'utiliser les alias dans ORDER BY

  

```sql

SELECT nom, prenom, departement

FROM employe

ORDER BY nom;

  

SELECT nom, prenom, departement AS dep

FROM employe

ORDER BY dep ASC NULLS LAST,

         nom DESC NULLS LAST,

         prenom;

```

  

### 9. LIMIT & OFFSET

  

- Permettent de récupérer un sous-ensemble de résultats

- `LIMIT`: nombre maximal de lignes à retourner

- `OFFSET`: à partir de quelle ligne commencer (0 = première ligne)

  

```sql

SELECT nom, prenom, departement

FROM employe

ORDER BY nom

LIMIT 3

OFFSET 2;

```

  

### 10. CASE

  

- Expression conditionnelle générique (comme un IF-THEN-ELSE)

- Syntaxe:

```sql

CASE WHEN condition THEN résultat

     [WHEN condition THEN résultat]*

     [ELSE résultat_défaut]

END

```

  

- Exemple:

```sql

SELECT

  nom,

  CASE WHEN genre = 'f' THEN 'Femme'

       WHEN genre = 'h' THEN 'Homme'

       WHEN genre = 'x' THEN 'Non binaire'

       ELSE 'Genre inconnu'

  END AS Genre,

  CASE WHEN ville = 'Montréal' THEN 'Citadin'

       ELSE 'Banlieusard'

  END AS Habite

FROM employe;

```

  

### 11. Requêtes imbriquées

  

- Une requête peut être utilisée à l'intérieur d'une autre requête

- La requête interne doit être entre parenthèses

- Usages courants:

  - Comme scalaire (dans une comparaison)

  - Comme liste (avec IN, ANY, ALL)

  

```sql

-- Employés du même département que Dupuis

SELECT nom, prenom

FROM employe

WHERE departement = (SELECT departement

                     FROM employe

                     WHERE nom = 'Dupuis');

  

-- Employés habitant dans les mêmes villes que les employés de R&D

SELECT nom, prenom

FROM employe

WHERE ville IN (SELECT ville

                FROM employe

                WHERE departement = 'r&d');

```

  

### 12. Combinaisons de requêtes

  

- Opérateurs:

  - `UNION`: union des résultats des deux requêtes

  - `INTERSECT`: intersection des résultats (lignes communes)

  - `EXCEPT`: différence (lignes de la 1ère requête absentes de la 2ème)

- Les requêtes combinées doivent avoir le même schéma (même nombre et types de colonnes)

  

```sql

SELECT nom FROM employe

UNION

SELECT prenom FROM employe;

```

  

### Points importants à retenir

  

1. SELECT est la seule clause du DQL, mais peut être accompagnée de clauses complémentaires.

2. L'ordre des résultats est arbitraire sans ORDER BY.

3. Les valeurs NULL nécessitent un traitement spécifique.

4. La puissance de SQL se trouve dans la combinaison des fonctions, opérateurs et clauses.

5. Les requêtes imbriquées permettent de construire des requêtes complexes.

6. Toujours consulter la documentation du SGBD utilisé pour connaître les spécificités d'implémentation.