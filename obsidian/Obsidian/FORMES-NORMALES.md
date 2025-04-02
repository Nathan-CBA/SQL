# Formes normales

La normalisation est un processus essentiel dans la conception de bases de données relationnelles visant à organiser les données de manière efficace, en éliminant les redondances et en assurant l'intégrité des données.

## Introduction aux formes normales

La normalisation est un processus systématique qui décompose les tables d'une base de données pour :
- Éliminer les redondances
- Découper adéquatement les structures ayant des dépendances
- Garantir l'intégrité des données

Une base de données relationnelle est dite "normalisée" lorsqu'elle respecte un ensemble de règles appelées "formes normales". Il existe théoriquement neuf formes normales, mais dans la pratique, on se concentre généralement sur les trois premières.

## Les neuf formes normales

1. **1ère forme normale (1NF)**
2. **2ème forme normale (2NF)**
3. **3ème forme normale (3NF)**
4. Forme normale de clé élémentaire (EKNF)
5. Forme normale de Boyce-Codd (BCNF)
6. 4ème forme normale (4NF)
7. 5ème forme normale (5NF)
8. Forme normale de domaine clé (DKNF)
9. 6ème forme normale (6NF)

Les trois premières formes normales sont les plus couramment utilisées et suffisent généralement pour la plupart des applications. Les formes normales supérieures sont plus abstraites et conduisent souvent à un découpage trop sévère des données, ce qui peut créer des problèmes de performance.

## Première forme normale (1NF)

### Définition

Une table est en première forme normale (1NF) si et seulement si :
- Tous les attributs sont atomiques (non divisibles)

### Signification

Chaque attribut (colonne) de la table ne doit contenir qu'une seule valeur, et non pas une liste ou un ensemble de valeurs. Les attributs multivalués, les tableaux, ou les attributs composés ne sont pas autorisés.

### Exemple

#### Table non conforme à la 1NF

| Id | Nom              | Supervise    |
|----|------------------|--------------|
| 3  | Dupuis, Lancelot | 5, 8         |
| 5  | Bordeleau, Marina| 9            |
| 8  | Gravel, Pierre   | -            |
| 9  | Pignon, François | -            |

Problèmes dans cette table :
- L'attribut "Nom" contient à la fois le nom et le prénom
- L'attribut "Supervise" contient plusieurs valeurs séparées par des virgules

#### Table conforme à la 1NF

| Id | Nom      | Prenom   | Superviseur |
|----|----------|----------|-------------|
| 3  | Dupuis   | Lancelot | -           |
| 5  | Bordeleau| Marina   | 3           |
| 8  | Gravel   | Pierre   | 3           |
| 9  | Pignon   | François | 5           |

Modifications effectuées :
- Séparation du nom et du prénom en deux attributs distincts
- Création d'un attribut "Superviseur" qui contient une seule valeur
- Utilisation de clés étrangères pour modéliser la relation de supervision

## Deuxième forme normale (2NF)

### Définition

Une table est en deuxième forme normale (2NF) si et seulement si :
- Elle est en 1NF
- Tous les attributs non-clés dépendent complètement de la clé primaire

### Signification

Si une table a une clé primaire composée (formée de plusieurs attributs), alors chaque attribut non-clé doit dépendre de l'ensemble complet de la clé primaire, et non pas seulement d'une partie de celle-ci.

> **Note** : Les tables ayant une clé primaire simple (un seul attribut) sont automatiquement en 2NF si elles sont déjà en 1NF.

### Exemple

#### Table non conforme à la 2NF

| IdEtudiant | IdCours | NomEtudiant | NomCours        | Note |
|------------|---------|-------------|-----------------|------|
| 3          | 12      | Dupuis      | Physique II     | 90%  |
| 3          | 14      | Dupuis      | Philosophie I   | 88%  |
| 7          | 4       | Gravel      | Mathématique I  | 76%  |
| 9          | 12      | Bordeleau   | Physique II     | 90%  |

Problèmes dans cette table :
- La clé primaire est composée de (IdEtudiant, IdCours)
- NomEtudiant dépend uniquement de IdEtudiant (pas de la clé entière)
- NomCours dépend uniquement de IdCours (pas de la clé entière)

