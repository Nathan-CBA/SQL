### 1. **Tableau comparatif : Fonction vs Procédure**

| Critère                                          | **Fonction** (`FUNCTION`)               | **Procédure** (`PROCEDURE`)                    |
| ------------------------------------------------ | --------------------------------------- | ---------------------------------------------- |
| **Retour**                                       | Toujours une **valeur** (`RETURN`)      | Peut ne rien retourner (`CALL`)                |
| **Utilisable dans une requête**                  | Oui (`SELECT`, `WHERE`, etc.)           | Non                                            |
| **Effets sur les données**                       | Ne modifie pas les tables               | Peut faire des `INSERT`, `UPDATE`, `DELETE`    |
| **Syntaxe d’appel**                              | `SELECT ma_fonction(...);`              | `CALL ma_procedure(...);` ou `EXECUTE`         |
| **Transaction possible ?**                       | Non (pas de COMMIT/ROLLBACK internes)   | Oui                                            |
| **Utilité principale**                           | Calculs, vérifications, transformations | Automatiser des traitements, chaînes d’actions |
| **Exécution automatique possible (ex. Trigger)** |  Oui                                    | Oui                                            |

---

### 2. **Avantages & Quand les utiliser ?**

####  **Fonction**

-  Réutilisable dans des requêtes SQL
    
-  Lisible et utile pour des **transformations simples**
    
-  Appelée directement dans un `SELECT`
    
-  Ne peut pas faire de changements dans la base
    

**Utilisation idéale :**

- Calculs personnalisés (`calcul_bonus`)
    
- Concaténation (`nom_complet`)
    
- Formatage (`format_date`)
    
- Validation logique (`valider_courriel`)
    

####  **Procédure**

-  Exécute des blocs logiques complexes
    
-  Peut modifier plusieurs tables
    
-  Gère des transactions
    
-  Ne peut pas être utilisée dans un `SELECT`
    

**Utilisation idéale :**

- Remplir automatiquement plusieurs tables
    
- Supprimer des données liées à un utilisateur
    
- Traitements complexes avec boucles, conditions, vérifications
    

---

###  3. **Exemples**

####  **Fonction – Calcul d’un bonus**

`CREATE FUNCTION calcul_bonus(salaire INT) 
RETURNS INT AS $ 
BEGIN   
RETURN salaire * 0.1 + 500;
END; 
$
LANGUAGE plpgsql;  
-- Appel dans une requête SELECT nom, 
calcul_bonus(salaire_mensuel) 
FROM employe;

---

####  **Procédure – Supprimer un employé et ses feuilles de temps**


`CREATE PROCEDURE supprimer_employe(IN emp_id INT) 
LANGUAGE plpgsql AS 
$ BEGIN   
DELETE FROM feuille_temps 
WHERE employe = emp_id;   
DELETE FROM employe 
WHERE nas = emp_id; 
END; 
$; 
-- Appel de la procédure 
CALL supprimer_employe(123456789);`



###  Conclusion

- Utilise une **fonction** si tu veux **retourner une valeur dans une requête** sans modifier les données.
    
- Utilise une **procédure** si tu veux **exécuter un processus complet** (avec des modifications de données, plusieurs étapes, des transactions…).



## `RAISE EXCEPTION` et `EXCEPTION` 

- Sert à **lancer une erreur volontairement** dans une fonction ou un trigger.
    
- Interrompt l'exécution normale et renvoie un message d'erreur personnalisé.
    
- Utile pour **valider des données**, **empêcher des modifications invalides** ou signaler un problème spécifique.
    
- Exemple simple :
    
   
    
    `IF NEW.nom IS NULL THEN  
     RAISE EXCEPTION 'Le nom ne peut pas être vide'; END IF;`
    

### Bloc `EXCEPTION`

- Permet de **capturer et gérer les erreurs** survenant dans un bloc `BEGIN ... END`.
    
- Fonctionne comme un gestionnaire d’erreurs, similaire à un `try-catch` dans d’autres langages.
    
- On peut capturer des erreurs spécifiques (`WHEN division_by_zero THEN ...`) ou toutes les erreurs (`WHEN OTHERS THEN ...`).
    
- Permet d'exécuter un code correctif ou de renvoyer une autre erreur avec un message adapté.
    
- Exemple :
    
    
    `BEGIN   
    -- code pouvant générer une erreur 
    EXCEPTION WHEN OTHERS THEN     
    RAISE EXCEPTION 'Une erreur inattendue est survenue'; END;`
    

---

### En résumé

- **`RAISE EXCEPTION`** : tu déclenches une erreur explicitement.
    
- **`EXCEPTION`** : tu gères les erreurs qui ont été déclenchées (par toi ou par le système).

### Exemple de code correctif Exception

DECLARE
  tentative_valeur TEXT := 'valeur_initiale';
  -- Bloc global (fonction ou trigger)
BEGIN
-- Bloc local protégé (exécution risquée, exemple : INSERT)
  BEGIN
    INSERT INTO ma_table (colonne) VALUES (tentative_valeur);
  EXCEPTION
    WHEN unique_violation THEN
      -- Code correctif : modifier la valeur pour éviter le doublon
      tentative_valeur := tentative_valeur || '_1';
      -- Réessayer l'insertion avec la nouvelle valeur
      INSERT INTO ma_table (colonne) VALUES (tentative_valeur);
  END;
END;

