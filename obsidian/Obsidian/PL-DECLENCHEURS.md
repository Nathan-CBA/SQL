# PL - Déclencheurs (Triggers)

Les déclencheurs (ou triggers) permettent d'exécuter automatiquement une fonction en réponse à certaines opérations sur une table. Ils sont utilisés pour automatiser des actions, garantir l'intégrité des données, et implémenter des règles métier complexes.

## Concepts fondamentaux

### Définition et utilité

Un déclencheur est un mécanisme qui associe une fonction à une opération DML (INSERT, UPDATE, DELETE) sur une table. Lorsque l'opération est effectuée, le déclencheur active automatiquement la fonction associée.

### Avantages

- **Automatisation** : Exécution automatique d'opérations lors d'événements spécifiques
- **Validation avancée** : Validation des données selon des critères complexes
- **Génération de données** : Calcul et remplissage automatique de champs
- **Journalisation** : Enregistrement des modifications dans des tables d'audit
- **Intégrité des données** : Maintien de contraintes d'intégrité complexes
- **Centralisation** : Application des règles métier du côté serveur

### Inconvénients

- **Complexité** : Difficiles à déboguer et à maintenir
- **Performance** : Peuvent impacter les performances des opérations DML
- **Transparence** : Comportement parfois non évident pour les développeurs

## Structure d'un déclencheur dans PostgreSQL

Dans PostgreSQL, un déclencheur est défini en deux parties :
1. Une **fonction de déclenchement** qui contient la logique à exécuter
2. Un **déclencheur** qui spécifie quand et comment exécuter la fonction

### Création d'une fonction de déclenchement

```sql
CREATE OR REPLACE FUNCTION nom_fonction_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Logique du déclencheur
    RETURN [NEW | OLD | NULL];  -- Détermine l'action à suivre
END;
$$;
```

Une fonction de déclenchement :
- Ne prend pas d'arguments explicites
- Doit retourner un objet de type TRIGGER
- A accès à des variables spéciales (NEW, OLD, TG_*)

### Création d'un déclencheur

```sql
CREATE TRIGGER nom_trigger
{ BEFORE | AFTER | INSTEAD OF } { INSERT | UPDATE | DELETE } [ OR ... ]
ON nom_table
[ FOR [ EACH ] { ROW | STATEMENT } ]
[ WHEN ( condition ) ]
EXECUTE PROCEDURE nom_fonction_trigger();
```

## Variables spéciales dans les déclencheurs

Les fonctions de déclenchement ont accès à des variables spéciales :

- **NEW** : Enregistrement contenant les nouvelles valeurs (INSERT, UPDATE)
- **OLD** : Enregistrement contenant les anciennes valeurs (UPDATE, DELETE)
- **TG_OP** : Opération qui a déclenché la fonction ('INSERT', 'UPDATE', 'DELETE')
- **TG_TABLE_NAME** : Nom de la table
- **TG_TABLE_SCHEMA** : Schéma de la table
- **TG_WHEN** : Moment du déclenchement ('BEFORE', 'AFTER', 'INSTEAD OF')
- **TG_LEVEL** : Niveau du déclenchement ('ROW', 'STATEMENT')

## Types de déclencheurs

### Selon le moment d'exécution

- **BEFORE** : Exécuté avant l'opération, peut modifier ou empêcher l'opération
- **AFTER** : Exécuté après l'opération, ne peut pas modifier ou empêcher l'opération
- **INSTEAD OF** : Remplace l'opération (uniquement pour les vues)

### Selon le niveau d'exécution

- **ROW** : Exécuté une fois pour chaque ligne affectée
- **STATEMENT** : Exécuté une fois pour l'instruction entière, quelle que soit le nombre de lignes affectées

### Selon l'événement déclencheur

- **INSERT** : Activé lors d'une insertion
- **UPDATE** : Activé lors d'une mise à jour
- **DELETE** : Activé lors d'une suppression

Il est possible de combiner plusieurs événements :
```sql
CREATE TRIGGER nom_trigger
BEFORE INSERT OR UPDATE OR DELETE
ON nom_table
FOR EACH ROW
EXECUTE PROCEDURE nom_fonction_trigger();
```

## Valeurs de retour de la fonction de déclenchement

La valeur retournée par une fonction de déclenchement détermine le comportement :

- Pour les déclencheurs **BEFORE ROW** :
  - **NEW** (modifié ou non) : L'opération se poursuit avec les valeurs de NEW
  - **NULL** : L'opération est annulée pour cette ligne
  
