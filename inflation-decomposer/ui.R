country_help_text = helpText(
  "This dashboard displays the contribution of unit labor costs, unit profits, and unit net taxes to inflation measured through the percentage change in the GDP deflator for a given country. See",
  a("here", href = "https://github.com/barisguven/inflation-decomposer/blob/main/README.md", target = "_blank"),
  "for the underlying framework.")

industry_help_text = helpText("This panel compares the compound average annual growth rate of labor compensation and gross operating surplus across industries for 1997-2019 and 2019-2023. Here, you can also select a two- or three-digit industry to view the changes in gross operating surplus (mostly profits), labor compensation (mostly wages and salaries), and net taxes in that industry for 2019-2023 at the bottom section of the panel.", tags$br(), tags$br(), "Notes: Only US data are available at the moment.")

ui = page_navbar(
  tags$head(includeHTML("google-analytics.html")),
  id = "nav",
  title = "Decomposing Inflation",
  theme = bs_theme(bootswatch = "cosmo"),
  underline = FALSE,
  sidebar = sidebar(
    conditionalPanel(
      "input.nav == 'Contributions of Unit Incomes to Annual Inflation' | input.nav == 'Tables'",
      country_help_text,
      selectInput(
        "country",
        "Select a country:",
        choices = c(unique(data$reference_area)),
        selected = "Türkiye"
      ),
      uiOutput("country_note")
    ),
    conditionalPanel(
      "input.nav == 'Industry Breakdown'",
      industry_help_text,
      selectInput(
        "industry",
        "Select an industry:",
        choices = c(unique(us_ind_cg$ind_title)),
        selected = "Mining"
      ),
      selectInput(
        "sub_industry",
        "Select a sub-industry:",
        choices = NULL
      )
    )
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
      )
    )
  ),
  nav_panel(
    title = "Industry Breakdown",
    icon = icon("layer-group"),
    card(
      full_screen = TRUE,
      tags$b("Compound Average Annual Growth in Labor Compensation and Gross Operating Surplus (%)", style = "text-align:center"),
      layout_column_wrap(
        plotOutput("ind_plot_comp1"),
        plotOutput("ind_plot_comp2")
      )
    ),
    layout_column_wrap(
      max_height = "270px",
      card(plotOutput("ind_plot")),
      card(plotOutput("ind_plot_tax"))
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