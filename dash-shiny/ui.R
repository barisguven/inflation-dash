ui <- page_navbar(
  title = "Inflation-decomposed",
  sidebar = sidebar(
    helpText(
      "This dashboard displays the contribution of unit labor cost, unit profit, and unit tax to inflation measured through the percentage change in the GDP deflator for a given country. For the underlying framework, see here."
    ),
    selectInput(
      "country",
      "Select a country:",
      choices = c(unique(data$reference_area)),
      selected = "Türkiye"
    )
  ),
  #fillable = FALSE,
  nav_panel(
    title = "Contributions of Unit Components to Annual Inflation",
    layout_column_wrap(
      card(plotOutput("decomp"), full_screen = TRUE),
      card(plotOutput("def_vs_cpi"), full_screen = TRUE),
    ),
    layout_column_wrap(
      card(plotOutput("decadal_avg"), full_screen = TRUE),
      card(plotOutput("pandemic"), full_screen = TRUE)
    )
  ),

  nav_panel(
    title = "Tables",
    layout_columns(
      col_widths = c(7, 5),
      card(card_header("Contributions of Unit Labor Cost, Unit Profit, and Unit Tax to the Percentage Change in GDP Deflator"), gt_output("table_quarterly")),
      card(card_header("Contributions of Unit Components to Annual Inflation by Decade"), gt_output("table_decadal")),
    ),
  )

  # nav_panel(
  #   "Quarterly Contributions",
  #   layout_column_wrap(
  #     # card(
  #     #   card_header("Contributions to Annual Inflation in Percentage Points"),
  #     #   plotOutput("decomp"),
  #     #   full_screen = TRUE
  #     # ),
  #     navset_card_tab(
  #       title = "Contributions of Unit Components to Annual Inflation",
  #       nav_panel("Plot", plotOutput("decomp"), full_screen=TRUE),
  #       nav_panel("Table", gt_output("table_quarterly"), height = 300)  
  #     ),
  #     card(
  #       card_header("Annual Inflation Based on GDP Deflator vs. Consumer Price Index"),
  #       plotOutput("def_vs_cpi")
  #     )
  #   )
  #   # card(
  #   #   card_header("Contributions of Unit Labor Cost, Unit Profit, and Unit Tax to the Percentage Change in GDP Deflator"),
  #   #   gt_output("table_quarterly"),
  #   #   height = 300
  #   # )
  # ),
  # nav_panel(
  #   "By Decade",
  #   # layout_column_wrap(
  #   #   card(
  #   #     card_header("Contributions of Unit Components to Annual Inflation by Decade"),
  #   #     plotOutput("decadal_avg")  
  #   #   ),
  #   #   card(
  #   #     gt_output("table_decadal") 
  #   #   )
  #   # )
  #   navset_card_tab(
  #     title = "Contributions of Unit Components to Annual Inflation by Decade",
  #     nav_panel(
  #       "Plot",
  #       plotOutput("decadal_avg") 
  #     ),
  #     nav_panel(
  #       "Table",
  #       gt_output("table_decadal") 
  #     )
  #   )
  # ),
  # nav_panel(
  #   "Since the Pandemic",
  #   plotOutput("pandemic")
  # )
)