library(shiny)
library(bslib)
library(tidyverse)
library(gt)

data = read.csv("data/merged_data.csv")
data <- mutate(data, time = as.Date(time))

# Decadal averages data
data_avg <- read.csv("data/merged_data_avg.csv")

income_comps = c("contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax")

light = bs_theme(bootswatch = "cerulean")
