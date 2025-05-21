### Qu’est-ce qu’un **type ENUM** ?

Un **type ENUM** (abréviation de _enumeration_) est un type de données spécial dans certaines bases de données (comme PostgreSQL, MySQL, etc.) qui permet de définir une liste **fermée** de valeurs possibles pour une colonne.

---

### Pourquoi utiliser un type ENUM ?

- Pour **forcer** une colonne à n’accepter que certaines valeurs prédéfinies.
    
- Cela garantit que les données sont **uniformes** et évite les erreurs de saisie (exemple : éviter d’écrire “gestion”, “Geston”, “Gestion” avec des variantes).
    
- C’est une façon simple et claire de gérer des valeurs catégorielles.
## Exemple1
Pour **assigner un attribut à une valeur d’énumération** en SQL (notamment PostgreSQL), il faut d’abord définir un type énuméré (`ENUM`), puis utiliser ce type dans la définition de la colonne (attribut) dans une table. Ensuite, tu peux insérer ou mettre à jour des valeurs en respectant ce type énuméré.

---

### Étapes pour assigner un attribut à une valeur d’énumération

1. **Créer le type énuméré**

`CREATE TYPE type_tache AS ENUM ('gestion', 'conception', 'developpement');`

2. **Définir une table avec une colonne de ce type**
    

`CREATE TABLE feuille_temps (   id SERIAL PRIMARY KEY,   tache type_tache NOT NULL,  -- attribut de type énumération   description VARCHAR(255) );`

3. **Insérer une ligne avec une valeur d’énumération**
    

`INSERT INTO feuille_temps (tache, description) VALUES ('gestion', 'Réunion projet');`

4. **Mettre à jour cet attribut**
    

`UPDATE feuille_temps SET tache = 'developpement' W`

## Exemple ENUM/CASE :

### Création du type ENUM

`CREATE TYPE statut_commande AS ENUM ('en_cours', 'livree', 'annulee');`

---

### 2. Exemple d’utilisation dans un CASE avec cast

Supposons qu’on ait une colonne `code_statut` qui contient des nombres, et on veut les convertir en statut ENUM :

`SELECT   
CASE code_statut     
WHEN 1 THEN 'en_cours'     
WHEN 2 THEN 'livree'     
WHEN 3 THEN 'annulee'    
ELSE 'en_cours'  -- valeur par défaut valide  
END :: statut_commande AS statut`