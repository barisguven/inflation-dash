library(shiny)
library(bslib)
library(tidyverse)
library(gt)

data = read.csv("../merged_data.csv")
data <- mutate(data, time = as.Date(time))

income_comps = c("contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax")

ui <- page_sidebar(
  title = "Inflation-dash",
  sidebar = sidebar(
    helpText(
      "This dashboard displays annual inflation based on GDP deflator and Consumer Price Index using quarterly data. It also displays the contribution of unit labor cost, unit profit, and unit tax to inflation measured through the percentage change in the GDP deflator for a given country."
    ),
    selectInput(
      "country",
      "Select a country:",
      choices = c(unique(data$reference_area))
    )
  ),
  card(
    plotOutput("decomp"),
    #plotOutput("cpi_vs_def")
  )
)

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
        aes(time, value, color = "inflation_def")) +
      scale_fill_viridis_d(
        breaks = c("contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax"),
        labels = c("Unit labor cost", "Unit profit", "Unit tax"),
        option = "turbo") +
      scale_color_manual(
        labels = "Deflator",
        values = c("inflation_def" = "red")
      ) +
      theme(
        legend.title = element_blank(),
        legend.position = "bottom"
      )
  })
}

shinyApp(ui, server)








