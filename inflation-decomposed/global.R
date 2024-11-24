library(shiny)
library(bslib)
library(dplyr)
library(readr)
library(ggplot2)
library(gt)

# Main data
data = read_csv("data/merged_data.csv")
data <- mutate(data, time = as.Date(time))

# Decadal averages data
data_avg <- read_csv("data/merged_data_avg.csv")

income_comps = c("contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax")

# Country notes
country_notes <- read_csv("data/country_notes.csv")
