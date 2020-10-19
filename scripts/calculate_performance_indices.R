#### Calculate performance indices ####

#### Setup

# Load packages
library(tidyverse)

## Load data
# Predictions
setwd("data")
Predictions_list <- lapply(list.files(), read_csv)
names(Predictions_list) <- list.files() %>% sub("\\_.*", "", .)

# Results
setwd("..")
setwd("Election_results")
Results <- read_csv("Results_fake.csv")

#### Data wrangling

### Create full dataset

## Combine datasets from each forecaster

Data_full <- bind_rows(Predictions_list)
Data_full <- add_column(Data_full, 
                        forecaster = rep(names(Predictions_list), sapply(Predictions_list, nrow)), 
                        .before = "date")

## Round predictions to nearest .1 (Prediction = democratic win)

Data_full <- mutate(Data_full, prediction = round(dem_chance, digits = 1))

### Clean data
## Economist
# Washington DC -> District of Columbia
Data_full$state[Data_full$state == "Washington DC"] <- c("District of Columbia")

## JHK
# Nebraska CD -> NE, Maine CD -> ME
Data_full <- mutate(Data_full, 
                    state = sub("Nebraska CD", "NE", Data_full$state), 
                    state = sub("Maine CD", "ME", state))

## Drop US-wide
Data_full <- filter(Data_full, state != "US")

### Join with results data

Data_full <- full_join(Data_full, Results)

### List & calculate indices

## Split into list by forecaster & date
List_full <- split(Data_full, list(Data_full$forecaster, Data_full$date), drop = T)

## Function to calculate indices

List_indices <- lapply(List_full, function(df) {
  
  pi <- df$prediction
  xi <- df$outcome
  N <- length(df$outcome)
  
  # PS
  PS <- (pi-xi)^2 %>% 
    sum()/N
  
  # VI
  b <- sum(xi)/N
  VI <- b*(1-b)
  
  # CI
  df_t <- df %>% 
    group_by(prediction) %>% 
    summarise(bt = mean(outcome), nt = n())
  
  pt <- df_t$prediction
  bt <- df_t$bt
  nt <- df_t$nt
  
  CI <- (nt*(pt-bt)^2) %>% 
    sum()/N
  
  # DI
  DI <- (nt*(bt-b)^2) %>% 
    sum()/N
  
  # Dataframe of indices
  Indices <- data.frame(PS = PS, VI = VI, CI = CI, DI = DI)
})

### Combine indices calculations into dataframe
Indices_calculated <- bind_rows(List_indices)
Indices_calculated <- add_column(Indices_calculated, 
                                 forecaster = rep(sub("\\..*", "", names(List_indices)), 
                                                  sapply(List_indices, nrow)), 
                                 .before = "PS")
Indices_calculated <- add_column(Indices_calculated, 
                                 date = rep(sub(".*\\.", "", names(List_indices)), 
                                                  sapply(List_indices, nrow)), 
                                 .before = "PS")

### Export dataset
write_csv(Indices_calculated, "index_calculation_results.csv")


#### Misc data cleaning code ####

econstates <- Predictions_list$economist$date
econdates <- Predictions_list$economist$state

jhkstates <- Predictions_list$jhk$date
jhkdates <- Predictions_list$jhk$state

Predictions_list$economist <- mutate(Predictions_list$economist, 
                                     date = econdates, state = econstates)


Predictions_list$jhk <- mutate(Predictions_list$jhk, 
                                     date = jhkdates, state = jhkstates)

Predictions_list$jhk <- mutate(Predictions_list$jhk, 
                                     dem_chance = dem_chance/100, rep_chance = rep_chance/100)
