# Résolution d'une requête

Lorsqu'une requête SQL est soumise à un système de gestion de base de données (SGBD) comme PostgreSQL, elle passe par plusieurs étapes de traitement avant de retourner un résultat. Cette note détaille ce processus de résolution d'une requête.

## Vue d'ensemble du processus

Le processus de résolution d'une requête SQL se décompose en huit étapes principales :

1. **Normalisation**
2. **Analyse lexicale**
3. **Analyse syntaxique**
4. **Analyse sémantique**
5. **Définition d'un plan d'exécution**
6. **Optimisation du plan d'exécution**
7. **Exécution**
8. **Retour du résultat**

## 1. Normalisation (prétraitement)

Cette première étape consiste à préparer la requête pour l'analyse en éliminant les éléments superflus et en standardisant le format.

### Opérations effectuées

- **Suppression des espaces superflus** : Élimination des espaces multiples, tabulations, retours à la ligne
- **Élimination des commentaires** : Suppression des commentaires simples (`--`) et multiligne (`/* */`)
- **Normalisation de la casse** : Standardisation de la casse pour les mots-clés (généralement en majuscules)
- **Normalisation des séparateurs** : Standardisation des séparateurs (virgules, points-virgules)
- **Normalisation des identifiants** : Traitement des identifiants délimités (entre guillemets)
- **Traitement des caractères spéciaux et d'échappement**

### Exemple

```sql
-- Requête initiale avec commentaires et espaces superflus
SELECT   e.nom,    -- Nom de l'employé
         e.prenom  /* Information personnelle */
FROM     employe e
WHERE    e.departement  =  3;

-- Après normalisation
SELECT e.nom, e.prenom FROM employe e WHERE e.departement = 3;
```

## 2. Analyse lexicale

L'analyse lexicale (ou tokenisation) consiste à découper la requête en unités lexicales (tokens) qui seront traitées par l'analyseur syntaxique.

### Opérations effectuées

- **Tokenisation** : Découpage de la requête en unités lexicales (tokens)
- **Identification des tokens** : Classification des tokens en mots-clés, identifiants, opérateurs, littéraux, etc.
- **Préparation pour l'analyse syntaxique**

### Exemple

```sql
SELECT e.nom, e.prenom FROM employe e WHERE e.departement = 3;

-- Tokens générés
[SELECT] [e] [.] [nom] [,] [e] [.] [prenom] [FROM] [employe] [e] [WHERE] [e] [.] [departement] [=] [3] [;]
```

## 3. Analyse syntaxique

L'analyse syntaxique vérifie que la structure de la requête est conforme à la grammaire SQL et construit un arbre syntaxique représentant cette structure.

### Opérations effectuées

- **Construction de l'arbre syntaxique** : Représentation hiérarchique de la requête
- **Gestion des erreurs syntaxiques** : Détection des erreurs de syntaxe
- **Gestion des priorités** : Application des règles de priorité pour les opérateurs et les parenthèses
- **Optimisations locales** : Premières optimisations basées sur la structure
- **Création de la table des symboles** : Référencement des objets utilisés

### Exemple d'arbre syntaxique simplifié

```
SELECT
├── COLONNES
│   ├── e.nom
│   └── e.prenom
├── FROM
│   └── employe AS e
└── WHERE
    └── CONDITION
        ├── e.departement
        ├── =
        └── 3
```

## 4. Analyse sémantique

L'analyse sémantique vérifie la validité du sens de la requête, notamment l'existence des objets référencés et la cohérence des types.

### Opérations effectuées

- **Validation de l'existence des objets** : Vérification que les tables, colonnes, fonctions existent
- **Résolution des droits** : Vérification que l'utilisateur a les permissions nécessaires
- **Vérification des types** : Contrôle de la compatibilité des types et domaines
- **Résolution des alias** : Association des alias à leurs objets
- **Vérification des fonctions** : Validation des arguments des fonctions
- **Vérification des sous-requêtes et jointures** : Validation de la cohérence
- **Validation des conditions WHERE** : Vérification de la logique des conditions
- **Contrôle d'intégrité référentielle** : Vérification des clés étrangères
- **Contexte transactionnel** : Vérification du contexte transactionnel (si applicable)

