# PL - Introduction à PL/pgSQL

PL/pgSQL (Procedural Language/PostgreSQL) est le langage procédural intégré à PostgreSQL. Il étend le langage SQL déclaratif standard avec des capacités procédurales comme des variables, des structures de contrôle et des fonctions complexes.

## Qu'est-ce que PL/pgSQL?

Le langage SQL est principalement déclaratif : vous spécifiez ce que vous voulez obtenir plutôt que comment l'obtenir. Cependant, pour des opérations complexes, un langage procédural offre davantage de flexibilité et de puissance.

PL/pgSQL est un langage procédural qui :
- Permet la création de fonctions, procédures et déclencheurs (triggers)
- Ajoute des structures de contrôle (boucles, conditions)
- Offre une gestion d'exceptions
- S'intègre parfaitement avec SQL
- Est très similaire au PL/SQL d'Oracle

## Comparaison avec d'autres langages procéduraux

| SGBD | Langage procédural |
|------|-------------------|
| PostgreSQL | PL/pgSQL |
| Oracle | PL/SQL |
| MySQL | Procédures stockées (syntaxe similaire à PL/SQL) |
| Microsoft SQL Server | T-SQL (Transact-SQL) |
| SQLite | Pas de langage procédural intégré |

## Avantages du PL/pgSQL

1. **Intégrité** : Centralisation de la logique métier au niveau de la base de données pour garantir l'intégrité des données.

2. **Sécurité** : Limitation des accès directs aux tables, accès aux données via des procédures contrôlées.

3. **Performance** :
   - Les requêtes SQL sont préparées une seule fois
   - Réduction des aller-retours réseau entre le client et le serveur
   - Optimisation des requêtes complexes

4. **Facilité d'utilisation** : Interface standard pour des opérations complexes.

5. **Centralisation** : Logique métier implémentée une seule fois et accessible par toutes les applications.

## Inconvénients du PL/pgSQL

1. **Complexité** : Plus difficile à tester, déboguer et maintenir que le code côté application.

2. **Surcharge potentielle** : Centraliser trop de logique côté serveur peut surcharger la base de données.

3. **Portabilité limitée** : Code spécifique à PostgreSQL, même s'il existe des similitudes avec d'autres langages procéduraux.

## Structure syntaxique générale

Le code PL/pgSQL est toujours écrit à l'intérieur d'une chaîne de caractères, généralement délimitée par des délimiteurs de type dollar (`$$`) pour faciliter l'écriture :

```sql
DO $$
DECLARE
    -- Zone de déclaration des variables
BEGIN
    -- Corps du bloc : instructions exécutables
EXCEPTION
    -- Zone de gestion des exceptions (optionnelle)
END
$$;
```

La structure générale comprend trois sections principales :

1. **DECLARE** (optionnel) : Déclaration des variables locales
2. **BEGIN ... END** (obligatoire) : Corps du bloc avec les instructions exécutables
3. **EXCEPTION** (optionnel) : Gestion des exceptions

## Blocs anonymes

Un bloc anonyme est du code PL/pgSQL exécuté immédiatement, sans être stocké comme fonction ou procédure.

```sql
DO $bloc_anonyme$
DECLARE
    v_nombre INTEGER := 10;
BEGIN
    RAISE NOTICE 'Le nombre est : %', v_nombre;
END
$bloc_anonyme$;
```

L'avantage des délimiteurs de type dollar est qu'ils peuvent être personnalisés (`$bloc_anonyme$` dans l'exemple) et évitent d'avoir à échapper les apostrophes à l'intérieur du code.

## Outils de débogage

### Messages d'information

La commande `RAISE` permet d'afficher des messages pendant l'exécution :

```sql
DO $$
BEGIN
    RAISE NOTICE 'Un message simple';
    RAISE NOTICE 'Un message avec variable : %', 42;
    RAISE NOTICE 'Un message avec plusieurs variables : % et %', 'hello', 'world';
END
$$;
```

Niveaux de messages (du moins au plus sévère) :
- `DEBUG`
- `LOG`
- `INFO`
- `NOTICE`
- `WARNING`
- `EXCEPTION` (provoque une erreur et arrête l'exécution)

### Assertions (ASSERT)

L'instruction `ASSERT` permet de valider des conditions pendant le développement :

```sql
DO $$
DECLARE
    v_id INTEGER := 5;
BEGIN
    -- Vérifie que v_id est positif
    ASSERT v_id > 0, 'L''ID ne peut pas être négatif ou nul';
    
    -- Suite du code
END
$$;
```

La validation des assertions peut être activée ou désactivée :

```sql
-- Vérifier l'état actuel
SHOW plpgsql.check_asserts;

-- Activer les assertions
SET plpgsql.check_asserts TO on;

-- Désactiver les assertions
SET plpgsql.check_asserts TO off;
```

## Premier exemple complet

```sql
DO $$
DECLARE
    v_departement_id INTEGER;
    v_nombre_employes INTEGER;
    v_message TEXT;
BEGIN
    -- Récupérer l'ID du département des ventes
    SELECT id INTO v_departement_id
    FROM departement
    WHERE nom = 'Ventes';
    
    -- Compter les employés dans ce département
    SELECT COUNT(*) INTO v_nombre_employes
    FROM employe
    WHERE departement = v_departement_id;
    
    -- Construire un message
    IF v_nombre_employes > 10 THEN
        v_message := 'Le département des ventes a beaucoup d''employés : ';
    ELSE
        v_message := 'Le département des ventes a peu d''employés : ';
    END IF;
    
    -- Afficher le résultat
    RAISE NOTICE '%', v_message || v_nombre_employes;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'Le département des ventes n''existe pas!';
END
$$;
```

## Types d'objets PL/pgSQL

PL/pgSQL peut être utilisé pour créer trois types d'objets principaux :

1. **Fonctions** : Retournent une valeur et peuvent être utilisées dans des requêtes SQL.
2. **Procédures** : Exécutent une série d'opérations sans nécessairement retourner une valeur.
3. **Déclencheurs (Triggers)** : Fonctions spéciales qui s'exécutent automatiquement en réponse à certains événements sur les tables.

## Construction de base vs. blocs imbriqués

PL/pgSQL permet l'imbrication de blocs, ce qui facilite la structuration du code et la gestion locale des variables et des exceptions :

```sql
DO $$
DECLARE
    v_externe INTEGER := 10;
BEGIN
    RAISE NOTICE 'Valeur externe : %', v_externe;
    
    DECLARE
        v_interne INTEGER := 20;
    BEGIN
        RAISE NOTICE 'Valeurs interne : % et externe : %', v_interne, v_externe;
    END;
    
    -- La variable v_interne n'est pas accessible ici
    RAISE NOTICE 'Valeur externe encore : %', v_externe;
END
$$;
```

## Prochaines étapes

Pour approfondir vos connaissances sur PL/pgSQL, consultez les notes suivantes :

- [[PL-VARIABLES]] - Déclaration et manipulation des variables
- [[PL-CONTROLE]] - Structures de contrôle (IF, CASE, boucles)
- [[PL-CURSEUR]] - Manipulation des curseurs
- [[PL-EXCEPTIONS]] - Gestion avancée des exceptions
- [[PL-PROCEDURES-FONCTIONS]] - Création de procédures et fonctions
- [[PL-DECLENCHEURS]] - Création de déclencheurs (triggers)

## Liens connexes
- [[DDL-PROCEDURE-FUNCTION]] - Procédures et fonctions SQL de base
- [[RESOLUTION-REQUETE]] - Processus de résolution d'une requête