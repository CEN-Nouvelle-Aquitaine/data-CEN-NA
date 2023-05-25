--Surface totale en maîtrise foncière ou d'usage par le CEN Nouvelle-Aquitaine (visualisation de type Counter)


WITH mfu_date AS (
        SELECT idparcelle, mfu, dateevenement, idevenement, rank
        FROM saisie.parcelle_mfu_bilan
                 JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                       FROM saisie.parcelle_mfu_bilan
                       WHERE mfu = 'start' AND dateevenement <= '{{datemax_mfu}}'
                       GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                      ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                         parcelle_mfu_bilan.dateevenement = max_date.maxdate

          AND idparcelle NOT IN
              (SELECT idparcelle
               FROM saisie.parcelle_mfu_bilan
                        JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                              FROM saisie.parcelle_mfu_bilan
                              WHERE mfu = 'end'AND dateevenement <= '{{datemax_mfu}}'
                              GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                             ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                                parcelle_mfu_bilan.dateevenement = max_date.maxdate)),

bilan_parcelle AS (

SELECT commune.dpt,CASE WHEN parcelle.parcelle_partie = true THEN pp.contenance WHEN parcelle.parcelle_bnd = true THEN pp.contenance ELSE parcelle.contenance END AS contenance,
       mfu_date.idevenement, evenement.libevenement,statut.idstatut,statut.libstatut,categorie.idcategorie,categorie.libcategorie
    FROM mfu_date
JOIN saisie.parcelle ON mfu_date.idparcelle = parcelle.idparcelle
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.evenement ON mfu_date.idevenement = evenement.idevenement
JOIN referentiel.statut ON evenement.idstatut = statut.idstatut
JOIN referentiel.categorie ON statut.idcategorie = categorie.idcategorie

LEFT JOIN saisie.parcelle_partie pp ON parcelle.idparcelle = pp.idparcelle)

SELECT contenance::numeric/10000::numeric AS surface,libcategorie AS "categorie mfu",dpt AS département
FROM bilan_parcelle
WHERE idcategorie IN (8,10,13,14)
ORDER BY dpt

-- Nombre de sites gérés (visualisation de type counter)

 WITH mfu_date AS (
        SELECT idparcelle, mfu, dateevenement, idevenement, rank
        FROM saisie.parcelle_mfu_bilan
                 JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                       FROM saisie.parcelle_mfu_bilan
                       WHERE mfu = 'start' AND dateevenement <= '{{datemax_mfu}}'
                       GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                      ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                         parcelle_mfu_bilan.dateevenement = max_date.maxdate

          AND idparcelle NOT IN
              (SELECT idparcelle
               FROM saisie.parcelle_mfu_bilan
                        JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                              FROM saisie.parcelle_mfu_bilan
                              WHERE mfu = 'end'AND dateevenement <= '{{datemax_mfu}}'
                              GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                             ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                                parcelle_mfu_bilan.dateevenement = max_date.maxdate)),

bilan_parcelle AS (

SELECT left(site.codesite,2) AS dpt,parcelle.idsite
    FROM mfu_date
JOIN saisie.parcelle ON mfu_date.idparcelle = parcelle.idparcelle
JOIN saisie.site ON site.idsite = parcelle.idsite
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune )


SELECT idsite,dpt
FROM bilan_parcelle
GROUP BY dpt,idsite


-- Bilan des surfaces en maîtrise foncière ou d'usage par département (visualisation de type Pivot table)

WITH mfu_date AS (
        SELECT idparcelle, mfu, dateevenement, idevenement, rank
        FROM saisie.parcelle_mfu_bilan
                 JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                       FROM saisie.parcelle_mfu_bilan
                       WHERE mfu = 'start' AND dateevenement <= '{{datemax_mfu}}'
                       GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                      ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                         parcelle_mfu_bilan.dateevenement = max_date.maxdate

          AND idparcelle NOT IN
              (SELECT idparcelle
               FROM saisie.parcelle_mfu_bilan
                        JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                              FROM saisie.parcelle_mfu_bilan
                              WHERE mfu = 'end'AND dateevenement <= '{{datemax_mfu}}'
                              GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                             ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                                parcelle_mfu_bilan.dateevenement = max_date.maxdate)),

bilan_parcelle AS (

SELECT commune.dpt,CASE WHEN parcelle.parcelle_partie = true THEN pp.contenance WHEN parcelle.parcelle_bnd = true THEN pp.contenance ELSE parcelle.contenance END AS contenance,
       mfu_date.idevenement, evenement.libevenement,statut.idstatut,statut.libstatut,categorie.idcategorie,categorie.libcategorie
    FROM mfu_date
JOIN saisie.parcelle ON mfu_date.idparcelle = parcelle.idparcelle
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.evenement ON mfu_date.idevenement = evenement.idevenement
JOIN referentiel.statut ON evenement.idstatut = statut.idstatut
JOIN referentiel.categorie ON statut.idcategorie = categorie.idcategorie

LEFT JOIN saisie.parcelle_partie pp ON parcelle.idparcelle = pp.idparcelle)

SELECT contenance::numeric/10000::numeric AS surface,libcategorie AS "categorie mfu",dpt AS département
FROM bilan_parcelle
WHERE idcategorie IN (8,10,13,14)
ORDER BY dpt


--Surface totale en maîtrise foncière par le CEN Nouvelle-Aquitaine (visualisation de type Counter)

