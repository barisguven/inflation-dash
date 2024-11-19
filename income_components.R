library(tidyverse)

setwd("~/My Documents/inflation-dash")

# Annual GDP and components - income approach (structure name) ----
# https://data-explorer.oecd.org/vis?fs%5B0%5D=Topic,1%7CEconomy%23ECO%23%7CNational%20accounts%23ECO_NAD%23&pg=40&fc=Topic&bp=true&snb=156&df%5Bds%5D=dsDisseminateFinalDMZ&df%5Bid%5D=DSD_NAMAIN1@DF_QNA_INCOME&df%5Bag%5D=OECD.SDD.NAD&df%5Bvs%5D=1.1&dq=Q..AUT..........&to%5BTIME_PERIOD%5D=false&lo=5&lom=LASTNPERIODS
data <- read_csv("data/oecd_gdp_quarterly_income_approach.csv")

data |>
    select(Transaction, `Economic activity`) |>
    distinct()

clean_data <- data |>
    filter(
        `Frequency of observation` == "Quarterly",
        Adjustment == "Calendar and seasonally adjusted",
        `Economic activity` %in% c("Total - all activities", "Not applicable")
    ) |>
    select(c(`Reference area`, REF_AREA, Transaction,
             `Economic activity`, TIME_PERIOD, OBS_VALUE)) |>
    rename(
        reference_area = `Reference area`,
        ref_area = REF_AREA,
        component = Transaction,
        activity = `Economic activity`,
        time = TIME_PERIOD,
        value = OBS_VALUE
    ) |>
    mutate(time = yq(time)) |>
    arrange(reference_area, component, time)

wide_data <- clean_data |>
    pivot_wider(names_from = component, values_from = value) |>
    arrange(reference_area, time)

wide_data_p1 <- filter(wide_data, activity == "Total - all activities")
wide_data_p2 <- filter(wide_data, activity == "Not applicable")

wide_data_p1 |>
    filter(!is.na(`Taxes on production and imports less subsidies`))

wide_data_p2 |>
    filter(!is.na(`Compensation of employees`))

wide_data_clean <- inner_join(
    wide_data_p1 |>
        select(c(reference_area, ref_area, time, `Compensation of employees`,
                 `Operating surplus and mixed income, gross`)),
    wide_data_p2 |>
        select(c(reference_area, ref_area, time,
                 `Taxes on production and imports less subsidies`,
                 `Gross domestic product`)),
    by = c("reference_area", "ref_area", "time")
)

wide_data_clean <- wide_data_clean |>
    rename(
        labor_compensation = `Compensation of employees`,
        operating_surplus_mixed_income = `Operating surplus and mixed income, gross`,
        taxes_minus_subsidies = `Taxes on production and imports less subsidies`,
        gdp = `Gross domestic product`
    )

write_csv(wide_data_clean, "income_components.csv")

# Sanity Check
wide_data_clean |>
    mutate(test = `Compensation of employees` +
               `Operating surplus and mixed income, gross` +
               `Taxes on production and imports less subsidies` -
               `Gross domestic product`) |>
    group_by(reference_area) |>
    summarise(mean = mean(test, na.rm = T)) |>
    arrange(desc(abs(mean)))

wide_data_clean |>
    mutate(labor_share = `Compensation of employees`/`Gross domestic product`) |>
    ggplot(aes(x = time, y = labor_share, color = ref_area)) +
    geom_line() +
    theme(legend.position = "none")