### Exemple d'erreurs détectées

```sql
-- Erreur : colonne inexistante
SELECT e.nom, e.salarie FROM employe e WHERE e.departement = 3;
-- Erreur détectée : "salarie" n'existe pas dans la table "employe"

-- Erreur : incompatibilité de types
SELECT e.nom FROM employe e WHERE e.id = 'abc';
-- Erreur détectée : incompatibilité entre INTEGER et VARCHAR
```

## 5. Définition d'un plan d'exécution

Cette étape consiste à déterminer comment la requête sera exécutée en créant un plan d'exécution qui spécifie les opérations à effectuer et leur ordre.

### Opérations effectuées

- **Types d'opération** : Sélection des opérations (scan de table, index, jointure, tri, etc.)
- **Ordre des opérations** : Détermination de l'ordre d'exécution
- **Estimation des coûts** : Première évaluation du coût de chaque opération
- **Prédicats et filtres** : Identification des conditions pour réduire les résultats
- **Utilisation des index** : Sélection des index à utiliser
- **Parallélisme** : Identification des opportunités de parallélisme
- **Méthodes d'agrégation** : Choix des méthodes pour les fonctions d'agrégation
- **Méthodes de tri** : Sélection des algorithmes de tri
- **Gestion de LIMIT et OFFSET** : Planification des restrictions de résultats

### Exemple de plan d'exécution simplifié

```
Pour la requête : SELECT e.nom, e.prenom FROM employe e WHERE e.departement = 3;

Plan initial :
1. Scan de la table employe
2. Filtre sur departement = 3
3. Projection des colonnes nom, prenom
```

## 6. Optimisation du plan d'exécution

L'optimiseur améliore le plan d'exécution initial en analysant plusieurs stratégies possibles et en sélectionnant celle qui minimise le coût (temps, ressources).

### Opérations effectuées

- **Analyse approfondie** : Examen des structures, statistiques, distribution des données
- **Génération de plans alternatifs** : Création de plusieurs plans d'exécution possibles
- **Estimation précise des coûts** : Calcul détaillé du coût de chaque plan
- **Évaluation des contraintes** : Prise en compte des limites de mémoire et disque
- **Optimisations locales et globales** : Améliorations à différents niveaux
- **Évaluation du parallélisme** : Décision finale sur la parallélisation
- **Sélection du plan optimal** : Choix du plan le plus efficace
- **Compilation du plan** : Préparation à l'exécution
- **Mise en cache** : Stockage du plan pour réutilisation
- **Rétroaction** : Préparation de la collecte de statistiques d'exécution

### Exemples d'optimisations

```
Plan optimisé :
1. Utilisation de l'index idx_employe_departement pour accéder directement aux lignes avec departement = 3
2. Projection des colonnes nom, prenom
```

## 7. Exécution

Cette étape consiste à exécuter le plan optimisé pour produire les résultats de la requête.

### Ordre d'exécution typique pour une requête SELECT

1. **FROM** : Identification des tables sources et exécution des jointures
2. **WHERE** : Filtrage des lignes selon les conditions
3. **GROUP BY** : Regroupement des lignes
4. **HAVING** : Filtrage des groupes
5. **SELECT** : Projection des colonnes sélectionnées
6. **DISTINCT** : Élimination des doublons
7. **ORDER BY** : Tri des résultats
8. **LIMIT/OFFSET** : Limitation du nombre de résultats

### Exemple

