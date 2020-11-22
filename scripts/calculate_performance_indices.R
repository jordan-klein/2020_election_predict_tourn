#### Calculate performance indices ####

#### Setup ####

# Load packages
library(tidyverse)
library(DescTools)

### Load data
setwd("data")
Data_full <- read_csv("predictions_outcomes_final.csv", 
                      col_types = cols("c", "c", "D", "c", "d", "d"))

## Drop ME & NE congressional districts (not forecasted by inside elections & economist)

Data_full <- Data_full[-grep("-", Data_full$state), ]

#### Calculations ####

### Function to calculate indices

index_calculation <- function(df) {
  
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
  
  # PS calculated
  PS_calc <- VI+CI-DI
  
  # Dataframe of indices
  Indices <- data.frame(PS = PS, VI = VI, CI = CI, DI = DI, PS_calc = PS_calc)
}

#### Calculate indices

### By forecaster & date

## Split data into lists & calculate indices
List_forecaster <- split(Data_full, list(Data_full$forecaster, Data_full$date), drop = T) %>% 
  lapply(index_calculation)

## Combine indices calculations into dataframe
Forecaster_indices <- bind_rows(List_forecaster)
Forecaster_indices <- add_column(Forecaster_indices, 
                                 forecaster = rep(sub("\\..*", "", names(List_forecaster)), 
                                                       sapply(List_forecaster, nrow)), 
                                 .before = "PS")
Forecaster_indices <- add_column(Forecaster_indices, 
                                 date = rep(sub(".*\\.", "", names(List_forecaster)), 
                                            sapply(List_forecaster, nrow)), 
                                 .before = "PS")

## Export dataset
setwd("Election_results")
write_csv(Forecaster_indices, "results_byforecaster.csv")

### By forecaster type & date

## Clean

# Cut off dates before all modelers/experts have started forecasting
Data_typeclean <- filter(Data_full, (forecaster_type == "quant_modeler" & date >= as.Date("2020-06-01")) | 
                           (forecaster_type == "expert" & date >= as.Date("2019-03-08")) | 
                           forecaster_type == "market")
# Duplicate quant modelers w/ no jhk
Data_typeclean <- filter(Data_typeclean, forecaster == "538" | forecaster == "economist") %>% 
  mutate(forecaster_type = "quant_modeler_nojhk") %>% 
  bind_rows(Data_typeclean, .)

## Split data into lists & calculate indices
List_forecastertype <- split(Data_typeclean, list(Data_typeclean$forecaster_type, Data_typeclean$date), drop = T) %>% 
  lapply(index_calculation)

## Combine indices calculations into dataframe
Forecastertype_indices <- bind_rows(List_forecastertype)
Forecastertype_indices <- add_column(Forecastertype_indices, 
                                 forecaster_type = rep(sub("\\..*", "", names(List_forecastertype)), 
                                                  sapply(List_forecastertype, nrow)), 
                                 .before = "PS")
Forecastertype_indices <- add_column(Forecastertype_indices, 
                                 date = rep(sub(".*\\.", "", names(List_forecastertype)), 
                                            sapply(List_forecastertype, nrow)), 
                                 .before = "PS")

## Export dataset
write_csv(Forecastertype_indices, "results_byforecastertype.csv")