- Pour les déclencheurs **AFTER ROW** :
  - La valeur retournée est ignorée, mais il faut quand même retourner quelque chose (généralement NEW)
  
- Pour les déclencheurs **INSTEAD OF** :
  - **NEW** : L'opération est considérée comme réussie
  - **NULL** : L'opération est considérée comme annulée

Si l'opération doit être complètement annulée, la fonction peut lever une exception avec RAISE EXCEPTION.

## Exemples de déclencheurs

### Exemple 1 : Table d'historique pour les superviseurs de département

Ce déclencheur enregistre automatiquement l'historique des superviseurs de département lorsqu'ils changent.

```sql
-- Création de la table d'historique
CREATE TABLE histo_departement(
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL,
    event DATE NOT NULL,
    department INT NOT NULL REFERENCES departement(id),
    superviseur INT NOT NULL REFERENCES employe(nas)
);

-- Création de la fonction de déclenchement
CREATE OR REPLACE FUNCTION histo_dep_update() RETURNS TRIGGER
LANGUAGE PLPGSQL AS $$
DECLARE
    do_hist_insert BOOLEAN;
BEGIN
    CASE TG_OP
        WHEN 'INSERT', 'DELETE' THEN
            do_hist_insert := TRUE;
        WHEN 'UPDATE' THEN
            do_hist_insert := (NEW.superviseur <> OLD.superviseur);
    END CASE;
    
    IF do_hist_insert THEN
        INSERT INTO histo_department
        VALUES (DEFAULT, TG_OP, CURRENT_TIMESTAMP, NEW.id, NEW.superviseur);
    END IF;
    
    RETURN NEW;
END$$;

-- Création du déclencheur
CREATE TRIGGER histo_dep_trig
AFTER INSERT OR UPDATE ON departement
FOR EACH ROW
EXECUTE PROCEDURE histo_dep_update();
```

### Exemple 2 : Génération automatique d'un numéro de série

Ce déclencheur génère automatiquement un numéro de série pour chaque nouveau produit selon un format spécifique.

```sql
-- Création des tables et de la séquence
CREATE TABLE modele (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(64) NOT NULL CHECK(length(nom) >= 2)
);

CREATE TABLE produit(
    id SERIAL PRIMARY KEY,
    modele INT NOT NULL REFERENCES modele(id),
    no_serie CHAR(17) NOT NULL UNIQUE
);

CREATE SEQUENCE modele_no_seq
START WITH 1000
INCREMENT BY 1;

-- Création de la fonction de déclenchement
CREATE OR REPLACE FUNCTION genere_no_serie() RETURNS TRIGGER
LANGUAGE PLPGSQL AS $$
BEGIN
    SELECT 'DX-' ||
           (SELECT SUBSTRING(UPPER(nom), 1, 2)
            FROM modele WHERE id = NEW.modele) || '-' ||
           TO_CHAR(CURRENT_DATE, 'YYDD') || '-' ||
           (SELECT LPAD(dec_to_base(
               nextval('modele_no_seq'),
               32, FALSE),
               6, '0'))
    INTO NEW.no_serie;
    
    RETURN NEW;
END$$;

-- Création du déclencheur
CREATE TRIGGER genere_no_serie_trig
BEFORE INSERT ON produit
FOR EACH ROW
EXECUTE PROCEDURE genere_no_serie();
```

### Exemple 3 : Validation de contrainte d'intégrité complexe

Ce déclencheur vérifie des règles d'intégrité complexes qui ne peuvent pas être exprimées par de simples contraintes CHECK.

```sql
-- Création de la fonction de déclenchement
CREATE OR REPLACE FUNCTION valide_supsup() RETURNS TRIGGER
LANGUAGE PLPGSQL AS $$
DECLARE
    nouveau_sup employe.superviseur%TYPE;
BEGIN
    SELECT emp.superviseur INTO nouveau_sup
    FROM employe AS emp
    WHERE nas = NEW.superviseur;
    
    IF NEW.superviseur = NEW.nas THEN
        RAISE EXCEPTION 'L''employé ne peut être son propre superviseur! NAS employe : %', NEW.nas;
    END IF;
    
    IF nouveau_sup = NEW.nas THEN
        RAISE EXCEPTION
            'L''employé ne peut être le superviseur de son superviseur! NAS employe : %', NEW.nas;
    END IF;
    
    RETURN NEW;
END$$;

-- Création du déclencheur
CREATE TRIGGER valide_supsup_trig
BEFORE INSERT OR UPDATE ON employe
FOR EACH ROW
EXECUTE PROCEDURE valide_supsup();
```

