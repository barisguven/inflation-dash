library(tidyverse)

# Merge income components with deflator and volume series ----
income_data <- read_csv("income_components.csv")
deflator_data <- read_csv("volume_deflator.csv")
cpi_data <- read_csv("cpi.csv")

data <- left_join(income_data, deflator_data)
data <- left_join(data, cpi_data)

data |>
    distinct(reference_area) |>
    write_lines(file="country_list.txt")

country_groups = c(
    "Euro area (20 countries)", 
    "European Union (27 countries from 01/02/2020)"
)

# Decomposition analysis ----
## Annual percentage change in key variables ----
data <- data |>
    group_by(reference_area) |>
    arrange(time, .by_group = TRUE) |>
    mutate(
        inflation_def = 100*(deflator_index/lag(deflator_index, 4) - 1),
        inflation_cpi = 100*(cpi/lag(cpi, 4) - 1),
        pc_lab_comp = 100*(lab_comp/lag(lab_comp, 4) - 1),
        pc_profits = 100*(profits/lag(profits, 4) - 1),
        pc_taxes = 100*(taxes/lag(taxes, 4) - 1),
        pc_rgdp = 100*(rgdp_index/lag(rgdp_index, 4) - 1)
    ) |>
    ungroup()

# Romania miss real GDP and GDP deflator
# Bulgaria, Croatia, and Ireland miss deflator-based inflation all along
data |>
    select(reference_area, time, inflation_def, inflation_cpi) |>
    filter(is.na(inflation_def), !is.na(inflation_cpi)) |>
    print(n=400)

data |>
    filter(!reference_area %in% c("Bulgaria", "Croatia", "Ireland", "Romania")) |>
    group_by(time) |>
    summarise(
        mean_inflation_def = mean(inflation_def, na.rm = TRUE),
        mean_inflation_cpi = mean(inflation_cpi, na.rm = TRUE)
    ) |>
    pivot_longer(cols = 2:3, names_to = "series", values_to = "value") |>
    ggplot(aes(time, value, color = series)) +
    geom_line()

## Unit labor cost, unit profit, and unit taxes (income components per product)
data = data |>
    mutate(
        unit_labor_cost = lab_comp/rgdp_index,
        unit_profit = profits/rgdp_index,
        unit_tax = taxes/rgdp_index
    )

data = data |>
    group_by(reference_area) |>
    arrange(time, .by_group = TRUE) |>
    mutate(
        delta_unit_labor_cost = 100*(unit_labor_cost/lag(unit_labor_cost, n = 4) - 1),
        delta_unit_profit = 100*(unit_profit/lag(unit_profit, n = 4) - 1),
        delta_unit_tax = 100*(unit_tax/lag(unit_tax, n = 4) - 1)
    ) |>
    ungroup()

## Income shares
data = data |>
    mutate(labor_share = lab_comp/gdp,
           profit_share = profits/gdp,
           tax_share = taxes/gdp)

## Contribution of Unit Costs to Inflation ----
data = data |>
    mutate(contr_unit_labor_cost = delta_unit_labor_cost*labor_share,
           contr_unit_profit = delta_unit_profit*profit_share,
           contr_unit_tax = delta_unit_tax*tax_share,
           contr_total = contr_unit_labor_cost + contr_unit_profit + contr_unit_tax,
           contr_relative = contr_unit_labor_cost/contr_unit_profit)

data |>
    filter(!reference_area %in% country_groups) |>
    group_by(time) |>
    summarise(mean_inflation1 = mean(inflation_def, na.rm = TRUE),
              mean_inflation2 = mean(contr_total, na.rm = TRUE)) |>
    ggplot() +
    geom_line(aes(time, mean_inflation1), color = "red") +
    geom_line(aes(time, mean_inflation2), color = "blue")

## Real total wages and total gross surplus
data <- data |>
    mutate(
        real_labor_comp_def = lab_comp/deflator_index,
        real_labor_comp_cpi = lab_comp/cpi,
        real_surplus_def = profits/deflator_index,
        real_surplus_cpi = profits/cpi,
        real_taxes_def = taxes/deflator_index, 
        real_taxes_cpi = taxes/cpi
    )

