***						                                                     ***
*** OSC: Session 09 Version control and writing reproducible code 			 ***
***						                                                     ***

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


**# 1. load data
use Latinobarometro_2020_Eng_Stata_v1_0.dta, clear


**# 2. hardcoding and copy & paste
tab1 p30st_?
tab1 p30st_?, nolab

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


**# 3. loop with macro
* reload data set
use Latinobarometro_2020_Eng_Stata_v1_0.dta, clear

* define value label
label define favo 1 "very unfavorable" 2 "somewhat unfavorable" 3 "somewhat favorable" 4 "very favorable" .a "DK/NA" .b "DK"

* run loop with dynamic call to local macros
local i = 1																		// define local macro as counter
local countries us russ chn eu cub												// define local macro for country names
	
foreach suffix in a b c d e {													// loop over local macro suffix with elements a b c d e
	replace p30st_`suffix' = p30st_`suffix' * -1 + 5	
	mvdecode p30st_`suffix', mv(6 = .a \ 10 = .b)	
	label values p30st_`suffix' favo	
	local country = word("`countries'", `i')									// dynamically define local macro as the ith word of macro countries
	rename p30st_`suffix' opinion_`country'	
	local ++i																	// add one to local counter after each run of the loop
}

tab1 opinion_*, m


**# 4. standardize variables, i.e. mean of 0 and standard deviation of 1
sum opinion_us
gen opinion_us_std = (opinion_us - 2.806528)/.8849583
sum opinion_us_std
drop opinion_us_std

sum opinion_us
gen opinion_us_std = (opinion_us - `r(mean)')/`r(sd)'
sum opinion_us*
drop opinion_us_std

foreach var of varlist opinion_* {
	sum `var'
	gen `var'_std = (`var' - `r(mean)')/`r(sd)'
}
sum opinion_*_std


**# 5. program your own command (i.e. a program in Stata jargon)
capture program drop stdvar														// delete own command if defined previously
program define stdvar															// define new command stdvar
	syntax varname																// define command syntax
	
	qui summarize `1'															// define what the new command does
	gen `1'_std = (`1' - `r(mean)')/`r(sd)'
	
end

drop opinion_*_std
foreach var of varlist opinion_* {
	stdvar `var'
}
