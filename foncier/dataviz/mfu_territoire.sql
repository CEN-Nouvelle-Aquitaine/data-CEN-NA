-- Surface totale en maîtrise foncière ou d'usage (visualisation de type Counter)

    WITH mfu_actuelle AS (
    SELECT  idparcelle, mfu, dateevenement, idevenement, rank FROM saisie.parcelle_mfu_bilan
    JOIN (SELECT idparcelle AS idparc,max(dateevenement) AS maxdate FROM saisie.parcelle_mfu_bilan GROUP BY parcelle_mfu_bilan.idparcelle) max_date
        ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND parcelle_mfu_bilan.dateevenement = max_date.maxdate
    WHERE mfu = 'start'),

bilan_parcelle AS (

SELECT commune.idterritoire, CASE WHEN parcelle.parcelle_partie = true THEN pp.contenance WHEN parcelle.parcelle_bnd = true THEN pp.contenance ELSE parcelle.contenance END AS contenance,
       mfu_actuelle.idevenement, evenement.libevenement,statut.idstatut,statut.libstatut,categorie.idcategorie,categorie.libcategorie
    FROM mfu_actuelle
JOIN saisie.parcelle ON mfu_actuelle.idparcelle = parcelle.idparcelle
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.territoire ON commune.idterritoire = territoire.idterritoire
JOIN referentiel.evenement ON mfu_actuelle.idevenement = evenement.idevenement
JOIN referentiel.statut ON evenement.idstatut = statut.idstatut
JOIN referentiel.categorie ON statut.idcategorie = categorie.idcategorie

LEFT JOIN saisie.parcelle_partie pp ON parcelle.idparcelle = pp.idparcelle)

SELECT sum(contenance)/10000::numeric AS surface
FROM bilan_parcelle bp
WHERE idterritoire = {{ territoire_unique }}
GROUP BY idterritoire
ORDER BY idterritoire

-- Bilan des surfaces en maîtrise foncière ou d'usage (visualisation de type Pivot Table)

    WITH mfu_actuelle AS (
    SELECT  idparcelle, mfu, dateevenement, idevenement, rank FROM saisie.parcelle_mfu_bilan
    JOIN (SELECT idparcelle AS idparc,max(dateevenement) AS maxdate FROM saisie.parcelle_mfu_bilan GROUP BY parcelle_mfu_bilan.idparcelle) max_date
        ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND parcelle_mfu_bilan.dateevenement = max_date.maxdate
    WHERE mfu = 'start'),

bilan_parcelle AS (

SELECT territoire.libterritoire,commune.idterritoire,CASE WHEN parcelle.parcelle_partie = true THEN pp.contenance WHEN parcelle.parcelle_bnd = true THEN pp.contenance ELSE parcelle.contenance END AS contenance,
       mfu_actuelle.idevenement, evenement.libevenement,statut.idstatut,statut.libstatut,categorie.idcategorie,categorie.libcategorie,
        CASE WHEN (parcelle.iddossier != 3 AND dossier.mc = true) THEN 'MC' WHEN parcelle.iddossier = 3 THEN 'Néo Terra' ELSE 'Autre' END AS dossier
    FROM mfu_actuelle
JOIN saisie.parcelle ON mfu_actuelle.idparcelle = parcelle.idparcelle
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.territoire ON commune.idterritoire = territoire.idterritoire
JOIN referentiel.evenement ON mfu_actuelle.idevenement = evenement.idevenement
JOIN referentiel.statut ON evenement.idstatut = statut.idstatut
JOIN referentiel.categorie ON statut.idcategorie = categorie.idcategorie
JOIN referentiel.dossier ON parcelle.iddossier = dossier.iddossier

LEFT JOIN saisie.parcelle_partie pp ON parcelle.idparcelle = pp.idparcelle)

SELECT contenance::numeric/10000::numeric AS surface,libstatut AS "type maîtrise", libterritoire AS territoire, dossier
FROM bilan_parcelle
WHERE idterritoire = {{ territoire_unique }}
ORDER BY libstatut


--Nombre de sites gérés (visualisation de type Counter)

 WITH mfu_actuelle AS (
 SELECT  idparcelle, mfu, dateevenement, idevenement, rank FROM saisie.parcelle_mfu_bilan
JOIN (SELECT idparcelle AS idparc,max(dateevenement) AS maxdate FROM saisie.parcelle_mfu_bilan GROUP BY parcelle_mfu_bilan.idparcelle) max_date
ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND parcelle_mfu_bilan.dateevenement = max_date.maxdate
WHERE mfu = 'start'),

