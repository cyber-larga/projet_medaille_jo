# projet_medaille_jo
#projet econometrie M1
#ce projet est une collaboration entre Antoine Collet et Emile Largaiolli

# recherche bibilographique:

# medaille JO vs PIB par pays:
https://www.kaggle.com/code/ernestitus/2024-olympic-medals-v-s-gdp

# Explication des variables :

Variable,Description,Source
ISO3

Code pays normalisé sur 3 lettres (ISO 3166-1 alpha-3).
C'est la clé primaire pour la fusion avec la base des médailles.,Standard ISO

GDP_USD_Mean

Définition : Produit Intérieur Brut (PIB) total moyen sur la période.
Unité : Dollars US courants ($).
Source : Banque Mondiale (World Development Indicators).

GDP_per_Capita_Mean

Définition : PIB moyen divisé par la population moyenne. Mesure le niveau de vie et le développement économique.
Unité : Dollars US par habitant ($/hab).
Calcul : GDP_USD_Mean / Population_Mean.

Log_GDP_Cap_Mean

Définition : Logarithme népérien du PIB par habitant.
Usage : Variable linéarisée à privilégier dans les régressions pour
interpréter les résultats en termes d'élasticité.

3. Variables Démographiques
Ces variables mesurent la taille du "vivier" humain disponible.

Population_Mean

Définition : Population totale moyenne sur la période 2014-2024.
Unité : Nombre d'habitants.
Source : Banque Mondiale.

Log_Pop_Mean

Définition : Logarithme népérien de la population.
Usage : Indispensable dans les modèles de gravité ou de comptage pour 
corriger les effets d'échelle (un pays 10x plus grand ne gagne
pas forcément 10x plus de médailles linéairement).

4. Variables Sanitaires & Culture Sportive
Ces variables servent de "proxies" pour la qualité du capital humain et l'accès aux infrastructures.

Health_Exp_Percent_Mean

Définition : Dépenses courantes de santé (publiques et privées) en pourcentage du PIB.
Interprétation : Mesure la priorité économique accordée à l'entretien biologique de 
la population.

Source : Banque Mondiale / OMS (Global Health Expenditure Database).

Health_Exp_USD_Mean

Définition : Dépense de santé réelle par habitant.
Unité : Dollars US ($).
Calcul : GDP_per_Capita_Mean * (Health_Exp_Percent_Mean / 100).

Inactivity_Adolescents_Mean

Définition : Pourcentage d'adolescents (11-17 ans) ne pratiquant pas au moins 60 minutes d'activité physique modérée à intense par jour.
Interprétation : Proxy inversé de la culture sportive. Un taux élevé indique un vivier de talent sportif restreint.
Source : OMS (Global Health Observatory).

⚠️ Note : Cette variable contient de nombreuses valeurs manquantes (NA).

5. Variables Politiques & Institutionnelles (Traitées)
Ces variables capturent l'effet du régime politique sur la performance sportive (investissement d'état).

Polity_Score_Mean (Donnée brute)

Définition : Score de démocratie moyen (échelle de -10 "Autocratie" à +10 "Démocratie").
Source : Projet Polity5 (Center for Systemic Peace).
Problème : Non disponible pour les micro-états (< 500k hab).

Polity_Score_Imputed (Variable à utiliser)

Définition : Score Polity5 où les valeurs manquantes (NA) ont été remplacées par la moyenne mondiale.
Usage : Permet d'inclure les petits pays dans la régression sans les perdre.

Polity_Missing_Flag (Variable de contrôle)

Définition : Variable binaire (Dummy).

Valeur : 1 si le score politique était manquant (donc imputé), 0 sinon.
Usage : À inclure dans le modèle pour capter "l'effet spécifique" des micro-états non notés par Polity5.

6. Variables Événementielles

Is_Host_2024

Définition : Variable binaire indiquant le pays organisateur des Jeux Olympiques 2024.
Valeur : 1 pour la France (FRA), 0 pour les autres.
Usage : Capture l'avantage du pays hôte ("Home Advantage").