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
        aes(time, value, color = "inflation_def"), linewidth=0.6) +
      scale_fill_viridis_d(
        breaks = c("contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax"),
        labels = c("Unit labor cost", "Unit profit", "Unit tax"),
        option = "turbo") +
      scale_color_manual(
        labels = "Deflator",
        values = c("inflation_def" = "red")
      ) +
      labs(title = paste0("Contributions to Annual Inflation, Quarterly, ", input$country)) +
      theme(
        plot.title = element_text(size = 14),
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
      geom_line(linewidth=0.7) +
      scale_color_brewer(
        breaks = c("inflation_def", "inflation_cpi"),
        labels = c("Deflator", "Consumer Price Index"),
        palette = "Dark2") +
      labs(y = "Percent", x = NULL, title = paste0("Deflator vs. CPI Inflation, ", input$country)) +
      theme(
        plot.title = element_text(size = 14),
        axis.text = element_text(size = 12),
        axis.title.y = element_text(size=14),
        legend.text = element_text(size = 12),
        legend.title = element_blank(),
        legend.position = "bottom",
        legend.margin = margin(t=-5)
      )
  })

  output$table_quarterly <- render_gt({
    data |>
      filter(reference_area == input$country) |>
      filter(series %in% c("inflation_def", "inflation_cpi", income_comps)) |>
      pivot_wider(names_from = series, values_from = value) |>
      select(c(reference_area, time, contr_unit_labor_cost,
              contr_unit_profit, contr_unit_tax,
              inflation_def, inflation_cpi)) |>
      rename(
        Country = reference_area,
        Quarter = time,
        `Unit labor cost` = contr_unit_labor_cost,
        `Unit profit` = contr_unit_profit,
        `Unit tax` = contr_unit_tax,
        Deflator = inflation_def,
        CPI = inflation_cpi
      ) |>
      arrange(desc(Quarter)) |>
      gt() |>
      fmt_number(columns = 3:7, decimals = 2) |>
      fmt_date(columns = Quarter, date_style = "year_quarter") |>
      opt_stylize(style = 6, color = "gray")
  })
  
  output$decadal_avg = renderPlot({
    data_avg |>
      filter(var == "mean") |>
      filter(series %in% income_comps) |>
      filter(reference_area == input$country) |>
      ggplot(aes(decade, value, fill = series)) +
      geom_bar(stat = "identity", position = position_dodge()) +
      scale_fill_manual(
        values = c("contr_unit_labor_cost" = "#30123BFF", "contr_unit_profit" = "#1AE4B6FF", "contr_unit_tax" = "#FABA39FF"),
        labels = c("Unit labor cost", "Unit profit", "Unit tax")) +
      labs(x=NULL, y="Percent", title = paste0("Decadal Contributions, ", input$country)) +
      theme(
        plot.title = element_text(size = 14),
        axis.text = element_text(size = 12),
        axis.title.y = element_text(size=14),
        legend.text = element_text(size = 12),
        legend.title = element_blank(),
        legend.position = "bottom",
        legend.margin = margin(t=-5)
      )
  })

  output$table_decadal <- render_gt({
    data_avg |>
      filter(var == "mean") |>
      filter(series %in% income_comps) |>
      filter(reference_area == input$country) |>
      select(reference_area, series, decade, value) |>
      pivot_wider(names_from = series, values_from = value) |>
      rename(
        "Country" = reference_area,
        "Decade" = decade,
        "Unit labor cost" = contr_unit_labor_cost,
        "Unit profit" = contr_unit_profit,
        "Unit tax"  = contr_unit_tax
      ) |>
      gt() |>
      fmt_number(columns = 3:5, decimals = 2) |>
      cols_align("left", columns = 2) |>
      opt_stylize(style = 6, color = "gray")
  })

  ymaxFind <- reactive({
    ymax = data |>
      filter(reference_area == input$country) |>
      filter(series %in% income_comps) |>
      filter(time >= as.Date("2020-01-01")) |>
      group_by(time) |>
      summarise(sum = sum(value, na.rm = TRUE)) |>
      pull(sum) |>
      max()

    ymax + 1
  })

  output$pandemic <- renderPlot({
    data |>
      filter(reference_area == input$country) |>
      filter(series %in% income_comps) |>
      filter(time >= as.Date("2020-01-01")) |>
      ggplot(aes(x = time, y = value, fill = series)) +
      geom_bar(stat = "identity") +
      labs(x="", y="Percent") +
      geom_line(
        data = filter(data, reference_area == input$country, series == "inflation_def", time >= as.Date("2020-01-01")), 
        aes(time, value, color = "inflation_def"), linewidth=0.6) +
      geom_vline(xintercept = as.Date("2020-01-01"), linewidth = 0.6, color = "grey50", linetype = "dashed") +
        annotate(geom = "text", label = "Covid-19 starts", x = as.Date("2020-01-10"), y = ymaxFind(), color="grey50", hjust = "left", vjust = "bottom") +
      geom_vline(xintercept = as.Date("2022-01-01"), linewidth = 0.6, color = "grey50", linetype = "dashed") +
      annotate(geom = "text", label = "Russia invades Ukraine", x = as.Date("2022-01-10"), y = ymaxFind(), color="grey50", hjust = "left", vjust = "bottom") +
      scale_fill_viridis_d(
        breaks = c("contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax"),
        labels = c("Unit labor cost", "Unit profit", "Unit tax"),
        option = "turbo") +
      scale_color_manual(
        labels = "Deflator",
        values = c("inflation_def" = "red")
      ) +
      labs(title = paste0("Annual Contributions since the Pandemic, Quarterly, ", input$country)) +
      theme(
        plot.title = element_text(size = 14),
        axis.text = element_text(size = 12),
        axis.title.y = element_text(size=14),
        legend.text = element_text(size = 12),
        legend.title = element_blank(),
        legend.position = "bottom",
        legend.margin = margin(t=-18)
      )
  })
}