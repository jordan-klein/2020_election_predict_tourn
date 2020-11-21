#### Calculate performance indices ####

#### Setup ####

# Load packages
library(tidyverse)
library(DescTools)

### Load data
setwd("data")
Data_full <- read_csv("predictions_outcomes_final.csv", 
                      col_types = cols("c", "c", "D", "c", "d", "d"))

#### Analysis ####

### List & calculate indices

## Split into list by forecaster & date
List_full <- split(Data_full, list(Data_full$forecaster_type, Data_full$forecaster, Data_full$date), drop = T)

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
                                 forecaster_type = rep(sub("\\..*", "", names(List_indices)), 
                                                  sapply(List_indices, nrow)), 
                                 .before = "PS")
Indices_calculated <- StrExtract(names(List_indices), "\\..*.*\\.") %>% 
  sub("\\.", "", .) %>% 
  sub("\\.", "", .) %>%
  add_column(Indices_calculated, forecaster = ., .before = "PS")
Indices_calculated <- add_column(Indices_calculated, 
                                 date = rep(sub(".*\\.", "", names(List_indices)), 
                                                  sapply(List_indices, nrow)), 
                                 .before = "PS")

### Export dataset
setwd("Election_results")
write_csv(Indices_calculated, "index_calculation_results.csv")
