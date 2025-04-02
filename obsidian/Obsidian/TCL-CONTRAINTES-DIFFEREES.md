# TCL - Transactions

Le Transaction Control Language (TCL) est un ensemble de commandes SQL qui permettent de gérer les transactions dans une base de données. Une transaction est un ensemble d'opérations qui constituent une unité logique de travail, qui doit être exécutée entièrement ou pas du tout.

## Principes des transactions

Une transaction regroupe plusieurs opérations en une unité atomique, garantissant que :
- Soit toutes les opérations sont exécutées avec succès (COMMIT)
- Soit aucune n'est exécutée (ROLLBACK)

Les transactions garantissent également que les étapes intermédiaires ne sont pas visibles par les autres utilisateurs de la base de données avant la validation (COMMIT).

## Commandes TCL principales

### BEGIN

Lance une nouvelle transaction.

```sql
BEGIN [TRANSACTION];  -- Le mot TRANSACTION est optionnel
```

### COMMIT

Valide et termine la transaction courante, rendant permanent tous les changements effectués.

```sql
COMMIT [TRANSACTION];  -- Le mot TRANSACTION est optionnel
```

### ROLLBACK

Annule tous les changements effectués depuis le début de la transaction courante.

```sql
ROLLBACK [TRANSACTION];  -- Le mot TRANSACTION est optionnel
```

### SAVEPOINT

Crée un point de sauvegarde dans la transaction courante, permettant d'annuler partiellement une transaction.

```sql
SAVEPOINT nom_point_sauvegarde;
```

### ROLLBACK TO SAVEPOINT

Annule tous les changements effectués depuis le point de sauvegarde spécifié.

```sql
ROLLBACK TO [SAVEPOINT] nom_point_sauvegarde;  -- Le mot SAVEPOINT est optionnel
```

### RELEASE SAVEPOINT

Supprime un point de sauvegarde précédemment défini (mais ne valide pas les modifications).

```sql
RELEASE [SAVEPOINT] nom_point_sauvegarde;  -- Le mot SAVEPOINT est optionnel
```

## Exemple simple

Transfert de 1000$ du compte de Frédérick vers le compte de Caroline :

```sql
BEGIN;
    UPDATE client SET avoir = avoir - 1000 WHERE prenom = 'Frédérick';
    UPDATE client SET avoir = avoir + 1000 WHERE prenom = 'Caroline';
COMMIT;
```

Cette transaction garantit que soit les deux opérations sont exécutées avec succès, soit aucune. Il est impossible de débiter le compte de Frédérick sans créditer celui de Caroline, ou inversement.

## Exemple avec SAVEPOINT

```sql
BEGIN;
    -- Première opération
    UPDATE client SET avoir = avoir - 1000 WHERE prenom = 'Gustave';
    UPDATE client SET avoir = avoir + 1000 WHERE prenom = 'Gaétan';
    
    ROLLBACK;  -- Annule tout ce qui précède
    
    BEGIN;
    UPDATE client SET avoir = avoir - 1000 WHERE prenom = 'Frédérick';
    
    SAVEPOINT mon_point_de_reprise;
    
    UPDATE client SET avoir = avoir + 1000 WHERE prenom = 'Gustave';
    
    -- Oups, mauvais destinataire
    ROLLBACK TO mon_point_de_reprise;
    
    UPDATE client SET avoir = avoir + 1000 WHERE prenom = 'Caroline';
    
COMMIT;  -- Seules les opérations sur Frédérick et Caroline sont validées
```

## Comportement implicite des transactions dans PostgreSQL

PostgreSQL gère les transactions de deux manières :

1. **Mode transaction explicite** : Lorsque vous utilisez BEGIN et COMMIT/ROLLBACK.

2. **Mode auto-commit** : Par défaut, chaque instruction SQL est traitée comme une transaction individuelle qui est automatiquement validée (COMMIT) à la fin de l'instruction, à moins qu'elle ne soit dans un bloc transactionnel explicite.

```sql
-- En mode auto-commit, cette instruction est une transaction complète
UPDATE client SET avoir = avoir - 1000 WHERE prenom = 'Frédérick';
```

## Niveaux d'isolation des transactions

PostgreSQL prend en charge les quatre niveaux d'isolation définis par la norme SQL :

1. **READ UNCOMMITTED** : Peut lire les données non validées (dirty reads), mais PostgreSQL le traite comme READ COMMITTED.

2. **READ COMMITTED** (par défaut) : Une requête ne voit que les données validées avant le début de la requête.

3. **REPEATABLE READ** : Toutes les requêtes d'une transaction ne voient que les données validées avant le début de la transaction.

4. **SERIALIZABLE** : Toutes les transactions s'exécutent comme si elles étaient séquentielles, évitant les anomalies de lecture fantôme.

### Définir le niveau d'isolation

