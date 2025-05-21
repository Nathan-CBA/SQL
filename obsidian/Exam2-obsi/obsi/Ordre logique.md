**l’ordre logique** dans lequel tu dois créer tes tables pour **éviter les erreurs de dépendance immédiate**.

#### Exemple :

Tu veux créer deux tables avec une relation simple :

`CREATE TABLE departement (   
id SERIAL PRIMARY KEY
);  
CREATE TABLE employe (  
id SERIAL PRIMARY KEY,   
departement_id INTEGER REFERENCES departement(id) -- dépend de departement 
);`

 Ici, il faut **obligatoirement créer `departement` AVANT `employe`**, sinon tu auras une erreur, car `departement` n'existera pas encore.