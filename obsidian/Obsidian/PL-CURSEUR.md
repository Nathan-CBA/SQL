# PL - Curseurs

Les curseurs dans PL/pgSQL permettent de parcourir les résultats d'une requête ligne par ligne, offrant un contrôle précis sur le traitement des données, particulièrement utile pour les grands ensembles de résultats.

## Concept et avantages

Un curseur est un objet qui encapsule une requête SQL et permet d'accéder à ses résultats de manière séquentielle. Les curseurs offrent plusieurs avantages :

- **Traitement par lots** : Possibilité de traiter de grandes quantités de données en mémoire sans les charger toutes en même temps
- **Positionnement précis** : Capacité de se déplacer dans le jeu de résultats
- **Modification pendant le parcours** : Possibilité de modifier ou supprimer les données pendant leur parcours
- **Réutilisabilité** : Les curseurs peuvent être passés entre fonctions ou procédures
- **Flexibilité** : Ouverture et fermeture à volonté

## Types de curseurs

PostgreSQL supporte deux types principaux de curseurs :

### Curseurs liés

Un curseur lié est défini avec une requête spécifique au moment de sa déclaration.

```sql
DECLARE nom_curseur CURSOR FOR requête;
```

### Curseurs liés paramétrés

Un curseur lié paramétré accepte des paramètres qui peuvent être fournis lors de l'ouverture du curseur.

```sql
DECLARE nom_curseur CURSOR(param1 type, param2 type, ...) FOR requête;
```

### Curseurs non liés (REFCURSOR)

Un curseur non lié (de type `REFCURSOR`) est défini sans requête associée. La requête est spécifiée lors de l'ouverture du curseur.

```sql
DECLARE nom_curseur REFCURSOR;
```

## Cycle de vie d'un curseur

L'utilisation d'un curseur suit généralement les étapes suivantes :

1. **Déclaration** : Définition du curseur et de sa requête associée (si curseur lié)
2. **Ouverture** : Exécution de la requête et préparation des résultats
3. **Récupération** : Lecture des lignes une par une
4. **Fermeture** : Libération des ressources associées au curseur

## Déclaration des curseurs

### Curseur lié simple

```sql
DECLARE
    c_employes CURSOR FOR
        SELECT id, nom, prenom, salaire
        FROM employe
        WHERE departement = 3
        ORDER BY salaire DESC;
```

### Curseur lié paramétré

```sql
DECLARE
    c_employes_dep CURSOR(p_departement_id INTEGER) FOR
        SELECT id, nom, prenom, salaire
        FROM employe
        WHERE departement = p_departement_id
        ORDER BY salaire DESC;
```

### Curseur non lié

```sql
DECLARE
    c_dynamique REFCURSOR;
```

## Manipulation des curseurs

### Ouverture d'un curseur

```sql
-- Curseur lié simple
OPEN c_employes;

-- Curseur lié paramétré
OPEN c_employes_dep(5);

-- Curseur non lié
OPEN c_dynamique FOR
    SELECT id, nom, prenom
    FROM employe
    WHERE departement = 3;
```

### Récupération des données

La commande `FETCH` permet de récupérer la ligne suivante du curseur.

```sql
-- Récupérer la ligne suivante dans une variable de type RECORD
FETCH c_employes INTO r_emp;

-- Récupérer la ligne suivante dans des variables distinctes
FETCH c_employes INTO v_id, v_nom, v_prenom, v_salaire;
```

Après chaque `FETCH`, il est important de vérifier si une ligne a été trouvée :

```sql
FETCH c_employes INTO r_emp;
IF NOT FOUND THEN
    -- Plus de lignes dans le curseur
    RAISE NOTICE 'Fin des résultats';
END IF;
```

### Fermeture d'un curseur

```sql
CLOSE c_employes;
```

## Exemple complet avec un curseur lié

```sql
DO $$
DECLARE
    c_employes CURSOR FOR
        SELECT id, nom, prenom, salaire
        FROM employe
        WHERE departement = 3
        ORDER BY salaire DESC;
    r_emp RECORD;
    v_total_salaire NUMERIC := 0;
    v_count INTEGER := 0;
BEGIN
    -- Ouverture du curseur
    OPEN c_employes;
    
    -- Boucle de parcours
    LOOP
        -- Récupération de la ligne suivante
        FETCH c_employes INTO r_emp;
        
        -- Sortie si plus de lignes
        EXIT WHEN NOT FOUND;
        
        -- Traitement de la ligne
        RAISE NOTICE 'Employé: % % (ID: %), Salaire: %',
            r_emp.prenom, r_emp.nom, r_emp.id, r_emp.salaire;
            
        -- Accumulation des données
        v_total_salaire := v_total_salaire + r_emp.salaire;
        v_count := v_count + 1;
    END LOOP;
    
    -- Fermeture du curseur
    CLOSE c_employes;
    
    -- Affichage des résultats
    IF v_count > 0 THEN
        RAISE NOTICE 'Salaire moyen: %', v_total_salaire / v_count;
    ELSE
        RAISE NOTICE 'Aucun employé trouvé';
    END IF;
END;
$$;
```

