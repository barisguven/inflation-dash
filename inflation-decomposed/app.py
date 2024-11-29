from shiny.express import input, ui, render
import plotly.express as px
import pandas as pd
import plotly.express as px
from shinywidgets import render_plotly

data = pd.read_csv("inflation-decomposed/data/merged_data.csv")

income_comps = ["contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax"]

ui.page_opts(title="inflation-decomposed", fillable=True)

with ui.sidebar():
  "Content"

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
          xaxis_title=None,
          yaxis_title=None,
          legend=dict(orientation='h', title=None, y=0.98, yanchor="top", x=0.5, xanchor="center")
        )

        fig.update_traces({'name':  'Unit labor costs'}, selector={'name':'contr_unit_labor_cost'})
        fig.update_traces({'name':  'Unit profits'}, selector={'name':'contr_unit_profit'})
        fig.update_traces({'name':  'Unit net taxes'}, selector={'name':'contr_unit_tax'})

        return fig

    with ui.card():
      "bbb"

  with ui.layout_columns():
    with ui.card():
      "aaa"
    
    with ui.card():
      "bbb"

with ui.nav_panel("Tables"):
  "Tables will appear here."