bilan_parcelle AS (

SELECT commune.idterritoire,parcelle.idsite
FROM mfu_actuelle
JOIN saisie.parcelle ON mfu_actuelle.idparcelle = parcelle.idparcelle
JOIN saisie.site ON site.idsite = parcelle.idsite
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.territoire ON commune.idterritoire = territoire.idterritoire )

SELECT idsite,idterritoire
FROM bilan_parcelle
WHERE idterritoire = {{ territoire_unique }} 
GROUP BY idterritoire,idsite


--Localisation des parcelles gérées (visualisation de type Map (Markers))

WITH mfu_actuelle AS (
 SELECT  idparcelle, mfu, dateevenement, idevenement, rank FROM saisie.parcelle_mfu_bilan
JOIN (SELECT idparcelle AS idparc,max(dateevenement) AS maxdate FROM saisie.parcelle_mfu_bilan GROUP BY parcelle_mfu_bilan.idparcelle) max_date
ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND parcelle_mfu_bilan.dateevenement = max_date.maxdate
WHERE mfu = 'start'),

bilan_parcelle AS (

SELECT commune.idterritoire,parcelle.idsite,site.nom_site,site.codesite,parcelle.idparcelle,
CASE WHEN parcelle.parcelle_partie = true THEN pp.contenance ELSE parcelle.contenance END AS contenance,
CASE WHEN parcelle.parcelle_partie = true THEN pp.geom ELSE parcelle.geom END AS geom
FROM mfu_actuelle
JOIN saisie.parcelle ON mfu_actuelle.idparcelle = parcelle.idparcelle
LEFT JOIN saisie.parcelle_partie pp ON parcelle.idparcelle = pp.idparcelle
LEFT JOIN saisie.site ON site.idsite = parcelle.idsite
LEFT JOIN saisie.site_dates ON site_dates.idsite = parcelle.idsite
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.territoire ON commune.idterritoire = territoire.idterritoire )


SELECT CASE WHEN bilan_parcelle.idsite IS NULL THEN 'Parcelle non rattachée' ELSE 'Parcelle rattachée' END AS rattachement_site,bilan_parcelle.idparcelle,
CASE WHEN bilan_parcelle.codesite IS NULL THEN bilan_parcelle.idparcelle ELSE bilan_parcelle.codesite END AS codesite, bilan_parcelle.nom_site,
st_X(st_centroid(geom)) as x,st_y(st_centroid(geom)) as y,sum(contenance)/10000::numeric as contenance
FROM bilan_parcelle
WHERE idterritoire = {{ territoire_unique }} 
GROUP BY bilan_parcelle.idsite,bilan_parcelle.codesite,bilan_parcelle.idparcelle,bilan_parcelle.nom_site,st_X(st_centroid(geom)),st_y(st_centroid(geom))


-- Liste des sites gérés (visualisation de type Table)

WITH mfu_actuelle AS (
 SELECT  idparcelle, mfu, dateevenement, idevenement, rank FROM saisie.parcelle_mfu_bilan
JOIN (SELECT idparcelle AS idparc,max(dateevenement) AS maxdate FROM saisie.parcelle_mfu_bilan GROUP BY parcelle_mfu_bilan.idparcelle) max_date
ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND parcelle_mfu_bilan.dateevenement = max_date.maxdate
WHERE mfu = 'start'),

bilan_parcelle AS (

SELECT commune.idterritoire,parcelle.idsite,site.nom_site,site.codesite,site.idsite_fcen,site.idsite_inpn,site_dates.date_premiere_mfu,site_dates.date_derniere_mfu,f_type_milieu.libelle_type_milieu
FROM mfu_actuelle
JOIN saisie.parcelle ON mfu_actuelle.idparcelle = parcelle.idparcelle
JOIN saisie.site ON site.idsite = parcelle.idsite
JOIN saisie.site_dates ON site_dates.idsite = parcelle.idsite
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.territoire ON commune.idterritoire = territoire.idterritoire
LEFT JOIN referentiel.f_type_milieu ON site.idmilieu = f_type_milieu.id_type_milieu )

SELECT nom_site,codesite,libelle_type_milieu AS "Typologie milieu FCEN", date_premiere_mfu,date_derniere_mfu,idsite_fcen,idsite_inpn
FROM bilan_parcelle
WHERE idterritoire = {{ territoire_unique }} 
GROUP BY nom_site,codesite,libelle_type_milieu,idsite_fcen,idsite_inpn,date_premiere_mfu,date_derniere_mfu


--Bilan des surfaces en maîtrise foncière ou d'usage par site (visualisation de type Pivot Table)

