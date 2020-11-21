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

## Fill in dates between prediction updates

Experts_list_full <- lapply(Experts_list, function(x) {
  # Create vector of dates spanning full range of predictions
  date_range <- seq.Date(x$date[order(x$date)][1], as.Date("2020-11-03"), by = "day")
  # Combine dates with set of states
  date_states <- expand_grid(date = date_range, state = unique(x$state))
  # # Join back into data
  data_fullrange <- full_join(x, date_states)
  # # Fill in previous values for each state
  split(data_fullrange, data_fullrange$state) %>%
    lapply(function(y) {
      y[order(y$date), ] %>%
        fill(dem_chance)
    }) %>%
    bind_rows()
})

## Combine datasets from each expert

Experts_full <- bind_rows(Experts_list_full)
Experts_full <- add_column(Experts_full, 
                           forecaster = rep(names(Experts_list_full), sapply(Experts_list_full, nrow)), 
                           .before = "date")

## Round predictions to nearest .05 (Prediction = democratic win)

Experts_full <- mutate(Experts_full, prediction = RoundTo(dem_chance, .05))

## Clean state field

Experts_full <- mutate(Experts_full, state = sub("0", "", state))

### Clean predictit dataset

## Fill in data for election day

predictit_full <- bind_rows(predictit, expand_grid(date = as.Date("2020-11-03"), 
                                 state = unique(predictit$state), 
                                 dem_price = NA, rep_price = NA)) %>% 
  split(.$state) %>% 
  lapply(function(x) {
    x[order(x$date), ] %>%
      fill(dem_price)
  }) %>%
  bind_rows()

## Add name of forecaster

predictit_full <- add_column(predictit_full, 
                        forecaster = "predictit", .before = "date")

## Round predictions to nearest .05 (Prediction = democratic win)

predictit_full <- mutate(predictit_full, prediction = RoundTo(dem_price, .05))

## Clean state field

predictit_full <- mutate(predictit_full, state = sub("0", "", state))

### Combine all prediction datasets

## Add forecaster type to each dataset

Modelers_full <- add_column(Modelers_full, 
                            forecaster_type = "quant_modeler", .before = "forecaster")
Experts_full <- add_column(Experts_full, 
                           forecaster_type = "expert", .before = "forecaster")
predictit_full <- add_column(predictit_full, 
                        forecaster_type = "market", .before = "forecaster")

## Combine datasets

Predictions_full <- bind_rows(select(Modelers_full, -dem_chance), 
                              select(Experts_full, -dem_chance), 
                              select(predictit_full, -dem_price, -rep_price))

### Join with results data

Data_full <- full_join(Predictions_full, Results)

#### Export full data

setwd("..")
write_csv(Data_full, "predictions_outcomes_final.csv")