## Cas d'utilisation courants

### Mise à jour automatique de champs

```sql
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_modification = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_modification_timestamp
BEFORE UPDATE ON ma_table
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();
```

### Table d'audit pour tracer les modifications

```sql
CREATE OR REPLACE FUNCTION log_audit()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log(
        table_name,
        operation,
        record_id,
        old_data,
        new_data,
        changed_by,
        changed_at
    ) VALUES (
        TG_TABLE_NAME,
        TG_OP,
        CASE 
            WHEN TG_OP = 'INSERT' THEN NEW.id
            WHEN TG_OP = 'UPDATE' THEN NEW.id
            WHEN TG_OP = 'DELETE' THEN OLD.id
        END,
        CASE WHEN TG_OP != 'INSERT' THEN row_to_json(OLD) ELSE NULL END,
        CASE WHEN TG_OP != 'DELETE' THEN row_to_json(NEW) ELSE NULL END,
        current_user,
        CURRENT_TIMESTAMP
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON ma_table
FOR EACH ROW
EXECUTE PROCEDURE log_audit();
```

### Calcul automatique d'un total

```sql
CREATE OR REPLACE FUNCTION update_commande_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE commande
    SET total = (
        SELECT SUM(prix_unitaire * quantite)
        FROM ligne_commande
        WHERE commande_id = NEW.commande_id
    )
    WHERE id = NEW.commande_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_commande_total_trigger
AFTER INSERT OR UPDATE OR DELETE ON ligne_commande
FOR EACH ROW
EXECUTE PROCEDURE update_commande_total();
```

## Gestion et maintenance des déclencheurs

### Désactivation/activation temporaire

```sql
-- Désactiver tous les déclencheurs sur une table
ALTER TABLE nom_table DISABLE TRIGGER ALL;

-- Désactiver un déclencheur spécifique
ALTER TABLE nom_table DISABLE TRIGGER nom_trigger;

-- Réactiver tous les déclencheurs
ALTER TABLE nom_table ENABLE TRIGGER ALL;

-- Réactiver un déclencheur spécifique
ALTER TABLE nom_table ENABLE TRIGGER nom_trigger;
```

### Suppression d'un déclencheur

```sql
DROP TRIGGER [IF EXISTS] nom_trigger ON nom_table [CASCADE | RESTRICT];
```

### Liste des déclencheurs existants

```sql
SELECT 
    t.tgname AS trigger_name,
    t.tgenabled AS enabled,
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_get_triggerdef(t.oid) AS trigger_definition
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE NOT t.tgisinternal
ORDER BY schema_name, table_name, trigger_name;
```

## Bonnes pratiques

1. **Nommage explicite** : Utilisez des noms descriptifs pour les déclencheurs et les fonctions.

2. **Commentaires** : Documentez le fonctionnement et l'intention des déclencheurs.

3. **Évitez les chaînes de déclencheurs** : Les déclencheurs qui déclenchent d'autres déclencheurs peuvent créer des comportements complexes et difficiles à déboguer.

4. **Performances** : Gardez le code des déclencheurs aussi léger que possible.

5. **Gérez les erreurs** : Utilisez des blocs EXCEPTION pour gérer les cas d'erreur.

6. **Transactions** : Comprenez comment les déclencheurs interagissent avec les transactions.

7. **Testez rigoureusement** : Les déclencheurs peuvent avoir des effets subtils et inattendus.

## Alternatives aux déclencheurs

Dans certains cas, d'autres approches peuvent être préférables :

- **Contraintes** : Pour les vérifications simples d'intégrité
- **Règles** (RULES) : Pour modifier ou remplacer des requêtes
- **Procédures stockées** : Pour des opérations explicites plutôt qu'implicites
- **Applications clientes** : Pour la logique métier complexe

## Liens connexes
- [[PL-INTRODUCTION]] - Introduction à PL/pgSQL
- [[PL-VARIABLES]] - Variables et types de données
- [[PL-CONTROLE]] - Structures de contrôle
- [[PL-EXCEPTIONS]] - Gestion des exceptions
- [[PL-PROCEDURES-FONCTIONS]] - Procédures et fonctions
- [[DDL-CONTRAINTES]] - Contraintes d'intégrité