### Qu’est-ce qu’une transaction ?

Une **transaction** est un ensemble d’opérations SQL qui sont exécutées **comme une seule unité logique**.

- Soit **tout réussit** (commit)
    
- Soit **tout est annulé** (rollback)
    

Cela garantit la **cohérence des données** même en cas de problème.


## Pourquoi faire des `INSERT`, `UPDATE`, `DELETE` dans une transaction ?

- Pour **regrouper plusieurs modifications** et ne pas laisser la base dans un état intermédiaire
    
- Pour pouvoir **annuler toutes les modifications** si une erreur survient
    
- Pour permettre les contraintes `DEFERRABLE` (qu’on a vu plus tôt)
    
- Pour gérer la concurrence avec plus de contrôle

## Syntaxe de base d’une transaction :


`BEGIN;  
-- Démarre la transaction  
-- Ici on met nos opérations SQL 
INSERT INTO table (col1, col2) 
VALUES ('val1', 'val2');
UPDATE table 
SET col1 = 'val3' WHERE col2 = 'val2'; 
DELETE FROM 
table WHERE col1 = 'val4';  
COMMIT; 
-- Valide toutes les opérations, les rend permanentes -- OU 
ROLLBACK;
-- Annule toutes les opérations faites depuis BEGIN

## Insert:

### Insertion basée sur une requête SELECT

### Qu’est-ce que c’est ?

Au lieu d’insérer une seule ligne avec des valeurs fixes, on peut insérer **plusieurs lignes à partir des résultats d’une requête SELECT**.

**Syntaxe générale :**

`INSERT INTO table_cible (col1, col2, col3, ...) SELECT colA, colB, colC, ... FROM table_source WHERE conditions;`

- La requête `SELECT` peut venir d’une même table ou de plusieurs tables jointes.
    
- Le nombre et le type de colonnes sélectionnées doivent correspondre aux colonnes ciblées dans la table d’insertion.
    

---

### Pourquoi utiliser cette méthode ?

- **Insertion en masse** : permet d’insérer plusieurs lignes en une seule instruction, pratique pour transférer ou copier des données.
    
- **Transformation des données** : on peut utiliser des fonctions, des expressions, des CASE, etc., pour transformer ou filtrer les données au moment de l’insertion.
    
- **Synchronisation entre tables** : utile pour copier des données issues d’autres tables, ou insérer des données agrégées.
    

---

### Subtilités à connaître

1. **Correspondance des colonnes**  
    Les colonnes listées dans l’`INSERT INTO` doivent correspondre **en nombre et en type** à celles produites par le `SELECT`. Sinon, erreur.
    
2. **Ordre des colonnes**  
    L’ordre des colonnes dans le `INSERT INTO` doit correspondre à celui des colonnes retournées par le `SELECT`.
    
3. **Performance**  
    Insérer en masse avec `INSERT INTO ... SELECT` est souvent plus performant que faire plusieurs `INSERT INTO ... VALUES` séparés.
    
4. **Contraintes & Triggers**  
    Les contraintes (clés étrangères, NOT NULL, CHECK, etc.) et triggers s’appliquent aussi pendant cette insertion :
    
    - Si une ligne du `SELECT` viole une contrainte, l’insertion échoue (selon le système et la transaction).
        
    - Les triggers d’insertion s’exécutent pour chaque ligne insérée.
        
5. **Transactions**  
    Comme une requête d’insertion classique, tu peux encapsuler un `INSERT INTO ... SELECT` dans une transaction pour garantir atomicité.
    
6. **Sous-requêtes complexes**  
    Le `SELECT` peut contenir des jointures, des agrégats, des sous-requêtes, des expressions conditionnelles (CASE), etc., pour produire exactement les données désirées.
    
7. **Pas de valeurs fixes**  
    Contrairement à un `INSERT INTO ... VALUES (...)`, il n’y a pas de valeurs explicites données dans l’instruction, tout vient de la requête `SELECT`.
    

---

### Exemple simple

`-- Copie des employés de Paris dans une table archive 
INSERT INTO employe_archive (id, nom, ville) 
SELECT id, 
nom, 
ville 
FROM employe WHERE ville = 'Paris';`


### Update:

Modifier des données existantes.

### Subtilités importantes :

- **Ciblage précis des lignes**
    
    - La clause `WHERE` doit être bien définie pour éviter de modifier trop ou trop peu de lignes.
        
    - Sans `WHERE`, toutes les lignes sont mises à jour !
        
- **Effets cascades**
    
    - Mise à jour des clés primaires référencées peut entraîner des cascades (si défini).
        
    - Sans cascade, un `UPDATE` modifiant une clé primaire référencée échouera.
    -
    - il faut insérer On update CASCADE dans la contrainte foreign key pour gérer un futur update dans une transaction 
    -  ex : CONSTRAINT fk_livre_auteur FOREIGN KEY (auteur_id)
		    REFERENCES auteur(id)
			    ON UPDATE CASCADE
- **Contrainte d’intégrité**
    - La nouvelle valeur doit respecter les contraintes de la table (FK, UNIQUE, CHECK...).
- **Transactions**
    - Les `UPDATE` dans une transaction peuvent être annulés avec un `ROLLBACK`.
- **Verrouillage**
    
    - Les lignes modifiées sont verrouillées pendant la transaction, ce qui peut créer des blocages.

# ****

###  DELETE:

Supprimer des lignes existantes.

### Subtilités importantes :

- **Ciblage précis**
    
    - Comme pour `UPDATE`, la clause `WHERE` est cruciale pour éviter des suppressions massives non voulues.
        
- **Effets cascades**
    
    - Les suppressions peuvent déclencher des suppressions en cascade sur les     tables référencées si `ON DELETE CASCADE` est défini.
    - ex : CONSTRAINT fk_livre_auteur FOREIGN KEY (auteur_id)
		    REFERENCES auteur(id)
			    ON DELETE CASCADE
        
    - Sinon, la suppression échoue si la ligne est référencée par une FK.
        
- **Contrainte d’intégrité**
    
    - Impossible de supprimer une ligne référencée sans cascade.
        
- **Transactions**
    
    - Suppressions dans une transaction peuvent être annulées avec `ROLLBACK`.
        
- **Verrouillage**
    
    - Les lignes supprimées sont verrouillées pendant la transaction.


## EX DELETE:
|id|nom|occupation|
|---|---|---|
|1|Alice|Tennis|
|2|Bob|Football|
|3|Clara|Basket|

`DELETE FROM ta_table WHERE id = 1;`

Alors la ligne entière avec `id = 1` (Alice, Tennis) **sera supprimée complètement**.

Le résultat de ta table après suppression sera :

|id|nom|occupation|
|---|---|---|
|2|Bob|Football|
|3|Clara|Basket|

