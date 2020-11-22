#### Analysis of results ####

#### Setup ####

# Load packages
library(tidyverse)
library(zoo)

### Load data
setwd("data/Election_results")
f_results <- read_csv("results_byforecaster.csv")
# ft_results <- read_csv("results_byforecastertype.csv")

# # Drop JHK
# f_results <- filter(f_results, forecaster != "jhk")
# ft_results <- filter(ft_results, forecaster_type != "quant_modeler")
# Keep JHK
# ft_results <- filter(ft_results, forecaster_type != "quant_modeler_nojhk")

# # Round results to nearest 4th decimal
# f_results[, 3:7] <- round(f_results[, 3:7], 4)
# ft_results[, 3:7] <- round(ft_results[, 3:7], 4)

# Add forecaster type variable to forecaster outlet data
f_results <- mutate(f_results, forecaster_type = 
                      case_when(forecaster == "538" | forecaster == "economist" | forecaster == "jhk" ~ "quant_modeler", 
                                forecaster == "cook" | forecaster == "sabato" | forecaster == "inside" ~ "expert", 
                                forecaster == "predictit" ~ "market"))

# Calculate mean scores
ft_means <- group_by(f_results, forecaster_type, date) %>% 
  summarise(PS = mean(PS), VI = mean(VI), CI = mean(CI), DI = mean(DI)) %>% 
  mutate(PS_calc = VI+CI-DI) %>% 
  mutate(PS_diff = PS - PS_calc)

# Cut off dates before June 1, 2020
# f_results <- filter(f_results, date >= as.Date("2020-06-01"))
# ft_results <- filter(ft_results, date >= as.Date("2020-06-01"))

#### Graphing ####

#### Election day forecasts

# Select election day forecasts
f_results_eday <- filter(f_results, date == as.Date("2020-11-03"))
ft_means_eday <- filter(ft_means, date == as.Date("2020-11-03"))

### Forecaster outlets

## PS
ggplot(f_results_eday, aes(y = PS, x = date, color = forecaster_type, shape = forecaster)) + 
  geom_point(size = 3) + 
  ylab("Probability Score") + xlab("Election Day") +  
  theme(axis.text.x=element_blank()) + 
  scale_color_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler")) + 
  scale_shape_manual(values=1:7, limits = c("cook", "inside", "sabato", "predictit", "economist", "538", "jhk"), 
                       name = "Forecaster Outlet (PS)", 
                       labels = c("Cook (.0650)", "Inside Elections (.0642)", "Sabato (.0557)", 
                                  "PredictIt (.0381)", "Economist (.0364)", "FiveThirtyEight (.0362)", 
                                  "JHK (.0348)"))

  
## CI + DI
ggplot(f_results_eday, aes(x = 1-CI, y = DI, color = forecaster_type, shape = forecaster)) + 
  geom_point(size = 3) + 
  xlab("1-Calibration") + ylab("Discrimination") + 
  scale_color_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler")) + 
  scale_shape_manual(values=1:7, limits = c("cook", "inside", "sabato", "predictit", "economist", "538", "jhk"), 
                    name = "Forecaster Outlet", 
                    labels = c("Cook", "Inside Elections", "Sabato", 
                               "PredictIt", "Economist", "FiveThirtyEight", 
                               "JHK")) + 
  geom_abline(slope = -1, intercept = seq(0, 10, by = .005), lty = "dashed")

### Forecaster types

## PS
ggplot(ft_means_eday, aes(y = PS, x = date, color = forecaster_type, shape = forecaster_type)) + 
  geom_point(size = 3) + 
  ylab("Probability Score") + xlab("Election Day") +  
  theme(axis.text.x=element_blank()) + 
  scale_shape_discrete(name = "Forecaster Type (PS)", 
                       labels = c("Expert (.0616)", "Prediction market (.0381)", "Quant modeler (.0358)")) + 
  scale_color_discrete(name = "Forecaster Type (PS)", 
                       labels = c("Expert (.0616)", "Prediction market (.0381)", "Quant modeler (.0358)"))

