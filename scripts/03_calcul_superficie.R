################################################################################
# SCRIPT 03: CALCUL DES SUPERFICIES

################################################################################

# 1. Chargement des bibliothèques
suppressPackageStartupMessages({
  library(sf)
  library(dplyr)
  library(writexl)
})

# Définir le répertoire de base (si lancé depuis le dossier scripts)
if (basename(getwd()) == "scripts") {
  setwd("..")
}

# 2. Chargement du shapefile
shp_file <- "data/processed/BFA_subdivision_2025/BFA_niveau3_communes_2025.shp"
if (!file.exists(shp_file)) stop("Shapefile introuvable: ", shp_file)

communes <- st_read(shp_file, quiet = TRUE)

# 3. Calcul de la superficie
communes$Superficie_km2 <- as.numeric(st_area(communes)) / 10^6

# 4. Préparation du tableau
tableau_final <- communes %>%
  st_drop_geometry() %>%
  select(
    Region = nvll_rg,
    Province = nvll_pr,
    Commune = NAME_3,
    Superficie_km2
  ) %>%
  arrange(Region, Province, Commune) %>%
  mutate(
    Population_2019 = NA_real_, # Colonne vide pour la population
    Densite_2019 = NA_real_     # Colonne vide pour la densité
  )

# 5. Export Excel
output_file <- "outputs/rapports/BFA_communes_superficie_2025.xlsx"
write_xlsx(tableau_final, output_file)

cat(paste("\n Fichier bien généré:\n   ", output_file, "\n"))
