library(tidyverse)

data = read_csv('data_usa/GDPByIndustry.csv')

data = rename(data, series = IndustrYDescription)
data = data |>
  select(c(Year, Industry, series, DataValue)) |>
  rename(year = Year, ind = Industry, value = DataValue)
head(data)

data[data$ind == "31G", "ind"] = "31-32-33"
data[data$ind == "44RT", "ind"] = "44-45"
data[data$ind == "4A0", "ind"] = "459"
data[data$ind == "48TW", "ind"] = "48-49"
data[data$ind == "G", "ind"] = "GF-GS"

components = c(
  'Gross operating surplus',
  'Compensation of employees',
  'Taxes on production and imports less subsidies'
)

industry_catalog = data |>
  filter(!series %in% components) |>
  distinct(ind, series) |>
  rename(ind_title = series)

industry_catalog  |> print(n=110)

industries = industry_catalog$ind
industries_2d = industries[which(str_width(industries) == 2)]
industries_2d = industries_2d[which(!industries_2d %in% c('GF', 'HS'))]
industries_2d = c(industries_2d, '31-32-33', '44-45','48-49', 'GF-GS')

# Computing annual compound growth for 2d industries ----
data_2d = data |> filter(ind %in% industries_2d | ind == "GDP")

data_2d = data_2d |>
  mutate(series = case_when(
    series == 'Gross operating surplus' ~ 'gos',
    series == 'Compensation of employees' ~ 'coe',
    series == 'Taxes on production and imports less subsidies' ~ 'taxes',
    .default = 'va')
  )

# the sum of industry component values add up to the corresponding GDP component
data_2d |>
  pivot_wider(names_from = series, values_from = value) |>
  mutate(isGDP = if_else(ind=='GDP', 1, 0), .after = ind) |>
  pivot_longer(
    cols = c(gos, taxes, coe, va), 
    names_to = 'series', 
    values_to = 'value'
  ) |>
  group_by(series, year, isGDP) |>
  summarise(sum = sum(value))

# simple average annual growth
# data_cg = data_2d |>
#   filter(ind != "GDP") |>
#   group_by(ind, series) |>
#   arrange(year, .by_group = TRUE) |>
#   mutate(value = 100*(value/lag(value, 1) - 1)) |>
#   ungroup() |>
#   mutate(period = case_when(
#     year < 2020 ~ "1997-2019",
#     year <= 2023 ~ "2019-2023",
#   )) |>
#   group_by(ind, series, period) |>
#   summarize(mean = mean(value, na.rm = TRUE)) |>
#   ungroup() |>
#   left_join(industry_catalog, by = "ind")

# compound average annual growth due to the pandemic fluctuations
data_cg = data_2d |>
  filter(ind != "GDP") |>
  pivot_wider(names_from = year, values_from = value) |>
  mutate(
    `1997-2019` = 100*((`2019`/`1997`)^(1/(2019-1997)) - 1),
    `2019-2023` = 100*((`2023`/`2019`)^(1/(2023-2019)) - 1),
  ) |>
  select(c(ind, series, `1997-2019`, `2019-2023`)) |>
  pivot_longer(
    cols = c(`1997-2019`, `2019-2023`),
    names_to = "period",
    values_to = "value"
  ) |>
  left_join(industry_catalog, by = "ind")

# double check industries
unique(data_cg$ind)

write_csv(data_cg, 'inflation-decomposer/data/us_ind_cg.csv')

data_cg |>
  filter(ind == "11", series %in% c("coe", "gos")) |>
  ggplot(aes(value, period, fill = series)) +
  geom_bar(stat = "identity", position = position_dodge())

data_cg |>
  pivot_wider(names_from = series, values_from = value) |>
  filter(period == "2019-2023") |>
  arrange(desc(gos))

data_cg |>
  pivot_wider(names_from = series, values_from = value) |>
  ggplot(aes(coe, gos, color = period)) +
  geom_point()

dot_plot = function (term){
  gos_avg_pc = data_cg |>
  filter(ind %in% industries_2d) |>
  filter(series == "gos") |>
  filter(period == term) |>
  arrange(value) |>
  mutate(ind_title = factor(ind_title, levels = .data$ind_title))

data_cg |>
  filter(ind %in% industries_2d) |>
  filter(series %in% c("coe", "gos")) |>
  filter(period == term) |>
  mutate(ind_title = factor(ind_title, levels = gos_avg_pc$ind_title)) |>
  ggplot(aes(value, ind_title)) +
  geom_point(aes(color = series)) +
  geom_line(aes(group = ind), alpha = 0.3)
}

plot_list = map(c("1997-2019", "2019-2023"), dot_plot)
plot_list[[1]]
plot_list[[2]]

# Indices for 2d industries with sub-industries ----
ind_dash = industries_2d[grep("-", industries_2d)]
ind_nondash = industries_2d[grep("-", industries_2d, invert = TRUE)]
industries_2d_ext = c(ind_nondash, "31", "32", "33", "44", "45", "48", "49", "GF", "GS")

ind_for_index = industry_catalog |>
  filter(str_width(ind) >= 2) |> 
  filter(!ind %in% c('31ND', '33DG')) |>
  filter(str_sub(ind, 1, 2) %in% industries_2d_ext) |>
  pull(ind)

data_index = data |>
  filter(series %in% components) |>
  filter(ind %in% ind_for_index) |>
  filter(year > 2018) |>
  mutate(series = case_when(
    series == 'Gross operating surplus' ~ 'gos',
    series == 'Compensation of employees' ~ 'coe',
    series == 'Taxes on production and imports less subsidies' ~ 'taxes'
  )) |>
  group_by(ind, series) |>
  arrange(year, .by_group = TRUE) |>
  mutate(value = 100*value/value[1]) |>
  ungroup()

data_index = left_join(
  data_index,
  industry_catalog |> filter(ind %in% ind_for_index),
  by = "ind"
)

data_index = data_index |>
  mutate(ind_2d = if_else(ind %in% industries_2d, TRUE, FALSE))

data_index |>
  filter(ind_2d == TRUE) |>
  distinct(ind)

data_index |>
  filter(ind %in% c('11', '21', '22', '31-32-33','44-45')) |>
  filter(!series %in% c('va', 'taxes')) |>
  ggplot(aes(year, value, color = series)) +
  geom_line() +
  facet_wrap(~ind_title)

write_csv(data_index, 'inflation-decomposer/data/us_ind_index.csv')
