library(tidyverse)

# Annual GDP and components - income approach (structure name) ----
# https://data-explorer.oecd.org/vis?fs%5B0%5D=Topic,1%7CEconomy%23ECO%23%7CNational%20accounts%23ECO_NAD%23&pg=40&fc=Topic&bp=true&snb=156&df%5Bds%5D=dsDisseminateFinalDMZ&df%5Bid%5D=DSD_NAMAIN1@DF_QNA_INCOME&df%5Bag%5D=OECD.SDD.NAD&df%5Bvs%5D=1.1&dq=Q..AUT..........&to%5BTIME_PERIOD%5D=false&lo=5&lom=LASTNPERIODS
data <- read_csv("data_oecd/oecd_gdp_quarterly_income_approach.csv")

data |>
    select(Transaction, `Economic activity`, Adjustment) |>
    distinct() |>
    arrange(Transaction)

# For compensation of employees and operating surplus, economic activity is stated as "Total - all activities" whereas for taxes and GDP it is stated as "Not applicable"

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

# Checking data availability
wide_data_p1 |>
    filter(is.na(`Compensation of employees`)) |>
    group_by(reference_area) |>
    count(sort = TRUE)

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

wide_data_clean |>
    filter(is.na(labor_compensation)) |>
    group_by(reference_area) |>
    count(sort = TRUE)

wide_data_clean |>
    filter(is.na(operating_surplus_mixed_income)) |>
    group_by(reference_area) |>
    count(sort = TRUE)

wide_data_clean |>
    filter(is.na(taxes_minus_subsidies)) |>
    group_by(reference_area) |>
    count(sort = TRUE)

canada <- filter(wide_data_clean, ref_area == "CAN")
usa <- filter(wide_data_clean, ref_area == "USA")
japan <- filter(wide_data_clean, ref_area == "JPN")
israel <- filter(wide_data_clean, ref_area == "ISR")

# Canada (fully) and USA have missing labor compensation data.
# I use the other two components and GDP data to fill in the missing values
canada <- canada |>
    filter(is.na(labor_compensation)) |>
    mutate(labor_compensation = gdp - operating_surplus_mixed_income - taxes_minus_subsidies)

canada |>
    mutate(ls = labor_compensation/gdp) |>
    ggplot(aes(time, ls)) +
    geom_line()

usa = usa |>
    filter(is.na(labor_compensation)) |>
    mutate(labor_compensation = gdp - operating_surplus_mixed_income - taxes_minus_subsidies)

# Japan missing operating surplus and taxes.
# I combine both under operating surplus by subtracting labor compensation from GDP.
japan = japan |>
    mutate(operating_surplus_mixed_income = gdp - labor_compensation)

# Isreal missing labor compensation and taxes.
# I combine both under labor compensation by subtractiong operating surplus from GDP.
israel = israel |>
    mutate(labor_compensation = gdp - operating_surplus_mixed_income)

# Pasting imputed data for Canada, US, Japan, and Israel to main data
wide_data_clean[wide_data_clean$ref_area == "USA" & is.na(wide_data_clean$labor_compensation), "labor_compensation"] <- usa$labor_compensation

wide_data_clean[wide_data_clean$ref_area == "CAN" & is.na(wide_data_clean$labor_compensation), "labor_compensation"] <- canada$labor_compensation

wide_data_clean[wide_data_clean$ref_area == "JPN" & is.na(wide_data_clean$operating_surplus_mixed_income), "operating_surplus_mixed_income"] <- japan$operating_surplus_mixed_income

wide_data_clean[wide_data_clean$ref_area == "ISR" & is.na(wide_data_clean$labor_compensation), "labor_compensation"] <- israel$labor_compensation

# Sanity Check
wide_data_clean |>
    mutate(test = labor_compensation +
               operating_surplus_mixed_income +
               taxes_minus_subsidies -
               gdp) |>
    group_by(reference_area) |>
    summarise(mean = mean(test, na.rm = T)) |>
    arrange(desc(abs(mean)))

wide_data_clean |>
    mutate(labor_share = labor_compensation/gdp) |>
    ggplot(aes(x = time, y = labor_share, color = ref_area)) +
    geom_line() +
    theme(legend.position = "none")

# Write the data to a csv file
write_csv(wide_data_clean, "income_components.csv")