# Guide de révision SQL - Examen 1

Ce document explique en détail comment raisonner pour répondre aux questions SQL fournies dans le fichier de révision. Chaque question sera analysée étape par étape, avec des explications sur les concepts SQL utilisés.

## Schéma de la base de données

Avant de commencer, examinons le schéma de notre base de données :

```
Table utilisateurs {
  id integer [primary key]
  prenom varchar
  nom varchar 
}

Table photos {
  id integer [primary key]
  url varchar
  photographe int [not null, ref: > utilisateurs.id]
  categorie_id int [null, ref: > categories.id]
}

Table categories {
  id integer [primary key]
  nom varchar
}

Table likes {
  id integer [primary key]
  utilisateur_id int [not null, ref: > utilisateurs.id]
  photo_id int [not null, ref: > photos.id]
}
```

Relations :

- Un utilisateur peut prendre plusieurs photos (relation 1-n entre utilisateurs et photos)
- Une photo appartient à un seul utilisateur (via la clé étrangère photographe)
- Une photo peut appartenir à une seule catégorie, ou à aucune (via la clé étrangère categorie_id qui peut être NULL)
- Un utilisateur peut aimer plusieurs photos (via la table likes)
- Une photo peut être aimée par plusieurs utilisateurs (via la table likes)

## Question 1 : Utilisateurs n'ayant jamais "liké"

> Écrire une requête qui retourne le prénom et le nom des utilisateurs n'ayant jamais "liké". Ordonner par ordre alphabétique sur le prénom.

### Raisonnement

Pour résoudre ce problème, nous devons :

1. Identifier les utilisateurs qui n'ont jamais effectué d'action "like"
2. Sélectionner leur prénom et nom
3. Trier par prénom

Pour trouver les utilisateurs qui n'ont jamais "liké", nous pouvons utiliser une sous-requête avec NOT IN :

- D'abord, nous obtenons tous les IDs d'utilisateurs qui ont au moins un enregistrement dans la table "likes"
- Ensuite, nous sélectionnons les utilisateurs dont l'ID n'est PAS dans cette liste

### Solution

```sql
SELECT prenom, nom 
FROM utilisateurs AS u
WHERE u.id NOT IN (SELECT utilisateur_id FROM likes)
ORDER BY prenom ASC;
```

### Concepts clés

- **Sous-requête** : Une requête imbriquée dans une autre requête
- **NOT IN** : Opérateur qui vérifie si une valeur n'est pas dans un ensemble de valeurs
- **ORDER BY** : Clause pour trier les résultats (ASC pour ordre croissant)

### Alternatives

Nous aurions aussi pu utiliser une jointure externe (LEFT JOIN) avec une clause WHERE pour vérifier les valeurs NULL :

```sql
SELECT u.prenom, u.nom
FROM utilisateurs u
LEFT JOIN likes l ON u.id = l.utilisateur_id
WHERE l.id IS NULL
ORDER BY u.prenom ASC;
```

## Question 2 : Utilisateurs ayant pris des photos de la catégorie 'Portrait'

> Écrire une requête qui retourne le prénom et le nom des utilisateurs qui ont réalisé au moins une photo dans la catégorie 'Portrait'

### Raisonnement

Pour résoudre ce problème, nous devons :

1. Identifier l'ID de la catégorie 'Portrait'
2. Trouver toutes les photos de cette catégorie
3. Obtenir les IDs des photographes de ces photos
4. Sélectionner les prénoms et noms de ces utilisateurs

Nous pouvons le faire avec des sous-requêtes imbriquées ou avec des jointures.

### Solution avec sous-requêtes

```sql
SELECT prenom, nom 
FROM utilisateurs 
WHERE id IN (
    SELECT photographe 
    FROM photos 
    WHERE categorie_id = (
        SELECT id 
        FROM categories 
        WHERE nom = 'Portrait'
    )
);
```

### Solution avec jointures (plus lisible et souvent plus performante)

```sql
SELECT DISTINCT u.prenom, u.nom
FROM utilisateurs u
JOIN photos p ON u.id = p.photographe
JOIN categories c ON p.categorie_id = c.id
WHERE c.nom = 'Portrait';
```

