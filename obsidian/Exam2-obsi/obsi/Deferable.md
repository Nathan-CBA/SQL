**pour que les contraintes `DEFERRABLE` aient un effet**, **les `INSERT` (ou `UPDATE` / `DELETE`) doivent être dans une transaction**.

---

##  Pourquoi ?

Les contraintes marquées `DEFERRABLE INITIALLY DEFERRED` ne sont **vérifiées qu'à la fin de la transaction**. Transaction -> [[Insert-Update-Delete]]
Donc si tu n’utilises pas explicitement une transaction, alors :

- Chaque `INSERT` est traité comme une **transaction implicite individuelle**.
    
- La contrainte est vérifiée **tout de suite**, ce qui revient à un comportement `IMMEDIATE`.


La clause `DEFERRABLE` permet de **retarder la vérification** d’une **contrainte de clé étrangère** **jusqu’à la fin de la transaction**, au lieu de la vérifier immédiatement.
> C’est **utile en cas de dépendance circulaire** ou quand tu veux insérer plusieurs lignes liées entre elles **en une seule transaction**.

syntaxe:
DEFERRABLE INITIALLY DEFERRED;
- `DEFERRABLE` : rend la contrainte retardable.
- `INITIALLY DEFERRED` : elle est vérifiée **à la fin de la transaction**.
-  INITIALLY IMMEDIATE:  elle soit vérifiée tout de suite **par défaut**

## Exemple simple avec dépendance circulaire

### Tables : `auteur` et `livre`
### `DEFERRABLE INITIALLY DEFERRED

`CREATE TABLE auteur (   
id SERIAL PRIMARY KEY,  
nom VARCHAR(100)
);  
CREATE TABLE livre (   
id SERIAL PRIMARY KEY,  
titre VARCHAR(100),   
auteur_id INTEGER,   
CONSTRAINT fk_livre_auteur FOREIGN KEY (auteur_id)     REFERENCES auteur(id)     DEFERRABLE INITIALLY DEFERRED 
);`

Puis, on ajoute une colonne de référence dans l’autre sens :

`ALTER TABLE auteur 
ADD COLUMN livre_prefere INTEGER; 
ALTER TABLE auteur 
ADD CONSTRAINT fk_auteur_livre
FOREIGN KEY (livre_prefere)   
REFERENCES livre(id)   DEFERRABLE INITIALLY DEFERRED;`

###  Pourquoi ça marche ?

Parce que la vérification est **repoussée à la fin de la transaction**, tu peux insérer d’abord les lignes vides ou partiellement remplies, et **mettre à jour les relations ensuite**, le tout **dans une seule transaction**.

## Exemple d’usage dans une transaction

`BEGIN;  
INSERT INTO auteur (id, nom) 
VALUES (1, 'Victor Hugo'); 
INSERT INTO livre (id, titre, auteur_id) 
VALUES (10, 'Les Misérables', 1); 
UPDATE auteur 
SET livre_prefere = 10 WHERE id = 1;  
COMMIT;`

> Les contraintes FK ne sont **vérifiées qu’à la fin** (`COMMIT`), donc ça passe même si `auteur` fait référence à `livre` et vice versa.



###  `DEFERRABLE INITIALLY IMMEDIATE`


`CREATE TABLE auteur (   
id SERIAL PRIMARY KEY,   
nom VARCHAR(100),   
livre_prefere INTEGER );  
CREATE TABLE livre (   
id SERIAL PRIMARY KEY,   
titre VARCHAR(100),   
auteur_id INTEGER NOT NULL,   
CONSTRAINT fk_livre_auteur  FOREIGN KEY (auteur_id)     
REFERENCES auteur(id)    DEFERRABLE INITIALLY IMMEDIATE 
);  
ALTER TABLE auteur 
ADD CONSTRAINT fk_auteur_livre FOREIGN KEY (livre_prefere)  
REFERENCES livre(id)   DEFERRABLE INITIALLY IMMEDIATE;`

---

## Utilisation sans modifier le mode (contrainte immédiate)


`-- Ceci va ÉCHOUER car les contraintes sont vérifiées immédiatement BEGIN;  
INSERT INTO auteur (id, nom, livre_prefere) 
VALUES (1, 'Victor Hugo', 10); 
INSERT INTO livre (id, titre, auteur_id) 
VALUES (10, 'Les Misérables', 1);  COMMIT;`

**Erreur** : au moment où tu insères l’auteur, le livre 10 n’existe pas encore → la FK échoue immédiatement.

---

##  Solution : retarder les contraintes dans la transaction

`BEGIN;  
-- On retarde la vérification des contraintes 
DEFERRABLE SET CONSTRAINTS ALL DEFERRED;  
INSERT INTO auteur (id, nom, livre_prefere) 
VALUES (1, 'Victor Hugo', 10); 
INSERT INTO livre (id, titre, auteur_id)
VALUES (10, 'Les Misérables', 1); 
COMMIT;



## Pourquoi utilise-t-on `DEFERRABLE` alors ?

### 1. **Dépendances circulaires**

Oui, **c’est un cas classique**.  
Quand deux tables se réfèrent **mutuellement** avec des clés étrangères, on **doit** utiliser `DEFERRABLE` pour permettre leur création et insertion sans erreur immédiate.

 **Exemple classique :**

- `auteur.livre_prefere → livre.id`
    
- `livre.auteur_id → auteur.id`
    

Les deux colonnes dépendent l’une de l’autre. Impossible de satisfaire les deux contraintes au même moment sans `DEFERRABLE`.

---

###  2. **Ordre d'insertion temporairement incorrect**

Quand tu dois insérer des données dans un ordre qui **viole temporairement une contrainte**, mais qui sera **valide à la fin de la transaction**.

 **Exemple concret :**

`BEGIN;  
-- FK vers un compte qui n’existe pas encore 
INSERT INTO transaction (compte_id, montant) 
VALUES (1, 100);  
-- Création du compte ensuite 
INSERT INTO compte_bancaire (id, nom) 
VALUES (1, 'Nathan');  
COMMIT;`

 Ce scénario **n’est pas circulaire**, mais a besoin d’une contrainte `DEFERRABLE INITIALLY DEFERRED` pour réussir.

---

###  3. **Scénarios complexes avec suppression, mise à jour, batchs**

Quand on met à jour plusieurs lignes ou qu’on supprime des données dans un ordre qui **peut temporairement violer** une contrainte, mais qui **sera correct à la fin**.

---

##  Résumé

| Situation                                     | `DEFERRABLE` requis ?               | Dépendance circulaire ? |     |
| --------------------------------------------- | ----------------------------------- | ----------------------- | --- |
| Deux tables se référencent mutuellement       | Oui                                 | Oui                     |     |
| Insertion par lots dans un ordre non respecté | Oui (si on veut éviter des erreurs) | Non                     |     |
| Suppression/modification massive              | Souvent utile                       |  Non                    | `   |