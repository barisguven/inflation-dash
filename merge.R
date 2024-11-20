library(tidyverse)

setwd("~/My Documents/inflation-dash")

# Merge income components with deflator and volume series ----
income_data <- read_csv("income_components.csv")
deflator_data <- read_csv("volume_deflator.csv")
cpi_data <- read_csv("cpi.csv")

data <- left_join(income_data, deflator_data)
data <- left_join(data, cpi_data)

data |>
    distinct(reference_area) |>
    write_lines(file="country_list.txt")

country_groups = c("Euro area (20 countries)", "European Union (27 countries from 01/02/2020)")

# Decomposition analysis ----
## Annual inflation
data <- data |>
    group_by(reference_area) |>
    arrange(time, .by_group = TRUE) |>
    mutate(
        inflation_def = 100*(deflator_index/lag(deflator_index, n = 4) - 1),
        inflation_cpi = 100*(cpi/lag(cpi, n = 4) - 1)
    ) |>
    ungroup()

# Bulgaria, Croatia, and Ireland miss deflator-based inflation all along
data |>
    select(reference_area, time, inflation_def, inflation_cpi) |>
    filter(is.na(inflation_def), !is.na(inflation_cpi)) |>
    print(n=400)

data |>
    filter(!reference_area %in% c("Bulgaria", "Croatia", "Ireland")) |>
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
        unit_labor_cost = labor_compensation/chain_linked_valume_index,
        unit_profit = operating_surplus_mixed_income/chain_linked_valume_index,
        unit_tax = taxes_minus_subsidies/chain_linked_valume_index
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
    mutate(labor_share = labor_compensation/gdp,
           profit_share = operating_surplus_mixed_income/gdp,
           tax_share = taxes_minus_subsidies/gdp)

## Contribution to Inflation of Unit Costs
data = data |>
    mutate(contr_unit_labor_cost = delta_unit_labor_cost*labor_share,
           contr_unit_profit = delta_unit_profit*profit_share,
           contr_unit_tax = delta_unit_tax*tax_share,
           contr_total = contr_unit_labor_cost + contr_unit_profit + contr_unit_tax)

data |>
    filter(!reference_area %in% country_groups) |>
    group_by(time) |>
    summarise(mean_inflation1 = mean(inflation_def, na.rm = TRUE),
              mean_inflation2 = mean(contr_total, na.rm = TRUE)) |>
    ggplot() +
    geom_line(aes(time, mean_inflation1), color = "red") +
    geom_line(aes(time, mean_inflation2), color = "blue")

data_long = data |>
    select(c(reference_area, ref_area, time, inflation_def, inflation_cpi,
        starts_with("contr_"))) |>
    pivot_longer(cols = 4:9, names_to = "series", values_to = "value")

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
        aes(time, value), color = "blue"
    )

write_csv(data_long, "merged_data.csv")