data_real_incomes = data |>
    select(c(reference_area, ref_area, time, starts_with("real_"))) |>
    filter(time >= as.Date("2019-01-01")) |>
    group_by(ref_area) |>
    arrange(.by_group = TRUE) |>
    mutate(across(starts_with("real"), ~ .x/.x[1]*100)) |>
    ungroup() |>
    pivot_longer(cols = starts_with("real_"), names_to = "series", values_to = "value")

data_real_incomes |>
    filter(reference_area == "Germany") |>
    ggplot(aes(time, value, color = series)) +
    geom_line()

## Make data long
data_long = data |>
    select(c(
        reference_area, ref_area, time, lab_comp, profits, taxes, gdp, rgdp_index, inflation_def, inflation_cpi,labor_share,
        starts_with("contr_"), starts_with("pc_")
    )) |>
    pivot_longer(cols = 4:20, names_to = "series", values_to = "value")

unique(data_long$series)

income_comps = c("contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax")

data_long |>
    filter(!reference_area %in% country_groups) |>
    filter(series %in% income_comps) |>
    group_by(series, time) |>
    summarise(mean = mean(value, na.rm = TRUE)) |>
    ggplot(aes(x = time, y = mean, fill = series)) +
    geom_col()

ref_area_examp = "FRA"
data_long |>
    filter(ref_area == ref_area_examp) |>
    filter(series %in% income_comps) |>
    ggplot(aes(x = time, y = value, fill = series)) +
    geom_col() +
    geom_line(
        data = filter(data_long, ref_area == ref_area_examp, series == "inflation_def"),
        aes(time, value)
    ) +
    geom_line(
        data = filter(data_long, ref_area == ref_area_examp, series == "inflation_cpi"),
        aes(time, value),
        color = "blue"
    )

# Excluding Bulgaria, Croatia, Ireland
data_clean = data_long |>
    filter(!reference_area %in% c("Bulgaria", "Croatia", "Ireland", "Romania"))

write_csv(data_clean, "inflation-decomposed/data/merged_data.csv")

# Write real wages and profits data
data_real_incomes |>
    filter(!reference_area %in% c("Bulgaria", "Croatia", "Ireland", "Romania")) |>
    write_csv(file = "inflation-decomposed/data/merged_data_real_incomes.csv")

# Decadal averages ----
data_clean <- data_clean |>
    mutate(year = year(time), .after = time) |>
    mutate(decade = case_when(
        year < 1960 ~ "1950-59",
        year < 1970 ~ "1960-69",
        year < 1980 ~ "1970-79",
        year < 1990 ~ "1980-89",
        year < 2000 ~ "1990-99",
        year < 2010 ~ "2000-09",
        year < 2020 ~ "2010-19",
        year >= 2020 ~ "2020-" 
    ), .after = year)

data_avg <- data_clean |>
    group_by(reference_area, ref_area, series, decade) |>
    summarize(
        mean = mean(value, na.rm = TRUE),
        sd = sd(value, na.rm = TRUE)
    ) |>
    ungroup() |>
    pivot_longer(
        cols = c(mean, sd), names_to = "var", values_to = "value"
    )

write_csv(data_avg, file = "inflation-decomposed/data/merged_data_avg.csv")

# Country notes ----
country_notes <- tibble(
    country = c("United States", "Canada", "Japan", "Israel"),
    note = c(
        '"Compensation of employees" series is missing from 1959-Q1 to 1968-Q4 in the original data set and computed by subtracting the sum of "Operating surplus and mixed income" and "Taxes on production and imports less subsidies" from "Gross Domestic Product."',
        '"Compensation of employees" series is missing in the original data set and computed by subtracting the sum of "Operating surplus and mixed income" and "Taxes on production and imports less subsidies" from "Gross Domestic Product" for the whole period.',
        'Only "Compensation of employees" series is available in the original data. "Operating surplus and mixed income" is computed by subtracting "Compensation of employees" from "Gross Domestic Product" so it also reflects "Taxes on production and imports less subsidies."',
        'Only "Operating surplus and mixed income" series is available in the original data. "Compensation of employees" is computed by subtracting "Operating surplus and mixed income" from "Gross Domestic Product" so it also reflects "Taxes on production and imports less subsidies."'
    )
)

write_csv(country_notes, file = "inflation-decomposed/data/country_notes.csv")
