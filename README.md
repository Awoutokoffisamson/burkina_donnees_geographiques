# Burkina Faso - Données Géographiques 2025

## Description
Ce dépôt contient les **shapefiles** et **données brutes** des subdivisions administratives du Burkina Faso selon la réforme de juillet 2025.

## Contenu

### 📁 shapefiles/
Fichiers géographiques au format Shapefile (.shp, .dbf, .prj, .shx) :
- `BFA_niveau1_regions_2025` - 17 régions
- `BFA_niveau2_provinces_2025` - 47 provinces  
- `BFA_niveau3_communes_2025` - 351 communes

### 📁 donnees_brutes/
- `population_citypop.csv` - Population par commune (RGPH 2019)
- `table_correspondance_communes.csv` - Table de correspondance anciennes/nouvelles subdivisions

### 📁 scripts/
- `01_generation_shapefiles.R` - Script de génération des shapefiles
- `03_calcul_superficie.R` - Script de calcul des superficies

## Sources
- **Population** : INSD - RGPH 2019
- **Découpage administratif** : Réforme de Juillet 2025

## Auteur
AWOUTO K. Samson - Élève Ingénieur Statisticien Économiste, ENSAE Dakar

## Licence
Les données sont libres d'utilisation à des fins éducatives et de recherche.

Ce travail est sous licence **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)**.
- **Attribution** : Vous devez créditer l'auteur (AWOUTO K. Samson).
- **Pas d'usage commercial** : Vous ne pouvez pas utiliser ces données à des fins commerciales sans autorisation.
- **Partage** : Si vous modifiez ces données, vous devez distribuer vos contributions sous la même licence.

## 📜 Citation
Veuillez citer ce travail comme suit :
> AWOUTO, K. S. (2026). *Données Géographiques Burkina Faso - Réforme 2025*. ENSAE Dakar. https://github.com/Awoutokoffisamson/burkina_donnees_geographiques