### Concepts clés

- **Sous-requêtes imbriquées** : Requêtes à l'intérieur d'autres requêtes
- **IN** : Opérateur qui vérifie si une valeur est dans un ensemble
- **JOINS** : Méthode pour combiner des lignes de différentes tables
- **DISTINCT** : Élimine les doublons dans les résultats

## Question 3 : URL des photos avec leur catégorie

> Écrire une requête qui retourne l'url des photos et la catégorie à laquelle elles appartiennent. Si elles n'ont pas de catégorie, afficher 'aucun'.

### Raisonnement

Pour cette question, nous devons :

1. Sélectionner l'URL de chaque photo
2. Joindre avec la table des catégories pour obtenir le nom de la catégorie
3. Gérer le cas où une photo n'a pas de catégorie (valeur NULL)

Nous utiliserons une jointure externe (LEFT JOIN) pour inclure toutes les photos, même celles sans catégorie. Pour gérer les valeurs NULL, nous utiliserons la fonction COALESCE, qui renvoie le premier argument non-NULL.

### Solution

```sql
SELECT p.url, COALESCE(c.nom, 'aucun') AS categorie
FROM photos p
LEFT JOIN categories c ON p.categorie_id = c.id;
```

### Concepts clés

- **LEFT JOIN** : Inclut toutes les lignes de la table de gauche (photos), même si elles n'ont pas de correspondance dans la table de droite (categories)
- **COALESCE** : Fonction qui retourne le premier argument non-NULL, très utile pour gérer les valeurs manquantes
- **Alias de table** (p, c) : Raccourcis pour les noms de tables qui rendent la requête plus lisible

## Question 4 : Nombre de likes par photo

> Pour chaque photo, afficher son URL et le nombre de likes qu'elle a reçus.

### Raisonnement

Pour résoudre ce problème, nous devons :

1. Compter les likes pour chaque photo
2. Afficher l'URL avec ce décompte

Nous pouvons utiliser l'agrégation (COUNT) pour compter les likes, mais nous devons grouper les résultats par photo.

### Solution avec sous-requête

```sql
SELECT p.url, (SELECT COUNT(*) FROM likes l WHERE l.photo_id = p.id) AS nb_likes
FROM photos p;
```

### Solution avec jointure et GROUP BY (plus courante et souvent plus efficace)

```sql
SELECT p.url, COUNT(l.id) AS nb_likes
FROM photos p
LEFT JOIN likes l ON p.id = l.photo_id
GROUP BY p.id, p.url;
```

### Concepts clés

- **Fonction d'agrégation COUNT** : Compte le nombre de lignes ou de valeurs non-NULL
- **GROUP BY** : Regroupe les lignes ayant les mêmes valeurs dans les colonnes spécifiées
- **Sous-requête corrélée** : Une sous-requête qui fait référence à la requête externe (p.id dans notre cas)

## Question 5 : Utilisateurs ayant pris plus de 2 photos

> Afficher le prénom, le nom et le nombre total de photos prises par chaque utilisateur ayant pris plus de 2 photos.

### Raisonnement

Pour cette question, nous devons :

1. Compter le nombre de photos prises par chaque utilisateur
2. Filtrer pour ne garder que ceux ayant pris plus de 2 photos
3. Afficher leurs prénoms, noms et le décompte des photos

Nous utiliserons GROUP BY pour regrouper par utilisateur, et HAVING pour filtrer sur le nombre de photos.

### Solution

```sql
SELECT u.prenom, u.nom, COUNT(*) AS nb_photos
FROM utilisateurs u
JOIN photos p ON u.id = p.photographe
GROUP BY u.id, u.prenom, u.nom
HAVING COUNT(*) > 2;
```

### Concepts clés

- **COUNT(*)** : Compte toutes les lignes dans chaque groupe
- **GROUP BY** : Regroupe les lignes par utilisateur
- **HAVING** : Filtre les groupes après agrégation (contrairement à WHERE qui filtre avant agrégation)
- **JOIN** : Combine les lignes des tables utilisateurs et photos

## Question 6 : Nombre de likes par photo (incluant les zéros)

