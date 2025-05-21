## Format de date et timestamp

- **Date** : généralement au format `'YYYY-MM-DD'`
    
- **Timestamp** (date + heure) : `'YYYY-MM-DD hh:mm:ss'` (exemple : `'2025-05-20 14:30:00'`)
    

---

## 2. Insertion simple d’une date ou d’un timestamp

### Exemple avec une colonne `date_col` de type DATE :


`INSERT INTO ma_table (date_col) VALUES ('2025-05-20');`

### Exemple avec une colonne `timestamp_col` de type TIMESTAMP :



`INSERT INTO ma_table (timestamp_col) VALUES ('2025-05-20 14:30:00');`

---

## 3. Conversion explicite avec CAST ou TO_TIMESTAMP (selon SGBD)

- PostgreSQL :

    
    `INSERT INTO ma_table (timestamp_col) VALUES (TO_TIMESTAMP('2025-05-20 14:30:00', 'YYYY-MM-DD HH24:MI:SS'));`
    
- SQL standard (CAST) :
    
    
    `INSERT INTO ma_table (timestamp_col) VALUES (CAST('2025-05-20 14:30:00' AS TIMESTAMP));`
    

---

## 4. Lecture de date ou timestamp

Pour afficher dans ce format, tu peux utiliser la fonction `TO_CHAR` en PostgreSQL :

`SELECT TO_CHAR(timestamp_col, 'YYYY-MM-DD HH24:MI:SS') FROM ma_table;`

---

## Points importants :

- Le format `'YYYY-MM-DD hh:mm:ss'` est standard en SQL pour les timestamps.
    
- L’heure doit être en 24h (HH24).
    
- Les SGBD acceptent souvent la chaîne en format texte sans conversion explicite.
    
- Si besoin, CAST ou fonction TO_TIMESTAMP garantit le bon format.
- 
- `HH24` correspond à l’heure en **format 24 heures** (de 00 à 23) — c’est le plus courant et recommandé pour éviter les ambiguïtés.
    
- `HH` (ou parfois `HH12`) correspond à l’heure en **format 12 heures** (de 01 à 12), ce qui nécessite souvent un indicateur AM/PM pour être précis.

-- pour etre plus précis en format 12 heures - PM/AM
SELECT TO_TIMESTAMP('2025-05-20 02:30:00 PM', 'YYYY-MM-DD HH:MI:SS PM'); 

