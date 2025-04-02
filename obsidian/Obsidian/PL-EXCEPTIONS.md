# PL - Gestion des exceptions

La gestion des exceptions en PL/pgSQL permet de capturer et traiter les erreurs qui se produisent pendant l'exécution du code, assurant ainsi une exécution plus robuste et une meilleure expérience utilisateur.

## Principes fondamentaux

### Structure de base

La gestion des exceptions en PL/pgSQL s'effectue avec le bloc `EXCEPTION` placé après le corps principal du code :

```sql
BEGIN
    -- Instructions normales
    -- ...
EXCEPTION
    WHEN condition_exception THEN
        -- Gestionnaire d'exception
    WHEN condition_exception THEN
        -- Autre gestionnaire
    WHEN OTHERS THEN
        -- Capture toutes les autres exceptions
END;
```

### Priorité des exceptions

Lorsqu'une exception est levée, PostgreSQL recherche un gestionnaire adapté dans l'ordre d'apparition. Si aucun gestionnaire correspondant n'est trouvé dans le bloc actuel, l'exception est propagée au bloc parent.

### Propagation des exceptions

Une exception non traitée est propagée aux blocs parents jusqu'à ce qu'elle soit capturée ou qu'elle atteigne le niveau supérieur, où elle provoque l'annulation de la transaction.

## Lever des exceptions

### Instruction RAISE

L'instruction `RAISE` permet de lever des exceptions avec différents niveaux de gravité :

```sql
RAISE [niveau] 'message' [, expression [, ...]];
```

Niveaux disponibles (du moins au plus sévère) :
- `DEBUG` : Information de débogage
- `LOG` : Information de journalisation
- `INFO` : Information générique
- `NOTICE` : Avis
- `WARNING` : Avertissement
- `EXCEPTION` (par défaut) : Erreur fatale qui arrête l'exécution

Seul le niveau `EXCEPTION` provoque l'interruption du traitement, les autres niveaux permettent simplement d'afficher des informations sans interrompre l'exécution.

### Exemples de RAISE

```sql
-- Exception simple
RAISE EXCEPTION 'Cette opération n''est pas autorisée';

-- Exception avec paramètres
RAISE EXCEPTION 'L''employé % n''existe pas', p_emp_id;

-- Message de débogage
RAISE DEBUG 'Valeurs intermédiaires: a=%, b=%', v_a, v_b;

-- Avertissement
RAISE WARNING 'Cette fonction sera obsolète dans la prochaine version';
```

### Options de RAISE

L'instruction RAISE peut être personnalisée avec les options suivantes :

```sql
RAISE [niveau] 'message' [, expressions]
    [USING option = expression [, ...]];
```

Options disponibles :
- `MESSAGE` : Le message d'erreur
- `DETAIL` : Informations détaillées
- `HINT` : Suggestion pour résoudre le problème
- `ERRCODE` : Code d'erreur SQLSTATE

Exemple :
```sql
RAISE EXCEPTION 'Le compte est inactif'
    USING HINT = 'Veuillez contacter le service client',
          DETAIL = 'Compte ID: ' || p_compte_id,
          ERRCODE = 'P0001';  -- Code d'erreur personnalisé
```

## Capture d'exceptions

### Conditions d'exception prédéfinies

PostgreSQL fournit plusieurs conditions d'exception prédéfinies qui peuvent être utilisées dans les clauses `WHEN` :

| Nom de condition           | Code SQLSTATE | Description                                                 |
|----------------------------|---------------|-------------------------------------------------------------|
| `DIVISION_BY_ZERO`         | 22012         | Division par zéro                                           |
| `NO_DATA_FOUND`            | P0002         | Aucune ligne retournée par une requête                      |
| `TOO_MANY_ROWS`            | P0003         | Plus d'une ligne retournée par une requête SELECT INTO      |
| `UNIQUE_VIOLATION`         | 23505         | Violation de contrainte d'unicité                           |
| `FOREIGN_KEY_VIOLATION`    | 23503         | Violation de contrainte de clé étrangère                    |
| `NOT_NULL_VIOLATION`       | 23502         | Violation de contrainte NOT NULL                            |
| `CHECK_VIOLATION`          | 23514         | Violation de contrainte CHECK                               |
| `INVALID_CURSOR_STATE`     | 24000         | État de curseur invalide                                    |
| `CASE_NOT_FOUND`           | 20000         | Aucune condition WHEN n'est vraie dans un CASE              |
| `DATATYPE_MISMATCH`        | 42804         | Incompatibilité de type de données                          |
| `OTHERS`                   | -             | Capture toutes les exceptions non capturées par les autres   |

### Exemple de capture d'exceptions prédéfinies

```sql
DO $$
DECLARE
    v_emp_id INTEGER := 123;
    v_emp_data employe%ROWTYPE;
BEGIN
    -- Tentative de récupération d'un employé
    SELECT * INTO STRICT v_emp_data
    FROM employe
    WHERE id = v_emp_id;
    
    RAISE NOTICE 'Employé trouvé: %', v_emp_data.nom;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'Aucun employé avec ID % n''a été trouvé', v_emp_id;
    WHEN TOO_MANY_ROWS THEN
        RAISE NOTICE 'Plusieurs employés correspondent à cet ID, veuillez affiner la recherche';
    WHEN OTHERS THEN
        RAISE NOTICE 'Erreur inattendue: %', SQLERRM;
END;
$$;
```

