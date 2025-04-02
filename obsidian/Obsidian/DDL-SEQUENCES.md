# DDL - Séquences

Les séquences dans PostgreSQL sont des objets spéciaux qui génèrent des nombres uniques de manière automatique. Elles sont généralement utilisées pour créer des clés primaires auto-incrémentées.

## Définition et création

Une séquence est un objet générateur de nombres qui peut être paramétré selon plusieurs critères :
- La valeur de départ
- L'incrément (peut être positif ou négatif)
- Les valeurs minimale et maximale
- Le comportement cyclique (recommencer depuis le début lorsque les limites sont atteintes)
- Le nombre de valeurs mises en cache pour améliorer les performances

### Syntaxe de création

```sql
CREATE SEQUENCE [ IF NOT EXISTS ] nom_sequence
    [ INCREMENT [ BY ] increment ]
    [ MINVALUE valeur_min | NO MINVALUE ]
    [ MAXVALUE valeur_max | NO MAXVALUE ]
    [ START [ WITH ] valeur_debut ]
    [ CACHE valeur_cache ]
    [ [ NO ] CYCLE ];
```

### Valeurs par défaut

Si non spécifiés, les paramètres prennent ces valeurs par défaut :
- **INCREMENT** : +1
- **MINVALUE** : 
  - Pour les incréments positifs : 1
  - Pour les incréments négatifs : -2^63 - 1
- **MAXVALUE** : 
  - Pour les incréments positifs : 2^63 - 1
  - Pour les incréments négatifs : -1
- **START** : 
  - Pour les incréments positifs : MINVALUE
  - Pour les incréments négatifs : MAXVALUE
- **CACHE** : 1
- **CYCLE** : NO CYCLE

### Exemples de création

```sql
-- Séquence simple
CREATE SEQUENCE seq_emp_id;

-- Séquence personnalisée
CREATE SEQUENCE seq_dep_id
    INCREMENT BY 2
    START WITH 1000
    MINVALUE 1000
    MAXVALUE 9999
    NO CYCLE;

-- Séquence décroissante
CREATE SEQUENCE seq_countdown
    INCREMENT BY -1
    START WITH 10
    MINVALUE 1
    MAXVALUE 10
    CYCLE;
```

## Utilisation des séquences

### Fonctions de manipulation des séquences

PostgreSQL fournit plusieurs fonctions pour manipuler les séquences :

- **nextval('nom_sequence')** : Génère et retourne la valeur suivante de la séquence
- **currval('nom_sequence')** : Retourne la dernière valeur générée par la séquence dans la session courante
- **lastval()** : Retourne la dernière valeur générée par n'importe quelle séquence dans la session courante
- **setval('nom_sequence', valeur, [est_appelé])** : 
  - Définit la valeur actuelle de la séquence
  - `est_appelé` (booléen) détermine si nextval() a déjà été appelé (true) ou non (false)

### Exemples d'utilisation

```sql
-- Générer une nouvelle valeur
SELECT nextval('seq_emp_id');

-- Voir la valeur courante (doit être appelée après nextval au moins une fois)
SELECT currval('seq_emp_id');

-- Voir la dernière valeur générée par n'importe quelle séquence
SELECT lastval();

-- Définir la valeur actuelle
SELECT setval('seq_emp_id', 1000);  -- nextval() retournera 1001
SELECT setval('seq_emp_id', 1000, false);  -- nextval() retournera 1000
```

### Utilisation dans les requêtes

```sql
-- Insertion avec séquence pour l'ID
INSERT INTO departement (id, nom)
VALUES (nextval('seq_dep_id'), 'Administration');

-- Insertion et référence à la valeur actuelle
INSERT INTO employe (id, nom, prenom, departement)
VALUES (nextval('seq_emp_id'), 'Bo', 'Bill', currval('seq_dep_id'));
```

## Types SERIAL

PostgreSQL propose trois types à auto-incrément qui utilisent implicitement des séquences :

- **SMALLSERIAL** : petit entier auto-incrémenté (1 à 32767)
- **SERIAL** : entier auto-incrémenté (1 à 2147483647)
- **BIGSERIAL** : grand entier auto-incrémenté (1 à 9223372036854775807)

### Équivalence avec les séquences

Lorsque vous définissez une colonne avec un type SERIAL, PostgreSQL crée automatiquement une séquence et définit la valeur par défaut de la colonne pour utiliser cette séquence.