WITH mfu_actuelle AS (
 SELECT  idparcelle, mfu, dateevenement, idevenement, rank FROM saisie.parcelle_mfu_bilan
JOIN (SELECT idparcelle AS idparc,max(dateevenement) AS maxdate FROM saisie.parcelle_mfu_bilan GROUP BY parcelle_mfu_bilan.idparcelle) max_date
ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND parcelle_mfu_bilan.dateevenement = max_date.maxdate
WHERE mfu = 'start'),

bilan_parcelle AS (

SELECT commune.idterritoire,parcelle.idsite,site.nom_site,site.codesite,CASE WHEN parcelle.parcelle_partie = true THEN pp.contenance WHEN parcelle.parcelle_bnd = true THEN pp.contenance ELSE parcelle.contenance END AS contenance,
statut.libstatut,site.idsite_fcen,site.idsite_inpn,site_dates.date_premiere_mfu,site_dates.date_derniere_mfu
FROM mfu_actuelle
JOIN saisie.parcelle ON mfu_actuelle.idparcelle = parcelle.idparcelle
JOIN saisie.site ON site.idsite = parcelle.idsite
JOIN saisie.site_dates ON site_dates.idsite = parcelle.idsite
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.evenement ON mfu_actuelle.idevenement = evenement.idevenement
JOIN referentiel.statut ON evenement.idstatut = statut.idstatut
JOIN referentiel.categorie ON statut.idcategorie = categorie.idcategorie
JOIN referentiel.territoire ON commune.idterritoire = territoire.idterritoire
LEFT JOIN saisie.parcelle_partie pp ON parcelle.idparcelle = pp.idparcelle)

SELECT nom_site,codesite,libstatut,contenance::numeric/10000::numeric AS surface
FROM bilan_parcelle
WHERE idterritoire = {{ territoire_unique }}


-- Evolution annuelle de la surface acquise (visualisation de type Chart)

WITH acqui AS (
SELECT * FROM saisie.parcelle_mfu_bilan
JOIN (SELECT idparcelle AS idparc,max(dateevenement) AS maxdate FROM saisie.parcelle_mfu_bilan GROUP BY parcelle_mfu_bilan.idparcelle) max_date
    ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND parcelle_mfu_bilan.dateevenement = max_date.maxdate
JOIN saisie.parcelle ON parcelle_mfu_bilan.idparcelle = parcelle.idparcelle
JOIN referentiel.evenement ON parcelle_mfu_bilan.idevenement = evenement.idevenement
JOIN referentiel.statut ON evenement.idstatut = statut.idstatut
JOIN referentiel.categorie ON statut.idcategorie = categorie.idcategorie
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.territoire ON commune.idterritoire = territoire.idterritoire
WHERE parcelle_mfu_bilan.mfu = 'start' AND statut.idstatut = 12 AND commune.idterritoire = {{ territoire_unique }}) ,
bilan_annee AS (
SELECT extract(year from dateevenement ) AS annee, sum(contenance)/10000::numeric AS contenance
FROM acqui
GROUP BY extract(year from dateevenement )
ORDER BY annee),
total AS (
SELECT annee, contenance, sum(contenance) OVER(ORDER BY annee) AS surf_cumul
FROM bilan_annee
ORDER BY 1)


SELECT annee,contenance AS surf_acquise,surf_cumul,surf_cumul - contenance AS old_contenance
FROM total


-- Evolution annuelle du nombre de sites gérés (visualisation de type Chart)

WITH min_mfu AS (
SELECT parcelle.idsite, extract(year from dateevenement) AS annee, commune.idterritoire FROM saisie.parcelle_mfu_bilan pmb
JOIN saisie.parcelle ON pmb.idparcelle = parcelle.idparcelle
JOIN referentiel.commune ON parcelle.commune_ref = commune.idcommune
JOIN referentiel.territoire ON commune.idterritoire = territoire.idterritoire
WHERE pmb.mfu = 'start' AND parcelle.idsite IS NOT NULL
GROUP BY parcelle.idsite, pmb.dateevenement, commune.idterritoire
ORDER BY parcelle.idsite, pmb.dateevenement ),
min_mfu_site AS (
SELECT idsite, idterritoire, min(annee) AS annee FROM min_mfu
GROUP BY idsite, idterritoire
ORDER BY idsite),
bilan_annee AS (
SELECT annee, idterritoire, count(idsite) as nb_newsite
FROM min_mfu_site
GROUP BY annee,idterritoire
ORDER BY annee),
bilan_cumul AS (
SELECT annee, nb_newsite,sum(nb_newsite) OVER(ORDER BY annee) AS nb_cumul
FROM bilan_annee
WHERE idterritoire = {{ territoire_unique }})

SELECT annee, nb_newsite, nb_cumul, nb_cumul - nb_newsite AS oldsite FROM bilan_cumul

ORDER BY 1