### Capture par code SQLSTATE

Vous pouvez également capturer des exceptions en utilisant directement le code SQLSTATE :

```sql
EXCEPTION
    WHEN SQLSTATE '23505' THEN
        -- Violation de contrainte d'unicité
    WHEN SQLSTATE '23503' THEN
        -- Violation de contrainte de clé étrangère
```

### Variables spéciales dans les gestionnaires d'exceptions

Lorsqu'une exception est capturée, plusieurs variables spéciales sont disponibles :

- `SQLSTATE` : Code d'erreur SQLSTATE
- `SQLERRM` : Message d'erreur
- `RETURNED_SQLSTATE` : Similaire à SQLSTATE
- `MESSAGE_TEXT` : Message d'erreur principal
- `PG_EXCEPTION_DETAIL` : Détails de l'exception
- `PG_EXCEPTION_HINT` : Suggestion pour résoudre le problème
- `PG_EXCEPTION_CONTEXT` : Contexte de la pile d'appel

```sql
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Erreur: %, État: %, Détail: %', 
                     SQLERRM, SQLSTATE, PG_EXCEPTION_DETAIL;
```

## Exceptions et blocs imbriqués

### Propagation entre blocs

Lorsqu'une exception est levée dans un bloc imbriqué, elle est propagée vers le bloc parent si elle n'est pas capturée :

```sql
DO $$
BEGIN
    -- Bloc externe
    BEGIN
        -- Bloc interne
        RAISE EXCEPTION 'Exception interne';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Exception capturée dans le bloc interne: %', SQLERRM;
            -- L'exception est traitée ici, elle ne se propage pas
    END;
    
    RAISE NOTICE 'Exécution du bloc externe continue normalement';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Exception capturée dans le bloc externe: %', SQLERRM;
END;
$$;
```

### Relance d'exceptions

Vous pouvez capturer une exception, effectuer certaines opérations, puis la relancer :

```sql
BEGIN
    -- Instructions
EXCEPTION
    WHEN OTHERS THEN
        -- Journalisation de l'erreur
        INSERT INTO log_erreurs(date, message, code)
        VALUES (CURRENT_TIMESTAMP, SQLERRM, SQLSTATE);
        
        -- Relance de l'exception
        RAISE;
END;
```

L'instruction `RAISE` sans paramètres relance l'exception courante avec ses informations d'origine.

## Exemples pratiques

### Validation de données avec exceptions

```sql
CREATE OR REPLACE FUNCTION valider_employe(
    p_nom VARCHAR,
    p_email VARCHAR,
    p_salaire NUMERIC,
    p_dept_id INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_emp_id INTEGER;
BEGIN
    -- Validation des données
    IF p_nom IS NULL OR LENGTH(TRIM(p_nom)) = 0 THEN
        RAISE EXCEPTION 'Le nom ne peut pas être vide';
    END IF;
    
    IF p_email IS NULL OR p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Email invalide: %', p_email;
    END IF;
    
    IF p_salaire IS NULL OR p_salaire <= 0 THEN
        RAISE EXCEPTION 'Le salaire doit être un nombre positif, reçu: %', p_salaire;
    END IF;
    
    -- Vérification que le département existe
    PERFORM 1 FROM departement WHERE id = p_dept_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Le département avec ID % n''existe pas', p_dept_id
            USING HINT = 'Vérifiez la liste des départements valides';
    END IF;
    
    -- Insertion si toutes les validations sont passées
    INSERT INTO employe(nom, email, salaire, departement)
    VALUES (p_nom, p_email, p_salaire, p_dept_id)
    RETURNING id INTO v_emp_id;
    
    RETURN v_emp_id;
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Un employé avec cet email existe déjà';
    WHEN OTHERS THEN
        -- Relance de l'exception
        RAISE;
END;
$$ LANGUAGE plpgsql;
```

### Gestion de transaction avec rollback

```sql
CREATE OR REPLACE FUNCTION transfert_fonds(
    p_compte_source INTEGER,
    p_compte_dest INTEGER,
    p_montant NUMERIC
) RETURNS BOOLEAN AS $$
DECLARE
    v_solde_source NUMERIC;
BEGIN
    -- Validation des paramètres
    IF p_montant <= 0 THEN
        RAISE EXCEPTION 'Le montant doit être positif';
    END IF;
    
    -- Vérification du compte source
    SELECT solde INTO v_solde_source
    FROM compte
    WHERE id = p_compte_source
    FOR UPDATE;  -- Verrouille la ligne
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Compte source % introuvable', p_compte_source;
    END IF;
    
    -- Vérification du solde
    IF v_solde_source < p_montant THEN
        RAISE EXCEPTION 'Solde insuffisant (%.2f)', v_solde_source;
    END IF;
    
    -- Vérification du compte destination
    PERFORM 1 FROM compte WHERE id = p_compte_dest FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Compte destination % introuvable', p_compte_dest;
    END IF;
    
    -- Effectuer le transfert
    UPDATE compte SET solde = solde - p_montant WHERE id = p_compte_source;
    UPDATE compte SET solde = solde + p_montant WHERE id = p_compte_dest;
    
    -- Enregistrer la transaction
    INSERT INTO mouvement(compte_source, compte_dest, montant, date_operation)
    VALUES (p_compte_source, p_compte_dest, p_montant, CURRENT_TIMESTAMP);
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        -- Annuler la transaction
        RAISE NOTICE 'Erreur lors du transfert: %, Transaction annulée', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
```

