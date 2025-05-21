## Qu’est-ce qu’une jointure ?

Une **jointure** (ou **JOIN**) est une opération qui permet de **combiner des lignes provenant de deux (ou plusieurs) tables** dans une base de données relationnelle, en fonction d’une condition de correspondance entre ces tables.

### Pourquoi utiliser une jointure ?

Les bases relationnelles stockent souvent des données dans plusieurs tables distinctes pour éviter la redondance et pour organiser les données logiquement (modèle relationnel).  
Par exemple, on peut avoir :

- Une table `employe` avec les infos sur les employés (id, nom, département).
    
- Une table `projet` avec les infos sur les projets (id, nom, responsable).
    
- Une table `feuille_temps` indiquant combien de temps chaque employé a passé sur un projet.
    

Pour voir quel employé a travaillé combien de temps sur quel projet, il faut **relier ces tables entre elles** — c’est le rôle des jointures.

---

## Types de jointures principales

### 1. INNER JOIN (jointure interne)

- La jointure la plus utilisée.
    
- Elle **renvoie uniquement les lignes où il y a une correspondance dans les deux tables**.
    
- Si une ligne dans une table ne correspond à aucune ligne dans l’autre, elle n’apparaît pas.
    

**Exemple** :



`SELECT e.nom, f.minutes 
FROM employe e 
INNER JOIN feuille_temps f ON e.id = f.employe_id;`

Ici on récupère les employés qui ont des enregistrements dans `feuille_temps`.

---

### 2. LEFT JOIN (jointure gauche)

- Renvoie **toutes les lignes de la table de gauche (la première)**, même si elles n’ont pas de correspondance dans la table de droite.
    
- Les colonnes de la table droite seront `NULL` si pas de correspondance.
    

**Exemple** :

`SELECT e.nom, f.minutes 
FROM employe e 
LEFT JOIN feuille_temps f ON e.id = f.employe_id;`

Ici on obtient tous les employés, même ceux qui n’ont pas de feuille de temps (minutes seront NULL dans ce cas).

---

### 3. RIGHT JOIN (jointure droite)

- Symétrique de LEFT JOIN, renvoie toutes les lignes de la table de droite.
    
- Moins souvent utilisée.
    

---

### 4. FULL JOIN (jointure complète)

- Combine LEFT JOIN et RIGHT JOIN : renvoie toutes les lignes des deux tables, avec NULL quand pas de correspondance.
    

---

## Comment ça fonctionne ?

Une jointure se fait généralement sur une **clé** ou un attribut commun entre les tables, souvent une clé primaire et une clé étrangère.

Exemple simplifié :

- Table `employe` avec `id` (clé primaire).
    
- Table `feuille_temps` avec `employe_id` (clé étrangère).
    

La condition de jointure est donc :

`ON employe.id = feuille_temps.employe_id`