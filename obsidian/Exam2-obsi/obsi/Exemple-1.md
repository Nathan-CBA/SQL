### **Résumé – Gestion du superviseur d’un employé**

Pour garantir qu’un employé ait toujours un superviseur, même s’il n’en a pas réellement, on utilise une **clé étrangère autoréférentielle non nulle** sur la colonne `superviseur`.

- La colonne `superviseur` référence la clé primaire `nas` de la **même table `employe`**.
    
- Elle est définie avec `NOT NULL`, donc chaque employé doit avoir un superviseur.
    
- **Si un employé n’a pas de supérieur réel, il se supervise lui-même** (on met `superviseur = nas`).
    
- Cette stratégie repose sur une **relation récursive** et peut être renforcée avec un **trigger** si nécessaire.
    

 Cela garantit qu’un superviseur est toujours présent, sans violer les contraintes d’intégrité.

---

###  **Exemple de code SQL**


`CREATE TABLE employe (  
nas INTEGER PRIMARY KEY, 
nom VARCHAR(50),   
prenom VARCHAR(50),   
date_embauche DATE,  
superviseur INTEGER NOT NULL,  
FOREIGN KEY (superviseur) REFERENCES employe(nas) 
);


### Gestion des dépendances entre projets : résumé

- La relation entre projets est de type **n vers n** : un projet peut dépendre de plusieurs projets et être requis par plusieurs projets.
    
- Cette relation est modélisée par une **table d’association** (`projet_dependance`) contenant deux clés étrangères :
    
    - `projet_dependant` : projet qui dépend d’un autre
        
    - `projet_requis` : projet dont dépend le précédent
        
- La dépendance est **optionnelle** : un projet peut ne pas avoir de dépendances (aucune ligne dans la table d’association).
    
- Les colonnes de la table sont des **clés étrangères** vers la table `projet`, assurant l’intégrité référentielle.
    

---

**Exemple de création de la table d’association :**


`CREATE TABLE projet_dependance (  
projet_dependant INTEGER NOT NULL,  
projet_requis INTEGER NOT NULL,  
PRIMARY KEY (projet_dependant, projet_requis),   
FOREIGN KEY (projet_dependant) REFERENCES projet(id),  
FOREIGN KEY (projet_requis) REFERENCES projet(id)
);


### Résumé sur la contrainte directeur unique par employé

- **Conception actuelle :**  
    La table `departement` contient une colonne `directeur_id` obligatoire qui référence un employé, ce qui garantit qu’un département a toujours un directeur.
    
- **Limitation actuelle :**  
    Rien n’empêche qu’un même employé soit directeur de plusieurs départements.
    
- **Pour garantir qu’un employé dirige au plus un département :**  
    Il faut ajouter une **contrainte d’unicité** (`UNIQUE`) sur la colonne `directeur_id` dans la table `departement`.  
    Cela interdit qu’un même `directeur_id` apparaisse plusieurs fois.
    
- **Alternatives :**
    
    - Modifier la modélisation en plaçant la relation dans la table `employe` (moins courant).
        
    - Gérer cette contrainte via la logique métier ou des triggers (moins fiable).``
    -
## 6 contraintes 
CREATE TABLE employe (
  id SERIAL PRIMARY KEY,                  -- 3. PRIMARY KEY (implique NOT NULL + UNIQUE)
  nom VARCHAR(100) NOT NULL,              -- 1. NOT NULL (nom obligatoire)
  email VARCHAR(255) UNIQUE NOT NULL,    -- 2. UNIQUE + NOT NULL (email unique et obligatoire)
  age INTEGER CHECK (age >= 18),          -- 5. CHECK (âge >= 18)
  departement_id INTEGER,                  -- 4. FOREIGN KEY optionnelle
  statut VARCHAR(20) DEFAULT 'actif',     -- 6. DEFAULT ('actif' par défaut)
  
  FOREIGN KEY (departement_id) REFERENCES departement(id)
);
