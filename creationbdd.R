library(dplyr)

# 1. Charger la base complète (celle créée à l'étape précédente)
df <- read.csv("Dataset_Explicatif_JO_Complet.csv")

# 2. Filtrer sur les 10 dernières années (2014-2024)
# On prend large pour maximiser le nombre de données disponibles (pour gérer les NA)
df_10ans <- df %>%
  filter(Year >= 2014 & Year <= 2024)

# 3. Calculer la MOYENNE par pays
# na.rm = TRUE est CRUCIAL : cela ignore les trous. 
# Si un pays a son PIB en 2015 et 2016 mais pas 2017, on fait la moyenne de ce qu'on a.
df_moyenne <- df_10ans %>%
  group_by(ISO3) %>%
  summarise(
    # On fait la moyenne de toutes les variables numériques
    GDP_USD_Mean = mean(GDP_USD, na.rm = TRUE),
    Population_Mean = mean(Population_Total, na.rm = TRUE),
    Health_Exp_Percent_Mean = mean(Health_Exp_Percent_GDP, na.rm = TRUE),
    Polity_Score_Mean = mean(Polity_Score, na.rm = TRUE),
    Inactivity_Adolescents_Mean = mean(Inactivity_Adolescents_Percent, na.rm = TRUE),
    GDP_per_Capita_Mean = mean(GDP_per_Capita, na.rm = TRUE),
    Health_Exp_USD_Mean = mean(Health_Exp_per_Capita_USD, na.rm = TRUE),
    Log_Pop_Mean = mean(Log_Population, na.rm = TRUE),
    Log_GDP_Cap_Mean = mean(Log_GDP_per_Capita, na.rm = TRUE)
  )

# 4. Créer la variable "Pays Hôte 2024" proprement
# On ne fait pas la moyenne (sinon la France aurait 0.1), on met 1 si c'est la France.
df_moyenne <- df_moyenne %>%
  mutate(Is_Host_2024 = ifelse(ISO3 == "FRA", 1, 0))

# 5. Nettoyage final (Retirer les lignes où tout est vide ou NaN)
# Parfois le calcul de moyenne renvoie NaN si toutes les années sont vides
df_moyenne <- df_moyenne %>%
  filter(!is.nan(GDP_USD_Mean))

# 6. Sauvegarder le résultat final
write.csv(df_moyenne, "Dataset_Final_Moyenne_10ans.csv", row.names = FALSE)

# Vérification
print(head(df_moyenne))
print(paste("Nombre de pays dans la base finale :", nrow(df_moyenne)))