#### Tables conformes à la 2NF

Table Etudiant :

| Id    | Nom       |
|-------|-----------|
| 3     | Dupuis    |
| 7     | Gravel    |
| 9     | Bordeleau |

Table Cours :

| Id    | Nom            |
|-------|----------------|
| 4     | Mathématique I |
| 12    | Physique II    |
| 14    | Philosophie I  |

Table EtudiantCours :

| Etudiant | Cours | Note |
|----------|-------|------|
| 3        | 12    | 90%  |
| 3        | 14    | 88%  |
| 7        | 4     | 76%  |
| 9        | 12    | 90%  |

Modifications effectuées :
- Décomposition en trois tables
- Les attributs qui dépendent seulement d'une partie de la clé ont été déplacés dans les tables appropriées
- Utilisation de clés étrangères pour maintenir les relations

## Troisième forme normale (3NF)

### Définition

Une table est en troisième forme normale (3NF) si et seulement si :
- Elle est en 2NF
- Tous les attributs non-clés dépendent directement de la clé primaire et non transitivement via un autre attribut non-clé

### Signification

Il ne doit pas y avoir de dépendance transitive entre les attributs non-clés et la clé primaire. En d'autres termes, si A → B et B → C, alors C dépend transitivement de A via B. Cette situation doit être évitée.

### Exemple

#### Table non conforme à la 3NF

| Id | Nom      | Departement | NomDepartement |
|----|----------|-------------|----------------|
| 3  | Dupuis   | VT          | Ventes         |
| 5  | Bordeleau| AD          | Administration |
| 8  | Gravel   | AC          | Achats         |
| 9  | Pignon   | VT          | Ventes         |

Problèmes dans cette table :
- NomDepartement dépend de Departement, qui n'est pas la clé primaire
- Il y a donc une dépendance transitive : Id → Departement → NomDepartement

#### Tables conformes à la 3NF

Table Employe :

| Id | Nom      | SigleDepartement |
|----|----------|------------------|
| 3  | Dupuis   | VT               |
| 5  | Bordeleau| AD               |
| 8  | Gravel   | AC               |
| 9  | Pignon   | VT               |

Table Departement :

| Sigle | Nom           |
|-------|---------------|
| VT    | Ventes        |
| AC    | Achats        |
| AD    | Administration|

Modifications effectuées :
- Séparation en deux tables pour éliminer la dépendance transitive
- Création d'une clé étrangère pour maintenir la relation

## Dénormalisation

### Définition et objectifs

La dénormalisation est le processus inverse de la normalisation, où l'on réintroduit intentionnellement des redondances dans une base de données normalisée pour améliorer les performances.

### Pourquoi dénormaliser ?

- **Performance** : Réduction du nombre de jointures nécessaires pour les requêtes fréquentes
- **Complexité des requêtes** : Simplification des requêtes complexes
- **Rapidité d'accès** : Accès plus rapide à des données fréquemment utilisées ensemble

### Inconvénients de la dénormalisation

- **Risque d'incohérence** : Difficultés à maintenir la cohérence des données redondantes
- **Complexité de maintenance** : Nécessité de mettre à jour plusieurs copies des mêmes données
- **Espace de stockage** : Augmentation de l'espace disque nécessaire

### Quand dénormaliser ?

La dénormalisation est particulièrement utile dans les situations suivantes :
- Applications orientées lecture plutôt qu'écriture
- Entrepôts de données et systèmes décisionnels
- Applications avec des requêtes complexes fréquentes
- Systèmes à haute charge où les performances sont critiques

### Techniques de dénormalisation

1. **Duplication de colonnes** : Stocker la même information à plusieurs endroits
2. **Précalcul de valeurs** : Stocker des résultats de calculs fréquents
3. **Tables agrégées** : Créer des tables de résumé ou d'agrégation
4. **Tables dénormalisées** : Combiner plusieurs tables normalisées en une seule
5. **Tables de recherche** : Dupliquer des informations de recherche fréquente

## Processus de normalisation

### Étapes de la normalisation

