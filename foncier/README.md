# Foncier

Le CEN est amené à maîtriser une parcelle par **maîtrise foncière** (achat ou bail emphytéotique), **maîtrise d'usage** (convention de gestion, bail, ORE, etc.) afin d'y mettre en place une gestion écologique prenant en compte les enjeux du site.

Le CEN Nouvelle-Aquitaine a développé l'application web **FoncierCEN** qui permet de consigner dans une base de données (*PostgreSQL/PostGIS*) toutes les informations relatives à l'animation foncière réalisée par ses salariés.

Ces informations sont facilement mobilisables en SQL et interprétables par un serveur web cartographique (*Geoserver*) afin de véhiculer en temps réel des données métier qualitatives :

- Parcelles cadastrales en Maîtrise Foncière ou d'Usage (MFU) par le CEN Nouvelle-Aquitaine
- Sites gérés par le CEN Nouvelle-Aquitaine

<br>

Les données métier Foncier du CEN Nouvelle-Aquitaine sont disponible en open-data sous forme de web service vecteur (WFS) avec les renseignements essentiels associés :

```
https://opendata.cen-nouvelle-aquitaine.org/partage/wfs
```
<br>

----

<br>


Le référentiel cadastral utilisé (géométrie,identifiant,contenance) est celui distibué par [Etalab](https://cadastre.data.gouv.fr/datasets/cadastre-etalab) et mis à jour trimestriellement.

Ce référentiel peut cependant être contourné et faire l'objet d'une numérisation manuelle dans les cas suivants :

* Maîtrise par le CEN d'une partie de parcelle (dans le cas d'un conventionnement) : la géométrie et la contenance maîtrisées de la partie de parcelle concernée sont stockées dans une table spécifique de la base de données. 

* Maîtrise par le CEN d'un bien non délimité (BND) : la contenance maîtrisée de la parcelle concernée ainsi que la géométrie initiale sont stockées dans une table spécifique de la base de données (la géométrie de la parcelle n'est pas modifiée s'agissant d'un bien non délimité)

* Division parcellaire récente : lors de l'achat par le CEN d'une parcelle,  il peut arriver qu'une division parcellaire soit opérée. La remontée de cette modification dans le référentiel pouvant être longue, une modification temporaire du référentiel est donc effectuée manuellement sur la base du document d'arpentage d'un géomètre expert précisant le nouvel identifiant et la nouvelle contenance des parcelles impactées.

<br>

-----

<br>

## Parcelles en maîtrise foncière ou d'usage par le CEN Nouvelle-Aquitaine

<br>

### Contexte

<br>


Une parcelle peut contenir plusieurs événéments d'animation foncière impactant la MFU dont voici quelques exemples parmi d'autres à prendre en compte :

* une parcelle à été conventionnée puis la convention a été renouvellée (2 événéments de type start)
* une parcelle à été conventionnée puis la convention a été résiliée (1 événement de type start et 1 événément de type end)
* une parcelle a été achetée puis renvendue (1 événement de type start et 1 événément de type end)
* une parcelle a été conventionnée, la convention a été renouvelée puis ensuite achetée (3 événements de type start)

<br>

### Récupération des informations dans FoncierCEN

<br>

Dans FoncierCEN, les événéments d'animation foncière sont consignés dans la table *saisie.parcelle_evenement*. Selon le dernier évenement rattaché à une parcelle, on ne pourra saisir que les événements fils de l'évenement parent en cours selon le **logigramme des événements d'animation foncière**.

En fin de logigramme, les  évenements sont caractérisés par le fait de passer la parcelle en MFU ou bien au contraire de stopper la MFU. Afin de repérer ces évenements, le dictionnaire des événements *referentiel.evenement* stocke en plus du nom le type d'action lié à la MFU (*start* pour le début de la MFU ou *end* pour la fin).

Dès qu'un événément impactant la MFU sur une parcelle est intégré, supprimé ou mis à jour, un trigger est lancé afin de mettre à jour la table *saisie.parcelle_mfu_bilan* qui permet de consigner pour chaque parcelle tous les événéments impactant la MFU et de les classer selon leur date. Cette table bilan va permettre d'optimiser le temps total d'éxécution de la récupération des parcelles en MFU.

Pour récupérer les parcelles en MFU et prendre en compte tous les cas de figures énoncés juste avant, on va interroger cette table saisie.parcelle_mfu_bilan pour :

* récupérer par parcelle et par action de MFU (start ou end) le dernier événément saisi
* récupérer par parcelle et par action de MFU (start ou end) les dates et rangs maximaux et minimaux
* filtrer en ne gardant uniquement que les parcelles dont la dernière action de MFU est de type start

