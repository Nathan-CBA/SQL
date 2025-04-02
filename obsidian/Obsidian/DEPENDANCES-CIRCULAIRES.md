# Dépendances circulaires

Les dépendances circulaires surviennent lorsque deux ou plusieurs objets dans une base de données se référencent mutuellement. Ce concept est particulièrement important pour comprendre certains défis dans la création et la manipulation des données dans PostgreSQL.

## Types de dépendances circulaires

Il existe deux principaux types de dépendances circulaires dans les bases de données :

1. **Dépendances circulaires structurelles (DCDDL)** - Liées à la définition des tables et des contraintes
2. **Dépendances circulaires de données (DCDML)** - Liées à l'insertion et à la manipulation des données

## Dépendances circulaires structurelles (DCDDL)

Ces dépendances surviennent lors de la création de tables qui se référencent mutuellement via des contraintes de clé étrangère.

### Exemple classique : Employé et Département

Un exemple courant est la relation entre les tables `employe` et `departement` :

- La table `employe` contient une clé étrangère vers `departement` (un employé appartient à un département)
- La table `departement` contient une clé étrangère vers `employe` (un département a un responsable qui est un employé)

```sql
-- Tentative incorrecte de création
CREATE TABLE departement (
    id INTEGER PRIMARY KEY,
    nom VARCHAR(100),
    responsable INTEGER REFERENCES employe(id)  -- Référence à la table employe qui n'existe pas encore
);

CREATE TABLE employe (
    id INTEGER PRIMARY KEY,
    nom VARCHAR(100),
    departement INTEGER REFERENCES departement(id)
);
```

Cette approche échoue car la table `employe` n'existe pas encore lors de la création de `departement`.

### Solution aux DCDDL

La solution standard consiste à créer d'abord toutes les tables sans les contraintes de clé étrangère, puis à ajouter ces contraintes après la création de toutes les tables :

```sql
-- 1. Créer les tables sans contraintes de clé étrangère
CREATE TABLE departement (
    id INTEGER PRIMARY KEY,
    nom VARCHAR(100),
    responsable INTEGER
);

CREATE TABLE employe (
    id INTEGER PRIMARY KEY,
    nom VARCHAR(100),
    departement INTEGER
);

-- 2. Ajouter les contraintes après la création des tables
ALTER TABLE departement
ADD CONSTRAINT fk_dep_resp FOREIGN KEY (responsable) REFERENCES employe(id);

ALTER TABLE employe
ADD CONSTRAINT fk_emp_dep FOREIGN KEY (departement) REFERENCES departement(id);
```

## Dépendances circulaires de données (DCDML)

Ces dépendances apparaissent lorsqu'on tente d'insérer des données dans des tables ayant des références mutuelles.

### Problème avec l'insertion des premières données

