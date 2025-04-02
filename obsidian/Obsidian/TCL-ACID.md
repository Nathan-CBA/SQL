# TCL - Propriétés ACID

Les propriétés ACID sont un ensemble de caractéristiques garantissant la fiabilité des transactions dans un système de gestion de base de données. ACID est un acronyme qui représente Atomicité, Cohérence, Isolation et Durabilité.

## Vue d'ensemble

Les propriétés ACID sont essentielles pour maintenir l'intégrité des données dans les systèmes de bases de données relationnelles, particulièrement dans les environnements multi-utilisateurs où plusieurs transactions peuvent s'exécuter simultanément.

## Atomicité (Atomicity)

**Principe** : Une transaction est une unité indivisible et atomique. Elle doit être exécutée entièrement ou pas du tout.

**Explication** : Si une partie de la transaction échoue, toute la transaction est annulée (rollback), laissant la base de données dans l'état où elle était avant le début de la transaction.

**Exemple** :
```sql
BEGIN;
    UPDATE compte SET solde = solde - 1000 WHERE id = 123; -- Débit
    UPDATE compte SET solde = solde + 1000 WHERE id = 456; -- Crédit
COMMIT;
```

Si la deuxième instruction échoue (par exemple, si le compte 456 n'existe pas), la première mise à jour est automatiquement annulée. L'argent n'est pas "perdu" - soit les deux comptes sont mis à jour, soit aucun.

**Mise en œuvre PostgreSQL** :
- Transactions explicites (BEGIN/COMMIT/ROLLBACK)
- Journalisation des transactions (WAL - Write-Ahead Logging)
- Gestion des points de sauvegarde (SAVEPOINT)

## Cohérence (Consistency)

**Principe** : Une transaction fait passer la base de données d'un état cohérent à un autre état cohérent, respectant toutes les règles et contraintes définies.

**Explication** : Les contraintes d'intégrité (clés primaires, clés étrangères, contraintes CHECK, etc.) doivent être respectées à la fin de la transaction. Si une transaction tente de violer ces contraintes, elle est entièrement annulée.

**Exemple** :
```sql
-- Définition d'une contrainte pour assurer un solde positif
ALTER TABLE compte ADD CONSTRAINT ck_solde_positif CHECK (solde >= 0);

-- Transaction qui essaie de violer cette contrainte
BEGIN;
    UPDATE compte SET solde = solde - 5000 WHERE id = 123; -- Solde devient négatif
COMMIT; -- Cette transaction sera rejetée si le solde devient négatif
```

**Mise en œuvre PostgreSQL** :
- Contraintes d'intégrité (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL)
- Triggers et règles
- Transactions
- Contraintes différées (pour gérer certains cas complexes de cohérence, voir [[TCL-CONTRAINTES-DIFFEREES]])

## Isolation (Isolation)

**Principe** : Les transactions s'exécutent de manière isolée les unes des autres, comme si elles étaient séquentielles, même si elles s'exécutent en parallèle.

**Explication** : Une transaction ne doit pas être affectée par les modifications non validées d'autres transactions concurrentes. Les niveaux d'isolation déterminent le degré auquel une transaction est isolée des modifications apportées par d'autres transactions.

**Niveaux d'isolation dans PostgreSQL** :

1. **READ UNCOMMITTED** :
   - En théorie, permet de lire les données non validées (dirty reads)
   - En pratique, PostgreSQL traite ce niveau comme READ COMMITTED

2. **READ COMMITTED** (niveau par défaut) :
   - Une requête ne voit que les données validées avant le début de la requête
   - Chaque instruction de la transaction voit les modifications validées par d'autres transactions entre le début de la transaction et le début de l'instruction
   - Évite les "dirty reads" mais peut entraîner des "non-repeatable reads" et des "phantom reads"

3. **REPEATABLE READ** :
   - Toutes les requêtes d'une transaction ne voient que les données validées avant le début de la transaction
   - Si les mêmes requêtes sont exécutées plusieurs fois dans la même transaction, elles produiront toujours les mêmes résultats
   - Évite les "dirty reads" et les "non-repeatable reads", mais peut entraîner des "phantom reads"

4. **SERIALIZABLE** :
   - Le niveau d'isolation le plus strict
   - Les transactions s'exécutent comme si elles étaient séquentielles
   - Évite tous les problèmes d'isolation, mais peut entraîner des erreurs de sérialisation qui nécessitent de réessayer la transaction

**Définir le niveau d'isolation** :
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Instructions de la transaction
COMMIT;
```

**Problèmes d'isolation** :

1. **Dirty Read** : Une transaction lit des données modifiées par une autre transaction non validée.
2. **Non-repeatable Read** : Une transaction relit des données qu'elle a déjà lues et constate que ces données ont été modifiées par une autre transaction (validée entre-temps).
3. **Phantom Read** : Une transaction exécute une requête qui retourne un ensemble de lignes, puis une autre transaction insère de nouvelles lignes qui correspondent à la requête. Si la première transaction répète sa requête, elle verra ces nouvelles lignes "fantômes".
4. **Serialization Anomaly** : Le résultat d'un groupe de transactions s'exécutant en parallèle est incohérent avec tous les résultats possibles si ces transactions s'exécutaient séquentiellement.

## Durabilité (Durability)

**Principe** : Une fois qu'une transaction est validée (COMMIT), ses effets sont permanents et persistants, même en cas de panne système.

**Explication** : Les modifications apportées par une transaction validée sont stockées de manière permanente et ne seront pas perdues, même en cas de coupure d'électricité ou de défaillance matérielle.

**Mise en œuvre PostgreSQL** :
- Journalisation des transactions (WAL - Write-Ahead Logging)
- Système de points de contrôle (checkpoints)
- Récupération après crash
- Sauvegarde et restauration

**Exemple** :
```sql
BEGIN;
    INSERT INTO journal_transactions (operation, montant, date)
    VALUES ('dépôt', 1000, CURRENT_TIMESTAMP);
    
    UPDATE compte SET solde = solde + 1000 WHERE id = 123;
COMMIT;
```

Après le COMMIT, même si le système s'arrête brusquement, les modifications (l'entrée de journal et la mise à jour du solde) seront persistantes lorsque la base de données redémarrera.

## Équilibre et compromis

Les propriétés ACID sont essentielles pour l'intégrité des données, mais elles peuvent avoir un impact sur les performances :

1. **Performance vs. Fiabilité** : Des niveaux d'isolation plus élevés offrent une meilleure cohérence mais peuvent réduire les performances en raison du verrouillage accru.

2. **Transactions longues vs. courtes** : Les transactions longues peuvent bloquer des ressources pendant de longues périodes, affectant la concurrence.

3. **Bases de données NoSQL** : Certaines bases de données NoSQL sacrifient certaines propriétés ACID pour obtenir une meilleure évolutivité et disponibilité (voir le théorème CAP).

## Exemple concret d'application des propriétés ACID

Considérons un système bancaire où deux clients, Alice et Bob, effectuent des transferts d'argent simultanément :

```sql
-- Transaction 1 : Alice transfère 100€ à Charlie
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    UPDATE comptes SET solde = solde - 100 WHERE client = 'Alice';
    UPDATE comptes SET solde = solde + 100 WHERE client = 'Charlie';
COMMIT;

-- Transaction 2 (simultanée) : Bob transfère 50€ à Alice
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    UPDATE comptes SET solde = solde - 50 WHERE client = 'Bob';
    UPDATE comptes SET solde = solde + 50 WHERE client = 'Alice';
COMMIT;
```

Avec les propriétés ACID :
- **Atomicité** : Si la mise à jour du compte de Charlie échoue, le retrait du compte d'Alice est annulé automatiquement.
- **Cohérence** : Les contraintes (solde positif, somme totale des comptes constante) sont maintenues.
- **Isolation** : Même si les transactions s'exécutent simultanément, le résultat final est comme si elles s'étaient exécutées séquentiellement.
- **Durabilité** : Une fois validés, les transferts sont permanents et résisteront à une panne système.

## Liens connexes
- [[TCL-CONTRAINTES-DIFFEREES]] - Transactions en PostgreSQL
- [[TCL-CONTRAINTES-DIFFEREES]] - Contraintes différées