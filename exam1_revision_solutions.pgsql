-- 1
-- SELECT prenom || ' ' || nom 
-- FROM utilisateurs AS u
-- WHERE u.id NOT IN (SELECT utilisateur_id FROM likes)
-- ORDER BY prenom ASC

-- 2
-- SELECT prenom || ' ' || nom 
-- FROM utilisateurs WHERE id IN (
-- SELECT photographe FROM photos WHERE categorie_id = 
-- 	(SELECT id FROM categories c WHERE nom = 'Portrait'))

-- 3
-- SELECT p.url, COALESCE(c.nom, 'aucun') 
-- FROM photos p
-- LEFT JOIN categories c ON p.categorie_id = c.id

-- 4
-- SELECT p.url, (SELECT COUNT(*) FROM likes l WHERE l.photo_id = p.id) AS nb_likes
-- FROM photos p;

-- 5
-- SELECT u.prenom, u.nom, COUNT(*) AS nb_photos
-- FROM utilisateurs u
-- JOIN photos p ON u.id = p.photographe
-- GROUP BY u.id, u.prenom, u.nom
-- HAVING COUNT(*) > 2;

-- 6
-- SELECT p.id, p.url, COALESCE(COUNT(l.id), 0) AS nb_likes
-- FROM photos p
-- LEFT JOIN likes l ON p.id = l.photo_id
-- GROUP BY p.id, p.url;

-- 7
-- SELECT p.url
-- FROM photos p
-- LEFT JOIN likes l ON p.id = l.photo_id
-- WHERE l.id IS NULL;

-- 8
-- SELECT c.nom AS categorie, COUNT(p.id) AS nb_photos
-- FROM categories c
-- LEFT JOIN photos p ON c.id = p.categorie_id
-- GROUP BY c.nom;

-- 9
-- SELECT u.prenom || ' ' || u.nom AS nom_complet, COUNT(*) AS nb_likes
-- FROM utilisateurs u
-- JOIN likes l ON u.id = l.utilisateur_id
-- GROUP BY nom_complet
-- ORDER BY nb_likes;

-- Version 2 sortira seulement celui ou ceux ayant le maximum de like
-- WITH user_likes AS (
--     SELECT u.prenom || ' ' || u.nom AS nom_complet, COUNT(*) AS nb_likes
--     FROM utilisateurs u
--     JOIN likes l ON u.id = l.utilisateur_id
--     GROUP BY u.prenom, u.nom
-- )
-- SELECT nom_complet, nb_likes
-- FROM user_likes
-- WHERE nb_likes = (SELECT MAX(nb_likes) FROM user_likes);

-- Version 3 sortira seulement celui ou ceux ayant le maximum de like
-- SELECT ul.nom_complet, ul.nb_likes
-- FROM (
--     SELECT u.prenom || ' ' || u.nom AS nom_complet, COUNT(*) AS nb_likes
--     FROM utilisateurs u
--     JOIN likes l ON u.id = l.utilisateur_id
--     GROUP BY nom_complet
-- ) AS ul
-- WHERE ul.nb_likes = (
--     SELECT MAX(sub.nb_likes)
--     FROM (
--         SELECT COUNT(*) AS nb_likes
--         FROM utilisateurs u2
--         JOIN likes l2 ON u2.id = l2.utilisateur_id
--         GROUP BY u2.id
--     ) AS sub
-- );

-- 10
-- SELECT c.nom AS categorie, COUNT(l.id) AS nb_likes
-- FROM categories c
-- LEFT JOIN photos p ON c.id = p.categorie_id
-- LEFT JOIN likes l ON p.id = l.photo_id
-- GROUP BY c.nom
-- ORDER BY nb_likes DESC;