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

# minmax function to find the time range
minmax <- function(x) {
  c(min(x), max(x))
}

# US industry data
us_ind_cg = read_csv("data/us_ind_cg.csv")
us_ind_index = read_csv("data/us_ind_index.csv")

# Dashboard plot theme settings
theme_update(
  plot.title = element_text(size = 14),
  plot.subtitle = element_text(size = 12),
  axis.text = element_text(size = 12),
  axis.title.y = element_text(size = 12),
  legend.text = element_text(size = 12),
  legend.title = element_blank(),
  legend.position = 'bottom',
  legend.margin = margin(t=-5)
)