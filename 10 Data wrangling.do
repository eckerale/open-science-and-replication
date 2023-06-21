********************************************************************************
***						                                                     ***
*** OSC: Session 10 Data wrangling								 			 ***
***						                                                     ***
********************************************************************************

**# 0. default settings
clear all
set more off
set scheme sj
capture log close

* define directories
if regexm(c(username),"Ecker") {
	if regexm(c(os),"Windows") == 1 {
		global WDIR "C:\Users\Ecker\Seafile\teaching\2023_Summer\OSC\01_slides\open-science-and-replication"
	}
	else if regexm(c(os),"Mac") == 1 {
		global WDIR "/Users/alejandroecker/Seafile/teaching/2023_Summer/01_slides/open-science-and-replication"
	}
}

cd "$WDIR"
********************************************************************************


**# 1. data import
* import delimited loads data sets in CSV format
import delimited "qog_bas_cs_jan22.csv", clear

* export delimited stores data as CSV file
export delimited "new_test_data.csv", replace


**# 2. relational data
import delimited "netflix_data.csv", clear
import delimited "netflix_productions.csv", clear
import delimited "netflix_language.csv", clear


**# 3. pivoting data
* wide to long
import delimited "wide_data.csv", clear
reshape long cpi_ rank_, i(country iso3 region) j (year)
rename (cpi_ rank_) (cpi rank)
sort country year

* long to wide               
import delimited "long_data.csv", clear
replace value = "" if value == "NA"
destring value, replace
reshape wide value, i(country iso3 region year) j(name) string
rename (valuecpi valuerank) (cpi rank)
reshape wide cpi rank, i(country iso3 region) j(year)

* standard pivoting
import delimited "UNIGME-2021.csv", clear
foreach var of varlist u5* {
	capture replace `var' = "" if `var' == "NA"
	destring `var', replace
}

reshape long u5mr, i(countryname) j(year)
rename u5mr child_mort
