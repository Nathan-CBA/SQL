# PL - Structures de contrôle

Les structures de contrôle en PL/pgSQL permettent de diriger le flux d'exécution du code en fonction de conditions, de répéter des opérations, et d'organiser le traitement des données de manière procédurale.

## Structures conditionnelles

### IF-THEN-ELSIF-ELSE

La structure `IF` permet d'exécuter du code en fonction d'une condition booléenne.

```sql
IF condition THEN
    -- instructions exécutées si condition est vraie
ELSIF autre_condition THEN
    -- instructions exécutées si condition est fausse et autre_condition est vraie
ELSE
    -- instructions exécutées si toutes les conditions précédentes sont fausses
END IF;
```

Exemple :
```sql
DO $$
DECLARE
    v_age INTEGER := 25;
BEGIN
    IF v_age < 18 THEN
        RAISE NOTICE 'Mineur';
    ELSIF v_age < 65 THEN
        RAISE NOTICE 'Adulte en âge de travailler';
    ELSE
        RAISE NOTICE 'Retraité';
    END IF;
END;
$$;
```

### CASE

Il existe deux variantes de la structure `CASE` :

#### CASE avec expression de recherche

```sql
CASE expression_recherche
    WHEN valeur1 [, valeur2, ...] THEN
        instructions1
    WHEN valeur3 [, valeur4, ...] THEN
        instructions2
    [...]
    [ELSE
        instructions_par_defaut]
END CASE;
```

Exemple :
```sql
DO $$
DECLARE
    v_jour_semaine jour_semaine := 'lundi';  -- Type énuméré
BEGIN
    CASE v_jour_semaine
        WHEN 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi' THEN
            RAISE NOTICE 'Jour ouvrable';
        WHEN 'samedi', 'dimanche' THEN
            RAISE NOTICE 'Weekend';
        ELSE
            RAISE NOTICE 'Jour inconnu';
    END CASE;
END;
$$;
```

#### CASE avec conditions booléennes

```sql
CASE
    WHEN condition1 THEN
        instructions1
    WHEN condition2 THEN
        instructions2
    [...]
    [ELSE
        instructions_par_defaut]
END CASE;
```

Exemple :
```sql
DO $$
DECLARE
    v_note NUMERIC := 85;
BEGIN
    CASE
        WHEN v_note >= 90 THEN
            RAISE NOTICE 'A - Excellent';
        WHEN v_note >= 80 THEN
            RAISE NOTICE 'B - Très bien';
        WHEN v_note >= 70 THEN
            RAISE NOTICE 'C - Bien';
        WHEN v_note >= 60 THEN
            RAISE NOTICE 'D - Passable';
        ELSE
            RAISE NOTICE 'E - Échec';
    END CASE;
END;
$$;
```

Si aucune condition n'est vraie et qu'il n'y a pas de clause `ELSE`, une exception `CASE_NOT_FOUND` est levée.

## Structures de boucle

### Boucle simple (LOOP)

```sql
LOOP
    -- instructions à répéter
    [EXIT WHEN condition;]  -- Sortie conditionnelle
    [CONTINUE WHEN condition;]  -- Passer à l'itération suivante
END LOOP;
```

Exemple :
```sql
DO $$
DECLARE
    v_compteur INTEGER := 1;
BEGIN
    LOOP
        RAISE NOTICE 'Itération %', v_compteur;
        v_compteur := v_compteur + 1;
        
        -- Sortie conditionnelle
        EXIT WHEN v_compteur > 5;
    END LOOP;
END;
$$;
```

### Boucle WHILE

```sql
WHILE condition LOOP
    -- instructions à répéter tant que condition est vraie
END LOOP;
```

Exemple :
```sql
DO $$
DECLARE
    v_compteur INTEGER := 1;
BEGIN
    WHILE v_compteur <= 5 LOOP
        RAISE NOTICE 'Itération %', v_compteur;
        v_compteur := v_compteur + 1;
    END LOOP;
END;
$$;
```

### Boucle FOR avec plage d'entiers

```sql
FOR nom_variable IN [REVERSE] valeur_debut..valeur_fin [BY pas] LOOP
    -- instructions à répéter
END LOOP;
```

Exemple :
```sql
DO $$
BEGIN
    -- Comptage de 1 à 5
    FOR i IN 1..5 LOOP
        RAISE NOTICE 'Compteur: %', i;
    END LOOP;
    
    -- Comptage à rebours de 10 à 1 par pas de 2
    FOR i IN REVERSE 10..1 BY 2 LOOP
        RAISE NOTICE 'Compte à rebours: %', i;
    END LOOP;
END;
$$;
```

### Boucle FOR avec requête

```sql
FOR nom_variable IN requête LOOP
    -- instructions à répéter pour chaque ligne retournée
END LOOP;
```

Exemple :
```sql
DO $$
DECLARE
    r_emp RECORD;
BEGIN
    FOR r_emp IN SELECT id, nom, prenom FROM employe WHERE departement = 3 LOOP
        RAISE NOTICE 'Employé: % % (ID: %)', r_emp.prenom, r_emp.nom, r_emp.id;
    END LOOP;
END;
$$;
```

## Instructions de contrôle de flux

### RETURN

L'instruction `RETURN` termine immédiatement l'exécution de la fonction ou de la procédure. Dans une fonction, elle doit spécifier la valeur à retourner.

```sql
-- Dans une fonction
RETURN expression;

-- Dans une procédure ou un bloc anonyme
RETURN;
```

Exemple :
```sql
CREATE OR REPLACE FUNCTION calculer_bonus(p_salaire NUMERIC, p_anciennete INTEGER)
RETURNS NUMERIC AS $$
BEGIN
    -- Retour anticipé pour les cas particuliers
    IF p_anciennete < 1 THEN
        RETURN 0;  -- Pas de bonus pour moins d'un an d'ancienneté
    END IF;
    
    -- Calcul normal du bonus
    RETURN p_salaire * (0.05 + p_anciennete * 0.01);
END;
$$ LANGUAGE plpgsql;
```

### EXIT

L'instruction `EXIT` termine la boucle la plus interne ou une boucle spécifique identifiée par une étiquette.

```sql
EXIT;  -- Termine la boucle la plus interne
EXIT nom_label;  -- Termine la boucle identifiée par nom_label
EXIT WHEN condition;  -- Termine la boucle si condition est vraie
```

Exemple :
```sql
DO $$
DECLARE
    v_total INTEGER := 0;
BEGIN
    <<boucle_externe>>
    FOR i IN 1..5 LOOP
        FOR j IN 1..5 LOOP
            v_total := v_total + 1;
            
            IF i = 3 AND j = 3 THEN
                EXIT boucle_externe;  -- Sort complètement des deux boucles
            END IF;
        END LOOP;
    END LOOP;
    
    RAISE NOTICE 'Total: %', v_total;  -- Affichera 13
END;
$$;
```

### CONTINUE

L'instruction `CONTINUE` passe à l'itération suivante de la boucle, en sautant toutes les instructions qui suivent.

```sql
CONTINUE;  -- Passe à l'itération suivante de la boucle la plus interne
CONTINUE nom_label;  -- Passe à l'itération suivante de la boucle identifiée
CONTINUE WHEN condition;  -- Passe à l'itération suivante si condition est vra