#### Prediction & results data cleaning & wrangling ####

#### Setup ####

# Load packages
library(tidyverse)
library(DescTools)

### Load data
## Predictions
setwd("data")
# Quant modelers
setwd("quant_modelers")
Modelers_list <- lapply(list.files(), read_csv)
names(Modelers_list) <- list.files() %>% sub(".csv", "", .)
# Experts
setwd("..")
setwd("experts")
Experts_list <- lapply(list.files(), read_csv)
names(Experts_list) <- list.files() %>% sub(".csv", "", .)
# Markets
setwd("..")
setwd("markets")
predictit <- read_csv("predictit_cleaned.csv")

# Results
setwd("..")
setwd("Election_results")
Results <- read_csv("Results_real.csv")

#### Data wrangling ####

### Quant modelers full dataset

## Combine datasets from each quant modeler

Modelers_full <- bind_rows(Modelers_list)
Modelers_full <- add_column(Modelers_full, 
                            forecaster = rep(names(Modelers_list), sapply(Modelers_list, nrow)), 
                            .before = "date")

## Round predictions to nearest .05 (Prediction = democratic win)

Modelers_full <- mutate(Modelers_full, prediction = RoundTo(dem_chance, .05))

## Change state names to abbreviations

Modelers_full <- left_join(select(Modelers_full, state), 
                           tibble(state.abb, state.name), 
                           by = c("state" = "state.name")) %>% 
  mutate(state.abb = if_else(!is.na(state.abb), state.abb, 
                             if_else(state == "District of Columbia", "DC", state))) %>% 
  .$state.abb %>% 
  mutate(Modelers_full, state = .)

### Experts full dataset

## Clean sabato

names(Experts_list$sabato) <- names(Experts_list$cook)

## Combine datasets from each expert

Experts_full <- bind_rows(Experts_list)
Experts_full <- add_column(Experts_full, 
                           forecaster = rep(names(Experts_list), sapply(Experts_list, nrow)), 
                           .before = "date")

## Round predictions to nearest .05 (Prediction = democratic win)

Experts_full <- mutate(Experts_full, prediction = RoundTo(dem_chance, .05))

## Clean state field

Experts_full <- mutate(Experts_full, state = sub("0", "", state))

### Clean predictit dataset

## Add name of forecaster

predictit <- add_column(predictit, 
                        forecaster = "predictit", .before = "date")

## Round predictions to nearest .05 (Prediction = democratic win)

predictit <- mutate(predictit, prediction = RoundTo(dem_price, .05))

## Clean state field

predictit <- mutate(predictit, state = sub("0", "", state))

### Combine all prediction datasets

## Add forecaster type to each dataset

Modelers_full <- add_column(Modelers_full, 
                            forecaster_type = "quant_modeler", .before = "forecaster")
Experts_full <- add_column(Experts_full, 
                           forecaster_type = "expert", .before = "forecaster")
predictit <- add_column(predictit, 
                        forecaster_type = "market", .before = "forecaster")

## Combine datasets

Predictions_full <- bind_rows(select(Modelers_full, -dem_chance), 
                              select(Experts_full, -dem_chance), 
                              select(predictit, -dem_price, -rep_price))

### Join with results data

Data_full <- full_join(Predictions_full, Results)

#### Export full data

setwd("..")
write_csv(Data_full, "predictions_outcomes_final.csv")
