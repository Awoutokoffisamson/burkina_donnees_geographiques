################################################################################
# SCRIPT 03: CALCUL DES SUPERFICIES
#
# Ce script calcule la superficie de chaque commune à partir du shapefile
# et génère un fichier Excel prêt à être complété avec les données de population.
#
# Entrées:
# - data/processed/BFA_subdivision_2025/BFA_niveau3_communes_2025.shp
#
# Sorties:
# - outputs/rapports/BFA_communes_superficie_2025.xlsx
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

cat("================================================================================\n")
cat("CALCUL DES SUPERFICIES DES COMMUNES\n")
cat("================================================================================\n\n")

# 2. Chargement du shapefile
shp_file <- "data/processed/BFA_subdivision_2025/BFA_niveau3_communes_2025.shp"
if (!file.exists(shp_file)) stop("Shapefile introuvable: ", shp_file)

cat("Chargement des données géographiques...\n")
communes <- st_read(shp_file, quiet = TRUE)

# 3. Calcul de la superficie
cat("Calcul des superficies en km²...\n")
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

cat(paste("\n✅ Fichier Excel généré avec succès:\n   ", output_file, "\n"))
cat("\nNote: Les colonnes Population et Densité sont vides et doivent être complétées\n")
cat("      avec les données du RGPH 2019 (disponibles sur insd.bf ou opendataforafrica.org).\n")
