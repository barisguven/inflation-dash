# Decomposing Inflation

From the late 1960s through the early 1980s, inflation rose by at least two to three times in many countries due to preceding high growth, tight labor markets, and two oil shocks in the 1970s. The ensuing interest rate hikes, deceleration in economic growth, and the substantial decline in workers' bargaining power not only made high inflation disappear but also sometimes caused inflation to stay below the target inflation pursued by the central banks. Less than two years into the COVID-19 pandemic, the unusually high inflation made a comeback, leading to a cost-of-living crisis for millions of people, which in turn led to the fall of a series of incumbent governments.

Economists point mainly to four factors for high inflation during the pandemic: supply-chain bottlenecks, fiscal stimuli, concentration in product markets, and the Russia-Ukraine war, with the debate on the role of each factor continuing.

This project gathers data and presents the results of a decomposition analysis that empirical studies have used to link inflation to wages/salaries and profits.

## Decomposition Equation  

Gross Domestic Product (GDP) can be measured in three different ways relying on either expenditure, output, or income approach. According to the income approach, GDP is measured as the sum of the following three income components:

1. compensation of employees (wages and salaries paid to employees and their employers’ social contributions) (simply labor costs),

2. gross operating surplus (business profits) and gross mixed income (profits of the self-employed) (simply profits),

3. taxes on production and imports minus subsidies (i.e., net taxes).

Let $W$, $S$, and $T$ denote these (nominal) income components respectively. Let also $Y$ and $Y_r$ denote nominal and real GDP respectively. The income approach leads to the following identity:

$$Y = W + S + T$$

Dividing both sides by real GDP gives us
  
$$\frac{Y}{Y_r} = \frac{W}{Y_r} + \frac{S}{Y_r} + \frac{T}{Y_r}$$

or

$$P = w + s + t.$$

$P$ on the left-hand side of the equation is simply the GDP deflator. $w$, the total labor costs divided by real GDP, measures the labor costs per product and is called unit labor costs. Similarly, $s$ and $t$ denote unit profits and unit net taxes respectively. The change in the GDP deflator can then be written as

$$\Delta P = \Delta w + \Delta s + \Delta t$$

dividing both sides of which by $P$ yields

$$\frac{\Delta P}{P} = \frac{\Delta w}{P} + \frac{\Delta s}{P} + \frac{\Delta t}{P}$$

which can be further written as

$$\frac{\Delta P}{P} = \frac{\Delta w}{w}\frac{w}{P} + \frac{\Delta s}{s}\frac{s}{P} + \frac{\Delta t}{t}\frac{t}{P}$$

or

$$\frac{\Delta P}{P} = \frac{\Delta w}{w}\frac{W}{Y} + \frac{\Delta s}{s}\frac{S}{Y} + \frac{\Delta t}{t}\frac{T}{Y}.$$

Finally, we can write

$$\\%\Delta P = \\%\Delta w \frac{W}{Y} + \\%\Delta s \frac{S}{Y} + \\%\Delta t \frac{T}{Y}$$

where $W/Y$, $S/Y$, and $T/Y$ denote labor share, profit share, and tax share of income respectively.

In words, then, the percentage change in the GDP deflator, i.e., domestic inflation, is the weighted sum of the percentage changes in unit labor costs, unit profits, and unit net taxes where the weights are the corresponding shares of income. Each additive term in the equation represents the contribution of a distinct income component per product to domestic inflation decomposing the latter into three measurable parts. Empirically, all one needs to do is divide each nominal income component by real GDP to find the unit income component, compute the percentage change in it, and then multiply it by the respective income share for each period.

## A Snapshot

While countries differ in the magnitude of the contributions of unit labor costs, unit profits, and unit taxes to inflation, a snapshot analysis aggregating the country data would be highly useful. The figure below shows the cross-country simple average of country-based four-quarter trailing moving averages of annual contributions and inflation focusing on the eighteen OECD-member countries.[^1]

[^1]: The countries included in the analysis are Australia, Austria, Belgium, Canada, Denmark, Finland, France, Germany, Greece, Italy, Luxembourg, Netherlands, Portugal, Spain, Sweden, Switzerland, United Kingdom, and United States. I don't include the contribution of unit taxes in the figure because the government aid packages led to massive changes in this variable, blurring the picture. However, the dashboard provides data for this variable.

