library(tidyverse)

data = read_csv('data_usa/GDPByIndustry.csv')

data = rename(data, 'Series' = 'IndustrYDescription')
data = select(data, c(Year, Industry, Series, DataValue))
head(data)

components = c(
  'Gross operating surplus',
  'Compensation of employees',
  'Taxes on production and imports less subsidies'
)

industry_catalog = data |>
  filter(!Series %in% components) |>
  distinct(Industry, Series)

industry_catalog  |> print(n=110)

industries = industry_catalog$Industry
industries_2d = industries[which(str_width(industries) == 2)]
industries_2d = industries_2d[which(!industries_2d %in% c('GF', 'HS'))]
industries_2d = c(industries_2d, '31G', '44RT','48TW', 'G', 'GDP')

industry_2d_names = industry_catalog |>
  filter(Industry %in% industries_2d) |>
  pull(Series)

data_clean = data |> filter(Industry %in% industries_2d)

data_clean = data_clean |>
  mutate(Series = case_when(
    Series == 'Gross operating surplus' ~ 'gos',
    Series == 'Compensation of employees' ~ 'coe',
    Series == 'Taxes on production and imports less subsidies' ~ 'taxes',
    .default = 'va'
  )) |>
  pivot_wider(names_from = Series, values_from = DataValue) |>
  mutate(test = va - (gos + taxes + coe)) |>
  mutate(isGDP = if_else(Industry=='GDP', 1, 0), .after = Industry)

data_clean |>
  select(-test) |>
  pivot_longer(
    cols = c(gos, taxes, coe, va), 
    names_to = 'Series', 
    values_to = 'Value'
  ) |>
  group_by(Series, Year, isGDP) |>
  summarise(sum = sum(Value))

data_index = data_clean |>
  filter(isGDP==0) |>
  select(-c(test, isGDP)) |>
  filter(Year > 2018) |>
  group_by(Industry) |>
  arrange(Year, .by_group = TRUE) |>
  mutate(across(.cols = c(gos, taxes, coe, va), .fns = ~100*.x/.x[1])) |>
  pivot_longer(cols = c(gos, taxes, coe, va), names_to = 'series', values_to = 'value')
  
data_index |>
  filter(Industry %in% c('11', '21', '22', '31G','44RT')) |>
  filter(!series %in% c('va', 'taxes')) |>
  ggplot(aes(Year, value, color = series)) +
  geom_line() +
  facet_wrap(~Industry)

write_csv(data_index, 'inflation-decomposer/data/us_industry_index.csv')
