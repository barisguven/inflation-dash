ui <- page_navbar(
  tags$head(includeHTML("google-analytics.html")),
  title = "Decomposing Inflation",
  theme = bs_theme(bootswatch = "cosmo"),
  underline = FALSE,
  sidebar = sidebar(
    helpText(
      "This dashboard displays the contribution of unit labor costs, unit profits, and unit net taxes to inflation measured through the percentage change in the GDP deflator for a given country. See",
      a("here", href = "https://github.com/barisguven/inflation-decomposer/blob/main/README.md", target = "_blank"),
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
    title = "Contributions of Unit Incomes to Annual Inflation",
    icon = icon("chart-simple"),
    layout_column_wrap(
      navset_card_tab(
        title = NULL,
        full_screen = TRUE,
        nav_panel(title = "Pandemic Contributions", plotOutput("pandemic")),
        nav_panel(title = "Relative", plotOutput("rel_contr")),
        nav_panel(title = "Labor Share", plotOutput("ls")),
        nav_panel(title = "Real Incomes", plotOutput("real_inc"))  
      ),
      navset_card_tab(
        title = NULL,
        full_screen = TRUE,
        nav_panel(title = "Pandemic Inflation", plotOutput("def_vs_cpi_pand")),
        nav_panel(title = "Overall", plotOutput("def_vs_cpi"))
      )
      #card(plotOutput("def_vs_cpi"), full_screen = TRUE)
    ),
    layout_column_wrap(
      card(plotOutput("decomp"), full_screen = TRUE),
      card(plotOutput("decadal_avg"), full_screen = TRUE)
    )
  ),

  nav_panel(
    title = "Tables",
    icon = icon("table"),
    layout_columns(
      col_widths = c(7, 5),
      card(
        gt_output("table_quarterly"), 
        downloadButton("download_quarterly")
      ),
      card(
        gt_output("table_decadal"), 
        downloadButton("download_decadal")
      ),
    )
  ),
  nav_spacer(),
  nav_item(
    a(
      icon("github"),
      href = "https://github.com/barisguven/inflation-decomposer",
      target = "_blank"
    )
  ),
  nav_item(input_dark_mode(mode = "light"))
)