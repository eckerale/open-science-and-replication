********************************************************************************
***						                                                     ***
*** OSC: Session 09 Version control and writing reproducible code 			 ***
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
		global WDIR "C:\Users\Ecker\Seafile\teaching\2023_Summer\OSC"
	}
	else if regexm(c(os),"Mac") == 1 {
		global WDIR "/Users/alejandroecker/Seafile/teaching/2023_Summer/OSC"
	}
}

cd "$WDIR"
********************************************************************************


**# 1. load data
use "C:\Users\Ecker\Seafile\data\Latinobarometro\Latinobarometro_2020_Eng_Stata_v1_0.dta", clear

**# 2. loops and macros
tab1 p30st_?
tab1 p30st_?, nolab

	**# 2.1 via hardcoding and copy & paste
	* recode variable so that higher values indicate more favorable opinions
	replace p30st_a = p30st_a * -1 + 5
	
	* change numeric values to missing values
	mvdecode p30st_a, mv(6 = .a \ 10 = .b)
	
	* relabel values 
	label define favo 1 "very unfavorable" 2 "somewhat unfavorable" 3 "somewhat favorable" 4 "very favorable" .a "DK/NA" .b "DK"
	label values p30st_a favo
	
	* rename variable
	rename p30st_a opinion_us
	tab opinion_us, m
	
	* rinse and repeat
	replace p30st_b = p30st_b * -1 + 5
	mvdecode p30st_b, mv(6 = .a \ 10 = .b)
	label values p30st_b favo
	rename p30st_b opinion_russ
	
	replace p30st_c = p30st_c * -1 + 5
	mvdecode p30st_c, mv(6 = .a \ 10 = .b)
	label values p30st_c favo
	rename p30st_c opinion_chn
	
	replace p30st_d = p30st_d * -1 + 5
	mvdecode p30st_d, mv(6 = .a \ 10 = .b)
	label values p30st_d favo
	rename p30st_d opinion_eu
	
	replace p30st_e = p30st_e * -1 + 5
	mvdecode p30st_e, mv(6 = .a \ 10 = .b)
	label values p30st_e favo
	rename p30st_e opinion_cub
	
	**# 2.2 use a loop with a macro instead
	* reload data set
	use "C:\Users\Ecker\Seafile\data\Latinobarometro\Latinobarometro_2020_Eng_Stata_v1_0.dta", clear

	* define value label
	label define favo 1 "very unfavorable" 2 "somewhat unfavorable" 3 "somewhat favorable" 4 "very favorable" .a "DK/NA" .b "DK"

	* run loop with dynamic call to local macros
	local i = 1																	// define local macro as counter
	local countries us russ chn eu cub											// define local macro for country names
	
	foreach suffix in a b c d e {												// loop over
		replace p30st_`suffix' = p30st_`suffix' * -1 + 5
		mvdecode p30st_`suffix', mv(6 = .a \ 10 = .b)
		label values p30st_`suffix' favo
		local country = word("`countries'", `i')								// dynamically define local macro as the ith word of macro countries
		rename p30st_`suffix' opinion_`country'
		local ++i																// add one to local counter after each run of the loop
	}
	
	tab1 opinion_*, m
	
	**#2.3 standardize variables, i.e. mean of 0 and standard deviation of 1
	sum opinion_us
	gen opinion_us_std = (opinion_us - `r(mean)')/`r(sd)'
	sum opinion_us*
	drop opinion_us_std
	
	foreach var of varlist opinion_* {
		sum `var'
		gen `var'_std = (`var' - `r(mean)')/`r(sd)'
	}
	sum opinion_*_std
	