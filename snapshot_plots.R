library(tidyverse)
library(zoo)
library(ggrepel)

# Main data
data = read_csv("./inflation-decomposer/data/merged_data.csv")

# Income components contributions series
income_comps = c(
  "contr_unit_labor_cost", 
  "contr_unit_profit", 
  "contr_unit_tax"
)

# Nominal series
nom_series = c('lab_comp', 'profits', 'taxes')

# Growth in wages, profits, taxes, and real GDP series
growth_series = c('pc_lab_comp', 'pc_profits', 'pc_taxes','pc_rgdp')

countries = unique(data$reference_area)
# "Australia", "Austria", "Belgium", "Canada", "Czechia", "Denmark", "Estonia", "Euro area (20 countries)", "European Union (27 countries from 01/02/2020)", "Finland", "France", "Germany", "Greece", "Hungary", "Israel", "Italy", "Japan", "Latvia", "Lithuania", "Luxembourg", "Netherlands", "Norway", "Poland", "Portugal", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "Türkiye", "United Kingdom", "United States"

countries_to_exclude = c(
  "Czechia", "Estonia", "Euro area (20 countries)", "European Union (27 countries from 01/02/2020)", "Hungary", "Israel", "Japan", "Latvia", "Lithuania", "Norway", "Poland", "Slovak Republic", "Slovenia", "Türkiye"
)

countries_selected = countries[!countries %in% countries_to_exclude]

# Four-quarter trailing moving average ----
### Percent growth in nominal incomes
data |>
  filter(time >= as.Date('2018-01-01')) |>
  filter(reference_area %in% countries_selected) |>
  filter(series %in% c('pc_lab_comp', 'pc_profits', 'pc_rgdp')) |>
  group_by(reference_area, series) |>
  mutate(ma_trailing = rollmean(value, k=4, fill = NA, align = 'right')) |>
  group_by(series, time) |>
  summarize(mean_ma_trailing = mean(ma_trailing, na.rm = TRUE)) |>
  filter(time >= as.Date('2019-01-01')) |>
  ggplot(aes(time, mean_ma_trailing, color = series)) +
  geom_line(linewidth=0.6) +
  labs(
    x=NULL, 
    y=NULL, 
    title = 'Annual Growth in Key Variables (%), Quarterly'
  ) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_color_manual(
    values = c(
      "pc_lab_comp" = "#30123BFF", 
      "pc_profits" = "#1AE4B6FF", 
      "pc_rgdp" = "#FB8022FF"
    ),
    labels = c("Labor compensation", "Profits", "Real GDP")
  ) +
  theme(
    plot.title = element_text(size = 8),
    legend.title = element_blank(),
    legend.position = 'inside',
    legend.position.inside = c(0.25, 0.725),
    legend.background = element_rect(fill = 'transparent'),
    legend.key = element_rect(fill = 'transparent')
  )

ggsave(
  './assets/wages_profits_rgdp.jpeg', 
  width = 12, 
  height = 8, 
  units = 'cm',
  scale = 1
)

### Contributions
data |>
  filter(time >= as.Date('2018-01-01')) |>
  filter(reference_area %in% countries_selected) |>
  filter(series %in% c('contr_unit_profit', 'contr_unit_labor_cost', 'inflation_def')) |>
  group_by(reference_area, series) |>
  mutate(ma_trailing = rollmean(value, k=4, fill = NA, align = 'right')) |>
  group_by(series, time) |>
  summarize(mean_ma_trailing = mean(ma_trailing, na.rm = TRUE)) |>
  filter(time >= as.Date('2019-01-01')) |>
  ggplot(aes(time, mean_ma_trailing, color = series)) +
  geom_line(linewidth=0.6) +
  labs(
    x = NULL, 
    y = NULL, 
    title = "Annual Contribution of Unit Labor Costs and Unit Profits to Deflator Inflation (%)", 
    subtitle = "Quarterly, 2019-Q1 to 2024-Q2"
  ) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_color_manual(
    values = c(
      "contr_unit_labor_cost" = "#30123BFF", 
      "contr_unit_profit" = "#1AE4B6FF", 
      "inflation_def" = "#D23105FF"
    ),
    labels = c("Unit labor costs", "Unit profits", "Deflator inflation")
  ) +
  theme(
    plot.title = element_text(size = 8),
    plot.subtitle = element_text(size = 7),
    legend.title = element_blank(),
    legend.position = 'inside',
    legend.position.inside = c(0.2, 0.76),
    legend.background = element_rect(fill = 'transparent'),
    legend.key = element_rect(fill = 'transparent')
  )

  ggsave(
    './assets/contributions.jpeg', 
    width = 12, 
    height = 8, 
    units = 'cm',
    scale = 1
  )