```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- ou
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- ou
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

## Gestion des erreurs dans les transactions

Lorsqu'une erreur se produit dans une transaction :

1. PostgreSQL marque la transaction comme en échec.
2. Toutes les opérations suivantes jusqu'au prochain COMMIT ou ROLLBACK échoueront.
3. La transaction doit être explicitement annulée avec ROLLBACK.

```sql
BEGIN;
    UPDATE client SET avoir = avoir - 1000 WHERE prenom = 'Frédérick';
    -- Si une erreur se produit ici
    UPDATE client SET avoir = avoir + 1000 WHERE prenom = 'Caroline';
    -- Cette ligne ne s'exécutera pas si la précédente a échoué
COMMIT;
-- Si la transaction est en échec, le COMMIT échouera également
```

Pour gérer cette situation, vous pouvez utiliser des blocs PL/pgSQL avec gestion d'exceptions (voir [[PL-EXCEPTIONS]]).

## Transactions et contraintes différées

Les contraintes différées permettent de reporter la vérification des contraintes jusqu'à la fin de la transaction, ce qui est particulièrement utile pour résoudre des problèmes de dépendances circulaires.

```sql
BEGIN;
    SET CONSTRAINTS fk_emp_dep DEFERRED;
    
    -- Les opérations peuvent temporairement violer la contrainte
    
    -- À la fin de la transaction, toutes les contraintes doivent être respectées
COMMIT;
```

Pour plus de détails, voir [[TCL-CONTRAINTES-DIFFEREES]].

## Bonnes pratiques

1. **Garder les transactions courtes** : Les transactions longues peuvent bloquer des ressources et créer des problèmes de concurrence.

2. **Choisir le bon niveau d'isolation** : Utiliser le niveau le plus bas qui satisfait les besoins de l'application.

3. **Utiliser les SAVEPOINTs** : Ils permettent une gestion plus fine des erreurs.

4. **Éviter les opérations externes dans les transactions** : Comme les appels réseau ou fichiers, qui peuvent bloquer longuement la transaction.

5. **Gérer correctement les erreurs** : S'assurer qu'un ROLLBACK est appelé en cas d'erreur.

6. **Réessayer les transactions échouées** : Certaines erreurs (comme les deadlocks) sont temporaires et peuvent être résolues en réessayant la transaction.

## Limitations

1. **DDL et transactions** : Bien que PostgreSQL supporte les DDL (CREATE, ALTER, DROP) dans les transactions, ce n'est pas le cas de tous les SGBD.

2. **Auto-COMMIT** : Certains clients SQL exécutent chaque instruction dans sa propre transaction auto-validée, ce qui peut nécessiter une configuration spécifique pour utiliser des transactions explicites.

3. **Verrouillage et concurrence** : Les transactions peuvent entraîner des problèmes de verrouillage et de concurrence s'ils ne sont pas correctement gérés.

## Exemple complet

```sql
BEGIN;
    -- Créer une commande
    INSERT INTO commande (client_id, date, total)
    VALUES (123, CURRENT_DATE, 0)
    RETURNING id INTO v_commande_id;
    
    SAVEPOINT apres_commande;
    
    -- Ajouter les lignes de commande
    BEGIN
        INSERT INTO ligne_commande (commande_id, produit_id, quantite, prix_unitaire)
        VALUES (v_commande_id, 1, 2, 10.00);
        
        INSERT INTO ligne_commande (commande_id, produit_id, quantite, prix_unitaire)
        VALUES (v_commande_id, 2, 1, 25.00);
    EXCEPTION WHEN OTHERS THEN
        -- Si erreur lors de l'ajout des lignes, annuler jusqu'au savepoint
        ROLLBACK TO apres_commande;
        RAISE EXCEPTION 'Erreur lors de l''ajout des lignes: %', SQLERRM;
    END;
    
    -- Mettre à jour le total de la commande
    UPDATE commande 
    SET total = (SELECT SUM(quantite * prix_unitaire) 
                 FROM ligne_commande 
                 WHERE commande_id = v_commande_id)
    WHERE id = v_commande_id;
    
    -- Vérifier le stock
    PERFORM 1 FROM produit p
    JOIN ligne_commande lc ON p.id = lc.produit_id
    WHERE lc.commande_id = v_commande_id
    AND p.stock < lc.quantite;
    
    IF FOUND THEN
        ROLLBACK;
        RAISE EXCEPTION 'Stock insuffisant pour un ou plusieurs produits';
    END IF;
    
    -- Mise à jour du stock
    UPDATE produit p
    SET stock = p.stock - lc.quantite
    FROM ligne_commande lc
    WHERE p.id = lc.produit_id
    AND lc.commande_id = v_commande_id;
    
COMMIT;
```

## Liens connexes
- [[TCL-ACID]] - Propriétés ACID
- [[TCL-CONTRAINTES-DIFFEREES]] - Contraintes différées
- [[PL-EXCEPTIONS]] - Gestion des exceptions en PL/pgSQL
- [[DEPENDANCES-CIRCULAIRES]] - Gestion des dépendances circulaires