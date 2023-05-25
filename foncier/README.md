# Foncier

Le référentiel cadastral utilisé (géométrie,identifiant,contenance) est celui distibué par [Etalab](https://cadastre.data.gouv.fr/datasets/cadastre-etalab) et mis à jour trimestriellement.

Ce référentiel peut cependant être contourné et faire l'objet d'une numérisation manuelle dans les cas suivants :

* Maîtrise par le CEN d'une partie de parcelle (dans le cas d'un conventionnement) : la géométrie et la contenance maîtrisées de la partie de parcelle concernée sont stockées dans une table spécifique de la base de données. 

* Maîtrise par le CEN d'un bien non délimité (BND) : la contenance maîtrisée de la parcelle concernée ainsi que la géométrie initiale sont stockées dans une table spécifique de la base de données (la géométrie de la parcelle n'est pas modifiée s'agissant d'un bien non délimité)

* Division parcellaire récente : lors de l'achat par le CEN d'une parcelle,  il peut arriver qu'une division parcellaire soit opérée. La remontée de cette modification dans le référentiel pouvant être longue, une modification temporaire du référentiel est donc effectuée manuellement sur la base du document d'arpentage d'un géomètre expert précisant le nouvel identifiant et la nouvelle contenance des parcelles impactées.


Les données métier Foncier du CEN Nouvelle-Aquitaine sont disponible en open-data sous forme de web service vecteur (WFS) avec les renseignements essentiels associés.

URL d'accès :

```
https://opendata.cen-nouvelle-aquitaine.org/partage/wfs
```
<br>

----

<br>

## Parcelles en Maîtrise Foncière ou d'Usage par le CEN Nouvelle-Aquitaine

<br>

La requête ***mfu_cenna_detaillee.sql*** récupère l'ensemble des parcelles en Maîtrise Foncière ou d'Usage (MFU) par le CEN Nouvelle-Aquitaine avec des informations détaillées.

En open-data, les parcelles sont mise à disposition par département (***mfu_cenna_16*** pour le département de la Charente par exemple)


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
| date_debut_mfu | Date à laquelle la parcelle a été maîtrisée |
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