> Affichez l'ID et l'URL de chaque photo ainsi que le nombre de likes qu'elle a reçus. Même si une photo n'a pas de likes, elle doit apparaître avec un nombre de likes égal à 0.

### Raisonnement

Cette question ressemble à la question 4, mais avec une contrainte supplémentaire : nous devons inclure toutes les photos, même celles sans likes.

Nous utiliserons :

1. Une jointure externe (LEFT JOIN) pour inclure toutes les photos
2. La fonction COALESCE pour remplacer les valeurs NULL par zéro

### Solution

```sql
SELECT p.id, p.url, COALESCE(COUNT(l.id), 0) AS nb_likes
FROM photos p
LEFT JOIN likes l ON p.id = l.photo_id
GROUP BY p.id, p.url;
```

### Concepts clés

- **LEFT JOIN** : Inclut toutes les photos, même celles sans likes
- **COALESCE avec COUNT** : Assure que nous obtenons 0 pour les photos sans likes
- **Agrégation avec GROUP BY** : Regroupe les résultats par photo

## Question 7 : Photos sans likes

> Affichez l'URL de toutes les photos qui n'ont reçu aucun like.

### Raisonnement

Pour cette question, nous devons :

1. Trouver les photos qui n'ont pas d'entrées correspondantes dans la table likes
2. Afficher leurs URLs

Nous utiliserons une jointure externe (LEFT JOIN) puis filtrerons avec IS NULL pour trouver les photos sans correspondance dans la table likes.

### Solution

```sql
SELECT p.url
FROM photos p
LEFT JOIN likes l ON p.id = l.photo_id
WHERE l.id IS NULL;
```

### Concepts clés

- **LEFT JOIN avec IS NULL** : Technique classique pour trouver les enregistrements sans correspondance
- **WHERE l.id IS NULL** : Filtre pour ne garder que les photos sans likes (puisque toutes les colonnes de la table likes seront NULL pour ces photos)

## Question 8 : Nombre de photos par catégorie

> Pour chaque catégorie, affichez son nom et le nombre de photos qui lui sont associées. Incluez également les catégories qui n'ont aucune photo.

### Raisonnement

Pour cette question, nous devons :

1. Compter les photos pour chaque catégorie
2. Inclure les catégories sans photos (avec un compteur à 0)

Nous utiliserons une jointure externe (LEFT JOIN) pour inclure toutes les catégories, même celles sans photos.

### Solution

```sql
SELECT c.nom AS categorie, COUNT(p.id) AS nb_photos
FROM categories c
LEFT JOIN photos p ON c.id = p.categorie_id
GROUP BY c.nom;
```

### Concepts clés

- **COUNT(p.id)** : Compte les valeurs non-NULL de p.id, ce qui exclut automatiquement les photos inexistantes
- **LEFT JOIN** : Inclut toutes les catégories, même celles sans photos
- **GROUP BY** : Regroupe les résultats par catégorie

## Question 9 : Utilisateurs et leurs likes (avec bonus)

> Afficher le prenom et le nom des utilisateurs avec le nombre de likes qu'ils ont reçus en ordre décroissant. Extra: Afficher celui ou ceux qui ont le maximum de likes.

### Raisonnement - Partie principale

Pour la première partie, nous devons :

1. Compter combien de fois les photos de chaque utilisateur ont été likées
2. Trier les résultats par ordre décroissant du nombre de likes

Nous joindrons les tables utilisateurs, photos et likes pour établir la relation entre utilisateurs et likes reçus sur leurs photos.

### Solution - Partie principale

```sql
SELECT u.prenom, u.nom, COUNT(l.id) AS nb_likes
FROM utilisateurs u
LEFT JOIN photos p ON u.id = p.photographe
LEFT JOIN likes l ON p.id = l.photo_id
GROUP BY u.id, u.prenom, u.nom
ORDER BY nb_likes DESC;
```

### Raisonnement - Partie bonus

Pour la partie bonus, nous devons trouver l'utilisateur (ou les utilisateurs) ayant reçu le maximum de likes. Nous pouvons utiliser une requête CTE (Common Table Expression) ou une sous-requête pour :

