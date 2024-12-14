library(tidyverse)

data = read_csv('data_usa/GDPByIndustry.csv')

data = rename(data, 'series' = 'IndustrYDescription')
data = data |>
  select(c(Year, Industry, series, DataValue)) |>
  rename(year = Year, ind = Industry, value = DataValue)
head(data)

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
industries_2d = c(industries_2d, '31G', '44RT','48TW', 'G', 'GDP')

industry_2d_title = industry_catalog |>
  filter(ind %in% industries_2d) |>
  pull(ind_title)

data_2d = data |> filter(ind %in% industries_2d)

data_2d = data_2d |>
  mutate(series = case_when(
    series == 'Gross operating surplus' ~ 'gos',
    series == 'Compensation of employees' ~ 'coe',
    series == 'Taxes on production and imports less subsidies' ~ 'taxes',
    .default = 'va'
  )) |>
  pivot_wider(names_from = series, values_from = value) |>
  mutate(test = va - (gos + taxes + coe)) |>
  mutate(isGDP = if_else(ind=='GDP', 1, 0), .after = ind)

data_2d |>
  select(-test) |>
  pivot_longer(
    cols = c(gos, taxes, coe, va), 
    names_to = 'series', 
    values_to = 'value'
  ) |>
  group_by(series, year, isGDP) |>
  summarise(sum = sum(value))

data_2d = select(data_2d, -test)

data_index = data_2d |>
  filter(isGDP==0) |>
  select(-isGDP) |>
  filter(year > 2018) |>
  group_by(ind) |>
  arrange(year, .by_group = TRUE) |>
  mutate(across(.cols = c(gos, taxes, coe, va), .fns = ~100*.x/.x[1])) |>
  ungroup() |>
  pivot_longer(cols = c(gos, taxes, coe, va), names_to = 'series', values_to = 'value')
  
data_index |>
  filter(ind %in% c('11', '21', '22', '31G','44RT')) |>
  filter(!series %in% c('va', 'taxes')) |>
  ggplot(aes(year, value, color = series)) +
  geom_line() +
  facet_wrap(~ind)

write_csv(data_index, 'inflation-decomposer/data/us_industry_index.csv')
write_csv(industry_catalog, 'inflation-decomposer/data/us_industry_catalog.csv')

data_avg_pc = data_2d |>
  select(-isGDP) |>
  pivot_longer(
    cols = c(gos, taxes, coe, va), 
    names_to = 'series', 
    values_to = 'value'
  ) |>
  group_by(ind, series) |>
  arrange(year, .by_group = TRUE) |>
  mutate(value = 100*(value/lag(value, 1) - 1)) |>
  ungroup() |>
  # mutate(period = case_when(
  #   year < 2020 ~ "1997-2019",
  #   year <= 2021 ~ "2019-2021",
  #   year <= 2023 ~ "2021-2023"
  # )) |>
  mutate(period = case_when(
    year < 2020 ~ "1997-2019",
    year <= 2023 ~ "2019-2023",
  )) |>
  group_by(ind, series, period) |>
  summarize(mean = mean(value, na.rm = TRUE)) |>
  ungroup() |>
  left_join(industry_catalog, by = "ind")

write_csv(data_avg_pc, 'inflation-decomposer/data/us_ind_avg_pc.csv')

data_avg_pc |>
  filter(ind == "11", series %in% c("coe", "gos")) |>
  ggplot(aes(mean, period, fill = series)) +
  geom_bar(stat = "identity", position = position_dodge())

data_avg_pc |>
  pivot_wider(names_from = series, values_from = mean) |>
  filter(period == "2019-2023") |>
  arrange(desc(gos))

data_avg_pc |>
  pivot_wider(names_from = series, values_from = mean) |>
  ggplot(aes(coe, gos, color = period)) +
  geom_point()

industry_catalog[industry_catalog$ind=="44RT",]

dot_plot = function (term){
  gos_avg_pc = data_avg_pc |>
  filter(ind %in% industries_2d) |>
  filter(series == "gos") |>
  filter(period == term) |>
  arrange(mean) |>
  mutate(ind_title = factor(ind_title, levels = .data$ind_title))

data_avg_pc |>
  filter(ind %in% industries_2d) |>
  filter(series %in% c("coe", "gos")) |>
  filter(period == term) |>
  mutate(ind_title = factor(ind_title, levels = gos_avg_pc$ind_title)) |>
  ggplot(aes(mean, ind_title)) +
  geom_point(aes(color = series)) +
  geom_line(aes(group = ind), alpha = 0.3)
}

plot_list = map(c("1997-2019", "2019-2023"), dot_plot)
plot_list[[1]]
plot_list[[2]]


