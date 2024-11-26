ui <- page_navbar(
  title = "Inflation-decomposed",
  theme = bs_theme(bootswatch = "cerulean"),
  underline = FALSE,
  sidebar = sidebar(
    helpText(
      "This dashboard displays the contribution of unit labor costs, unit profits, and unit net taxes to inflation measured through the percentage change in the GDP deflator for a given country. See",
      a("here", href = "https://github.com/barisguven/inflation-decomposed/blob/main/README.md", target = "_blank"),
      "for the underlying framework."
    ),
    selectInput(
      "country",
      "Select a country:",
      choices = c(unique(data$reference_area)),
      selected = "Türkiye"
    ),
    uiOutput("country_note")
  ),

  nav_panel(
    title = "Contributions of Unit Components to Annual Inflation",
    layout_column_wrap(
      card(plotOutput("decomp"), full_screen = TRUE),
      card(plotOutput("def_vs_cpi"), full_screen = TRUE)
    ),
    layout_column_wrap(
      card(plotOutput("decadal_avg"), full_screen = TRUE),
      card(plotOutput("pandemic"), full_screen = TRUE)
    )
  ),

  nav_panel(
    title = "Tables",
    icon = icon("table"),
    layout_columns(
      col_widths = c(7, 5),
      card(
        #card_header("Contributions of Unit Labor Cost, Unit Profit, and Unit Tax to the Percentage Change in GDP Deflator"), 
        gt_output("table_quarterly"), 
        downloadButton("download_quarterly")
      ),
      card(
        #card_header("Contributions of Unit Components to Annual Inflation by Decade"), 
        gt_output("table_decadal"), 
        downloadButton("download_decadal")
      ),
    )
  ),
  nav_spacer(),
  nav_item(
    a(
      icon("github"),
      href = "https://github.com/barisguven/inflation-decomposed",
      target = "_blank"
    )
  ),
  nav_item(input_dark_mode(mode = "light"))
)