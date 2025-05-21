
# 📘 Fonctions SQL de base

## 📅 Fonctions de date et heure

| Fonction | Description | Exemple |
|----------|-------------|---------|
| `TO_CHAR(date, format)` | Convertit une date en texte formaté | `TO_CHAR(NOW(), 'YYYY-MM-DD')` |
| `CURRENT_DATE` | Date actuelle | `SELECT CURRENT_DATE;` |
| `CURRENT_TIME` | Heure actuelle | `SELECT CURRENT_TIME;` |
| `NOW()` | Timestamp actuel complet | `SELECT NOW();` |
| `AGE(date1, date2)` | Différence entre deux dates | `AGE(NOW(), date_embauche)` |
| `DATE_TRUNC('part', date)` | Tronque la date à l’unité donnée (`month`, etc.) | `DATE_TRUNC('month', NOW())` |
| `EXTRACT(part FROM date)` | Extrait une composante (`year`, `month`, etc.) | `EXTRACT(YEAR FROM NOW())` |

## 🔤 Fonctions sur les chaînes de caractères

| Fonction | Description | Exemple |
|----------|-------------|---------|
| `UPPER(string)` | Met en majuscules | `UPPER('nathan') → 'NATHAN'` |
| `LOWER(string)` | Met en minuscules | `LOWER('MONTRÉAL') → 'montréal'` |
| `INITCAP(string)` | Première lettre de chaque mot en majuscule | `INITCAP('nathan cherizier') → 'Nathan Cherizier'` |
| `CONCAT(str1, str2)` | Concatène deux chaînes | `CONCAT(nom, prenom)` |
| `string1 || string2` | Concaténation avec l’opérateur `||` | `nom || ' ' || prenom` |
| `SUBSTRING(string FROM int FOR int)` | Sous-chaîne | `SUBSTRING('Nathan' FROM 1 FOR 3) → 'Nat'` |
| `LENGTH(string)` | Longueur de la chaîne | `LENGTH('SQL') → 3` |
| `TRIM(string)` | Supprime les espaces au début et fin | `TRIM('  test  ') → 'test'` |
| `REPLACE(string, from, to)` | Remplace une sous-chaîne | `REPLACE('abc_def', '_', '-') → 'abc-def'` |

## 🔢 Fonctions numériques

| Fonction | Description | Exemple |
|----------|-------------|---------|
| `ROUND(nombre, n)` | Arrondit à `n` décimales | `ROUND(123.456, 1) → 123.5` |
| `CEIL(x)` | Arrondi supérieur | `CEIL(4.2) → 5` |
| `FLOOR(x)` | Arrondi inférieur | `FLOOR(4.8) → 4` |
| `ABS(x)` | Valeur absolue | `ABS(-10) → 10` |
| `MOD(x, y)` | Reste de la division | `MOD(10, 3) → 1` |
| `POWER(x, y)` | Puissance | `POWER(2, 3) → 8` |
| `SQRT(x)` | Racine carrée | `SQRT(16) → 4` |

## 🔎 Fonctions d’agrégation

| Fonction | Description | Exemple |
|----------|-------------|---------|
| `SUM(col)` | Somme | `SUM(salaire)` |
| `AVG(col)` | Moyenne | `AVG(heures)` |
| `MIN(col)` | Valeur minimale | `MIN(date_embauche)` |
| `MAX(col)` | Valeur maximale | `MAX(salaire)` |
| `COUNT(*)` | Nombre de lignes | `COUNT(*)` |
| `COUNT(col)` | Nombre de valeurs non nulles | `COUNT(nom)` |
