server <- function(input, output, session) {
  # Plots ----
    ## Top left: pandemic focus ----
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
        filter(!is.na(value)) |>
        filter(time >= as.Date("2019-01-01")) |>
        ggplot(aes(x = time, y = value, fill = series)) +
        geom_bar(stat = "identity") +
        labs(x=NULL, y=NULL) +
        geom_line(
          data = filter(data, reference_area == input$country, series == "inflation_def", time >= as.Date("2019-01-01")),
          aes(time, value, color = "inflation_def"), linewidth=0.7) +
        geom_vline(
          xintercept = as.Date("2020-01-01"),
          linewidth = 0.6,
          color = "grey50",
          linetype = "dashed"
        ) +
        annotate(
          geom = "text",
          label = "Covid-19 starts",
          x = as.Date("2020-01-10"),
          y = ymaxFind(),
          color="grey50",
          hjust = "left",
          vjust = "bottom"
        ) +
        geom_vline(
          xintercept = as.Date("2022-01-01"),
          linewidth = 0.6,
          color = "grey50",
          linetype = "dashed"
        ) +
        annotate(
          geom = "text",
          label = "Russia invades Ukraine",
          x = as.Date("2022-01-10"),
          y = ymaxFind(),
          color="grey50",
          hjust = "left",
          vjust = "bottom"
        ) +
        scale_fill_manual(
          values = c(
            "contr_unit_labor_cost" = "#30123BFF",
            "contr_unit_profit" = "#1AE4B6FF",
            "contr_unit_tax" = "#FABA39FF"
          ),
          labels = c("Unit labor costs", "Unit profits", "Unit net taxes")) +
        scale_color_manual(
          labels = "Deflator inflation",
          values = c("inflation_def" = "#D23105FF")
        ) +
        scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
        labs(title = paste0("Annual Contributions since the Pandemic (%), Quarterly, ", input$country))
    })

    ## Relative Contributions, Quarterly ----
    output$rel_contr <- renderPlot({
      data |>
        filter(reference_area == input$country) |>
        filter(time >= as.Date("2019-01-01")) |>
        filter(series == "contr_relative") |>
        filter(!is.na(value)) |>
        ggplot(aes(time, value)) +
        geom_col(fill = "#30123BFF") +
        scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
        labs(
          x=NULL,
          y=NULL,
          title = paste0("Contribution of Unit Labor Costs to That of Unit Profits, Quarterly, ", input$country)
        )
    })

    ## Labor Share ----
    output$ls <- renderPlot({
      data |>
        filter(reference_area == input$country) |>
        filter(time >= as.Date("2019-01-01")) |>
        filter(series == "labor_share") |>
        filter(!is.na(value)) |>
        ggplot(aes(time, value)) +
        geom_line(linewidth = 0.8, color = "#30123BFF") +
        scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
        labs(
          x=NULL,
          y=NULL,
          title = paste0("Labor Share, Quarterly, ", input$country)
        )
    })

    ## Real incomes ----
    output$real_inc <- renderPlot({
      data_real_inc |>
      filter(reference_area == input$country) |>
      filter(series %in% c("real_labor_comp_def", "real_surplus_def")) |>
      ggplot(aes(time, value, color = series)) +
      geom_line(linewidth = 0.8) +
      scale_color_manual(
        values = c(
          "real_labor_comp_def" = "#30123BFF",
          "real_surplus_def" = "#1AE4B6FF"
        ),
        labels = c("Real labor income", "Real profits")
      ) +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
      labs(
        x=NULL,
        y=NULL,
        title = paste0("Real Incomes Indices (2019-Q1=100), Quarterly, ", input$country)
      )
    })

  ## Top right: deflator vs. CPI ----
  output$def_vs_cpi <- renderPlot({
    data |>
      filter(series %in% c("inflation_def", "inflation_cpi")) |>
      filter(reference_area == input$country) |>
      filter(!is.na(value)) |>
      ggplot(aes(time, value, color = series)) +
      geom_line(linewidth=0.8) +
      scale_color_manual(
        values = c(
          "inflation_cpi" = "#30123BFF",
          "inflation_def" = "#D23105FF"
        ),
        labels = c("Consumer Price Index", "Deflator")) +
      labs(
        x = NULL,
        y = NULL,
        title = paste0("Annual Deflator vs. CPI Inflation (%), Quarterly, ", input$country)
      )
  })

  output$def_vs_cpi_pand <- renderPlot({
    data |>
      filter(series %in% c("inflation_def", "inflation_cpi")) |>
      filter(reference_area == input$country) |>
      filter(time >= as.Date("2019-01-01")) |>
      filter(!is.na(value)) |>
      ggplot(aes(time, value, color = series)) +
      geom_line(linewidth=0.8) +
      scale_color_manual(
        values = c(
          "inflation_cpi" = "#30123BFF",
          "inflation_def" = "#D23105FF"
        ),
        labels = c("Consumer Price Index", "Deflator")) +
      labs(
        x = NULL,
        y = NULL,
        title = paste0("Annual Deflator vs. CPI Inflation (%), Quarterly, ", input$country)
      )
  })

