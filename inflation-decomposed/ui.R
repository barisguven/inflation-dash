ui <- page_navbar(
  title = "inflation-decomposed",
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
      navset_card_tab(
        title = "Deflator vs. CPI",
        full_screen = TRUE,
        nav_panel(title = "Whole Period", plotOutput("def_vs_cpi")),
        nav_panel(title = "Pandemic", plotOutput("def_vs_cpi_pand"))
      )
      #card(plotOutput("def_vs_cpi"), full_screen = TRUE)
    ),
    layout_column_wrap(
      navset_card_tab(
        title = "Pandemic",
        full_screen = TRUE,
        nav_panel(title = "Contributions", plotOutput("pandemic")),
        nav_panel(title = "Labor Share", plotOutput("ls_ps")),
        nav_panel(title = "Relative Contr.", plotOutput("rel_contr"))  
      ),
      navset_card_tab(
        title = "Decadal",
        full_screen = TRUE,
        nav_panel(title = "Contributions", plotOutput("decadal_avg")),
        nav_panel("Relative Contributions", plotOutput("decadal_rel_contr"))
      )
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
      href = "https://github.com/barisguven/inflation-decomposed",
      target = "_blank"
    )
  ),
  nav_item(input_dark_mode(mode = "light"))
)