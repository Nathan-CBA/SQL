# TCL - Contraintes différées

Les contraintes différées permettent de reporter la vérification des contraintes jusqu'à la fin d'une transaction. Cette fonctionnalité est particulièrement utile pour résoudre les problèmes liés aux dépendances circulaires entre tables.

## Problématique des dépendances circulaires

### Dépendances circulaires structurelles (DCDDL)

Les dépendances circulaires structurelles surviennent lors de la création de tables qui se référencent mutuellement via des clés étrangères. Par exemple:

- La table `employe` a une clé étrangère vers `departement`
- La table `departement` a une clé étrangère vers `employe` (pour le responsable)

Ce type de dépendance est relativement facile à résoudre en créant d'abord les tables sans les contraintes, puis en ajoutant les contraintes après la création des tables.

```sql
-- 1. Créer les tables sans contraintes
CREATE TABLE departement (
    id INTEGER PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    responsable INTEGER NULL
);

CREATE TABLE employe (
    id INTEGER PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    departement INTEGER NULL
);

-- 2. Ajouter les contraintes ensuite
ALTER TABLE departement
ADD CONSTRAINT fk_dep_resp FOREIGN KEY (responsable) REFERENCES employe(id);

ALTER TABLE employe
ADD CONSTRAINT fk_emp_dep FOREIGN KEY (departement) REFERENCES departement(id);
```

### Dépendances circulaires de données (DCDML)

Les dépendances circulaires de données sont plus complexes. Elles surviennent lors de l'insertion de données dans des tables ayant des dépendances circulaires.

Par exemple, pour insérer les premières données dans les tables `employe` et `departement` avec des références mutuelles:

- Pour créer un employé, on a besoin d'un département existant
- Pour créer un département, on a besoin d'un responsable (employé) existant

C'est là que les contraintes différées deviennent nécessaires.

## Solutions inadéquates aux dépendances circulaires de données

### Solution 1: Permettre les valeurs NULL

Cette approche consiste à permettre temporairement des valeurs NULL dans les clés étrangères:

```sql
-- 1. Insérer un employé avec un département NULL
INSERT INTO employe (id, nom, departement) VALUES (1, 'Dupuis', NULL);

-- 2. Insérer un département avec cet employé comme responsable
INSERT INTO departement (id, nom, responsable) VALUES (1, 'Ventes', 1);

-- 3. Mettre à jour l'employé avec son département
UPDATE employe SET departement = 1 WHERE id = 1;
```

**Problèmes**: 
- Nécessite que les colonnes acceptent NULL
- Génère temporairement des données incohérentes

### Solution 2: Insérer d'abord des valeurs temporaires

Cette approche consiste à insérer d'abord des données "bidon" puis à les corriger:

```sql
-- 1. Insérer un département temporaire
INSERT INTO departement (id, nom, responsable) VALUES (999, 'Temp', NULL);

-- 2. Insérer un employé référençant ce département
INSERT INTO employe (id, nom, departement) VALUES (1, 'Dupuis', 999);

-- 3. Insérer le vrai département
INSERT INTO departement (id, nom, responsable) VALUES (1, 'Ventes', 1);

-- 4. Mettre à jour l'employé avec le bon département
UPDATE employe SET departement = 1 WHERE id = 1;

-- 5. Supprimer le département temporaire
DELETE FROM departement WHERE id = 999;
```

**Problèmes**:
- Procédure complexe
- Génère temporairement des données incohérentes
- Nécessite des suppressions ultérieures

### Solution 3: Désactiver temporairement les contraintes

Cette approche consiste à désactiver temporairement les contraintes:

```sql
-- 1. Désactiver les contraintes
ALTER TABLE employe DISABLE TRIGGER ALL;

-- 2. Insérer les données sans validation
INSERT INTO employe (id, nom, departement) VALUES (1, 'Dupuis', 1);
INSERT INTO departement (id, nom, responsable) VALUES (1, 'Ventes', 1);

-- 3. Réactiver les contraintes
ALTER TABLE employe ENABLE TRIGGER ALL;
```

**Problèmes**:
- Très risqué car les données ne sont pas validées
- Les contraintes ne sont pas vérifiées même après réactivation
- L'intégrité des données n'est plus garantie

## Contraintes différées: la solution adéquate

PostgreSQL permet de déclarer des contraintes comme "différables" (DEFERRABLE), ce qui signifie que leur vérification peut être reportée jusqu'à la fin de la transaction.

### Définir des contraintes différables

Une contrainte différable peut être définie avec deux comportements initiaux:
- `INITIALLY IMMEDIATE`: vérifiée immédiatement par défaut (peut être différée explicitement)
- `INITIALLY DEFERRED`: vérifiée uniquement à la fin de la transaction par défaut

```sql
-- Lors de la création de la table
CREATE TABLE employe (
    id INTEGER PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    departement INTEGER,
    CONSTRAINT fk_emp_dep FOREIGN KEY (departement) REFERENCES departement(id)
    DEFERRABLE INITIALLY IMMEDIATE
);

-- Ou lors de l'ajout de contrainte
ALTER TABLE departement
ADD CONSTRAINT fk_dep_resp FOREIGN KEY (responsable) REFERENCES employe(id)
DEFERRABLE INITIALLY DEFERRED;
```

### Modifier le comportement des contraintes dans une transaction

À l'intérieur d'une transaction, vous pouvez modifier le comportement des contraintes différables:

```sql
-- Différer une contrainte spécifique
SET CONSTRAINTS fk_emp_dep DEFERRED;

-- Rendre une contrainte immédiate
SET CONSTRAINTS fk_dep_resp IMMEDIATE;

-- Différer toutes les contraintes différables
SET CONSTRAINTS ALL DEFERRED;

-- Rendre toutes les contraintes différables immédiates
SET CONSTRAINTS ALL IMMEDIATE;
```

### Exemple de résolution de dépendance circulaire avec contraintes différées

```sql
-- 1. Commencer une transaction
BEGIN;

-- 2. Différer la vérification des contraintes
SET CONSTRAINTS ALL DEFERRED;

-- 3. Insérer un employé
INSERT INTO employe (id, nom, departement) 
VALUES (1, 'Dupuis', 1);  -- Référence un département qui n'existe pas encore

-- 4. Insérer un département
INSERT INTO departement (id, nom, responsable) 
VALUES (1, 'Ventes', 1);  -- Référence l'employé qu'on vient d'insérer

-- 5. Valider la transaction
-- C'est à ce moment que les contraintes sont vérifiées
COMMIT;
```

Les deux insertions seraient normalement rejetées si les contraintes étaient vérifiées immédiatement. Avec les contraintes différées, les données sont vérifiées à la fin de la transaction, où elles forment un état cohérent.

## Avantages des contraintes différées

1. **Résolution élégante des dépendances circulaires** : Permet d'insérer des données mutuellement dépendantes sans compromettre l'intégrité.

2. **Maintien de l'intégrité des données** : Contrairement à la désactivation des contraintes, les contraintes différées sont vérifiées à la fin de la transaction.

3. **Simplicité** : Solution plus claire et plus propre que les alternatives.

4. **Flexibilité** : Possibilité de choisir quelles contraintes différer et quand les vérifier.

## Limitations et considérations

1. **Seulement pour les clés étrangères** : Dans PostgreSQL, seules les contraintes de clé étrangère peuvent être différées. Les contraintes CHECK, UNIQUE et NOT NULL sont toujours vérifiées immédiatement.

2. **Transactions obligatoires** : Les contraintes différées nécessitent d'utiliser des transactions explicites.

3. **Performance** : La vérification différée peut être moins performante car elle nécessite de maintenir plus d'informations pendant la transaction.

4. **Complexité** : Le comportement des contraintes différées peut être moins intuitif et plus difficile à déboguer.

## Exemple complet: Système employé-département-projet

```sql
-- Création des tables avec contraintes différables
CREATE TABLE departement (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    responsable INTEGER NULL
);

CREATE TABLE employe (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    departement INTEGER NULL,
    superviseur INTEGER NULL
);

CREATE TABLE projet (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    departement INTEGER NULL,
    chef_projet INTEGER NULL
);

-- Ajout des contraintes différables
ALTER TABLE departement
ADD CONSTRAINT fk_dep_resp FOREIGN KEY (responsable) REFERENCES employe(id)
DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE employe
ADD CONSTRAINT fk_emp_dep FOREIGN KEY (departement) REFERENCES departement(id)
DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE employe
ADD CONSTRAINT fk_emp_sup FOREIGN KEY (superviseur) REFERENCES employe(id)
DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE projet
ADD CONSTRAINT fk_proj_dep FOREIGN KEY (departement) REFERENCES departement(id)
DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE projet
ADD CONSTRAINT fk_proj_chef FOREIGN KEY (chef_projet) REFERENCES employe(id)
DEFERRABLE INITIALLY IMMEDIATE;

-- Insertion de données avec dépendances circulaires
BEGIN;

-- Insertion du premier employé (sans département ni superviseur)
INSERT INTO employe (id, nom, prenom)
VALUES (1, 'Dupuis', 'Lancelot');

-- Insertion du premier département avec Dupuis comme responsable
INSERT INTO departement (id, nom, responsable)
VALUES (1, 'Direction', 1);

-- Mise à jour de Dupuis pour l'affecter à son département
UPDATE employe SET departement = 1 WHERE id = 1;

-- Insertion d'employés supplémentaires
INSERT INTO employe (id, nom, prenom, departement, superviseur)
VALUES 
    (2, 'Lebel', 'Marie', 1, 1),
    (3, 'Martin', 'Jacques', 1, 1);

-- Insertion d'un nouveau département avec un employé comme responsable
INSERT INTO departement (id, nom, responsable)
VALUES (2, 'Développement', 3);

-- Création d'un projet avec dépendances
INSERT INTO projet (id, nom, departement, chef_projet)
VALUES (1, 'Nouveau CRM', 2, 2);

-- Les contraintes seront vérifiées ici
COMMIT;
```

## Bonnes pratiques

1. **Utiliser INITIALLY DEFERRED pour les relations circulaires** : Cela simplifie le code en différant automatiquement la vérification.

2. **Utiliser INITIALLY IMMEDIATE pour les relations non circulaires** : Cela permet de détecter les erreurs plus tôt.

3. **Limiter la portée des contraintes différées** : Ne différer que les contraintes nécessaires pour résoudre les dépendances circulaires.

4. **Documenter clairement les contraintes différées** : Elles peuvent rendre le comportement du système moins évident.

5. **Utiliser des transactions courtes** : Plus la transaction est longue, plus le risque d'incohérence temporaire est grand.

6. **Tester rigoureusement** : Les contraintes différées peuvent créer des comportements subtils en cas d'erreur.

## Liens connexes
- [[TCL-CONTRAINTES-DIFFEREES]] - Transactions
- [[TCL-ACID]] - Propriétés ACID
- [[DDL-CONTRAINTES]] - Contraintes d'intégrité
- [[DEPENDANCES-CIRCULAIRES]] - Gestion des dépendances circulaires