#  "#30123BFF" "#4662D7FF" "#36AAF9FF" "#1AE4B6FF" "#72FE5EFF"
#  [6] "#C7EF34FF" "#FABA39FF" "#F66B19FF" "#CB2A04FF" "#7A0403FF"

  ## Bottom left: decompostion quarterly ----
  output$decomp <- renderPlot({
    data |>
      filter(reference_area == input$country) |>
      filter(series %in% income_comps) |>
      filter(!is.na(value)) |>
      ggplot(aes(x = time, y = value, fill = series)) +
      geom_bar(stat = "identity") +
      labs(x=NULL, y=NULL) +
      geom_line(
        data = filter(data, reference_area == input$country, series == "inflation_def", !is.na(value)),
        aes(time, value, color = "inflation_def"), linewidth=0.7) +
      scale_fill_manual(
        values = c(
          "contr_unit_labor_cost" = "#30123BFF",
          "contr_unit_profit" = "#1AE4B6FF",
          "contr_unit_tax" = "#FABA39FF"
        ),
        labels = c("Unit labor costs", "Unit profits", "Unit net taxes")
      ) +
      scale_color_manual(
        labels = "Deflator inflation",
        values = c("inflation_def" = "#D23105FF")
      ) +
      labs(title = paste0("All Contributions to Annual Inflation (%), Quarterly, ", input$country))
  })

  ## Bottom right: decadal average ----
  output$decadal_avg = renderPlot({
    data_avg |>
      filter(var == "mean") |>
      filter(series %in% income_comps) |>
      filter(reference_area == input$country) |>
      filter(!is.na(value)) |>
      ggplot(aes(decade, value, fill = series)) +
      geom_bar(stat = "identity", position = position_dodge()) +
      scale_fill_manual(
        values = c(
          "contr_unit_labor_cost" = "#30123BFF",
          "contr_unit_profit" = "#1AE4B6FF",
          "contr_unit_tax" = "#FABA39FF"
        ),
        labels = c("Unit labor costs", "Unit profits", "Unit net taxes")) +
      labs(
        x=NULL,
        y=NULL,
        title = paste0("Decadal Contributions (%), ", input$country)
      )
  })

#   ## Relative Contributions by Decade ----
#   output$decadal_rel_contr <- renderPlot({
#   data_avg |>
#     filter(var == "mean") |>
#     filter(series == "contr_relative") |>
#     filter(reference_area == input$country) |>
#     filter(!is.na(value)) |>
#     ggplot(aes(value, decade)) +
#     geom_col(fill = "#30123BFF", orientation = "y") +
#     labs(x=NULL, y=NULL, title = paste0("Contribution of Unit Labor Costs to That of Unit Profits, ", input$country)) +
#     theme(
#       plot.title = element_text(size = 14),
#       axis.text = element_text(size = 12)
#     )
# })

  # Tables ----

  ## Quarterly data ----
  data_quarterly <- reactive({
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
        `Unit labor costs` = contr_unit_labor_cost,
        `Unit profits` = contr_unit_profit,
        `Unit net taxes` = contr_unit_tax,
        Deflator = inflation_def,
        CPI = inflation_cpi
      ) |>
      arrange(desc(Quarter))
  })

  output$table_quarterly <- render_gt({
    data_quarterly() |>
      gt() |>
      tab_header(
        title = "Contributions of Unit Incomes to Annual Deflator Inflation"
      ) |>
      fmt_number(columns = 3:7, decimals = 2) |>
      fmt_date(columns = Quarter, date_style = "year_quarter") |>
      sub_missing(columns = 3:7, missing_text = "---") |>
      opt_stylize(style = 6, color = "gray")
  })

  output$download_quarterly <- downloadHandler(
    filename = function() {
      paste0("quarterly_data_", input$country, ".csv")
    },
    content = function(file) {
      write.csv(data_quarterly(), file)
    }
  )

  ## Decadal data ----
  data_decadal <- reactive({
    data_avg |>
      filter(var == "mean") |>
      filter(series %in% income_comps) |>
      filter(reference_area == input$country) |>
      select(reference_area, series, decade, value) |>
      pivot_wider(names_from = series, values_from = value) |>
      filter((!is.na(contr_unit_labor_cost) | !is.na(contr_unit_profit) | !is.na(contr_unit_tax))) |>
      rename(
        "Country" = reference_area,
        "Decade" = decade,
        "Unit labor costs" = contr_unit_labor_cost,
        "Unit profits" = contr_unit_profit,
        "Unit net taxes"  = contr_unit_tax
      )
  })

  output$table_decadal <- render_gt({
    data_decadal() |>
      gt() |>
      tab_header(
        title = "Decadal Contributions of Unit Incomes to Annual Deflator Inflation"
      ) |>
      fmt_number(columns = 3:5, decimals = 2) |>
      sub_missing(columns = 3:5, missing_text = "---") |>
      cols_align("left", columns = 2) |>
      opt_stylize(style = 6, color = "gray")
  })

  output$download_decadal <- downloadHandler(
    filename = function() {
      paste0("decadal_data_", input$country, ".csv")
    },
    content = function(file) {
      write.csv(data_decadal(), file)
    }
  )

  time_range <- reactive({
    time_range = data |>
      filter(reference_area == input$country) |>
      pull(time) |>
      minmax()

    paste0(year(time_range), "-Q", quarter(time_range))
  })

  ## Country notes ----
  output$country_note <- renderUI({

    notes = paste0("Notes: Data are available for ", input$country, " from ", time_range()[1], " through ", time_range()[2], ".")

    if (input$country %in% c("United States", "Canada", "Japan", "Israel")) {
      country_note = country_notes |>
        filter(country == input$country) |>
        pull(note)

      notes = paste(notes, country_note)
    }

    helpText(notes)
  })
}