# DQL - Gestion des valeurs nulles

La valeur NULL représente l'absence de valeur ou une valeur inconnue dans une base de données SQL. Sa gestion appropriée est essentielle pour maintenir l'intégrité des données et obtenir des résultats de requête corrects.

## Concept de NULL

### Définition

NULL n'est pas une valeur à proprement parler, mais plutôt l'absence de valeur. Il est important de comprendre que :

- NULL n'est égal à rien, pas même à lui-même
- NULL n'est ni vrai ni faux, mais inconnu
- NULL nécessite des opérateurs et fonctions spécifiques pour sa manipulation

### Différence entre NULL et autres valeurs

NULL diffère fondamentalement des valeurs comme 0, '' (chaîne vide), ou false :

| Valeur | Signification |
|--------|---------------|
| NULL | Valeur inconnue ou absence de valeur |
| 0 | Valeur numérique connue égale à zéro |
| '' (chaîne vide) | Chaîne de caractères connue ne contenant aucun caractère |
| false | Valeur booléenne connue et fausse |

### Situations où NULL apparaît

- Colonne sans valeur par défaut et aucune valeur fournie lors de l'insertion
- Valeur explicitement définie à NULL
- Résultat d'une opération impliquant NULL
- Absence de correspondance dans une jointure externe

## Opérateurs pour NULL

### IS NULL / IS NOT NULL

Les opérateurs standard (=, <>, etc.) ne fonctionnent pas avec NULL. Pour tester si une valeur est NULL, utilisez :

```sql
-- Trouver les employés sans supérieur
SELECT nom, prenom 
FROM employe 
WHERE superviseur IS NULL;

-- Trouver les employés avec un département assigné
SELECT nom, prenom 
FROM employe 
WHERE departement IS NOT NULL;
```

### IS DISTINCT FROM / IS NOT DISTINCT FROM

Ces opérateurs traitent NULL comme une valeur comparable :

```sql
-- IS DISTINCT FROM (similaire à <> mais gère NULL)
SELECT * FROM employe 
WHERE departement IS DISTINCT FROM 3;  -- Inclut les NULL

-- IS NOT DISTINCT FROM (similaire à = mais gère NULL)
SELECT * FROM employe 
WHERE departement IS NOT DISTINCT FROM ancien_departement;  -- Même valeur ou tous deux NULL
```

Comparaison des comportements :

| a | b | a = b | a <> b | a IS NOT DISTINCT FROM b | a IS DISTINCT FROM b |
|---|---|-------|--------|--------------------------|----------------------|
| 1 | 1 | TRUE | FALSE | TRUE | FALSE |
| 1 | 2 | FALSE | TRUE | FALSE | TRUE |
| 1 | NULL | NULL | NULL | FALSE | TRUE |
| NULL | NULL | NULL | NULL | TRUE | FALSE |

## Logique à trois valeurs

