library(tidyverse)

# Consumer price indices (CPIs, HICPs), COICOP 1999
# https://data-explorer.oecd.org/vis?fs%5B0%5D=Topic,1%7CEconomy%23ECO%23%7CPrices%23ECO_PRI%23&pg=0&fc=Topic&bp=true&snb=30&df%5Bds%5D=dsDisseminateFinalDMZ&df%5Bid%5D=DSD_PRICES@DF_PRICES_ALL&df%5Bag%5D=OECD.SDD.TPS&df%5Bvs%5D=1.0&dq=.M.N.CPI.._T.N.GY+_Z&lom=LASTNPERIODS&lo=13&to%5BTIME_PERIOD%5D=false

data = read_csv("data/oecd_cpi_coicop1999.csv")
data |>
  distinct(`Reference area`)

data |>
  distinct(Adjustment) |>
  print(n=30)

# Quarterly data are available for only 4 countries!?
data |>
  filter(`Frequency of observation` == "Quarterly") |>
  distinct(`Reference area`)

data |>
  filter(`Frequency of observation` == "Monthly") |>
  distinct(`Reference area`)


clean_data = data |>
  filter(
   `Frequency of observation` == "Quarterly",
   `Unit of measure` == "Index",
   Expenditure == "Total",
   Adjustment == "Seasonally adjusted, not calendar adjusted"
  ) |>
  select(`Reference area`, REF_AREA, TIME_PERIOD, OBS_VALUE) |>
    rename(
      reference_area = `Reference area`,
      ref_area = REF_AREA,
      time = TIME_PERIOD,
      value = OBS_VALUE
  ) |>
  mutate(time = yq(time)) |>
  arrange(ref_area, time)

readr::write_csv(clean_data, file = "cpi.csv")