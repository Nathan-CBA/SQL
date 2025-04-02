# DQL - ORDER BY, LIMIT et OFFSET

Les clauses `ORDER BY`, `LIMIT` et `OFFSET` permettent de contrôler le tri et la pagination des résultats d'une requête SQL, ce qui est essentiel pour présenter les données de manière organisée et gérer efficacement de grands ensembles de résultats.

## ORDER BY

La clause `ORDER BY` permet de trier les résultats d'une requête selon un ou plusieurs critères.

### Syntaxe de base

```sql
SELECT colonnes
FROM tables
[WHERE condition]
[GROUP BY expressions]
[HAVING condition]
ORDER BY expression [ASC | DESC] [NULLS {FIRST | LAST}] [, ...];
```

### Options de tri

- **ASC** : Tri ascendant (par défaut)
- **DESC** : Tri descendant
- **NULLS FIRST** : Place les valeurs NULL au début
- **NULLS LAST** : Place les valeurs NULL à la fin

Par défaut :
- `ASC NULLS LAST` : Les valeurs NULL sont placées à la fin dans un tri ascendant
- `DESC NULLS FIRST` : Les valeurs NULL sont placées au début dans un tri descendant

### Exemples simples

```sql
-- Tri par nom en ordre alphabétique
SELECT nom, prenom, salaire
FROM employe
ORDER BY nom;

-- Tri par salaire décroissant
SELECT nom, prenom, salaire
FROM employe
ORDER BY salaire DESC;

-- Tri par département (ascendant) puis par salaire (descendant)
SELECT nom, prenom, departement, salaire
FROM employe
ORDER BY departement ASC, salaire DESC;
```

### Tri avec contrôle des valeurs NULL

```sql
-- Les employés sans date de départ (NULL) apparaissent en premier
SELECT nom, prenom, date_depart
FROM employe
ORDER BY date_depart ASC NULLS FIRST;

-- Les employés sans date de départ (NULL) apparaissent en dernier
SELECT nom, prenom, date_depart
FROM employe
ORDER BY date_depart ASC NULLS LAST;
```

### Tri par alias de colonne

Vous pouvez trier par des colonnes référencées par leur alias :

```sql
SELECT nom, prenom, salaire * 12 AS salaire_annuel
FROM employe
ORDER BY salaire_annuel DESC;
```

### Tri par position

Vous pouvez trier par la position des colonnes dans la liste de sélection :

```sql
SELECT nom, prenom, salaire
FROM employe
ORDER BY 3 DESC;  -- Trie par la 3ème colonne (salaire)
```

> **Note** : Le tri par position est déconseillé car il rend le code moins lisible et plus difficile à maintenir.

### Tri par expressions

Vous pouvez trier par des expressions calculées :

```sql
-- Tri par longueur du nom
SELECT nom, prenom
FROM employe
ORDER BY LENGTH(nom);

-- Tri par ancienneté
SELECT nom, prenom, date_embauche
FROM employe
ORDER BY CURRENT_DATE - date_embauche DESC;
```

## LIMIT et OFFSET

Les clauses `LIMIT` et `OFFSET` permettent de restreindre le nombre de lignes retournées et de définir un décalage de départ, ce qui est essentiel pour la pagination des résultats.

### Syntaxe de base

```sql
SELECT colonnes
FROM tables
[WHERE condition]
[GROUP BY expressions]
[HAVING condition]
[ORDER BY expressions]
LIMIT nombre [OFFSET nombre];
```

### Fonctionnement

- **LIMIT** : Spécifie le nombre maximum de lignes à retourner
- **OFFSET** : Indique le nombre de lignes à sauter avant de commencer à retourner des résultats

> **Important** : `LIMIT` et `OFFSET` doivent toujours être utilisés avec `ORDER BY` pour garantir des résultats cohérents et prévisibles.

### Exemples

```sql
-- Les 5 employés les mieux payés
SELECT nom, prenom, salaire
FROM employe
ORDER BY salaire DESC
LIMIT 5;

-- Les employés du 6ème au 10ème salaire
SELECT nom, prenom, salaire
FROM employe
ORDER BY salaire DESC
LIMIT 5 OFFSET 5;
```

### Pagination

`LIMIT` et `OFFSET` sont couramment utilisés pour implémenter la pagination dans les applications :

```sql
-- Page 1 (10 résultats par page)
SELECT * FROM produits ORDER BY nom LIMIT 10 OFFSET 0;

-- Page 2
SELECT * FROM produits ORDER BY nom LIMIT 10 OFFSET 10;

-- Page 3
SELECT * FROM produits ORDER BY nom LIMIT 10 OFFSET 20;

-- Page n
SELECT * FROM produits ORDER BY nom LIMIT 10 OFFSET ((n-1) * 10);
```