1. **Création du modèle initial** : Ébauche du modèle relationnel
2. **Application de la 1NF** : 
   - Identifier et éliminer les attributs non atomiques
   - Créer de nouvelles tables si nécessaire
3. **Application de la 2NF** : 
   - Identifier les dépendances partielles
   - Déplacer les attributs concernés dans de nouvelles tables
4. **Application de la 3NF** : 
   - Identifier les dépendances transitives
   - Déplacer les attributs concernés dans de nouvelles tables
5. **Formes normales supérieures** (si nécessaire) :
   - Continuer le processus pour les formes normales supérieures
6. **Dénormalisation** (si nécessaire) :
   - Identifier les points où la dénormalisation peut être bénéfique
   - Réintroduire des redondances contrôlées

### Exemple de processus complet

#### Modèle initial

| CommandeID | Client   | ClientEmail     | Produit    | ProduitCat  | Quantité | PrixUnitaire | Total    |
|------------|----------|-----------------|------------|------------|----------|--------------|----------|
| 1001       | Dupont   | dupont@mail.com | Écran LCD  | Électronique| 2        | 150.00       | 300.00   |
| 1001       | Dupont   | dupont@mail.com | Clavier    | Accessoire  | 1        | 25.00        | 25.00    |
| 1002       | Martin   | martin@mail.com | Souris     | Accessoire  | 3        | 15.00        | 45.00    |

#### Après 1NF (élimination des attributs multivalués)

_Le modèle est déjà en 1NF car il n'y a pas d'attributs multivalués._

#### Après 2NF (élimination des dépendances partielles)

Table Client :

| ClientID | Nom     | Email           |
|----------|---------|-----------------|
| C1       | Dupont  | dupont@mail.com |
| C2       | Martin  | martin@mail.com |

Table Produit :

| ProduitID | Nom       | Catégorie     | PrixUnitaire |
|-----------|-----------|---------------|--------------|
| P1        | Écran LCD | Électronique  | 150.00       |
| P2        | Clavier   | Accessoire    | 25.00        |
| P3        | Souris    | Accessoire    | 15.00        |

Table Commande :

| CommandeID | ClientID |
|------------|----------|
| 1001       | C1       |
| 1002       | C2       |

Table LigneCommande :

| CommandeID | ProduitID | Quantité | Total  |
|------------|-----------|----------|--------|
| 1001       | P1        | 2        | 300.00 |
| 1001       | P2        | 1        | 25.00  |
| 1002       | P3        | 3        | 45.00  |

#### Après 3NF (élimination des dépendances transitives)

_Remarque : Le Total peut être calculé à partir de la Quantité et du PrixUnitaire, donc c'est une dépendance transitive._

Table Client :

| ClientID | Nom     | Email           |
|----------|---------|-----------------|
| C1       | Dupont  | dupont@mail.com |
| C2       | Martin  | martin@mail.com |

Table Produit :

| ProduitID | Nom       | Catégorie     | PrixUnitaire |
|-----------|-----------|---------------|--------------|
| P1        | Écran LCD | Électronique  | 150.00       |
| P2        | Clavier   | Accessoire    | 25.00        |
| P3        | Souris    | Accessoire    | 15.00        |

Table Commande :

| CommandeID | ClientID |
|------------|----------|
| 1001       | C1       |
| 1002       | C2       |

Table LigneCommande :

| CommandeID | ProduitID | Quantité |
|------------|-----------|----------|
| 1001       | P1        | 2        |
| 1001       | P2        | 1        |
| 1002       | P3        | 3        |

#### Possible dénormalisation

Pour optimiser les performances de certaines requêtes fréquentes, on pourrait réintroduire certaines redondances, par exemple :

Table CommandeEtendue :

| CommandeID | ClientID | ClientNom | TotalCommande |
|------------|----------|-----------|---------------|
| 1001       | C1       | Dupont    | 325.00        |
| 1002       | C2       | Martin    | 45.00         |

Cette table dénormalisée facilite les rapports de vente sans nécessiter de jointures.

## Liens connexes
- [[DDL-CONTRAINTES]] - Contraintes d'intégrité
- [[DEPENDANCES-CIRCULAIRES]] - Gestion des dépendances circulaires
- [[DDL-CREATE]] - Création d'objets