SQL utilise une logique à trois valeurs : TRUE, FALSE et UNKNOWN (résultat d'opérations avec NULL).

### Tables de vérité

#### Opérateur AND

| a | b | a AND b |
|---|---|---------|
| TRUE | TRUE | TRUE |
| TRUE | FALSE | FALSE |
| TRUE | NULL | NULL |
| FALSE | TRUE | FALSE |
| FALSE | FALSE | FALSE |
| FALSE | NULL | FALSE |
| NULL | TRUE | NULL |
| NULL | FALSE | FALSE |
| NULL | NULL | NULL |

#### Opérateur OR

| a | b | a OR b |
|---|---|---------|
| TRUE | TRUE | TRUE |
| TRUE | FALSE | TRUE |
| TRUE | NULL | TRUE |
| FALSE | TRUE | TRUE |
| FALSE | FALSE | FALSE |
| FALSE | NULL | NULL |
| NULL | TRUE | TRUE |
| NULL | FALSE | NULL |
| NULL | NULL | NULL |

#### Opérateur NOT

| a | NOT a |
|---|-------|
| TRUE | FALSE |
| FALSE | TRUE |
| NULL | NULL |

### Impact sur les requêtes

Cette logique à trois valeurs peut créer des comportements surprenants :

```sql
-- Ceci ne retourne PAS tous les employés
SELECT * FROM employe WHERE departement = 3 OR departement <> 3;

-- Pour inclure aussi les NULL, il faut explicitement les mentionner
SELECT * FROM employe WHERE departement = 3 OR departement <> 3 OR departement IS NULL;

-- Alternative plus simple
SELECT * FROM employe;  -- Tous les employés, sans condition
```

## Fonctions pour gérer NULL

### COALESCE

`COALESCE` retourne le premier argument non NULL dans une liste. C'est l'équivalent PostgreSQL de NVL (Oracle) ou IFNULL (MySQL).

```sql
-- Retourne une valeur par défaut si NULL
SELECT nom, COALESCE(departement, 0) AS departement
FROM employe;

-- Chaîner plusieurs alternatives
SELECT COALESCE(telephone, mobile, email, 'Aucun contact') AS contact
FROM clients;
```

### NULLIF

`NULLIF` compare deux expressions et renvoie NULL si elles sont égales, sinon la première expression.

```sql
-- Éviter la division par zéro
SELECT nom, total_ventes / NULLIF(nombre_jours, 0) AS ventes_par_jour
FROM vendeurs;

-- Traiter les chaînes vides comme NULL
SELECT NULLIF(commentaire, '') FROM feedback;
```

### Fonctions d'agrégation et NULL

Les fonctions d'agrégation ignorent généralement les valeurs NULL, sauf `COUNT(*)` :

```sql
-- Compte toutes les lignes, y compris celles avec NULL
SELECT COUNT(*) FROM employe;  

-- Compte seulement les lignes où departement n'est pas NULL
SELECT COUNT(departement) FROM employe;

-- Compte les valeurs distinctes non NULL
SELECT COUNT(DISTINCT departement) FROM employe;
```

## NULL dans les jointures

### Jointures internes

Les jointures internes (INNER JOIN) excluent automatiquement les lignes avec des valeurs NULL dans les colonnes de jointure.

```sql
-- Ne retourne que les employés avec un département existant
SELECT e.nom, d.nom AS departement
FROM employe e
INNER JOIN departement d ON e.departement = d.id;
```

### Jointures externes

Les jointures externes (LEFT/RIGHT/FULL OUTER JOIN) conservent les lignes même si la correspondance est NULL :

```sql
-- Retourne tous les employés, même ceux sans département
SELECT e.nom, d.nom AS departement
FROM employe e
LEFT JOIN departement d ON e.departement = d.id;

-- Retourne tous les départements, même ceux sans employés
SELECT e.nom, d.nom AS departement
FROM employe e
RIGHT JOIN departement d ON e.departement = d.id;
```

## Tri et regroupement avec NULL

### NULL et ORDER BY

Par défaut, les valeurs NULL sont traitées comme "plus grandes" que toutes les autres valeurs en tri ascendant (placées à la fin) et "plus petites" en tri descendant (placées au début). Vous pouvez contrôler ce comportement :

```sql
-- NULL en dernier (comportement par défaut pour ASC)
SELECT nom, date_depart
FROM employe
ORDER BY date_depart ASC;  -- NULL à la fin

-- NULL en premier (spécifié explicitement)
SELECT nom, date_depart
FROM employe
ORDER BY date_depart ASC NULLS FIRST;

-- NULL en dernier (spécifié explicitement)
SELECT nom, date_depart
FROM employe
ORDER BY date_depart DESC NULLS LAST;
```

### NULL et GROUP BY

Dans un GROUP BY, toutes les valeurs NULL sont considérées comme identiques et regroupées ensemble :

```sql
-- Compte des employés par département, incluant ceux sans département
SELECT departement, COUNT(*) AS nombre
FROM employe
GROUP BY departement;
```

## Contraintes NOT NULL

Pour empêcher les valeurs NULL dans une colonne, utilisez la contrainte NOT NULL :

```sql
CREATE TABLE employe (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,  -- Ne peut pas être NULL
    prenom VARCHAR(100) NOT NULL,
    departement INTEGER,  -- Peut être NULL
    date_embauche DATE NOT NULL DEFAULT CURRENT_DATE
);
```

## Bonnes pratiques

### Quand utiliser NULL

- Pour représenter des données inconnues ou manquantes
- Pour les champs optionnels
- Pour les colonnes qui deviennent pertinentes uniquement dans certains contextes

### Quand éviter NULL

- Pour les colonnes qui devraient toujours avoir une valeur (utiliser NOT NULL)
- Pour les clés primaires et les identifiants
- Quand une valeur par défaut significative peut être utilisée

### Gestion cohérente

- Définir une stratégie claire pour l'utilisation de NULL dans votre modèle de données
- Utiliser COALESCE dans les interfaces utilisateur pour afficher des valeurs par défaut
- Documenter le sens de NULL pour chaque colonne où c'est permis

## Exemples pratiques

### Rapport avec gestion des NULL

```sql
-- Rapport d'employés avec gestion cohérente des NULL
SELECT 
    e.nom, 
    e.prenom,
    COALESCE(d.nom, 'Non assigné') AS departement,
    COALESCE(TO_CHAR(e.date_embauche, 'DD/MM/YYYY'), 'Inconnue') AS date_embauche,
    CASE 
        WHEN e.superviseur IS NULL THEN 'Direction'
        ELSE (SELECT nom FROM employe WHERE id = e.superviseur)
    END AS superviseur
FROM 
    employe e
LEFT JOIN 
    departement d ON e.departement = d.id
ORDER BY 
    CASE WHEN e.superviseur IS NULL THEN 0 ELSE 1 END,  -- Direction d'abord
    e.nom;
```

### Calculs avec gestion des NULL

```sql
-- Calcul d'ancienneté avec gestion des NULL
SELECT 
    nom,
    prenom,
    date_embauche,
    COALESCE(date_depart, CURRENT_DATE) AS date_fin,
    EXTRACT(YEAR FROM AGE(COALESCE(date_depart, CURRENT_DATE), date_embauche)) AS annees_service,
    CASE 
        WHEN date_depart IS NULL THEN 'Actif'
        ELSE 'Ancien'
    END AS statut
FROM 
    employe
ORDER BY 
    annees_service DESC;
```

### Filtrage complexe avec NULL

```sql
-- Trouver les incohérences dans les données
SELECT 
    id, 
    nom,
    'Département manquant' AS probleme
FROM 
    employe
WHERE 
    departement IS NULL AND date_depart IS NULL  -- Employés actifs sans département
    
UNION ALL

SELECT 
    id, 
    nom,
    'Superviseur manquant' AS probleme
FROM 
    employe
WHERE 
    superviseur IS NULL AND poste <> 'Directeur'  -- Tous sauf directeurs doivent avoir un superviseur
    
UNION ALL

SELECT 
    id, 
    nom,
    'Date incohérente' AS probleme
FROM 
    employe
WHERE 
    date_depart IS NOT NULL AND date_depart < date_embauche;  -- Dates impossibles
```

## Liens connexes
- [[DQL-SELECT]] - Structure générale du SELECT
- [[DQL-WHERE]] - Filtrage avec WHERE
- [[DQL-OPERATEURS]] - Opérateurs et fonctions
- [[DQL-JOINTURES]] - Jointures entre tables
- [[DDL-CONTRAINTES]] - Contraintes d'intégrité