## CI + DI
ggplot(ft_means_eday, aes(x = 1-CI, y = DI, color = forecaster_type, shape = forecaster_type)) + 
  geom_point(size = 3) + 
  xlab("1-Calibration") + ylab("Discrimination") + 
  scale_color_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler")) + 
  scale_shape_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler")) + 
  geom_abline(slope = -1, intercept = seq(0, 10, by = .005), lty = "dashed")

#### Forecasts over time

### Forecaster outlets

# ## PS
# ggplot(f_results, aes(y = PS, x = date, color = forecaster_type, lty = forecaster)) + 
#   geom_path() + 
#   ylab("Probability Score") + 
#   scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month", 
#                limit=c(as.Date("2020-06-01"),as.Date("2020-11-03")), name = "Date") + 
#   scale_color_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler")) + 
#   scale_linetype_discrete(limits = c("cook", "inside", "sabato", "predictit", "economist", "538", "jhk"), 
#                      name = "Forecaster Outlet", 
#                      labels = c("Cook", "Inside Elections", "Sabato", 
#                                 "PredictIt", "Economist", "FiveThirtyEight", 
#                                 "JHK"))
# 
# ## CI
# ggplot(f_results, aes(y = CI, x = date, color = forecaster_type, lty = forecaster)) + 
#   geom_path() + 
#   ylab("Calibration Index") + 
#   scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month", 
#                limit=c(as.Date("2020-06-01"),as.Date("2020-11-03")), name = "Date") + 
#   scale_color_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler")) + 
#   scale_linetype_discrete(limits = c("cook", "inside", "sabato", "predictit", "economist", "538", "jhk"), 
#                           name = "Forecaster Outlet", 
#                           labels = c("Cook", "Inside Elections", "Sabato", 
#                                      "PredictIt", "Economist", "FiveThirtyEight", 
#                                      "JHK"))
# 
# ## DI
# ggplot(f_results, aes(y = DI, x = date, color = forecaster_type, lty = forecaster)) + 
#   geom_path() + 
#   ylab("Discrimination Index") + 
#   scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month", 
#                limit=c(as.Date("2020-06-01"),as.Date("2020-11-03")), name = "Date") + 
#   scale_color_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler")) + 
#   scale_linetype_discrete(limits = c("cook", "inside", "sabato", "predictit", "economist", "538", "jhk"), 
#                           name = "Forecaster Outlet", 
#                           labels = c("Cook", "Inside Elections", "Sabato", 
#                                      "PredictIt", "Economist", "FiveThirtyEight", 
#                                      "JHK"))

### Forecaster types

## PS
mutate(ft_means, roll_PS = rollmean(PS, 7, fill = NA)) %>% 
  ggplot(aes(y = roll_PS, x = date, color = forecaster_type, lty = forecaster_type)) + 
  geom_path() + 
  ylab("Probability Score") + 
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month", 
               limit=c(as.Date("2020-06-01"),as.Date("2020-11-03")), name = "Date") + 
  scale_color_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler")) + 
  scale_linetype_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler"))

## CI
mutate(ft_means, roll_CI = rollmean(CI, 7, fill = NA)) %>% 
  ggplot(aes(y = roll_CI, x = date, color = forecaster_type, lty = forecaster_type)) + 
  geom_path() + 
  ylab("Calibration Index") + 
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month", 
               limit=c(as.Date("2020-06-01"),as.Date("2020-11-03")), name = "Date") + 
  scale_color_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler")) + 
  scale_linetype_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler"))

## DI
mutate(ft_means, roll_DI = rollmean(DI, 7, fill = NA)) %>% 
  ggplot(aes(y = roll_DI, x = date, color = forecaster_type, lty = forecaster_type)) + 
  geom_path() + 
  ylab("Discrimination Index") + 
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month", 
               limit=c(as.Date("2020-06-01"),as.Date("2020-11-03")), name = "Date") + 
  scale_color_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler")) + 
  scale_linetype_discrete(name = "Forecaster Type", labels = c("Expert", "Prediction market", "Quant modeler"))