### Syntaxes alternatives

PostgreSQL accepte également ces syntaxes alternatives :

```sql
-- Alternative à LIMIT x OFFSET y
SELECT * FROM table LIMIT x, y;  -- MySQL/PostgreSQL

-- Alternative à LIMIT
SELECT * FROM table FETCH FIRST x ROWS ONLY;  -- Standard SQL
```

## Performances et considérations

### ORDER BY et performances

- Le tri peut être coûteux pour de grandes tables
- Utilisez des index sur les colonnes de tri fréquentes
- Le tri sur des expressions calculées est généralement plus lent

```sql
-- Index pour optimiser le tri par nom
CREATE INDEX idx_employe_nom ON employe(nom);

-- Index pour optimiser le tri par salaire descendant
CREATE INDEX idx_employe_salaire_desc ON employe(salaire DESC);
```

### LIMIT/OFFSET et performances

- `LIMIT` seul est efficace car il arrête la production de résultats une fois le nombre spécifié atteint
- `OFFSET` peut être inefficace pour de grandes valeurs car PostgreSQL doit lire et sauter toutes les lignes jusqu'au point de décalage
- Pour de grandes tables, des techniques alternatives de pagination sont recommandées

### Alternatives à OFFSET pour de grandes tables

Pour de grandes tables, l'utilisation d'OFFSET peut devenir inefficace. Une approche alternative consiste à utiliser des conditions WHERE basées sur la dernière valeur vue :

```sql
-- Premier lot
SELECT id, nom, salaire
FROM employe
ORDER BY salaire DESC, id
LIMIT 10;

-- Supposons que le dernier employé vu a un salaire de 5000 et un ID de 42
-- Lot suivant
SELECT id, nom, salaire
FROM employe
WHERE (salaire < 5000) OR (salaire = 5000 AND id > 42)
ORDER BY salaire DESC, id
LIMIT 10;
```

Cette méthode évite de scanner toutes les lignes jusqu'au point de décalage.

## Cas d'utilisation avancés

### Tri aléatoire

```sql
-- Sélection aléatoire de 5 employés
SELECT nom, prenom
FROM employe
ORDER BY RANDOM()
LIMIT 5;
```

### Tri personnalisé avec CASE

```sql
-- Tri personnalisé : d'abord les managers, puis les autres employés par salaire
SELECT nom, prenom, poste, salaire
FROM employe
ORDER BY 
    CASE 
        WHEN poste = 'Manager' THEN 0
        ELSE 1
    END,
    salaire DESC;
```

### Top N par groupe

```sql
-- Les 3 employés les mieux payés de chaque département
WITH top_employes AS (
    SELECT 
        nom, 
        prenom, 
        departement, 
        salaire,
        ROW_NUMBER() OVER (PARTITION BY departement ORDER BY salaire DESC) AS rang
    FROM employe
)
SELECT nom, prenom, departement, salaire
FROM top_employes
WHERE rang <= 3
ORDER BY departement, rang;
```

## Exemples complets

### Rapport paginé des ventes par région

```sql
-- Page 2 des ventes par région (10 lignes par page)
SELECT 
    r.nom AS region, 
    COUNT(v.id) AS nombre_ventes, 
    SUM(v.montant) AS chiffre_affaires
FROM 
    ventes v
JOIN 
    regions r ON v.region_id = r.id
WHERE 
    v.date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 
    r.id, r.nom
ORDER BY 
    chiffre_affaires DESC
LIMIT 10 OFFSET 10;
```

### Liste des produits avec gestion des ruptures de stock

```sql
-- Afficher d'abord les produits en rupture de stock, puis les autres par quantité croissante
SELECT 
    id, 
    nom, 
    quantite_stock, 
    CASE WHEN quantite_stock = 0 THEN 'Rupture' ELSE 'En stock' END AS statut
FROM 
    produits
ORDER BY 
    quantite_stock = 0 DESC, -- Les ruptures d'abord (TRUE puis FALSE)
    quantite_stock ASC,
    nom ASC
LIMIT 20;
```

## Liens connexes
- [[DQL-SELECT]] - Structure générale du SELECT
- [[DQL-WHERE]] - Filtrage avec WHERE
- [[DQL-GROUP-BY]] - Regroupement et agrégation
- [[RESOLUTION-REQUETE]] - Processus de résolution d'une requête