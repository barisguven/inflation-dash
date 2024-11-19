library(tidyverse)

setwd("~/My Documents/inflation-dash")

# Quarterly GDP and components - output approach ----
data <- read_csv("oecd_gdp.csv")

## Annual GDP ----
gdp_annual <- data |>
    filter(
        Transaction == "Gross domestic product",
        `Frequency of observation` == "Annual",
        Adjustment == "Neither seasonally adjusted nor calendar adjusted"
    ) |>
    select(c(`Reference area`, REF_AREA, `Price base`, TIME_PERIOD, OBS_VALUE)) |>
    rename(
        reference_area = `Reference area`,
        ref_area = REF_AREA,
        price_base = `Price base`,
        time = TIME_PERIOD,
        value = OBS_VALUE
    ) |>
    mutate(time = as.numeric(time)) |>
    arrange(ref_area, time)

gdp_annual_wide <- gdp_annual |>
    pivot_wider(names_from = price_base, values_from = value)

gdp_annual_wide |>
    filter(reference_area == "Türkiye") |>
    ggplot(aes(time, `Chain linked volume`)) +
    geom_line()

## Quarterly GDP ----
gdp_quarterly <- data |>
    filter(
        Transaction == "Gross domestic product",
        `Frequency of observation` == "Quarterly",
        Adjustment == "Calendar and seasonally adjusted"
    ) |>
    select(c(`Reference area`, REF_AREA, `Price base`, TIME_PERIOD, OBS_VALUE)) |>
    rename(
        reference_area = `Reference area`,
        ref_area = REF_AREA,
        price_base = `Price base`,
        time = TIME_PERIOD,
        value = OBS_VALUE
    ) |>
    mutate(time = yq(time)) |>
    arrange(ref_area, time)

gdp_quarterly_wide <- gdp_quarterly |>
    pivot_wider(names_from = price_base, values_from = value)

gdp_quarterly_wide <- gdp_quarterly_wide |>
    rename(
        chain_linked_volume = `Chain linked volume`,
        constant = `Constant prices`,
        current = `Current prices`
    )

gdp_quarterly_wide |>
    filter(reference_area == "Türkiye") |>
    ggplot(aes(time, chain_linked_volume)) +
    geom_line()
