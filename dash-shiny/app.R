library(shiny)
library(bslib)
library(tidyverse)
library(gt)

data = read.csv("../merged_data.csv")
data <- mutate(data, time = as.Date(time))

income_comps = c("contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax")

ui <- page_navbar(
  title = "Inflation-dash",
  sidebar = sidebar(
    helpText(
      "This dashboard displays annual inflation based on GDP deflator and Consumer Price Index using quarterly data. It also displays the contribution of unit labor cost, unit profit, and unit tax to inflation measured through the percentage change in the GDP deflator for a given country."
    ),
    selectInput(
      "country",
      "Select a country:",
      choices = c(unique(data$reference_area)),
      selected = "Türkiye"
    )
  ),
  nav_panel(
    "Quarterly Data",
    layout_columns(
      card(
        card_header("Contributions to Annual Inflation in Percentage Points"),
        plotOutput("decomp"),
        #plotOutput("cpi_vs_def")
      ),
      card(
        card_header("Annual Inflation Based on GDP Deflator vs. Consumer Price Index"),
        plotOutput("def_vs_cpi")
      )
    ),
    card(
      card_header("Contributions of Unit Labor Cost, Unit Profit, and Unit Tax to the Percentage Change in GDP Deflator"),
      tableOutput("table"),
      height = 200
    )
  ),
  nav_panel("By Period", "Page 2 content")
)

# ui <- page_sidebar(
#   title = "Inflation-dash",
#   sidebar = sidebar(
#     helpText(
#       "This dashboard displays annual inflation based on GDP deflator and Consumer Price Index using quarterly data. It also displays the contribution of unit labor cost, unit profit, and unit tax to inflation measured through the percentage change in the GDP deflator for a given country."
#     ),
#     selectInput(
#       "country",
#       "Select a country:",
#       choices = c(unique(data$reference_area)),
#       selected = "Türkiye"
#     )
#   ),
#   layout_columns(
#     card(
#       card_header("Contributions to Annual Inflation in Percentage Points"),
#       plotOutput("decomp"),
#       #plotOutput("cpi_vs_def")
#     ),
#     card(
#       card_header("Annual Inflation Based on GDP Deflator vs. Consumer Price Index"),
#       plotOutput("def_vs_cpi")
#     )
#   ),
#   card(
#     card_header("Contributions of Unit Labor Cost, Unit Profit, and Unit Tax to the Percentage Change in GDP Deflator"),
#     tableOutput("table"),
#     height = "200px"
#   )
# )

server <- function(input, output, session) {
 
  output$decomp <- renderPlot({
    data |>
      filter(reference_area == input$country) |>
      filter(series %in% income_comps) |>
      ggplot(aes(x = time, y = value, fill = series)) +
      geom_bar(stat = "identity") +
      labs(x="", y="Percent") +
      geom_line(
        data = filter(data, reference_area == input$country, series == "inflation_def"), 
        aes(time, value, color = "inflation_def"), size=0.6) +
      scale_fill_viridis_d(
        breaks = c("contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax"),
        labels = c("Unit labor cost", "Unit profit", "Unit tax"),
        option = "turbo") +
      scale_color_manual(
        labels = "Deflator",
        values = c("inflation_def" = "red")
      ) +
      theme(
        axis.text = element_text(size = 12),
        axis.title.y = element_text(size=14),
        legend.text = element_text(size = 12),
        legend.title = element_blank(),
        legend.position = "bottom",
        legend.margin = margin(t=-18)
      )
  })

  output$def_vs_cpi <- renderPlot({
    data |>
      filter(series %in% c("inflation_def", "inflation_cpi")) |>
      filter(reference_area == input$country) |>
      ggplot(aes(time, value, color = series)) +
      geom_line(size=0.7) +
      scale_color_brewer(
        breaks = c("inflation_def", "inflation_cpi"),
        labels = c("Deflator", "Consumer Price Index"),
        palette = "Dark2") +
      labs(y = "Percent", x = "") +
      theme(
        axis.text = element_text(size = 12),
        axis.title.y = element_text(size=14),
        legend.text = element_text(size = 12),
        legend.title = element_blank(),
        legend.position = "bottom",
        legend.margin = margin(t=-18)
      )
  })

  output$table <- renderTable({
    data |>
  filter(reference_area == input$country) |>
  filter(series %in% c("inflation_def", "inflation_cpi", income_comps)) |>
  pivot_wider(names_from = series, values_from = value) |>
  select(c(reference_area, time, contr_unit_labor_cost,
           contr_unit_profit, contr_unit_tax,
           inflation_def, inflation_cpi)) |>
  rename(
    Country = reference_area,
    Period = time,
    `Unit labor cost` = contr_unit_labor_cost,
    `Unit profit` = contr_unit_profit,
    `Unit tax` = contr_unit_tax,
    Deflator = inflation_def,
    CPI = inflation_cpi
  ) |>
  arrange(desc(Period)) |>
  gt() |>
  fmt_number(columns = 3:7, decimals = 2) |>
  fmt_date(columns = Period, date_style = "year_quarter") |>
  opt_stylize(style = 6, color = "gray")
  })
}

shinyApp(ui, server)








