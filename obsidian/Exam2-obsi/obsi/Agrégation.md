## Qu’est-ce qu’une agrégation ?

L’**agrégation** est un processus qui permet de **regrouper plusieurs lignes de données en une seule valeur résumée** selon une certaine règle ou fonction.

Cela permet de **résumer, calculer ou synthétiser** des informations sur un ensemble de données.

---

## Fonctions d’agrégation courantes

SQL fournit plusieurs fonctions d’agrégation très utilisées, notamment :

|Fonction|Description|Exemple d’usage|
|---|---|---|
|`SUM()`|Somme des valeurs numériques|Total des ventes, total des minutes|
|`COUNT()`|Compte le nombre de lignes|Nombre de clients, nombre de commandes|
|`AVG()`|Moyenne des valeurs numériques|Moyenne des notes, moyenne des salaires|
|`MIN()`|Valeur minimale|Plus petite date, plus petit prix|
|`MAX()`|Valeur maximale|Plus grande date, plus grand salaire|

---

## Pourquoi utiliser l’agrégation ?

- Pour **résumer les données volumineuses**
    
- Pour **faire des statistiques simples** (total, moyenne, max, min…)
    
- Pour **répondre à des questions de type “Combien ?”, “Quelle moyenne ?”, “Quel total ?”**
    

---

## Comment ça marche en SQL ?

Quand on utilise une fonction d’agrégation, on regroupe souvent les données selon certaines colonnes grâce à la clause **`GROUP BY`**.


## Détails importants

- **`GROUP BY`** regroupe les lignes qui ont les mêmes valeurs dans les colonnes spécifiées.
    
- Les colonnes **non agrégées** dans la sélection doivent être dans le `GROUP BY`.
    
- Sans `GROUP BY`, la fonction d’agrégation s’applique sur **toutes les lignes** de la table (exemple : `SELECT SUM(montant) FROM ventes;` donne le total global).
## EXEMPLE jointure/agrégation

## 1. 

`SELECT e.nom, SUM(ft.minutes) AS total_minutes 
FROM employe e 
JOIN feuille_temps ft ON e.nas = ft.employe GROUP BY e.nom;`

**Description :**  
On récupère la somme des minutes passées par chaque employé (`e.nom`).  
Simple agrégation par employé.

---

## 2. 

`SELECT e.nom, SUM(ft.minutes) AS total_minutes 
FROM employe e 
JOIN feuille_temps ft ON e.nas = ft.employe 
JOIN projet p ON ft.projet = p.id 
WHERE p.actif = TRUE 
GROUP BY e.nom;`

**Description :**  
Somme des minutes travaillées par employé uniquement pour les projets actifs (`p.actif = TRUE`).  
Filtrage avant agrégation.

---

## 3. 

`SELECT e.nom, SUM(ft.minutes) AS total_minutes 
FROM employe e 
JOIN feuille_temps ft ON e.nas = ft.employe 
GROUP BY e.nom 
HAVING SUM(ft.minutes) > 500;`

**Description :**  
On affiche seulement les employés ayant cumulé plus de 500 minutes de travail.  
Filtrage sur le résultat agrégé.

---

## 4. 

`SELECT e.nom, SUM(ft.minutes) AS total_minutes, COUNT(DISTINCT ft.projet) AS nb_projets 
FROM employe e 
JOIN feuille_temps ft ON e.nas = ft.employe
GROUP BY e.nom 
HAVING SUM(ft.minutes) > 500 AND COUNT(DISTINCT ft.projet) >= 3;`

**Description :**  
On récupère les employés qui ont travaillé plus de 500 minutes **et** sur au moins 3 projets différents.  
Filtrage sur plusieurs conditions agrégées.

---

## 5. 

`SELECT e.nom, SUM(ft.minutes) AS total_minutes 
FROM employe e 
JOIN feuille_temps ft ON e.nas = ft.employe 
WHERE e.departement = 2 
GROUP BY e.nom 
ORDER BY total_minutes DESC LIMIT 5;`

**Description :**  
On affiche les 5 employés du département 2 qui ont travaillé le plus longtemps.  
Filtrage avant agrégation, puis tri décroissant par temps total, avec limitation.

---

## 6. 

`SELECT e.departement, e.nom, SUM(ft.minutes) AS total_minutes 
FROM employe e 
JOIN feuille_temps ft ON e.nas = ft.employe 
WHERE e.date_embauche > '2020-01-01' 
GROUP BY e.departement, e.nom 
HAVING SUM(ft.minutes) > 200 
ORDER BY e.departement ASC, total_minutes DESC;`

**Description :**  
On liste les employés embauchés après 2020 qui ont travaillé plus de 200 minutes, triés par département (ascendant), puis par temps de travail (descendant).