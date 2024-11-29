from shiny.express import input, ui, render
import plotly.express as px
import pandas as pd
import plotly.express as px
from shinywidgets import render_plotly

data = pd.read_csv("inflation-decomposed/data/merged_data.csv")

income_comps = ["contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax"]

ui.page_opts(title="inflation-decomposed", fillable=True)

with ui.sidebar():
  ui.help_text("This dashboard displays the contribution of unit labor costs, unit profits, and unit (net) taxes to inflation measured through the percentage change in the GDP deflator for a given country. See ", ui.a("here", href = "https://github.com/barisguven/inflation-decomposed/blob/main/README.md", target = "_blank"), " for the underlying framework.")

  ui.input_selectize(
    "country", 
    "Select a country:",
    choices=list(data['reference_area'].unique()),
    selected="Türkiye"
  )

with ui.nav_panel("Contributions of Income Components to Annual Inflation"):
  with ui.layout_columns():
    with ui.card(full_screen=True):
      @render_plotly # from shinywidgets
      def plot():
        df = data[(data['series'].isin(income_comps)) & (data['reference_area']==input.country())].dropna()

        fig = px.bar(df, x='time', y='value', color='series')

        fig.update_layout(
          title="".join(['Percent Contributions to Annual Inflation, Quarterly, ', input.country()]),
          title_font=dict(size=14),
          xaxis_title=None,
          yaxis_title=None,
          legend=dict(orientation='h', title=None, y=0.98, yanchor="top", x=0.5, xanchor="center", bgcolor='rgba(0,0,0,0)')
        )

        fig.update_traces({'name':  'Unit labor costs'}, selector={'name':'contr_unit_labor_cost'})
        fig.update_traces({'name':  'Unit profits'}, selector={'name':'contr_unit_profit'})
        fig.update_traces({'name':  'Unit taxes'}, selector={'name':'contr_unit_tax'})

        return fig

    with ui.navset_card_tab(id='tab', title='Deflator vs. CPI'):
      with ui.nav_panel("Whole Period"):
        @render_plotly
        def plot_inf():
          df = data[(data['series'].isin(['inflation_def', 'inflation_cpi'])) & (data['reference_area']==input.country())].dropna()
          fig = px.line(df, x='time', y='value', color='series')

          fig.update_layout(
            title="".join(['Annual Deflator vs. CPI Inflation (%), Quarterly, ', input.country()]),
            title_font=dict(size=14),
            xaxis_title=None,
            yaxis_title=None,
            legend=dict(orientation='h', title=None, y=0.98, yanchor="top", x=0.5, xanchor="center", bgcolor='rgba(0,0,0,0)')
          )

          fig.update_traces({'name':  'Deflator'}, selector={'name':'inflation_def'})
          fig.update_traces({'name':  'CPI'}, selector={'name':'inflation_cpi'})

          return fig

      with ui.nav_panel("Pandemic"):
        @render_plotly
        def plot_inf_pand():
          df = data[(data['series'].isin(['inflation_def', 'inflation_cpi'])) & (data['reference_area']==input.country()) & (data['time'] >= '2019-01-01')].dropna()
          fig = px.line(df, x='time', y='value', color='series')

          fig.update_layout(
            title="".join(['Annual Deflator vs. CPI Inflation (%), Quarterly, ', input.country()]),
            title_font=dict(size=14),
            xaxis_title=None,
            yaxis_title=None,
            legend=dict(orientation='h', title=None, y=0.98, yanchor="top", x=0.3, xanchor="center", bgcolor='rgba(0,0,0,0)')
          )

          fig.update_traces({'name':  'Deflator'}, selector={'name':'inflation_def'})
          fig.update_traces({'name':  'CPI'}, selector={'name':'inflation_cpi'})

          return fig 

  with ui.layout_columns():
    with ui.navset_card_tab(title='Pandemic'):
      with ui.nav_panel(title='Contr.'):
        @render_plotly
        def plot_pand():
          df = data[(data['series'].isin(income_comps)) & (data['reference_area']==input.country()) & (data['time'] >= '2019-01-01')].dropna()

          fig = px.bar(df, x='time', y='value', color='series')

          fig.update_layout(
            title="".join(['Percent Contributions to Annual Inflation, Quarterly, ', input.country()]),
            title_font=dict(size=14),
            xaxis_title=None,
            yaxis_title=None,
            legend=dict(orientation='h', title=None, y=0.98, yanchor="top", x=0.5, xanchor="center", bgcolor='rgba(0,0,0,0)')
          )

          fig.update_traces({'name':  'Unit labor costs'}, selector={'name':'contr_unit_labor_cost'})
          fig.update_traces({'name':  'Unit profits'}, selector={'name':'contr_unit_profit'})
          fig.update_traces({'name':  'Unit taxes'}, selector={'name':'contr_unit_tax'})

          return fig

      with ui.nav_panel(title='Relative Contr.'):
        'Relative contributions here'
      with ui.nav_panel(title='Labor Share'):
        'Labor share here'
      with ui.nav_panel(title='Real Incomes'):
        'Real incomes here' 
    
    with ui.card():
      "Decadal contributions here"

with ui.nav_panel("Tables"):
  "Tables will appear here."