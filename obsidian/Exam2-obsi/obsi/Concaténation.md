## 1. Utiliser l’opérateur `||` (standard SQL, PostgreSQL, SQLite)


`SELECT prenom || ' ' || nom AS nom_complet FROM employe;`

**Description :**  
Concatène le prénom et le nom avec un espace entre les deux.  
L’opérateur `||` est standard et très utilisé en PostgreSQL.

---

## 2. Utiliser la fonction `CONCAT()` (MySQL, SQL Server, PostgreSQL 9.1+)


`SELECT CONCAT(prenom, ' ', nom) AS nom_complet FROM employe;`

**Description :**  
`CONCAT` prend plusieurs arguments et les assemble en une seule chaîne. Très simple et lisible.  
Attention : si un des arguments est `NULL`, dans certains SGBD `CONCAT` retourne `NULL` (exemple MySQL avant 5.7). PostgreSQL ignore les NULL.

---

## 3. Utiliser `CONCAT_WS()` (MySQL, PostgreSQL)


`SELECT CONCAT_WS(' ', prenom, nom) AS nom_complet FROM employe;`

**Description :**  
Concatène les chaînes avec un séparateur (ici un espace `' '`).  
Ignore automatiquement les valeurs `NULL`. Pratique pour éviter d’avoir des espaces inutiles.

---

## 4. Utiliser `+` (SQL Server)


`SELECT prenom + ' ' + nom AS nom_complet FROM employe;`

**Description :**  
En SQL Server, on peut concaténer avec `+`. Attention, si un champ est `NULL`, le résultat est `NULL`.  
Pour gérer ça, on utilise souvent `ISNULL` ou `COALESCE` (voir exemple plus bas).

---

## 5. Gérer les valeurs NULL avec `COALESCE`


`SELECT COALESCE(prenom, '') || ' ' || COALESCE(nom, '') AS nom_complet FROM employe;`

**Description :**  
Pour éviter que la concaténation retourne NULL quand un champ est NULL, on remplace NULL par chaîne vide avec `COALESCE`.

---

## 6. Exemple complet avec concaténation multiple


`SELECT    prenom || ' ' || nom || ' (' || departement || ')' AS info_employe FROM employe;`

**Description :**  
Concatène prénom, nom et le département entre parenthèses.