from shiny.express import input, ui, render
from shiny import reactive
import plotly.express as px
import pandas as pd
from shinywidgets import render_plotly

# Main data
data = pd.read_csv('inflation-decomposed/data/merged_data.csv')

# Decadal averages data
data_avg = pd.read_csv('inflation-decomposed/data/merged_data_avg.csv')

# Real incomes data
data_real_inc = pd.read_csv("inflation-decomposed/data/merged_data_real_incomes.csv")

# Country notes
country_notes = pd.read_csv("inflation-decomposed/data/country_notes.csv")

# Income components contributions series
income_comps = ["contr_unit_labor_cost", "contr_unit_profit", "contr_unit_tax"]

# Plotly configuration
config = {'displayModeBar': True, 'displaylogo': False, 'modeBarButtonsToRemove': ['zoom', 'pan', 'lasso', 'zoomIn', 'zoomOut', 'resetScale']} # not used

template='seaborn'

# minmax function for time range
def minmax(x):
  return [min(x), max(x)]

ui.page_opts(title="inflation-decomposed", fillable=True)

with ui.sidebar():
  ui.help_text("This dashboard displays the contribution of unit labor costs, unit profits, and unit (net) taxes to inflation measured through the percentage change in the GDP deflator for a given country. See ", ui.a("here", href = "https://github.com/barisguven/inflation-decomposed/blob/main/README.md", target = "_blank"), " for the underlying framework.")

  ui.input_selectize(
    "country", 
    "Select a country:",
    choices=list(data['reference_area'].unique()),
    selected="Türkiye"
  )

  @reactive.calc
  def time_range():
    time_range = data[data['reference_area']==input.country()]['time'].values
    time_range = pd.to_datetime(minmax(time_range))
    years, quarters = time_range.year, time_range.quarter
    
    return [str(t1 )+ "-Q" + str(t2) for t1, t2 in zip(years, quarters)]

  @render.ui
  def note():
    notes = " ".join(['Notes: Data are availabe for', input.country(), 'from', time_range()[0], 'to', time_range()[1]])
    notes = "".join([notes, '.']) 

    if input.country() in ["United States", "Canada", "Japan", "Israel"]:
      country_note = country_notes[country_notes['country']==input.country()]['note'].values[0]
      notes = " ".join([notes, country_note])

    return ui.help_text(notes)

with ui.nav_panel("Contributions of Unit Incomes to Annual Inflation"):
  with ui.layout_columns():
    with ui.navset_card_tab(title=None):
      with ui.nav_panel(title='Pandemic'):
        @render_plotly
        def plot_pand():
          df = data[(data['series'].isin(income_comps)) & (data['reference_area']==input.country()) & (data['time'] >= '2019-01-01')].dropna()

          fig = px.bar(df, x='time', y='value', color='series', template=template)

          fig.update_layout(
            title="".join(['Percent Contributions to Annual Inflation, Quarterly, ', input.country()]),
            title_font=dict(size=14),
            xaxis_title=None,
            yaxis_title=None,
            legend=dict(orientation='h', title=None, y=-0.1, yanchor="top", x=0.5, xanchor="center", bgcolor='rgba(0,0,0,0)')
          )

          fig.update_traces({'name':  'Unit labor costs'}, selector={'name':'contr_unit_labor_cost'})
          fig.update_traces({'name':  'Unit profits'}, selector={'name':'contr_unit_profit'})
          fig.update_traces({'name':  'Unit taxes'}, selector={'name':'contr_unit_tax'})

          return fig

      with ui.nav_panel(title='Relative'):
        @render_plotly
        def plot_rel():
          df = data[(data['reference_area']==input.country()) & (data['time']>='2019-01-01') & (data['series']=='contr_relative')].dropna()

          fig = px.bar(df, x='time', y='value', template=template)

          fig.update_layout(
            title="".join(['Contribution of Unit Labor Costs to That of Unit Profits, Quarterly, ', input.country()]),
            title_font=dict(size=14),
            xaxis_title=None,
            yaxis_title=None
          )

          return fig

      with ui.nav_panel(title='Labor Share'):
        @render_plotly
        def plot_ls():
          df = data[(data['reference_area']==input.country()) & (data['time']>='2019-01-01') & (data['series']=='labor_share')].dropna()

          fig = px.line(df, x='time', y='value', template=template)

          fig.update_layout(
            title="".join(['Labor Share, Quarterly, ', input.country()]),
            title_font=dict(size=14),
            xaxis_title=None,
            yaxis_title=None
          )

          return fig
      with ui.nav_panel(title='Real Incomes'):
        @render_plotly
        def plot_real_inc():
          df = data_real_inc[(data_real_inc['reference_area']==input.country()) & (data_real_inc['time']>='2019-01-01') & (data_real_inc['series'].isin(['real_labor_comp_def', 'real_surplus_def']))].dropna()

          fig = px.line(df, x='time', y='value', color='series', template=template)

          fig.update_layout(
            title="".join(['Real Incomes Indices (2019-Q1=100), Quarterly, ', input.country()]),
            title_font=dict(size=14),
            xaxis_title=None,
            yaxis_title=None,
            legend=dict(orientation='h', title=None, y=0.98, yanchor="top", x=0.5, xanchor="center", bgcolor='rgba(0,0,0,0)')
          )

          fig.update_traces({'name':  'Real labor income'}, selector={'name':'real_labor_comp_def'})
          fig.update_traces({'name':  'Real profits'}, selector={'name':'real_surplus_def'})

          return fig
    # Deflator vs. CPI Inflation 
    with ui.navset_card_tab(id='tab', title=None):
      with ui.nav_panel("Deflator vs. CPI"):
        @render_plotly
        def plot_inf():
          df = data[(data['series'].isin(['inflation_def', 'inflation_cpi'])) & (data['reference_area']==input.country())].dropna()
          fig = px.line(df, x='time', y='value', color='series', template='seaborn')

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
      with ui.nav_panel("Pandemic Only"):
        @render_plotly
        def plot_inf_pand():
          df = data[(data['series'].isin(['inflation_def', 'inflation_cpi'])) & (data['reference_area']==input.country()) & (data['time'] >= '2019-01-01')].dropna()
          fig = px.line(df, x='time', y='value', color='series', template=template)

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
  # Annual Contributions for the Whole Period
  with ui.layout_columns():
      with ui.card(full_screen=True):
        @render_plotly # from shinywidgets
        def plot():
          df = data[(data['series'].isin(income_comps)) & (data['reference_area']==input.country())].dropna()

          fig = px.bar(df, x='time', y='value', color='series', template=template)

          fig.update_layout(
            title="".join(['Percent Contributions to Annual Inflation, Quarterly, ', input.country()]),
            title_font=dict(size=14),
            xaxis_title=None,
            yaxis_title=None,
            legend=dict(orientation='h', title=None, y=0.99, yanchor="top", x=0.5, xanchor="center", bgcolor='rgba(0,0,0,0)')
          )

          fig.update_traces({'name':  'Unit labor costs'}, selector={'name':'contr_unit_labor_cost'})
          fig.update_traces({'name':  'Unit profits'}, selector={'name':'contr_unit_profit'})
          fig.update_traces({'name':  'Unit taxes'}, selector={'name':'contr_unit_tax'})

          return fig

      # Decadal Contributions
      with ui.card():
        "Decadal contributions here"

# Tables Tab
with ui.nav_panel("Tables"):
  "Tables will appear here."