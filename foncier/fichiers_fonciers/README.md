# Foncier - Fichiers fonciers

Le référentiel des données sur les propriétaires utilisé est celui distibué par le [Cerema](https://datafoncier.cerema.fr/fichiers-fonciers) et mis à jour chaque année. Appelé communément "**Fichiers fonciers**", il est issu du retraitement par le Cerema des fichiers MAJIC de la Direction Générale des Finances Publiques (DGFiP).

La Fédération des CEN (FCEN) centralise les demandes des CEN régionaux via les actes d'engagements puis distibue à chacun les données non anonymisées sous forme de scripts SQL pour intégration dans une base de données PostgreSQL/PostGIS.



<br>

----

<br>

## Utilisation des fichiers fonciers

<br>

Une fois la base de données créée et sécurisée, elle n'est consultable que par les salariés du CEN NA et en passant par l'application web FoncierCEN développée intégralement par le CEN NA.

Via un clic sur une parcelle dans l'application, l'utilisateur connecté peut ainsi consulter les informations sur le(s) propriétaire(s) de cette parcelle. Pour des raisons de confidentialité, aucun export des propriétaires n'est possible (simple consultation via un accès sécurisé dans FoncierCEN)

<br>

Les propriétaires sont quand même intégrés dans la vue des parcelles en MFU (accès avec authentification), uniquement donc pour les parcelles maîtrisées par le CEN NA. 

Cela permet de :

- vérifier les éventuelles incohérences sur des parcelles maîtrisées depuis longtemps
- connaître rapidement les propriétaires pour les parcelles en convention d'usage, les baux emphytéotiques ou les ORE.

<br>

2 tables des Fichiers fonciers sont utilisées pour récupérer les informations

[pnb10_parcelle](http://doc-datafoncier.cerema.fr/ff/doc_fftp/table/pnb10_parcelle/last/) : lien avec l'idparcelle du cadastre Etalab et récupération de l'identifiant de compte communal *idprocpte*.

[proprietaire_droit_non_ano](http://doc-datafoncier.cerema.fr/ff/doc_fftp/table/proprietaire_droit/last/) : lien avec *idprocpte* et récupération des informations sur les propriétaires

<br>

----

<br>

### Dictionnaire des données

<br>

Le Cerema ayant travaillé sur la fiabilité des données, les champs les mieux notés sont donc utilisés.


<br>

| Nom du champ | Définition | Table source |
|:---------|:---------------| :--------------- |
| idparcelle | Identifiant unique de la parcelle issu du cadastre |
| ctpdl | Type de pdl (type de copropriété) | pnb10_parcelle |
| catpro2 | Classification de personne morale niveau 2 | proprietaire_droit |
| catpro2txt | Classification de personne morale niveau 2 (décodé)| proprietaire_droit |
| catpro3 | Classification de personne morale niveau 3 |proprietaire_droit |
| catpro3txt | Classification de personne morale niveau 3 (décodé) |proprietaire_droit |
| ccogrm | Code groupe de personne morale | proprietaire_droit |
| ccogrmtxt | Code groupe de personne morale (décodé) | proprietaire_droit |
| ccodro | Code du droit réel ou particulier | proprietaire_droit |
| ccodrotxt | Code du droit réel ou particulier (décodé) | proprietaire_droit |
| typedroit  | Type de droit : propriétaire ou gestionnaire | proprietaire_droit |
| ccodem | Code du démembrement/indivision | proprietaire_droit |
| ccodemtxt | Code du démembrement/indivision (décodé) | proprietaire_droit |
| ddenom | Dénomination de personne physique ou morale | proprietaire_droit |
| jdatatv | Date de mutation valide (date de l'acte) | pnb10_parcelle |
| ff_millesime | Millesime des Fichiers foncier |
| fcen_typprop_id | Code du type de propriétaire utilisé par le FCEN (calculé à partir du champ *ccogrm* |
| fcen_typprop_det | Libellé du type de propriétaire utilisé par le FCEN |

<br>

Comme il peut y avoir plusieurs personnes liées à une parcelle (indivision, usfruit, emphytéose, etc.), les champs concernés sont concaténés pour n'avoir qu'une seule ligne par parcelle.

Le regroupement est réalisé de telle sorte que la concaténation ne soit pas réalisée quand il y a la même entrée pour les champs utilisés pour les statistiques. Par exemple, si 3 personnes physiques sont propriétaires d'une parcelle, le champ catpro2txt sera noté à PERSONNE PHYSIQUE (et non pas la concaténation PERSONNE PHYSIQUE | PERSONNE PHYSIQUE | PERSONNE PHYSIQUE).