WITH mfu_date AS (
        SELECT idparcelle, mfu, dateevenement, idevenement, rank
        FROM saisie.parcelle_mfu_bilan
                 JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                       FROM saisie.parcelle_mfu_bilan
                       WHERE mfu = 'start' AND dateevenement <= '{{datemax_mfu}}'
                       GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                      ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                         parcelle_mfu_bilan.dateevenement = max_date.maxdate

          AND idparcelle NOT IN
              (SELECT idparcelle
               FROM saisie.parcelle_mfu_bilan
                        JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                              FROM saisie.parcelle_mfu_bilan
                              WHERE mfu = 'end'AND dateevenement <= '{{datemax_mfu}}'
                              GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                             ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                                parcelle_mfu_bilan.dateevenement = max_date.maxdate)),

bilan_parcelle AS (

SELECT commune.dpt,CASE WHEN parcelle.parcelle_partie = true THEN pp.contenance WHEN parcelle.parcelle_bnd = true THEN pp.contenance ELSE parcelle.contenance END AS contenance,
       mfu_date.idevenement, evenement.libevenement,statut.idstatut,statut.libstatut,categorie.idcategorie,categorie.libcategorie
    FROM mfu_date
JOIN saisie.parcelle ON mfu_date.idparcelle = parcelle.idparcelle
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.evenement ON mfu_date.idevenement = evenement.idevenement
JOIN referentiel.statut ON evenement.idstatut = statut.idstatut
JOIN referentiel.categorie ON statut.idcategorie = categorie.idcategorie

LEFT JOIN saisie.parcelle_partie pp ON parcelle.idparcelle = pp.idparcelle)

SELECT sum(contenance)/10000::numeric AS surface FROM bilan_parcelle bp
WHERE idcategorie = 8
GROUP BY idcategorie
ORDER BY idcategorie


-- Bilan des surfaces en maîtrise foncière par département (visualisation de type Pivot table)

WITH mfu_date AS (
        SELECT idparcelle, mfu, dateevenement, idevenement, rank
        FROM saisie.parcelle_mfu_bilan
                 JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                       FROM saisie.parcelle_mfu_bilan
                       WHERE mfu = 'start' AND dateevenement <= '{{datemax_mfu}}'
                       GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                      ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                         parcelle_mfu_bilan.dateevenement = max_date.maxdate

          AND idparcelle NOT IN
              (SELECT idparcelle
               FROM saisie.parcelle_mfu_bilan
                        JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                              FROM saisie.parcelle_mfu_bilan
                              WHERE mfu = 'end'AND dateevenement <= '{{datemax_mfu}}'
                              GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                             ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                                parcelle_mfu_bilan.dateevenement = max_date.maxdate)),

bilan_parcelle AS (

SELECT commune.dpt,CASE WHEN parcelle.parcelle_partie = true THEN pp.contenance WHEN parcelle.parcelle_bnd = true THEN pp.contenance ELSE parcelle.contenance END AS contenance,
       mfu_date.idevenement, evenement.libevenement,statut.idstatut,statut.libstatut,categorie.idcategorie,categorie.libcategorie
    FROM mfu_date
JOIN saisie.parcelle ON mfu_date.idparcelle = parcelle.idparcelle
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.evenement ON mfu_date.idevenement = evenement.idevenement
JOIN referentiel.statut ON evenement.idstatut = statut.idstatut
JOIN referentiel.categorie ON statut.idcategorie = categorie.idcategorie

LEFT JOIN saisie.parcelle_partie pp ON parcelle.idparcelle = pp.idparcelle)

SELECT contenance::numeric/10000::numeric AS surface,libstatut AS "type maîtrise",dpt AS département
FROM bilan_parcelle
WHERE idcategorie = 8
ORDER BY libstatut

-- Type de maîtrise foncière (visualisation de type Chart)

WITH mfu_date AS (
        SELECT idparcelle, mfu, dateevenement, idevenement, rank
        FROM saisie.parcelle_mfu_bilan
                 JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                       FROM saisie.parcelle_mfu_bilan
                       WHERE mfu = 'start' AND dateevenement <= '{{datemax_mfu}}'
                       GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                      ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                         parcelle_mfu_bilan.dateevenement = max_date.maxdate

          AND idparcelle NOT IN
              (SELECT idparcelle
               FROM saisie.parcelle_mfu_bilan
                        JOIN (SELECT idparcelle AS idparc, max(dateevenement) AS maxdate
                              FROM saisie.parcelle_mfu_bilan
                              WHERE mfu = 'end'AND dateevenement <= '{{datemax_mfu}}'
                              GROUP BY parcelle_mfu_bilan.idparcelle) max_date
                             ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND
                                parcelle_mfu_bilan.dateevenement = max_date.maxdate)),

bilan_parcelle AS (

SELECT commune.dpt,CASE WHEN parcelle.parcelle_partie = true THEN pp.contenance WHEN parcelle.parcelle_bnd = true THEN pp.contenance ELSE parcelle.contenance END AS contenance,
       mfu_date.idevenement, evenement.libevenement,statut.idstatut,statut.libstatut,categorie.idcategorie,categorie.libcategorie
    FROM mfu_date
JOIN saisie.parcelle ON mfu_date.idparcelle = parcelle.idparcelle
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.evenement ON mfu_date.idevenement = evenement.idevenement
JOIN referentiel.statut ON evenement.idstatut = statut.idstatut
JOIN referentiel.categorie ON statut.idcategorie = categorie.idcategorie

LEFT JOIN saisie.parcelle_partie pp ON parcelle.idparcelle = pp.idparcelle)

SELECT sum(contenance::numeric/10000::numeric) AS surface,libstatut AS "type maîtrise"
FROM bilan_parcelle
WHERE idcategorie IN (8)
GROUP BY libstatut
ORDER BY libstatut