```sql
-- Requête
SELECT nom, COUNT(*) AS nb_employes
FROM employe
WHERE departement IS NOT NULL
GROUP BY departement
HAVING COUNT(*) > 5
ORDER BY nb_employes DESC
LIMIT 3;

-- Ordre d'exécution
1. FROM employe
2. WHERE departement IS NOT NULL
3. GROUP BY departement
4. HAVING COUNT(*) > 5
5. SELECT nom, COUNT(*) AS nb_employes
6. ORDER BY nb_employes DESC
7. LIMIT 3
```

## 8. Retour du résultat

La dernière étape consiste à formater et renvoyer les résultats au client.

### Opérations effectuées

- **Formatage** : Conversion des données dans les formats appropriés
- **Assemblage** : Organisation des données en lignes et colonnes
- **Compression** : Éventuelle compression pour réduire la taille
- **Envoi** : Transmission des données au client
- **Confirmation** : Vérification de la bonne réception
- **Gestion des métadonnées** : Envoi des informations sur les colonnes

## Optimisation des requêtes

Pour améliorer les performances des requêtes, plusieurs techniques peuvent être appliquées :

### Indexation

Les index permettent d'accélérer considérablement les recherches :

```sql
-- Création d'un index sur la colonne département
CREATE INDEX idx_employe_departement ON employe(departement);
```

### Requêtes préparées

Les requêtes préparées permettent de réutiliser les plans d'exécution :

```sql
-- Préparation de la requête
PREPARE find_emp(integer) AS
SELECT nom, prenom FROM employe WHERE departement = $1;

-- Exécution avec différents paramètres
EXECUTE find_emp(3);
EXECUTE find_emp(5);
```

### Analyse et statistiques

Maintenir à jour les statistiques de la base de données :

```sql
-- Analyse d'une table
ANALYZE employe;
```

### EXPLAIN

L'instruction EXPLAIN permet de visualiser le plan d'exécution :

```sql
-- Voir le plan d'exécution
EXPLAIN SELECT e.nom, e.prenom 
FROM employe e 
WHERE e.departement = 3;

-- Voir le plan d'exécution avec les coûts détaillés
EXPLAIN ANALYZE SELECT e.nom, e.prenom 
FROM employe e 
WHERE e.departement = 3;
```

## Exemple complet d'analyse de requête

```sql
-- Requête à analyser
SELECT d.nom AS departement, COUNT(e.id) AS nb_employes, AVG(e.salaire) AS salaire_moyen
FROM departement d
LEFT JOIN employe e ON d.id = e.departement
WHERE d.actif = TRUE AND (e.date_embauche > '2020-01-01' OR e.date_embauche IS NULL)
GROUP BY d.id, d.nom
HAVING COUNT(e.id) > 0
ORDER BY salaire_moyen DESC
LIMIT 5;
```

### Plan d'exécution possible

```
LIMIT 5
└── SORT (order by: salaire_moyen DESC)
    └── FILTER (having: COUNT(e.id) > 0)
        └── AGGREGATE (group by: d.id, d.nom)
            └── NESTED LOOP LEFT JOIN
                ├── SEQ SCAN on departement d (filter: d.actif = TRUE)
                └── INDEX SCAN on employe e (filter: e.date_embauche > '2020-01-01')
                    └── CONDITION: d.id = e.departement
```

### Ordre d'exécution réel

1. **FROM + JOIN** : Obtenir les données des tables departement et employe et effectuer la jointure
2. **WHERE** : Filtrer selon les conditions sur d.actif et e.date_embauche
3. **GROUP BY** : Regrouper par d.id et d.nom
4. **HAVING** : Filtrer les groupes ayant au moins un employé
5. **SELECT** : Sélectionner les colonnes et calculer les agrégations
6. **ORDER BY** : Trier par salaire moyen décroissant
7. **LIMIT** : Limiter à 5 résultats

## Liens connexes
- [[DQL-SELECT]] - Structure de la clause SELECT
- [[DDL-OBJETS]] - Objets supplémentaires
- [[DDL-PROCEDURE-FUNCTION]] - Procédures et fonctions SQL