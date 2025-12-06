library(dplyr)
library(ggplot2)
library(car) # Pour tester la multicollinéarité (VIF) si besoin
library(ggcorrplot)
# 1. Charger les données
df <- read.csv("data.csv")

# 2. Transformations Économétriques
df_model <- df %>%
  mutate(
    # Log Population (pour éviter l'effet d'écrasement par la Chine/Inde)
    Log_Pop = log(X2024),
    
    # Log PIB (pour linéariser l'effet richesse)
    Log_GDP = log(moy_gdp13_23),
    
    # Création de la Dummy "Nord" basée sur la Latitude
    # Hypothèse : Les pays au-dessus de 30° Nord (Europe, USA, Japon) ont un avantage historique
    # On prend la valeur absolue si on veut inclure l'Australie/NZL comme "Climat tempéré"
    # Ici, on teste l'hypothèse "Climat Tempéré" vs "Tropical"
    Abs_Latitude = abs(Latitude),
    Is_Temperate_Climate = ifelse(abs(Latitude) > 30, 1, 0)
  )

# 3. Le Modèle de Régression Multiple
# On explique la performance 2024 par :
# - L'inertie (2020)
# - Les facteurs structurels (PIB, Santé, Pop)
# - Les facteurs humains (Age moyen des athlètes)
# - Le facteur géographique (Latitude)

model_final <- lm(med_p_m ~ med_p_m_2020 + age_m + 
                    Log_GDP + Log_Pop + moy_health13_23 + 
                    Abs_Latitude, 
                  data = df_model)

# 4. Affichage des Résultats
summary(model_final)

# 5. Diagnostic des Résidus (Pour ton rapport)
# On vérifie s'il reste des outliers (comme la Grenade)
df_model$Residuals <- residuals(model_final)

# Top 5 des pays qui ont surperformé (Outliers positifs)
print("Pays ayant fait MIEUX que prévu par le modèle :")
df_model %>% 
  select(country_name, med_p_m, med_p_m_2020, Residuals) %>% 
  arrange(desc(Residuals)) %>% 
  head(5)

# Graphique : Prédiction vs Réalité
ggplot(df_model, aes(x = fitted(model_final), y = med_p_m)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1, col = "red", linetype = "dashed") +
  labs(title = "Qualité de la Prédiction (R² ~ 0.78)",
       x = "Médailles par Million PRÉDITES",
       y = "Médailles par Million RÉELLES (2024)") +
  theme_minimal()
