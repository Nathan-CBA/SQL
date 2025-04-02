# DQL - SELECT

La clause `SELECT` est l'unique clause du DQL (Data Query Language) et permet de retrouver de l'information dans une base de données.

## Syntaxe de base

```sql
SELECT [DISTINCT] expressions
FROM tables
[WHERE condition]
[GROUP BY expressions]
[HAVING condition]
[ORDER BY expressions [ASC|DESC]]
[LIMIT nombre [OFFSET nombre]]
```

## Résultats d'une requête SELECT

Une requête SELECT retourne toujours l'un de ces résultats :
- Une erreur si la requête est erronée ou refusée
- Le résultat sous forme d'une table avec colonnes et lignes

## SELECT sans FROM

Sans la clause `FROM`, une requête SELECT retourne un seul tuple :

```sql
SELECT 0;                              -- Retourne 0
SELECT 'Bonjour';                      -- Retourne 'Bonjour'
SELECT 2 * 3, 3 * 2;                   -- Retourne 6, 6
SELECT 'Hello' || ' world';            -- Retourne 'Hello world'
SELECT RANDOM();                       -- Retourne un nombre aléatoire
SELECT UPPER('déjà');                  -- Retourne 'DÉJÀ'
```

## SELECT avec FROM

La clause `FROM` spécifie la ou les tables d'où proviennent les données :

```sql
SELECT * FROM employe;                 -- Toutes les colonnes
SELECT nom, prenom FROM employe;       -- Seulement certaines colonnes
SELECT salaire, ROUND(salaire * 1.10, 2) FROM employe;  -- Avec calcul
```

## Alias de colonnes

Il est possible de renommer les colonnes résultantes :

```sql
SELECT salaire AS Salaire,
       ROUND(salaire * 1.10, 2) AS "Nouveau salaire"
FROM employe;
```

## SELECT DISTINCT

Pour éliminer les doublons dans le résultat :

```sql
SELECT DISTINCT departement FROM employe;
```

## Ordre d'évaluation des clauses

Une requête SELECT complète est évaluée dans cet ordre :
1. FROM - Tables source
2. WHERE - Filtrage des lignes
3. GROUP BY - Regroupement 
4. HAVING - Filtrage des groupes
5. SELECT - Sélection des colonnes
6. DISTINCT - Élimination des doublons
7. ORDER BY - Tri
8. LIMIT/OFFSET - Limitation du nombre de résultats

## Liens connexes
- [[DQL-WHERE]] - Filtrage avec WHERE
- [[DQL-OPERATEURS]] - Opérateurs et fonctions
- [[DQL-GROUP-BY]] - Groupement et agrégation
- [[DQL-JOINTURES]] - Jointures entre tables
- [[DQL-ORDER-BY]] - Tri des résultats