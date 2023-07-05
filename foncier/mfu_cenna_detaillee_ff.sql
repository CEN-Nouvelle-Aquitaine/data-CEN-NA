WITH bilan_evenement AS (
 SELECT idparcelle, mfu,idevenement,rank
FROM
    ( SELECT idparcelle, mfu,idevenement,rank,rank() OVER (PARTITION BY idparcelle ORDER BY rank DESC) AS pos
          FROM saisie.parcelle_mfu_bilan) AS ranking
  WHERE pos = 1
),

bilan_date AS (
SELECT idparcelle,mfu,max(dateevenement) AS max_date,min(dateevenement)AS min_date,max(rank) AS max_rank
FROM saisie.parcelle_mfu_bilan pmb
GROUP BY idparcelle,mfu),

mfu_actuelle AS (
SELECT ranking.idparcelle, ranking.mfu,max_date, min_date, max_rank, be.idevenement
FROM
  (SELECT idparcelle, mfu, max_date, min_date, max_rank,
          rank() OVER (PARTITION BY idparcelle ORDER BY max_rank DESC) AS pos
     FROM bilan_date
  ) AS ranking
JOIN bilan_evenement be ON be.idparcelle = ranking.idparcelle
WHERE pos = 1 AND ranking.mfu = 'start')

SELECT ROW_NUMBER() over()::bigint as gid,
       p.idparcelle,
       commune.dpt as departement,
       p.commune as insee_commune,
       p.commune_ref as insee_commune_ref,
       commune.nom as nom_commmune,
       p.section,
       p.numero,
       CASE WHEN p.parcelle_partie = true THEN pp.contenance WHEN p.parcelle_bnd = true THEN pp.contenance ELSE p.contenance END AS contenance,
       interet.libinteret,
       categorie.libcategorie AS categorie_mfu,
       statut.libstatut AS type_mfu,
       mfu_actuelle.min_date AS date_debut_mfu,
       site.codesite,
       site.nom_site,
       metasite.code_metasite,
       metasite.nom_metasite,
       ld.datestart AS date_debut_convention,
       ld.dateend AS date_fin_convention,
       ld.reconductibilite AS reconductibilite_convention,
       p.idaire AS idaire,
       aire.libaire AS lib_aire,
       dossier.libdossier,
       habitat.libhabitat,
       peb.idevenement AS last_idevenement,
       peb.libevenement AS last_libevenement,
       peb.dateevenement AS last_dateevenement,
       users.lastname || ' ' || users.firstname AS utilisateur,
       p.millesime AS millesime_cadastre,
	   CASE WHEN p.parcelle_ajout = true THEN 'DSI CEN-NA' WHEN p.parcelle_partie = true THEN 'DSI CEN-NA' ELSE 'Cadastre Etalab' END AS source_cadastre,
       CASE WHEN p.parcelle_partie = true THEN p.parcelle_partie ELSE false END AS parcelle_partie,
       CASE WHEN p.parcelle_bnd = true THEN p.parcelle_bnd ELSE false END AS parcelle_bnd,
       CASE WHEN p.parcelle_mc = true THEN p.parcelle_mc ELSE false END AS parcelle_mc,
       ptp.catpro2txt AS type_pro_2,
       ptp.catpro3txt AS type_pro_3,
       ptp.ccodrotxt AS lib_droit,
       ptp.typedroit AS type_droit,
       ptp.ccodemtxt AS lib_demembrement,
       ptp.ddenom AS nom_proprietaire,
       ptp.jdatatv::timestamp AS date_acte,
       ptp.ff_millesime,
       ptp.fcen_typprop_id,
       ptp.fcen_typprop_det,
       CASE WHEN p.parcelle_partie = true THEN pp.geom WHEN p.parcelle_bnd = true THEN pp.geom ELSE p.geom END AS geom

FROM saisie.parcelle p
JOIN mfu_actuelle ON mfu_actuelle.idparcelle = p.idparcelle
JOIN referentiel.commune ON commune.idcommune = p.commune_ref
JOIN referentiel.interet ON p.idinteret = interet.idinteret
JOIN referentiel.evenement ON mfu_actuelle.idevenement = evenement.idevenement
JOIN referentiel.statut ON evenement.idstatut = statut.idstatut
JOIN referentiel.categorie ON statut.idcategorie = categorie.idcategorie
LEFT JOIN saisie.site ON p.idsite = site.idsite
LEFT JOIN saisie.metasite ON site.idmetasite = metasite.idmetasite
LEFT JOIN referentiel.aire ON p.idaire = aire.idaire
LEFT JOIN saisie.parcelle_partie pp ON p.idparcelle = pp.idparcelle
JOIN referentiel.dossier ON p.iddossier = dossier.iddossier
JOIN referentiel.habitat ON p.idhabitat = habitat.idhabitat
JOIN saisie.parcelle_evenement_bilan peb ON peb.idparcelle = p.idparcelle
JOIN users ON peb.iduser = users.id
LEFT JOIN saisie.lot ON p.idlot = lot.idlot
LEFT JOIN saisie.lotdetail_bilan ld ON lot.idlot = ld.idlot AND mfu_actuelle.idevenement = ld.idevenement
LEFT JOIN saisie.parcelle_type_pro ptp ON p.idparcelle = ptp.idparcelle
ORDER BY p.idparcelle