## Exemple avec un curseur lié paramétré

```sql
DO $$
DECLARE
    c_employes_dep CURSOR(p_departement_id INTEGER) FOR
        SELECT id, nom, prenom, salaire
        FROM employe
        WHERE departement = p_departement_id
        ORDER BY salaire DESC;
    r_emp RECORD;
    v_dep_id INTEGER;
BEGIN
    -- Parcours des départements
    FOR v_dep_id IN SELECT id FROM departement LOOP
        RAISE NOTICE 'Employés du département %:', v_dep_id;
        
        -- Ouverture du curseur avec le paramètre
        OPEN c_employes_dep(v_dep_id);
        
        -- Récupération des trois premiers employés
        FOR i IN 1..3 LOOP
            FETCH c_employes_dep INTO r_emp;
            
            IF NOT FOUND THEN
                EXIT;  -- Sortie si plus de lignes
            END IF;
            
            RAISE NOTICE '  % % - Salaire: %', r_emp.prenom, r_emp.nom, r_emp.salaire;
        END LOOP;
        
        -- Fermeture du curseur
        CLOSE c_employes_dep;
        
        RAISE NOTICE '';  -- Ligne vide pour séparer les départements
    END LOOP;
END;
$$;
```

## Exemple avec un curseur non lié

```sql
DO $$
DECLARE
    c_dynamique REFCURSOR;
    r_data RECORD;
    v_requete TEXT;
    v_table_name TEXT := 'employe';
    v_condition TEXT := 'departement = 3';
BEGIN
    -- Construction dynamique de la requête
    v_requete := 'SELECT id, nom, prenom FROM ' || quote_ident(v_table_name);
    
    IF v_condition IS NOT NULL THEN
        v_requete := v_requete || ' WHERE ' || v_condition;
    END IF;
    
    RAISE NOTICE 'Exécution de la requête: %', v_requete;
    
    -- Ouverture du curseur avec la requête dynamique
    OPEN c_dynamique FOR EXECUTE v_requete;
    
    -- Parcours des résultats
    LOOP
        FETCH c_dynamique INTO r_data;
        EXIT WHEN NOT FOUND;
        
        RAISE NOTICE 'ID: %, Nom: % %', r_data.id, r_data.prenom, r_data.nom;
    END LOOP;
    
    -- Fermeture du curseur
    CLOSE c_dynamique;
END;
$$;
```

## Curseurs et boucle FOR

PostgreSQL offre une syntaxe simplifiée pour parcourir un curseur avec une boucle FOR :

```sql
DO $$
DECLARE
    c_employes CURSOR FOR
        SELECT id, nom, prenom, salaire
        FROM employe
        WHERE departement = 3;
    r_emp RECORD;
BEGIN
    -- Ouverture et parcours du curseur en une seule instruction
    FOR r_emp IN c_employes LOOP
        RAISE NOTICE 'Employé: % % (Salaire: %)',
            r_emp.prenom, r_emp.nom, r_emp.salaire;
    END LOOP;
END;
$$;
```

Cette syntaxe gère automatiquement l'ouverture et la fermeture du curseur.

## Utilisation implicite des curseurs

Dans certains cas, PostgreSQL utilise implicitement des curseurs, sans que vous ayez à les déclarer explicitement :

```sql
DO $$
DECLARE
    r_emp RECORD;
BEGIN
    -- Utilisation d'une boucle FOR sur une requête (curseur implicite)
    FOR r_emp IN SELECT id, nom, prenom FROM employe WHERE departement = 3 LOOP
        RAISE NOTICE 'Employé: % %', r_emp.prenom, r_emp.nom;
    END LOOP;
END;
$$;
```

## Curseurs avec mise à jour

Les curseurs peuvent être utilisés pour mettre à jour ou supprimer des données pendant leur parcours.

```sql
DO $$
DECLARE
    c_employes CURSOR FOR
        SELECT id, nom, salaire
        FROM employe
        WHERE departement = 3
        FOR UPDATE;  -- Important: permet la mise à jour
    r_emp RECORD;
BEGIN
    OPEN c_employes;
    
    LOOP
        FETCH c_employes INTO r_emp;
        EXIT WHEN NOT FOUND;
        
        -- Mise à jour en fonction des données
        IF r_emp.salaire < 3000 THEN
            UPDATE employe
            SET salaire = r_emp.salaire * 1.1
            WHERE CURRENT OF c_employes;  -- Référence à la ligne courante
            
            RAISE NOTICE 'Augmentation du salaire pour %', r_emp.nom;
        END IF;
    END LOOP;
    
    CLOSE c_employes;
END;
$$;
```

