################################################################################
# SCRIPT 01: GÉNÉRATION DES SHAPEFILES
################################################################################

# 1. Chargement des bibliothèques
suppressPackageStartupMessages({
    library(sf)
    library(dplyr)
    library(tidyr)
    library(readr)
})

# Définir le répertoire de base (si lancé depuis le dossier scripts)
if (basename(getwd()) == "scripts") {
    setwd("..")
}


# ==============================================================================
# 1. CHARGEMENT DES DONNÉES
# ==============================================================================

cat("1. Chargement des shapefiles...\n")

input_shp <- "data/raw/gadm41_BFA_3.shp"
if (!file.exists(input_shp)) stop("Fichier shapefile introuvable: ", input_shp)

communes <- st_read(input_shp, quiet = TRUE)

# ==============================================================================
# 2. CHARGEMENT DE LA TABLE DE CORRESPONDANCE
# ==============================================================================

input_csv <- "data/raw/table_correspondance_communes.csv"
if (!file.exists(input_csv)) stop("Fichier de correspondance introuvable: ", input_csv)

correspondance <- read_csv(input_csv, show_col_types = FALSE)
cat(paste("   ✓ Table de correspondance chargée (", nrow(correspondance), " lignes)\n"))

# Vérifier si la table est complète
incomplete <- correspondance %>%
    filter(nouvelle_province == "" | nouvelle_region == "")

if (nrow(incomplete) > 0) {
    stop(paste("\n  ERREUR:", nrow(incomplete), "communes n'ont pas de subdivision assignée."))
}

# ==============================================================================
# 3. APPLICATION DE LA NOUVELLE SUBDIVISION
# ==============================================================================

# Joindre les informations (Utilisation de NAME_1, NAME_2, NAME_3 pour unicité)
communes_nouvelle <- communes %>%
    left_join(correspondance %>% select(NAME_1, NAME_2, NAME_3, nouvelle_province, nouvelle_region),
        by = c("NAME_1", "NAME_2", "NAME_3")
    )

# Vérifier les communes sans mapping
communes_non_mappees <- communes_nouvelle %>%
    filter(is.na(nouvelle_province) | is.na(nouvelle_region))

if (nrow(communes_non_mappees) > 0) {
    print(communes_non_mappees %>% st_drop_geometry() %>% select(NAME_1, NAME_2, NAME_3))
    stop("\n    ERREUR: Mapping incomplet pour certaines communes.")
}

# ==============================================================================
# 4. CRÉATION DES NOUVELLES PROVINCES (47)
# ==============================================================================

provinces_nouvelles <- communes_nouvelle %>%
    group_by(nouvelle_region, nouvelle_province) %>%
    summarise(
        nb_communes = n(),
        communes_list = paste(NAME_3, collapse = ", "),
        .groups = "drop"
    ) %>%
    st_cast("MULTIPOLYGON")

cat(paste("   ✓", nrow(provinces_nouvelles), "provinces créées"))

if (nrow(provinces_nouvelles) != 47) {
    cat(paste(" on obtient toutes les provinces ne sont pas obtenus", nrow(provinces_nouvelles), "\n"))
} else {
    cat(" ✓ (Objectif atteint)\n")
}

# ==============================================================================
# 5. CRÉATION DES NOUVELLES RÉGIONS (17)
# ==============================================================================


regions_nouvelles <- provinces_nouvelles %>%
    group_by(nouvelle_region) %>%
    summarise(
        nb_provinces = n(),
        nb_communes = sum(nb_communes),
        .groups = "drop"
    ) %>%
    st_cast("MULTIPOLYGON")

cat(paste("   ok", nrow(regions_nouvelles), "régions créées"))

if (nrow(regions_nouvelles) != 17) {
    cat(paste("    Objectif 17non atteint, obtenu:", nrow(regions_nouvelles), "\n"))
} else {
    cat(" ✓ (Objectif atteint)\n")
}

# ==============================================================================
# 6. EXPORT DES SHAPEFILES
# ==============================================================================

output_dir <- "data/processed/BFA_subdivision_2025"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Export niveau communal
st_write(communes_nouvelle, file.path(output_dir, "BFA_niveau3_communes_2025.shp"),
    delete_dsn = TRUE, quiet = TRUE
)

# Export niveau provincial
st_write(provinces_nouvelles, file.path(output_dir, "BFA_niveau2_provinces_2025.shp"),
    delete_dsn = TRUE, quiet = TRUE
)

# Export niveau régional
st_write(regions_nouvelles, file.path(output_dir, "BFA_niveau1_regions_2025.shp"),
    delete_dsn = TRUE, quiet = TRUE
)
# ==============================================================================
# 7. EXPORT DES RAPPORTS
# ==============================================================================

rapport_dir <- "outputs/rapports"
if (!dir.exists(rapport_dir)) dir.create(rapport_dir, recursive = TRUE)

# Rapport des provinces
write_csv(
    provinces_nouvelles %>% st_drop_geometry() %>% select(nouvelle_region, nouvelle_province, nb_communes),
    file.path(rapport_dir, "rapport_provinces.csv")
)

# Rapport des régions
write_csv(
    regions_nouvelles %>% st_drop_geometry() %>% select(nouvelle_region, nb_provinces, nb_communes),
    file.path(rapport_dir, "rapport_regions.csv")
)

cat("fin du travail")
