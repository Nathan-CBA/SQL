## Qu’est-ce qu’un trigger (déclencheur) ?

Un **trigger** est un morceau de code (souvent en SQL ou en PL/SQL) qui s’exécute automatiquement **en réaction à un événement** sur une table :

- **INSERT** (ajout d’une ligne)
    
- **UPDATE** (modification d’une ligne)
    
- **DELETE** (suppression d’une ligne)
    

Ce code peut vérifier, modifier, ou enregistrer des données juste avant ou après l’événement.

---

## Pourquoi utiliser un trigger ?

Les contraintes classiques (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL, DEFAULT) sont très puissantes, mais elles sont **limitées** à des règles simples et directes sur la structure et l’intégrité des données.

Les **triggers** offrent :

### 1. **Des validations complexes et personnalisées**

Exemple : vérifier qu’une date de fin est bien après la date de début, ou que la somme de plusieurs colonnes respecte une condition, ce qui n’est pas toujours possible avec un simple CHECK.

### 2. **Des actions automatiques supplémentaires**

Exemple :

- Mettre à jour une autre table liée automatiquement après une insertion (historique, journalisation).
    
- Envoyer un avertissement, calculer une colonne dérivée.
    
- Bloquer une modification selon des règles métier complexes.
    

### 3. **Une intégrité référentielle avancée et conditionnelle**

Parfois, les règles de gestion dépendent du contexte (exemple : un employé ne peut changer de département que si le nouveau département accepte encore des employés). Impossible avec une simple clé étrangère.

### 4. **Gestion des effets secondaires**

Exemple : mise à jour automatique des totaux dans une autre table quand on insère ou supprime des lignes dans une table de détail.

---

## Les contraintes classiques ne permettent pas :

- D’exécuter du code dynamique, uniquement des règles statiques.
    
- De consulter plusieurs tables pour vérifier une condition (CHECK ne peut pas faire ça).
    
- De faire des modifications automatiques dans d’autres tables.
    
- D’envoyer des alertes ou déclencher des procédures complexes.
    

---

## Exemple simple de trigger



`CREATE TRIGGER verif_date 
BEFORE INSERT OR UPDATE ON projet 
FOR EACH ROW 
WHEN (NEW.date_fin < NEW.date_debut) 
BEGIN   
RAISE EXCEPTION 'La date de fin doit être après la date de début.';
END;`

Ici, on bloque une insertion/modification si la date de fin est antérieure à la date de début, ce qui ne peut pas se faire avec une contrainte CHECK standard.

### trigger automatique

Un trigger est **déclenché automatiquement** par le système de gestion de base de données (SGBD) lorsqu’un événement spécifique se produit sur une table : un `INSERT`, un `UPDATE` ou un `DELETE`.

---

### Comment un trigger est-il déclenché ?

1. **Tu définis un trigger** attaché à une table sur un événement précis (par exemple : avant ou après un `INSERT`).
    
2. **Dès que tu exécutes une commande SQL sur cette table qui correspond à cet événement,** le trigger s’exécute automatiquement.
    

---

### Exemple simple :

Supposons que tu as ce trigger sur la table `employe` :

`CREATE TRIGGER verif_nom 
BEFORE INSERT ON employe 
FOR EACH ROW
BEGIN   -- Par exemple, on pourrait vérifier que le nom n'est pas vide   
IF NEW.nom IS NULL OR NEW.nom = '' 
THEN     
RAISE EXCEPTION 'Le nom ne peut pas être vide.';   END IF;
END;`

**Comment le trigger se déclenche-t-il ?**

Quand tu fais :
INSERT INTO employe (nas, nom, prenom, date_embauche) 
VALUES (123456789, '', 'Jean', '2025-01-01');

## Autres possibilités:

### 1. **Structures conditionnelles :**

#### `CASE`

Tu peux utiliser une structure `CASE` à l'intérieur d’un trigger, surtout pour **affecter des valeurs** ou choisir une action :


`CREATE TRIGGER exemple_case 
BEFORE INSERT ON employe 
FOR EACH ROW 
BEGIN   
CASE    
WHEN NEW.departement IS NULL THEN      
RAISE EXCEPTION 'Un département doit être assigné.';    
WHEN NEW.salaire < 0 THEN       
RAISE EXCEPTION 'Le salaire ne peut pas être négatif.';    
ELSE       -- Rien à faire   
END CASE; 
END;`

---

### ✅ 2. **Boucles (loop, while, for)**

Si tu veux faire un traitement sur plusieurs lignes ou vérifier une logique répétitive :


`DECLARE   compteur INTEGER := 0; 
BEGIN   
WHILE compteur < 3 LOOP    
compteur := compteur + 1;     
RAISE NOTICE 'Vérification numéro %', compteur;   
END LOOP; 
END;`

---

### ✅ 3. **Instructions SQL dans le trigger**

Tu peux insérer, mettre à jour ou supprimer d’autres tables depuis un trigger (⚠️ avec prudence pour éviter les boucles infinies) :



`CREATE TRIGGER log_insert 
AFTER
INSERT ON employe FOR EACH ROW 
BEGIN   INSERT INTO log_table (message, date_evenement)   
VALUES ('Nouvel employé inséré', NOW());
END;`

---

### ✅ 4. **Utilisation de `EXCEPTION` pour gérer les erreurs**

Tu peux capturer et traiter les erreurs :


`BEGIN   -- Action EXCEPTION  
WHEN division_by_zero THEN    
RAISE NOTICE 'Erreur : division par zéro.'; END;`

---

### ✅ 5. **Appel à des fonctions**

Tu peux appeler une fonction définie ailleurs :

`BEGIN   PERFORM ou Call verifier_employe(NEW.id); END;`

### 

|Contexte|Instruction|Quand l’utiliser|
|---|---|---|
|Fonction dans une procédure|`PERFORM`|Tu veux exécuter une fonction, ignorer le retour|
|Fonction dans un trigger|`PERFORM`|Idem, très courant dans les triggers|
|Procédure en SQL direct|`CALL`|Appel d’une procédure (`CREATE PROCEDURE`)|
|PostgreSQL < 11|`EXECUTE PROCEDURE`|Ancienne manière d’appeler une procédure|
