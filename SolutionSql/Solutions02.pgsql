-- Série d'exercice 2.	
-- Analyse de requêtes simples


-- 2.1
-- INVALIDE
-- ---------------------------------------------------------------
-- Les crochets ne doivent pas être inscrits dans la commande. 
-- Dans la littérature, ils sont utilisés pour décrire la syntaxe 
-- des commandes à titre de partie optionnelle.

-- 2.2
-- INVALIDE
-- ---------------------------------------------------------------
-- On doit respecter l'ordre des clauses SQL (SELECT - FROM - WHERE). 

-- 2.3
-- INVALIDE
-- ---------------------------------------------------------------
-- La virgule est invalide. On pourrait la remplacer par les 
-- opérateurs AND, OR, ...

-- 2.4
-- VALIDE
-- ---------------------------------------------------------------

-- 2.5
-- VALIDE
-- ---------------------------------------------------------------

-- 2.6
-- INVALIDE
-- ---------------------------------------------------------------
-- Il manque le FROM qui est obligatoire l'identification 
-- de la source des colonnes.

-- 2.7
-- VALIDE / INVALIDE
-- ---------------------------------------------------------------
-- Cette requête est invalide avec plusieurs SGBD (dont Oracle). 
-- Elle est toutfois possible avec PostgreSQL.
--
-- Explication pour les SGBD où cette requête est impossible :
-- L'étoile inclue tout dans la requête et l'attribut nom n'est 
-- plus accepté. Néanmoins, il est possible de faire une telle 
-- requête en préfixant l'étoile par le nom de la table : employe.*

-- 2.8
-- VALIDE
-- ---------------------------------------------------------------
-- Cette requête est valide malgré son apparence. Toutefois, 
-- elle fait peu de sens et il est fort probable qu'elle 
-- corresponde à une erreur syntaxique où l'usage de la virgule 
-- a été oublié.

-- 2.9
-- VALIDE
-- ---------------------------------------------------------------

-- 2.10
-- VALIDE
-- ---------------------------------------------------------------
-- Cette requête est valide même si elle ne fait aucun sens réel. 
-- Elle ne correspond qu'à une suite d'opérations sur des valeurs 
-- numériques.