The deflator inflation surged in 2021 and 2022, peaked in the last quarter of 2022 and started falling thereafter. In the first year of the pandemic, the contribution of unit labor costs was greater than unit profits, with a slight increase in deflator inflation.[^2] This pattern completely changed in the next two years in that the contribution of unit profits exceeded the contribution of unit labor costs with inflation surging. The roles were swapped again in the first quarter of 2023, with an ensuing sustained fall in the contribution of unit profits and an accompanying fall in inflation.

[^2]: In contrast, CPI inflation fell in 2021.

![](/assets/contributions.jpeg)

In the previous section, we observed that the deflator inflation can be decomposed into the contribution of unit incomes.

To better understand these patterns, let us observe that the last equation in the previous section suggests

a) that the percentage contribution of, say, unit labor costs equals the percentage change in labor compensation minus the percentage change in real GDP times labor share of income and

b) that, so long as labor share and profit share are close to each other, what differentiates the contribution of unit labor costs and unit profits is the percentage change in the nominal labor compensation and nominal profits, given that the percentage change in real GDP appears in all contributions.

Therefore, we can focus on nominal labor compensation and profits, and real GDP to explain the patterns outlined above. The following figure shows the annual growth in labor compensation, profits, and real GDP.[^3]

[^3]: Similarly, the figure is based on the cross-country simple average of
country-based four-quarter trailing moving average of annual growth in each variable.

![](/assets/wages_profits_rgdp.jpeg)

Based on the previous observations, the period since the beginning of the COVID-19 pandemic in 2020 to the present can be divided into three episodes:

1. 2020-2021 where both labor compensation and profits fell but real GDP fell more and inflation remained supressed;

2. 2021-2022 where both labor compensation and profits grew at a higher-than-usual speed with the latter at a much faster rate and surging inflation; and

3. 2023 to the present where the growth in labor compensation sustained but the growth in profits decelarated fast and inflation fell.

The remarkable nature of the faster growth in profits in the second episode can be better understood through a comparision with the previous two decades (see the figure below). In the same countries as above, while profits grew on average at 3.53% per year between 2000 and 2019, they grew at 6.68% between 2020 and 2022! In contrast, the annual average growth in labor compensation was 3.62% and 4.49% in the same periods respectively.

![](/assets/wages_profits_period.jpeg)

## Dashboard

The dashboard, [inflation-decomposed](https://bguven.shinyapps.io/inflation-decomposed), presents the results of the decomposition analysis outlined above. You can select a country on the sidebar and view the quarterly contribution of unit labor costs, unit profits, and unit net taxes to domestic inflation for the selected country. You can also focus on the pandemic patterns and view the decadal averages of the contributions of unit components. The underlying data behind visuals can be downloaded on the *Tables* tab of the dashboard.

## Data Source

The decomposition analysis relies heavily on quarterly national accounts data provided by OECD's data warehouse *OECD Data Explorer*. I obtained the quarterly nominal GDP and components series from [here](https://data-explorer.oecd.org/vis?fs%5B0%5D=Topic,1%7CEconomy%23ECO%23%7CNational%20accounts%23ECO_NAD%23&pg=40&fc=Topic&bp=true&snb=156&df%5Bds%5D=dsDisseminateFinalDMZ&df%5Bid%5D=DSD_NAMAIN1@DF_QNA_INCOME&df%5Bag%5D=OECD.SDD.NAD&df%5Bvs%5D=1.1&dq=Q..AUT..........&to%5BTIME_PERIOD%5D=false&lo=5&lom=LASTNPERIODS), real GDP and deflator series from [here](https://data-explorer.oecd.org/vis?df%5Bds%5D=dsDisseminateFinalDMZ&df%5Bid%5D=DSD_NAMAIN1@DF_QNA_EXPENDITURE_INDICES&df%5Bag%5D=OECD.SDD.NAD&df%5Bvs%5D=1.1&dq=Q............&lom=LASTNPERIODS&lo=5&to%5BTIME_PERIOD%5D=false), and finally Consumer Price Index series from [here](https://data-explorer.oecd.org/vis?fs%5B0%5D=Topic,1%7CEconomy%23ECO%23%7CPrices%23ECO_PRI%23&pg=0&fc=Topic&bp=true&snb=30&df%5Bds%5D=dsDisseminateFinalDMZ&df%5Bid%5D=DSD_PRICES@DF_PRICES_ALL&df%5Bag%5D=OECD.SDD.TPS&df%5Bvs%5D=1.0&dq=.M.N.CPI.._T.N.GY+_Z&lom=LASTNPERIODS&lo=13&to%5BTIME_PERIOD%5D=false).

R scripts that extract the series used in the decomposition analysis from OECD data are all available on the project repository.