```sql
-- Ceci :
CREATE TABLE employe (id SERIAL);

-- Équivaut à :
CREATE SEQUENCE employe_id_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE employe (
    id INTEGER NOT NULL DEFAULT nextval('employe_id_seq')
);
ALTER SEQUENCE employe_id_seq OWNED BY employe.id;
```

### Nommage des séquences SERIAL

Le nom de la séquence générée pour une colonne SERIAL suit le modèle :
```
[nom_table]_[nom_colonne]_seq
```

Par exemple, pour une colonne `id` dans une table `employe`, la séquence sera nommée `employe_id_seq`.

## Modification des séquences

### Modification avec ALTER SEQUENCE

```sql
ALTER SEQUENCE [ IF EXISTS ] nom_sequence
    [ INCREMENT [ BY ] increment ]
    [ MINVALUE valeur_min | NO MINVALUE ]
    [ MAXVALUE valeur_max | NO MAXVALUE ]
    [ START [ WITH ] valeur_debut ]
    [ RESTART [ [ WITH ] valeur_restart ] ]
    [ CACHE valeur_cache ]
    [ [ NO ] CYCLE ]
    [ OWNED BY { nom_table.nom_colonne | NONE } ];
```

### Exemples de modification

```sql
-- Modifier l'incrément
ALTER SEQUENCE seq_emp_id INCREMENT BY 5;

-- Redémarrer la séquence
ALTER SEQUENCE seq_emp_id RESTART WITH 1000;

-- Associer la séquence à une colonne particulière (utile pour garantir que la séquence 
-- sera supprimée en même temps que la colonne ou la table)
ALTER SEQUENCE seq_emp_id OWNED BY employe.id;
```

## Suppression des séquences

```sql
DROP SEQUENCE [ IF EXISTS ] nom_sequence [, ...] [ CASCADE | RESTRICT ];
```

Exemple :
```sql
DROP SEQUENCE IF EXISTS seq_emp_id;
```

## Considérations importantes

### Performances

- Les séquences utilisent un cache pour améliorer les performances, mais cela peut entraîner des "trous" dans les valeurs générées en cas de crash.
- La valeur du cache peut être ajustée pour équilibrer performances et densité des valeurs générées.

### Transactions

Les valeurs des séquences sont générées en dehors du mécanisme de transaction, donc :
- Une valeur générée n'est pas annulée même si la transaction est annulée
- Cela peut créer des "trous" dans la séquence des nombres générés

### Unicité vs continuité

- Les séquences garantissent l'unicité des valeurs, mais pas nécessairement leur continuité
- Ne supposez jamais que les valeurs générées seront strictement consécutives

### Partage entre tables

- Une même séquence peut être utilisée par plusieurs tables si nécessaire
- Cela peut être utile pour générer des identifiants uniques à l'échelle de la base de données

### Multilication des incréments

Pour générer des valeurs espacées à intervalles réguliers (par exemple, des multiples de 10), définissez simplement l'incrément approprié :

```sql
CREATE SEQUENCE multiples_10 INCREMENT BY 10 START WITH 10;
-- nextval() générera : 10, 20, 30, ...
```

## Exemples pratiques

### Générateur d'ID pour plusieurs tables

```sql
-- Création d'une séquence commune
CREATE SEQUENCE common_id_seq START WITH 1000;

-- Utilisation dans plusieurs tables
CREATE TABLE client (
    id INTEGER PRIMARY KEY DEFAULT nextval('common_id_seq'),
    nom VARCHAR(100)
);

CREATE TABLE fournisseur (
    id INTEGER PRIMARY KEY DEFAULT nextval('common_id_seq'),
    nom VARCHAR(100)
);
```

### Séquence pour générer des codes de facture

```sql
-- Création d'une séquence pour les numéros de facture
CREATE SEQUENCE facture_num_seq
    INCREMENT BY 1
    START WITH 10001
    MINVALUE 10001
    NO MAXVALUE
    NO CYCLE;

-- Utilisation avec un préfixe
CREATE TABLE facture (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(15) DEFAULT 'FAC-' || TO_CHAR(nextval('facture_num_seq'), 'FM00000'),
    date_emission DATE DEFAULT CURRENT_DATE
);
```

## Liens connexes
- [[DDL-CREATE]] - Création d'objets
- [[DDL-ALTER]] - Modification d'objets
- [[DDL-DROP]] - Suppression d'objets
- [[DDL-TYPES]] - Types de données