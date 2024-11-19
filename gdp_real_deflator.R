library(tidyverse)

setwd("~/My Documents/inflation-dash")

# Quarterly GDP and components - expenditure approach - volume and price indices
# https://data-explorer.oecd.org/vis?df%5Bds%5D=dsDisseminateFinalDMZ&df%5Bid%5D=DSD_NAMAIN1@DF_QNA_EXPENDITURE_INDICES&df%5Bag%5D=OECD.SDD.NAD&df%5Bvs%5D=1.1&dq=Q............&lom=LASTNPERIODS&lo=5&to%5BTIME_PERIOD%5D=false

data <- read_csv("data/oecd_quarterly_gdp_expenditure_approach.csv")

data |>
    distinct(`Economic activity`)

clean_data <- data |>
    filter(
        `Frequency of observation` == "Quarterly",
        Transaction == "Gross domestic product"
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

wide_data <- clean_data |>
    pivot_wider(names_from = price_base, values_from = value)

wide_data <- wide_data |>
    rename(
        chain_linked_valume_index = `Chain linked volume (rebased)`,
        deflator_index = `Deflator (rebased)`
    )

write_csv(wide_data, "volume_deflator.csv")
