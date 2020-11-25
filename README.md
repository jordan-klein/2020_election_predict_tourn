# 2020 Presidential Election Prediction Tournament
**COS 597E Assignment 1**

## Data
We use data from three quantitative modelers (FiveThirtyEight, The Economist, and JHK Forecasts), three experts (Cook Political Report, Sabato's Crystal Ball, and Inside Elections), and one prediction market (PredictIt). The raw data can be publicly downloaded from the respective sources and is located in the folder `raw_data`. The cleaned data can be found in the `data` folder. The variable `dem_chance` (or `dem_price`) for the prediction market indicates the predicted subjective probability of a Joe Biden victory in a given state/district on a scale from 0 to 1. 

For the experts, we convert the qualitative probabilities they report into quantitative probabilities using the following chart: 
Rating (Qualitative Rating)| dem_chance (Corresponding Probability)
------------ | -------------
Solid / Safe Republican | 0.05 
Likely Republican | 0.25 
Lean Republican | 0.40 
Tilt (if included) Republican | 0.45 
Toss-up | 0.50 
Tilt (if included) Democrat | 0.55 
Lean Democrat | 0.60 
Likely Democrat | 0.75 
Solid / Safe Democrat | 0.95 

## Code
We evaluate the forecasters using the framework described by Philip E. Tetlock in *Expert Political Judgment: How Good is It? How Can We Know?*. We calculate the probability score, calibration index, discrimination index, and variability index for each prediction our selected forecasters make. 

In the `scripts` folder, we have the following:
* `prediction_results_data_wrangling.R`: Cleans and wrangles the prediction and results data
* `calculate_performance_indices.R`: Calculates the aforementioned performance indices
* `results_analysis.R`: Analyzes the results and generates the figures found in the `figures` folder
