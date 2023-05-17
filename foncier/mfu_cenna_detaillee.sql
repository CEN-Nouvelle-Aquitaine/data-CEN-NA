WITH mfu_actuelle AS (
SELECT  idparcelle, mfu, dateevenement, idevenement, rank FROM saisie.parcelle_mfu_bilan
JOIN (SELECT idparcelle AS idparc,max(dateevenement) AS maxdate FROM saisie.parcelle_mfu_bilan GROUP BY parcelle_mfu_bilan.idparcelle) max_date
    ON parcelle_mfu_bilan.idparcelle = max_date.idparc AND parcelle_mfu_bilan.dateevenement = max_date.maxdate
WHERE mfu = 'start')

SELECT ROW_NUMBER() over()::bigint as gid,
       p.idparcelle,
       commune.dpt as departement,
       p.commune as insee_commune,
       p.commune_ref as insee_commune_ref,
       commune.nom as nom_commmune,
       p.section,
       p.numero,
       CASE WHEN p.parcelle_partie = true THEN pp.contenance ELSE p.contenance END AS contenance,
       interet.libinteret,
       categorie.libcategorie AS categorie_mfu,
       statut.libstatut AS type_mfu,
       mfu_actuelle.dateevenement AS date_debut_mfu,
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
       CASE WHEN p.parcelle_mc = true THEN p.parcelle_mc ELSE false END AS parcelle_mc,
       CASE WHEN p.parcelle_partie = true THEN pp.geom ELSE p.geom END AS geom
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
LEFT JOIN saisie.lotdetail ld ON lot.idlot = ld.idlot AND mfu_actuelle.idevenement = ld.idevenement
ORDER BY p.idparcelle