La clause `FOR UPDATE` est cruciale car elle verrouille les lignes pour mise à jour. La clause `WHERE CURRENT OF` référence la ligne actuellement pointée par le curseur.

## Options de curseurs avancées

### Sensibilité aux mises à jour

Par défaut, les curseurs PostgreSQL sont sensibles aux mises à jour (ils voient les modifications apportées aux données pendant leur parcours). Vous pouvez modifier ce comportement :

```sql
DECLARE c_employes CURSOR FOR
    SELECT id, nom FROM employe
    WHERE departement = 3
    FOR READ ONLY;  -- Le curseur ne permet pas les mises à jour
```

### Direction de parcours

Par défaut, les curseurs avancent séquentiellement. Il est possible de définir des curseurs qui permettent de se déplacer dans les deux directions :

```sql
DECLARE c_employes SCROLL CURSOR FOR
    SELECT id, nom FROM employe;
```

Avec un curseur SCROLL, vous pouvez utiliser des commandes FETCH avancées :

```sql
FETCH NEXT FROM c_employes INTO r_emp;    -- Ligne suivante (comportement par défaut)
FETCH PRIOR FROM c_employes INTO r_emp;   -- Ligne précédente
FETCH FIRST FROM c_employes INTO r_emp;   -- Première ligne
FETCH LAST FROM c_employes INTO r_emp;    -- Dernière ligne
FETCH ABSOLUTE 5 FROM c_employes INTO r_emp;  -- 5ème ligne
FETCH RELATIVE -2 FROM c_employes INTO r_emp; -- 2 lignes en arrière
```

## Retourner des curseurs de fonctions

Les curseurs de type REFCURSOR peuvent être retournés par des fonctions, permettant au client de parcourir les résultats :

```sql
CREATE OR REPLACE FUNCTION obtenir_employes_dep(p_dep_id INTEGER)
RETURNS REFCURSOR AS $$
DECLARE
    c_resultat REFCURSOR;
BEGIN
    OPEN c_resultat FOR
        SELECT id, nom, prenom, salaire
        FROM employe
        WHERE departement = p_dep_id
        ORDER BY salaire DESC;
        
    RETURN c_resultat;
END;
$$ LANGUAGE plpgsql;

-- Utilisation
DO $$
DECLARE
    c_ref REFCURSOR;
    r_emp RECORD;
BEGIN
    c_ref := obtenir_employes_dep(3);
    
    LOOP
        FETCH c_ref INTO r_emp;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Employé: % %', r_emp.prenom, r_emp.nom;
    END LOOP;
    
    CLOSE c_ref;
END;
$$;
```

## Gestion des erreurs avec les curseurs

Il est important de toujours fermer les curseurs, même en cas d'erreur, pour éviter les fuites de ressources :

```sql
DO $$
DECLARE
    c_employes CURSOR FOR SELECT id, nom FROM employe;
    r_emp RECORD;
BEGIN
    OPEN c_employes;
    
    BEGIN
        LOOP
            FETCH c_employes INTO r_emp;
            EXIT WHEN NOT FOUND;
            
            -- Simulation d'une erreur
            IF r_emp.id = 123 THEN
                RAISE EXCEPTION 'Erreur pour l''employé %', r_emp.id;
            END IF;
            
            RAISE NOTICE 'Employé: %', r_emp.nom;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'Erreur lors du traitement: %', SQLERRM;
            -- On continue pour s'assurer que le curseur est fermé
    END;
    
    -- Fermeture du curseur (toujours exécutée)
    CLOSE c_employes;
END;
$$;
```

## Bonnes pratiques

1. **Fermeture explicite** : Toujours fermer les curseurs après utilisation pour libérer les ressources.

2. **Curseurs FOR** : Utiliser la syntaxe FOR ... IN lorsque possible pour une gestion automatique des curseurs.

3. **Vérification de FOUND** : Toujours vérifier si une ligne a été trouvée après un FETCH.

4. **Transactions** : Utiliser des transactions pour garantir la cohérence des opérations de modification.

5. **Taille de lot** : Pour de très grands ensembles, considérer le traitement par lots plutôt que ligne par ligne.

6. **Curseurs paramétrés** : Privilégier les curseurs paramétrés pour une meilleure réutilisation du code.

7. **Curseurs FOR UPDATE** : N'utiliser FOR UPDATE que lorsqu'une modification est nécessaire, car cela verrouille les lignes.

## Liens connexes
- [[PL-INTRODUCTION]] - Introduction à PL/pgSQL
- [[PL-VARIABLES]] - Variables et types de données
- [[PL-CONTROLE]] - Structures de contrôle
- [[PL-EXCEPTIONS]] - Gestion des exceptions
- [[PL-PROCEDURES-FONCTIONS]] - Procédures et fonctions