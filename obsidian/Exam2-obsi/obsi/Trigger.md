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

### 2. **Boucles (loop, while, for)**

Si tu veux faire un traitement sur plusieurs lignes ou vérifier une logique répétitive :


`DECLARE   compteur INTEGER := 0; 
BEGIN   
WHILE compteur < 3 LOOP    
compteur := compteur + 1;     
RAISE NOTICE 'Vérification numéro %', compteur;   
END LOOP; 
END;`

---

###  3. **Instructions SQL dans le trigger**

Tu peux insérer, mettre à jour ou supprimer d’autres tables depuis un trigger (⚠️ avec prudence pour éviter les boucles infinies) :



`CREATE TRIGGER log_insert 
AFTER
INSERT ON employe FOR EACH ROW 
BEGIN  
INSERT INTO log_table (message, date_evenement)   
VALUES ('Nouvel employé inséré', NOW());
END;`

---

###  4. **Utilisation de `EXCEPTION` pour gérer les erreurs**

Tu peux capturer et traiter les erreurs :


`BEGIN   -- Action EXCEPTION  
WHEN division_by_zero THEN    
RAISE NOTICE 'Erreur : division par zéro.'; END;`

---

###  5. **Appel à des fonctions**

Tu peux appeler une fonction définie ailleurs :

`BEGIN   PERFORM ou Call verifier_employe(NEW.id); END;`

### 

|Contexte|Instruction|Quand l’utiliser|
|---|---|---|
|Fonction dans une procédure|`PERFORM`|Tu veux exécuter une fonction, ignorer le retour|
|Fonction dans un trigger|`PERFORM`|Idem, très courant dans les triggers|
|Procédure en SQL direct|`CALL`|Appel d’une procédure (`CREATE PROCEDURE`)|
|PostgreSQL < 11|`EXECUTE PROCEDURE`|Ancienne manière d’appeler une procédure|


### Concepts clés

- **Trigger** : c’est un mécanisme qui exécute automatiquement du code (souvent une fonction) lors d’un événement spécifique sur une table (INSERT, UPDATE, DELETE).
    
- **Fonction trigger** : fonction spéciale qui contient le code exécuté par le trigger.
    
- **NEW** : en `INSERT` ou `UPDATE`, représente la nouvelle ligne qui va être insérée ou modifiée.
    
- **OLD** : en `UPDATE` ou `DELETE`, représente l’ancienne ligne (avant modification ou suppression).
    
- **RETURN** : dans une fonction trigger, il faut retourner la ligne à insérer/modifier (`NEW`) ou `NULL` pour supprimer la ligne.
    
- **RAISE EXCEPTION** : permet de déclencher une erreur personnalisée qui stoppe l’opération.
    

---

### Exemple concret

**Contexte** : Sur une table `employe`, on veut vérifier avant insertion ou mise à jour que le champ `nom` n’est pas vide. Sinon, on bloque l’opération.

---

#### 1. Création de la fonction trigger



`CREATE OR REPLACE FUNCTION verif_nom_non_vide() 
RETURNS trigger AS 
$ 
BEGIN     
-- Vérifie que le nom n'est pas NULL ni vide     
IF NEW.nom IS NULL OR TRIM(NEW.nom) = '' THEN         
RAISE EXCEPTION 'Le nom ne peut pas être vide';     
END IF;      
-- Retourne la ligne modifiée (NEW)     
RETURN NEW; 
END; 
$ LANGUAGE plpgsql;`

#### 2. Création du trigger lié à la table `employe`

`CREATE TRIGGER verif_nom_trigger 
BEFORE INSERT OR UPDATE ON employe 
FOR EACH ROW
EXECUTE FUNCTION verif_nom_non_vide();`

##### Non, on ne crée pas de trigger _à l’intérieur_ d’une fonction.

##### Oui, on crée une **fonction trigger** (une fonction spéciale qui sera appelée par un trigger).



## Before et After

### Différence entre `BEFORE` et `AFTER`

|Type de trigger|Quand il s'exécute|Usage typique|
|---|---|---|
|**BEFORE INSERT/UPDATE/DELETE**|Avant que l'opération ne soit réellement faite dans la table|- Valider/modifier les données avant insertion ou mise à jour  <br>- Bloquer l’opération en levant une exception  <br>- Modifier la ligne insérée ou mise à jour (`RETURN NEW` ou `RETURN NULL` pour annuler)  <br>- Prévenir des erreurs avant modification|
|**AFTER INSERT/UPDATE/DELETE**|Après que l'opération soit faite|- Actions dépendantes des données déjà modifiées  <br>- Mise à jour dans d’autres tables (audit, logs)  <br>- Déclenchement de traitements asynchrones ou notifications  <br>- Actions qui ne modifient pas directement la ligne insérée|




### BEFORE INSERT : Valider que `nom` n’est pas vide

`CREATE OR REPLACE FUNCTION verif_nom_non_vide() 
RETURNS trigger AS $
BEGIN     
IF NEW.nom IS NULL OR TRIM(NEW.nom) = '' THEN       
RAISE EXCEPTION 'Le nom ne peut pas être vide';    
END IF;   
RETURN NEW; 
END; $ 
LANGUAGE plpgsql; 

CREATE TRIGGER trg_verif_nom 
BEFORE INSERT ON employe
FOR EACH ROW EXECUTE FUNCTION verif_nom_non_vide();`

---

### 2. AFTER INSERT : Enregistrer une action dans une table d’historique



CREATE OR REPLACE FUNCTION log_insertion_employe()
RETURNS trigger AS $
BEGIN
    INSERT INTO historique (id_employe, action, date_action)
    VALUES (NEW.id, 'Insertion', NOW());
    RETURN NEW;
END;
$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_insertion
AFTER INSERT ON employe
FOR EACH ROW
EXECUTE FUNCTION log_insertion_employe();


---

### 3. BEFORE UPDATE : Mettre à jour une date de modification

CREATE OR REPLACE FUNCTION maj_date_modif()
RETURNS trigger AS $
BEGIN
    NEW.date_modif := NOW();
    RETURN NEW;
END;
$ LANGUAGE plpgsql;

CREATE TRIGGER trg_maj_date_modif
BEFORE UPDATE ON employe
FOR EACH ROW
EXECUTE FUNCTION maj_date_modif();


---

### 4. AFTER DELETE : Supprimer des données liées (suppression manuelle en cascade)

CREATE OR REPLACE FUNCTION suppr_commandes_client()
RETURNS trigger AS $
BEGIN
    DELETE FROM commandes WHERE client_id = OLD.id;
    RETURN OLD;
END;
$ LANGUAGE plpgsql;

CREATE TRIGGER trg_suppr_commandes
AFTER DELETE ON client
FOR EACH ROW
EXECUTE FUNCTION suppr_commandes_client();
