Une **dépendance circulaire** survient lorsque **deux ou plusieurs tables se réfèrent mutuellement entre elles**, créant ainsi un **cycle**. Cela complique :

- la **création des tables** (on ne peut pas créer A sans B, ni B sans A),
    
- la **suppression ou modification** de données,
    
- la **gestion de l’intégrité référentielle**.
    

---

## Pourquoi c’est problématique ?

- Tu ne peux pas insérer ou supprimer des données sans **casser une contrainte de clé étrangère**.
    
- Tu dois gérer l’ordre de création ou utiliser des options comme `DEFERRABLE`.
    

---

##  Exemple de dépendance circulaire

CREATE TABLE auteur (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(100),
  livre_prefere INTEGER REFERENCES livre(id) -- l'auteur a un livre préféré
);

CREATE TABLE livre (
  id SERIAL PRIMARY KEY,
  titre VARCHAR(100),
  auteur_id INTEGER REFERENCES auteur(id) -- chaque livre a un auteur
);
 Où est la dépendance circulaire ?
La table auteur dépend de livre (via livre_prefere)

La table livre dépend de auteur (via auteur_id)

 Impossible de créer ou insérer les données sans casser une contrainte.
 Il y a un cercle de dépendance.

 Comment régler ça ?
On peut :

Créer une des deux tables sans sa clé étrangère, puis l’ajouter après avec ALTER TABLE

Utiliser DEFERRABLE INITIALLY DEFERRED pour que la base de données vérifie les contraintes à la fin de la transaction. [[Deferable]]

Accepter des `NULL` temporairement pour casser le cycle.