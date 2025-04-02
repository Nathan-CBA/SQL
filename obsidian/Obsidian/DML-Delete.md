# DML - DELETE

La commande `DELETE` permet de supprimer des lignes existantes dans une table.

## Syntaxe de base

```sql
DELETE FROM nom_table
[WHERE condition];
```

Si la clause `WHERE` est omise, toutes les lignes de la table sont supprimées (la table elle-même reste).

## Exemples de base

### Suppression avec condition

```sql
-- Supprime tous les employés ayant la lettre 'a' dans leur nom
DELETE FROM employe
WHERE nom LIKE '%a%';
```

### Suppression de toutes les lignes

```sql
-- Supprime toutes les lignes de la table
DELETE FROM employe;
```

> ⚠️ **Attention** : Cette commande supprime toutes les données sans possibilité de récupération (sauf restauration de sauvegarde). Pour simplement vider une table, la commande `TRUNCATE TABLE` est souvent plus efficace, surtout pour les grandes tables.

## DELETE avec CTE (Common Table Expressions)

On peut utiliser une CTE pour effectuer des suppressions plus complexes ou basées sur des conditions élaborées.

```sql
-- Supprime les commandes obsolètes en identifiant d'abord les ID à supprimer
WITH old_orders AS (
    SELECT commande_id
    FROM commandes
    WHERE date_commande < '2023-01-01'
)
DELETE FROM commandes
WHERE commande_id IN (SELECT commande_id FROM old_orders);
```

## DELETE avec sous-requête

On peut utiliser des sous-requêtes dans la clause WHERE pour déterminer quelles lignes supprimer.

```sql
-- Supprime les employés des départements qui n'ont pas de budget
DELETE FROM employe
WHERE departement IN (
    SELECT id FROM departement WHERE budget IS NULL
);
```

## Dépendances et contraintes de clé étrangère

La suppression peut être affectée par des contraintes de clé étrangère :

1. Si une ligne est référencée par une clé étrangère, la suppression peut :
   - Échouer (comportement par défaut, RESTRICT)
   - Supprimer en cascade les lignes dépendantes (ON DELETE CASCADE)
   - Mettre NULL dans les références (ON DELETE SET NULL)
   - Mettre une valeur par défaut (ON DELETE SET DEFAULT)

```sql
-- Exemple : suppression d'un département avec ses employés (si ON DELETE CASCADE)
DELETE FROM departement
WHERE id = 5;
```

## Considérations importantes

1. **Clause WHERE** : Soyez très attentif à cette clause. Sans elle, toutes les lignes sont supprimées, ce qui est rarement l'intention.

2. **Contraintes de clé étrangère** : Les suppressions peuvent échouer ou déclencher des actions en cascade selon les contraintes définies.

3. **Performances** : Pour supprimer un grand nombre de lignes, envisagez de le faire par lots ou d'utiliser TRUNCATE si possible.

4. **Transactions** : Pour des suppressions multiples interdépendantes, utilisez des transactions pour garantir la cohérence des données.

5. **Récupération** : Contrairement à TRUNCATE, DELETE génère des WAL (Write-Ahead Logs) qui permettent la récupération point-in-time.

## Différence entre DELETE et TRUNCATE

- `DELETE` :
  - Supprime ligne par ligne
  - Génère des journaux pour chaque ligne
  - Peut utiliser WHERE pour filtrer
  - Déclenche les triggers
  - Peut être annulé dans une transaction
  - Compteurs SERIAL ne sont pas réinitialisés

- `TRUNCATE TABLE` :
  - Supprime toutes les lignes en une seule opération
  - Plus rapide pour de grandes tables
  - Ne peut pas filtrer avec WHERE
  - Ne déclenche pas les triggers
  - Réinitialise les compteurs SERIAL
  - Peut être annulé dans une transaction

```sql
-- Vider complètement une table et réinitialiser les compteurs
TRUNCATE TABLE commandes RESTART IDENTITY;
```

## Dépendances circulaires

Lorsqu'il existe des dépendances circulaires entre tables (via des clés étrangères), la suppression peut poser problème. Solutions possibles :

1. Désactiver temporairement les contraintes :
```sql
ALTER TABLE nom_table DISABLE TRIGGER ALL;
-- Suppressions
ALTER TABLE nom_table ENABLE TRIGGER ALL;
```

2. Utiliser des contraintes différées (voir [[TCL-CONTRAINTES-DIFFEREES]])

3. Utiliser des transactions avec les suppressions dans le bon ordre

## Exemple complet

```sql
BEGIN;

-- Supprimer d'abord les employés d'un département
DELETE FROM employe
WHERE departement = 5;

-- Puis supprimer le département lui-même
DELETE FROM departement
WHERE id = 5;

COMMIT;
```

## Liens connexes
- [[DML-INSERT]] - Insertion de données
- [[DML-UPDATE]] - Mise à jour de données
- [[DQL-WHERE]] - Filtrage avec WHERE
- [[TCL-CONTRAINTES-DIFFEREES]] - Transactions
- [[DDL-CONTRAINTES]] - Contraintes d'intégrité
- [[TCL-CONTRAINTES-DIFFEREES]] - Contraintes différées