### Journalisation des erreurs

```sql
CREATE OR REPLACE FUNCTION executer_avec_log(p_sql TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Exécuter la requête
    EXECUTE p_sql;
    
    -- Loguer le succès
    INSERT INTO log_operations(date, operation, statut, message)
    VALUES (CURRENT_TIMESTAMP, p_sql, 'SUCCES', NULL);
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        -- Loguer l'erreur
        INSERT INTO log_operations(date, operation, statut, message, detail)
        VALUES (
            CURRENT_TIMESTAMP,
            p_sql,
            'ECHEC',
            SQLERRM,
            'SQLSTATE: ' || SQLSTATE || ', Contexte: ' || PG_EXCEPTION_CONTEXT
        );
        
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
```

## Définition d'exceptions personnalisées

PostgreSQL permet de définir des exceptions personnalisées avec des codes d'erreur dans la plage 'P0001' à 'P9999' :

```sql
DO $$
BEGIN
    -- Lever une exception avec un code personnalisé
    RAISE EXCEPTION USING ERRCODE = 'P0123', 
                        MESSAGE = 'Exception métier personnalisée';
END;
$$;
```

Pour faciliter l'utilisation, vous pouvez définir des constantes pour ces codes :

```sql
DO $$
DECLARE
    ex_compte_inactif CONSTANT TEXT := 'P0101';
    ex_solde_insuffisant CONSTANT TEXT := 'P0102';
BEGIN
    -- Lever une exception personnalisée
    RAISE EXCEPTION USING ERRCODE = ex_compte_inactif,
                        MESSAGE = 'Le compte est inactif';
EXCEPTION
    -- Capturer spécifiquement cette exception
    WHEN SQLSTATE ex_compte_inactif THEN
        RAISE NOTICE 'Compte inactif détecté';
END;
$$;
```

## Isolation des exceptions avec les sous-blocs

Les sous-blocs peuvent être utilisés pour isoler certaines exceptions sans affecter le traitement principal :

```sql
DO $$
DECLARE
    r_emp RECORD;
    v_reussites INTEGER := 0;
    v_echecs INTEGER := 0;
BEGIN
    -- Parcours des employés
    FOR r_emp IN SELECT id, nom, salaire FROM employe LOOP
        BEGIN  -- Sous-bloc pour isoler les erreurs
            -- Traitement potentiellement problématique
            IF r_emp.salaire IS NULL THEN
                RAISE EXCEPTION 'Salaire null pour %', r_emp.nom;
            END IF;
            
            -- Mise à jour réussie
            UPDATE employe
            SET salaire = r_emp.salaire * 1.05
            WHERE id = r_emp.id;
            
            v_reussites := v_reussites + 1;
        EXCEPTION
            WHEN OTHERS THEN
                -- Enregistrement de l'erreur mais continuation
                INSERT INTO log_erreurs(employe_id, message)
                VALUES (r_emp.id, SQLERRM);
                
                v_echecs := v_echecs + 1;
        END;  -- Fin du sous-bloc
    END LOOP;
    
    RAISE NOTICE 'Traitement terminé: % réussites, % échecs', v_reussites, v_echecs;
END;
$$;
```

## Bonnes pratiques

1. **Spécificité des exceptions** : Capturez les exceptions spécifiques avant d'utiliser `WHEN OTHERS`.

2. **Messages informatifs** : Incluez des informations utiles dans les messages d'exception.

3. **Journalisation** : Enregistrez les exceptions pour le débogage ultérieur.

4. **Isolation** : Utilisez des sous-blocs pour isoler les sections problématiques.

5. **Relance appropriée** : Ne capturez pas les exceptions si vous ne pouvez pas les gérer correctement.

6. **Transactions** : Faites attention aux transactions imbriquées lors de la gestion des exceptions.

7. **Codes d'erreur** : Utilisez des codes d'erreur cohérents pour les exceptions personnalisées.

8. **Validation préalable** : Validez les données en amont pour éviter les exceptions prévisibles.

## Liens connexes
- [[PL-INTRODUCTION]] - Introduction à PL/pgSQL
- [[PL-VARIABLES]] - Variables et types de données
- [[PL-CONTROLE]] - Structures de contrôle
- [[PL-CURSEUR]] - Utilisation des curseurs
- [[TCL-CONTRAINTES-DIFFEREES]] - Transactions