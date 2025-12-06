library(ggplot2)
library(dplyr)
library(ggrepel)   # Pour les étiquettes qui ne se chevauchent pas
library(ggcorrplot)# Pour la jolie matrice de corrélation (install.packages("ggcorrplot"))

# Chargement
df <- read.csv("data.csv")

# Création de variables pour les graphs
df <- df %>%
  mutate(
    Log_GDP = log(moy_gdp13_23),
    Nord_Sud = ifelse(abs(Latitude) > 30, "Nord (Tempéré)", "Sud (Tropical)"),
    # On identifie les outliers pour les afficher (Top 5 + France)
    Label_Flag = rank(-med_p_m) <= 5 | country_code == "FRA"
  )

# Un thème personnalisé pour avoir la classe "Master"
theme_mas <- theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#2c3e50"),
    plot.subtitle = element_text(size = 11, color = "#7f8c8d"),
    axis.title = element_text(face = "bold", size = 10),
    panel.grid.minor = element_blank(),
    legend.position = "top"
  )


ggplot(df, aes(x = med_p_m)) +
  geom_histogram(aes(y = ..density..), bins = 20, fill = "#3498db", color = "white", alpha = 0.7) +
  geom_density(color = "#e74c3c", size = 1) +
  labs(title = "1. Distribution de la Performance Olympique 2024",
       subtitle = "Forte asymétrie à droite : la majorité des pays ont < 2 médailles/million",
       x = "Médailles par Million d'habitants", y = "Densité") +
  theme_mas


ggplot(df, aes(x = med_p_m_2020, y = med_p_m)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray50") + # Ligne x=y
  geom_point(aes(color = med_p_m > med_p_m_2020), size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE, color = "#2c3e50", size = 0.5) +
  geom_text_repel(data = subset(df, Label_Flag | abs(med_p_m - med_p_m_2020) > 2), 
                  aes(label = country_code), size = 3) +
  scale_color_manual(values = c("#e74c3c", "#2ecc71"), labels = c("Sous-performance", "Surperformance")) +
  labs(title = "2. Inertie Olympique : Tokyo 2020 vs Paris 2024",
       subtitle = "La ligne pointillée représente une performance identique. Vert = Progression.",
       x = "Médailles/Million (Tokyo 2020)", y = "Médailles/Million (Paris 2024)", color = "Bilan") +
  theme_mas


ggplot(df, aes(x = moy_gdp13_23, y = med_p_m)) +
  geom_point(aes(size = X2024, fill = Nord_Sud), shape = 21, color = "white", alpha = 0.8) +
  scale_x_log10(labels = scales::dollar_format()) + # Echelle Log pour le PIB
  geom_smooth(method = "loess", color = "orange", se = FALSE) +
  geom_text_repel(data = subset(df, Label_Flag), aes(label = country_code), size = 3) +
  scale_size_continuous(range = c(2, 10), name = "Population") +
  scale_fill_manual(values = c("#34495e", "#e67e22")) +
  labs(title = "3. L'argent fait-il le bonheur olympique ?",
       subtitle = "Relation entre le PIB (Log) et la performance relative",
       x = "PIB Moyen 2013-2023 (Echelle Log)", y = "Médailles par Million") +
  theme_mas

ggplot(df, aes(x = age_m, y = med_p_m)) +
  geom_point(color = "#9b59b6", size = 3, alpha = 0.6) +
  geom_smooth(method = "lm", color = "black", linetype = "dashed") +
  geom_text_repel(data = subset(df, med_p_m > 5 | age_m > 30), aes(label = country_code), size = 3) +
  labs(title = "4. La Jeunesse au Pouvoir ?",
       subtitle = "Lien entre l'âge moyen de la délégation et la performance",
       x = "Âge moyen des athlètes", y = "Médailles par Million") +
  theme_mas


ggplot(df, aes(x = Nord_Sud, y = med_p_m, fill = Nord_Sud)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.5, color = "black") + # Montre les points individuels
  scale_fill_manual(values = c("#3498db", "#f1c40f")) +
  labs(title = "5. Inégalités Nord-Sud",
       subtitle = "Comparaison des distributions de performance par zone climatique",
       x = "", y = "Médailles par Million") +
  theme_mas + theme(legend.position = "none")


# Sélection des variables numériques
corr_vars <- df %>% select(med_p_m, med_p_m_2020, age_m, Log_GDP, moy_health13_23, Latitude)
corr_matrix <- cor(corr_vars, use = "complete.obs")

ggcorrplot(corr_matrix, 
           method = "circle", 
           type = "lower", 
           lab = TRUE, 
           lab_size = 3, 
           colors = c("#e74c3c", "white", "#3498db"),
           title = "6. Matrice de Corrélation")

