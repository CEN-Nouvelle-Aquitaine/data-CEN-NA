# Foncier

Les parcelles sont basées sur le cadastre Etalab



## Parcelles en Maîtrise Foncière ou d'Usage par le CEN Nouvelle-Aquitaine

La requête ***mfu_cenna_detaillee.sql*** récupère l'ensemble des parcelles en Maîtrise Foncière ou d'Usage (MFU) par le CEN Nouvelle-Aquitaine avec des informations détaillées.

*Les champs avec astérisque ne sont pas véhiculés dans les données en open-data


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
| parcelle_partie | Source du cadastre utiliséIndique s'il s'agit d'une partie de parcelle ou non (s'il sagit d'une MFU de type Convention)  |
| parcelle_mc* | Indique s'il s'agit d'une parcelle maîtrisée via un dossier de mesures compensatoires ou non  |