1. Calculer le nombre de likes pour chaque utilisateur
2. Trouver le maximum
3. Sélectionner les utilisateurs ayant ce nombre maximum de likes

### Solution - Partie bonus (avec CTE)

```sql
WITH user_likes AS (
    SELECT u.prenom, u.nom, COUNT(l.id) AS nb_likes
    FROM utilisateurs u
    LEFT JOIN photos p ON u.id = p.photographe
    LEFT JOIN likes l ON p.id = l.photo_id
    GROUP BY u.id, u.prenom, u.nom
)
SELECT prenom, nom, nb_likes
FROM user_likes
WHERE nb_likes = (SELECT MAX(nb_likes) FROM user_likes);
```

### Concepts clés

- **LEFT JOIN en cascade** : Permet de lier plusieurs tables ensemble
- **ORDER BY ... DESC** : Trie les résultats par ordre décroissant
- **CTE (WITH clause)** : Crée une table temporaire pour simplifier les requêtes complexes
- **Sous-requête avec MAX** : Trouve la valeur maximale dans un ensemble

## Question 10 : Nombre de likes par catégorie

> Écrivez une requête qui affiche, pour chaque catégorie, le nom de la catégorie et le nombre total de likes reçus par l'ensemble des photos qui lui sont associées.

### Raisonnement

Pour cette question, nous devons :

1. Relier les catégories aux photos, puis aux likes
2. Compter les likes pour chaque catégorie
3. Inclure les catégories sans likes

Nous utiliserons deux jointures externes (LEFT JOIN) pour inclure toutes les catégories et photos, même celles sans correspondance.

### Solution

```sql
SELECT c.nom AS categorie, COUNT(l.id) AS nb_likes
FROM categories c
LEFT JOIN photos p ON c.id = p.categorie_id
LEFT JOIN likes l ON p.id = l.photo_id
GROUP BY c.nom
ORDER BY nb_likes DESC;
```

### Concepts clés

- **Jointures multiples** : Permettent de relier plusieurs tables ensemble
- **COUNT(l.id)** : Compte uniquement les likes existants (valeurs non-NULL)
- **ORDER BY ... DESC** : Trie les résultats par ordre décroissant du nombre de likes

## Conseils généraux pour résoudre les problèmes SQL

1. **Comprendre le schéma** : Avant de commencer à écrire une requête, assurez-vous de bien comprendre la structure de la base de données, les relations entre les tables et le sens des attributs.
    
2. **Définir les colonnes à afficher** : Identifiez clairement quelles colonnes doivent apparaître dans les résultats.
    
3. **Identifier les tables nécessaires** : Déterminez quelles tables contiennent les données dont vous avez besoin.
    
4. **Choisir les bons types de jointures** :
    
    - `INNER JOIN` : Seulement les lignes avec correspondance dans les deux tables
    - `LEFT JOIN` : Toutes les lignes de la table de gauche, avec ou sans correspondance
    - `RIGHT JOIN` : Toutes les lignes de la table de droite, avec ou sans correspondance
    - `FULL JOIN` : Toutes les lignes des deux tables
5. **Filtrer avec WHERE vs HAVING** :
    
    - `WHERE` : Filtre les lignes avant agrégation
    - `HAVING` : Filtre les groupes après agrégation
6. **Gérer les valeurs NULL** : Utilisez `IS NULL`, `IS NOT NULL`, `COALESCE` ou `IFNULL` pour traiter les valeurs manquantes.
    
7. **Optimiser les requêtes** : Préférez les jointures aux sous-requêtes lorsque possible, utilisez des index appropriés, et évitez les produits cartésiens.
    
8. **Structurer les requêtes** : Gardez un ordre logique dans vos clauses SQL :
    
    ```
    SELECT ... FROM ... JOIN ... ON ... WHERE ... GROUP BY ... HAVING ... ORDER BY ...
    ```
    
9. **Tester avec des données simples** : Commencez par tester vos requêtes sur un petit sous-ensemble de données pour vérifier qu'elles fonctionnent comme prévu.
    
10. **Décomposer les problèmes complexes** : Pour les requêtes complexes, envisagez d'utiliser des CTE (WITH) ou des tables temporaires pour décomposer le problème en étapes plus simples.