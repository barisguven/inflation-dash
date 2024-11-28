library(shiny)
library(bslib)
library(tidyverse)
library(gt)

# Main data
data = read_csv("data/merged_data.csv")

# Decadal averages data
data_avg <- read_csv("data/merged_data_avg.csv")

# Income components contributions series
income_comps = c("contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax")

# Real incomes data
data_real_inc <- read_csv("data/merged_data_real_incomes.csv")

# Country notes
country_notes <- read_csv("data/country_notes.csv")

# minmax functions for time range
minmax <- function(x) {
  c(min(x), max(x))
}