Avec l'exemple précédent :
- Pour insérer un employé, on doit spécifier un département (qui n'existe pas encore)
- Pour insérer un département, on doit spécifier un responsable (qui est un employé qui n'existe pas encore)

```sql
-- Ces insertions échoueront en raison des contraintes de clé étrangère
INSERT INTO employe (id, nom, departement) VALUES (1, 'Dupuis', 1);
INSERT INTO departement (id, nom, responsable) VALUES (1, 'Ventes', 1);
```

### Solutions inadéquates aux DCDML

#### 1. Permettre temporairement les valeurs NULL

```sql
-- 1. Insérer un employé avec un département NULL
INSERT INTO employe (id, nom, departement) VALUES (1, 'Dupuis', NULL);

-- 2. Insérer un département avec cet employé comme responsable
INSERT INTO departement (id, nom, responsable) VALUES (1, 'Ventes', 1);

-- 3. Mettre à jour l'employé avec son département
UPDATE employe SET departement = 1 WHERE id = 1;
```

**Problèmes** :
- Nécessite que les colonnes acceptent NULL
- Génère temporairement des données incohérentes
- Oblige à faire des mises à jour supplémentaires

#### 2. Utiliser des valeurs temporaires

```sql
-- 1. Insérer un département temporaire
INSERT INTO departement (id, nom, responsable) VALUES (999, 'Temp', NULL);

-- 2. Insérer un employé référençant ce département temporaire
INSERT INTO employe (id, nom, departement) VALUES (1, 'Dupuis', 999);

-- 3. Insérer le vrai département
INSERT INTO departement (id, nom, responsable) VALUES (1, 'Ventes', 1);

-- 4. Mettre à jour l'employé avec le bon département
UPDATE employe SET departement = 1 WHERE id = 1;

-- 5. Supprimer le département temporaire
DELETE FROM departement WHERE id = 999;
```

**Problèmes** :
- Procédure complexe
- Nécessite des suppressions ultérieures
- Risque d'erreurs

#### 3. Désactiver temporairement les contraintes

```sql
-- 1. Désactiver les contraintes de clé étrangère
ALTER TABLE employe DISABLE TRIGGER ALL;
ALTER TABLE departement DISABLE TRIGGER ALL;

-- 2. Insérer les données sans validation
INSERT INTO employe (id, nom, departement) VALUES (1, 'Dupuis', 1);
INSERT INTO departement (id, nom, responsable) VALUES (1, 'Ventes', 1);

-- 3. Réactiver les contraintes
ALTER TABLE employe ENABLE TRIGGER ALL;
ALTER TABLE departement ENABLE TRIGGER ALL;
```

**Problèmes** :
- Très risqué : aucune validation des données
- Les contraintes ne vérifient pas les données insérées pendant leur désactivation
- L'intégrité des données n'est plus garantie

### Solution optimale : Contraintes différées

PostgreSQL permet de définir des contraintes comme "différables" (DEFERRABLE), ce qui signifie que leur vérification peut être reportée jusqu'à la fin de la transaction.

```sql
-- 1. Définir les contraintes comme différables
ALTER TABLE departement
ADD CONSTRAINT fk_dep_resp FOREIGN KEY (responsable) REFERENCES employe(id)
DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE employe
ADD CONSTRAINT fk_emp_dep FOREIGN KEY (departement) REFERENCES departement(id)
DEFERRABLE INITIALLY DEFERRED;

-- 2. Insérer les données dans une transaction
BEGIN;
    -- Les contraintes ne seront vérifiées qu'à la fin de la transaction (COMMIT)
    INSERT INTO employe (id, nom, departement) VALUES (1, 'Dupuis', 1);
    INSERT INTO departement (id, nom, responsable) VALUES (1, 'Ventes', 1);
COMMIT;
```

Pour plus de détails sur cette approche, voir [[TCL-CONTRAINTES-DIFFEREES]].

## Dépendances circulaires dans les UPDATE et DELETE

Les dépendances circulaires peuvent également poser des problèmes lors de la mise à jour ou de la suppression de données.

### Problème de suppression (DELETE)

Si l'on tente de supprimer un département qui a des employés, et que ces employés ont des contraintes de clé étrangère vers le département, la suppression échouera.

```sql
-- Tentative de suppression (échouera si des employés référencent ce département)
DELETE FROM departement WHERE id = 1;
```

### Solutions pour UPDATE et DELETE

#### 1. Opérations en cascade

Définir les contraintes de clé étrangère avec la clause `ON DELETE CASCADE` ou `ON UPDATE CASCADE` :

```sql
ALTER TABLE employe
ADD CONSTRAINT fk_emp_dep FOREIGN KEY (departement) 
REFERENCES departement(id) ON DELETE CASCADE ON UPDATE CASCADE;
```

#### 2. Utiliser des contraintes différées

```sql
BEGIN;
    SET CONSTRAINTS ALL DEFERRED;
    
    -- Mettre à jour d'abord les employés
    UPDATE employe SET departement = NULL WHERE departement = 1;
    
    -- Puis supprimer le département
    DELETE FROM departement WHERE id = 1;
COMMIT;
```

#### 3. Désactiver temporairement les contraintes

Comme précédemment mentionné, mais cette approche doit être utilisée avec précaution.

## Dépendances circulaires complexes

Dans des modèles de données plus complexes, les dépendances circulaires peuvent impliquer plus de deux tables.

### Exemple : Employé → Projet → Département → Employé

```
employe.chef_projet → projet.id
projet.departement → departement.id
departement.responsable → employe.id
```

La solution reste similaire : utilisation de contraintes différées ou création des tables sans contraintes, puis ajout des contraintes après.

## Bonnes pratiques

1. **Anticipez les dépendances circulaires** lors de la conception du modèle de données

2. **Définissez les contraintes comme DEFERRABLE** pour les relations susceptibles de créer des cercles

3. **Utilisez des transactions** pour gérer les insertions ou modifications interdépendantes

4. **Évitez de désactiver les contraintes** sauf en cas de nécessité absolue

5. **Documentez clairement** les dépendances circulaires et les procédures pour gérer les données

6. **Considérez des alternatives de conception** qui pourraient éviter les dépendances circulaires, comme l'utilisation de tables intermédiaires

## Exemples pratiques

### Modèle classique Employé-Département-Projet

```sql
-- Création des tables
CREATE TABLE departement (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    responsable INTEGER
);

CREATE TABLE employe (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    departement INTEGER
);

CREATE TABLE projet (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    chef_projet INTEGER,
    departement INTEGER
);

-- Ajout des contraintes différées
ALTER TABLE departement
ADD CONSTRAINT fk_dep_resp FOREIGN KEY (responsable) 
REFERENCES employe(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE employe
ADD CONSTRAINT fk_emp_dep FOREIGN KEY (departement) 
REFERENCES departement(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE projet
ADD CONSTRAINT fk_proj_chef FOREIGN KEY (chef_projet) 
REFERENCES employe(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE projet
ADD CONSTRAINT fk_proj_dep FOREIGN KEY (departement) 
REFERENCES departement(id) DEFERRABLE INITIALLY DEFERRED;

-- Insertion des données initiales
BEGIN;
    -- Insertion du premier employé (sans département)
    INSERT INTO employe (id, nom) VALUES (1, 'Dupuis');
    
    -- Insertion du premier département avec Dupuis comme responsable
    INSERT INTO departement (id, nom, responsable) VALUES (1, 'Direction', 1);
    
    -- Mise à jour de l'employé pour l'associer au département
    UPDATE employe SET departement = 1 WHERE id = 1;
    
    -- Création d'un projet
    INSERT INTO projet (id, nom, chef_projet, departement)
    VALUES (1, 'Restructuration', 1, 1);
COMMIT;
```

## Liens connexes
- [[TCL-CONTRAINTES-DIFFEREES]] - Contraintes différées
- [[TCL-CONTRAINTES-DIFFEREES]] - Transactions
- [[DDL-CONTRAINTES]] - Contraintes d'intégrité