```sql
--1/ Récupération par parcelle et par mfu du dernier évenement

WITH bilan_evenement AS (
 SELECT idparcelle, mfu,idevenement,rank
FROM
    ( SELECT idparcelle, mfu,idevenement,rank,rank() OVER (PARTITION BY idparcelle ORDER BY rank DESC) AS pos
          FROM saisie.parcelle_mfu_bilan) AS ranking
  WHERE pos = 1
),

--2/ Récupération par parcelle et par mfu des dates et rangs minimaux et maximaux

bilan_date AS (
SELECT idparcelle,mfu,max(dateevenement) AS max_date,min(dateevenement)AS min_date,max(rank) AS max_rank
FROM saisie.parcelle_mfu_bilan pmb
GROUP BY idparcelle,mfu),


--3/ Récupération des parcelles ACTUELLEMENT en MFU à partir de bilan date (jointure avec bilan_evenement pour récupérer l'idevenement associé) : on ne garde que les parcelles dont la mfu de l'événenement le plus récent est de type start

mfu_actuelle AS (
SELECT ranking.idparcelle, ranking.mfu,max_date, min_date, max_rank, be.idevenement
FROM
  (SELECT idparcelle, mfu, max_date, min_date, max_rank,
          rank() OVER (PARTITION BY idparcelle ORDER BY max_rank DESC) AS pos
     FROM bilan_date
  ) AS ranking
JOIN bilan_evenement be ON be.idparcelle = ranking.idparcelle
WHERE pos = 1 AND ranking.mfu = 'start')


--3 variante/ Récupération des parcelles en MFU A UNE DATE DONNEE (exemple au 31/12/2022) à partir de bilan date (jointure avec bilan_evenement pour récupérer l'idevenement associé) : on ne garde que les parcelles dont la mfu de l'événenement le plus ancien est de type start et plus récent que la date choisie

mfu_date AS (
SELECT ranking.idparcelle, ranking.mfu,max_date, min_date, max_rank, be.idevenement
FROM
  (SELECT idparcelle, mfu, max_date, min_date, max_rank,
          rank() OVER (PARTITION BY idparcelle ORDER BY max_rank DESC) AS pos
     FROM bilan_date
     WHERE (mfu = 'start' AND min_date <= '2022-12-31') OR (mfu = 'end' AND max_date <= '2022-12-31')
  ) AS ranking
JOIN bilan_evenement be ON be.idparcelle = ranking.idparcelle
WHERE pos = 1 AND ranking.mfu = 'start')
```

<br>

--------

<br>

La requête [***mfu_cenna_detaillee.sql***](./mfu_cenna_detaillee.sql) récupère l'ensemble des parcelles **actuellement** en Maîtrise Foncière ou d'Usage (MFU) par le CEN Nouvelle-Aquitaine avec des informations détaillées.

En open-data, les parcelles sont mise à disposition par département (*mfu_cenna_16* pour le département de la Charente par exemple)



<br>

### Dictionnaire des données

<br>

*Les champs avec astérisque ne sont pas véhiculés dans les données en open-data

<br>

| Nom du champ | Définition |
|:---------|:---------------|
| idparcelle | Identifiant unique de la parcelle issu du cadastre |
| departement | Code du département |
| insee_commune | Code INSEE de la commune issu du cadastre |
| insee_commune_ref | Code INSEE de la commune de référence (il diffère de insee_commune quand une fusion de commune n'est pas encore répercutée dans le cadastre)|
| nom_commune | Nom de la commune de référence |
| section | Code de la section cadastrale |
| numero | Numéro de la parcelle |
| contenance | Surface cadastrale en m2 issue du cadastre |
| libinteret* | Intérêt de la parcelle |
| categorie_mfu | Catégorie de MFU |
| type_mfu | Type de MFU |
| date_debut_mfu | Date à laquelle la parcelle a été maîtrisée pour la première fois |
| codesite* | Code du site géré associé à la parcelle |
| nom_site | Nom du site géré associé à la parcelle |
| code_metasite* | Code du meta-site géré associé au site géré (si le site géré fait partie d'un méta-site) |
| nom_metasite | Nom du meta-site géré associé au site géré (si le site géré fait partie d'un méta-site) |
| date_debut_convention* | Date de début de la dernière convention signée (s'il sagit d'une MFU de type Convention) |
| date_fin_convention* | Date de fin de la dernière convention signée (s'il sagit d'une MFU de type Convention) |
| reconductibilite_convention* | Indique si la convention est reconductible tacitement ou non (s'il sagit d'une MFU de type Convention) |
| idaire* | Identififiant de l'Aire Prioritaire d'Intervention Foncière associée à la parcelle |
| lib_aire* | Libellé de l'Aire Prioritaire d'Intervention Foncière associée à la parcelle |
| libdossier* | Libellé du dossier de financement lié à la parcelle (s'il sagit d'une MFU de type Acquisition)|
| libhabitat | Libellé de l'habitat générique majoritaire au sein de la parcelle|
| last_idevenement* | Identifiant du dernier événement d'animation foncière asocié à la parcelle|
| last_libevenement* | Libellé du dernier événement d'animation foncière asocié à la parcelle|
| last_dateevenement* | Date du dernier événement d'animation foncière asocié à la parcelle|
| utilisateur* | Nom et prénom de l'utilisateur qui a saisi le dernier événement d'animation foncière asocié à la parcelle|
| millesime_cadastre | Millesime du cadastre utilisé |
| source_cadastre | Source du cadastre utilisé |
| parcelle_partie | Indique s'il s'agit d'une partie de parcelle ou non (s'il sagit d'une MFU de type Convention)  |
| parcelle_bnd | Indique si la parcelle est un bien non délimité |
| parcelle_mc* | Indique s'il s'agit d'une parcelle maîtrisée via un dossier de mesures compensatoires ou non  |


<br>

## Sites gérés par le CEN Nouvelle-Aquitaine

<br>
