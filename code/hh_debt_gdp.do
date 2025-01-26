
global inputs "C:\Users\z99ka\OneDrive\Desktop\STATA\Input"
global outputs "C:\Users\z99ka\OneDrive\Desktop\STATA\Output"

import excel "C:\Users\z99ka\OneDrive\Desktop\STATA\Data\hh_debt_gdp_us.xlsx" , sheet ("Quarterly") firstrow
br
d 
codebook date debt_gdp_hh
save "$outputs\hh_debt_gdp_us.dta", replace

*** Research Questions 
* 1- How has the household debt to GDP ratio changed over the years?

gen year = year(date) // Extract the year from the date
collapse (mean) debt_gdp_hh, by(year) //calculate the average debt to gdp by year
br

* Plotting the trend over the years
twoway line debt_gdp_hh year, ///
    title("Household Debt to GDP Ratio Over the Years") ///
    ytitle("Debt to GDP (%)") xtitle("Year") ///
    legend(off) graphregion(color(white))

* calculating the summary statistics
summarize debt_gdp_hh

** 2- Are there specific periods of significant increase or decrease in the ratio?

* calculating the overall change
// Calculate yearly change in debt to GDP ratio
gen yearly_change = debt_gdp_hh[_n] - debt_gdp_hh[_n-1] if year[_n] != year[_n-1]
summarize yearly_change
br

// Identify periods with maximum and minimum change
list year debt_gdp_hh yearly_change if yearly_change == r(max) // Maximum change
list year debt_gdp_hh yearly_change if yearly_change == r(min) // Minimum change

// Plot yearly change
twoway (bar yearly_change year), ///
    title("Yearly Change in Household Debt to GDP Ratio") ///
    ytitle("Change in Debt to GDP (%)") xtitle("Year")

save "$outputs\hh_debt_gdp_us_trend.dta", replace

** Seasonality and Cycles 
** a. Is there any seasonal pattern in the quarterly data?
// Extract quarter from the date variable
use "$outputs\hh_debt_gdp_us.dta",clear 
gen quarter = quarter(date)

// Create a seasonal plot
graph box debt_gdp_hh, over(quarter, label(angle(45))) ///
    title("Seasonality in Household Debt to GDP Ratio") ytitle("Debt to GDP (%)")

*b. Are there recurring cycles of growth or decline in the ratio?
// Plot quarterly data to observe cycles
twoway line debt_gdp_hh date, title("Quarterly Household Debt to GDP Ratio") ///
    ytitle("Debt to GDP (%)") xtitle("Date") legend(off)

save "$outputs\hh_debt_gdp_us_seasonality.dta", replace

*** Reserach Question 3 - Impact of Economic Events 
* a. How did the Household Debt to GDP ratio respond during significant economic events?
// Create indicator variables for key events

use "$outputs\hh_debt_gdp_us.dta",clear

gen year = year(date)
gen crisis_2008 = (year >= 2007 & year <= 2009) // Financial crisis
gen covid_2020 = (year == 2020)                 // COVID-19 pandemic
br
// Compare averages during these periods
collapse (mean) debt_gdp_hh, by(crisis_2008)
list crisis_2008 debt_gdp_hh
br
collapse (mean) debt_gdp_hh, by(covid_2020)
list covid_2020 debt_gdp_hh
br

*** RQ - Rate of Change
* a. What is the average rate of quarterly change in the Household Debt to GDP ratio?
use "$outputs\hh_debt_gdp_us.dta", clear
// Calculate quarterly change
gen quarterly_change = debt_gdp_hh - debt_gdp_hh[_n-1]

// Calculate average change
summarize quarterly_change if _n > 1

*b. Which quarter or year experienced the highest or lowest change? 
// Identify quarters with the highest and lowest change
list date debt_gdp_hh quarterly_change if quarterly_change == r(max)
list date debt_gdp_hh quarterly_change if quarterly_change == r(min)

clear all
