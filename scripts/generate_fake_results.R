#### Create fake election results data ####

#### Setup

# Load packages
library(tidyverse)

## Load data
# Predictions
setwd("data")
Predictions_list <- lapply(list.files(), read_csv)

#### Data wrangling

# Select 538
five38 <- Predictions_list[[1]]

# Select most recent 538 predictions (10/1/20)
five38_recent <- mutate(five38, date = as.Date(date, format = "%m/%d/%y")) %>% 
  filter(date == max(date)) 

#### Generate fake election results data

## Simulate fake election results data based on 538 10/1/20 outcome probabilities for each state
# (1 = dem win, 0 = rep win)
set.seed(538)
outcomes_vector <- mapply(function(P_dem, P_rep) {
  sample(c(1,0), 1, prob = c(P_dem, P_rep))
}, P_dem = five38_recent$dem_chance, P_rep = five38_recent$rep_chance)

# Create fake election results dataframe
Results_fake <- data.frame(state = five38_recent$state, outcome = outcomes_vector)

#### Write results to file
setwd("..")
setwd("Election_results")
write_csv(Results_fake, "Results_fake.csv")