# Average across countries
data |>
  filter(reference_area %in% countries_selected) |>
  filter(between(time, as.Date('2000-01-01'), as.Date('2023-04-01'))) |>
  filter(series %in% c('pc_lab_comp', 'pc_profits')) |>
  mutate(year = year(time)) |>
  mutate(decade = case_when(
    year < 2020 ~ "2000-19",
    year >= 2020 ~ "2020-23" 
  ), .after = year) |>
  group_by(series, decade) |>
  summarize(mean = mean(value, na.rm = TRUE)) |>
  ggplot(aes(mean, decade, color = series, 
    label = sprintf("%0.2f", mean))) +
  geom_point(size = 2) +
  geom_text_repel(vjust = -1, color = 'black', size = 3) +
  labs(
    x = NULL, 
    y = NULL, 
    title = 'Average Annual Growth in Labor Compensation and Profits (%), 2000-Q1 to 2023-Q2',
    caption = 'Notes: Based on quarterly data from eighteen OECD-member countries. 2020-2023 captures 2020-Q1 \nto 2023-Q2.'
  ) +
  scale_color_manual(
    values = c('pc_lab_comp' = "#30123BFF", 'pc_profits' = "#31F299FF"),
    labels = c('Labor compensation', 'Profits')
  ) +
  theme(
    plot.title = element_text(size = 8),
    plot.caption = element_text(size = 6, hjust = 0),
    legend.title = element_blank(),
    legend.position = 'bottom',
    legend.background = element_rect(fill = 'transparent'),
    legend.key = element_rect(fill = 'transparent'),
    legend.margin = margin(t=-5),
  )

ggsave(
  './assets/wages_profits_period.jpeg', 
  width = 12, 
  height = 8, 
  units = 'cm',
  scale = 1
)

# Comparison numbers referred in the text
data |>
  filter(reference_area %in% countries_selected) |>
  filter(between(time, as.Date('2000-01-01'), as.Date('2023-04-01'))) |>
  filter(series %in% c('pc_lab_comp', 'pc_profits')) |>
  mutate(year = year(time)) |>
  mutate(decade = case_when(
    year < 2020 ~ "2000-19",
    year >= 2020 ~ "2020-23" 
  ), .after = year) |>
  group_by(series, decade) |>
  summarize(mean = mean(value, na.rm = TRUE)) 

# The last quarter in which profits grew faster than wages
data |>
  filter(time >= as.Date('2018-01-01')) |>
  filter(reference_area %in% countries_selected) |>
  filter(series %in% c('pc_lab_comp', 'pc_profits', 'pc_rgdp')) |>
  group_by(reference_area, series) |>
  mutate(ma_trailing = rollmean(value, k=4, fill = NA, align = 'right')) |>
  group_by(series, time) |>
  summarize(mean_ma_trailing = mean(ma_trailing, na.rm = TRUE)) |>
  filter(time >= as.Date('2019-01-01')) |>
  pivot_wider(names_from = series, values_from = mean_ma_trailing) |>
  print(n=30)
