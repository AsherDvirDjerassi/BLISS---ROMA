clear
cd "C:\Users\Asher\OneDrive\Roma Paper\Data\World Bank Long 2013"

*1)Education 7467 with Everyone 15 yrs+ who reported working
use BGR_2013_BLISS_v01_M_M2A_2B
sort HH_ID HHM_ID
save sorted_BGR_2013_BLISS_v01_M_M2A_2B, replace
use BGR_2013_BLISS_v01_M_M1
merge m:m HH_ID HHM_ID using sorted_BGR_2013_BLISS_v01_M_M2A_2B
gen merge_1 = _merge 
drop _merge
sort HH_ID HHM_ID
save 1_WB_2013.dta, replace

*2)Social Assistance - by household
clear
use BGR_2013_BLISS_v01_M_M5A
sort HH_ID
count
save sorted_BGR_2013_BLISS_v01_M_M5A, replace
clear
use 1_WB_2013.dta
merge m:m HH_ID using sorted_BGR_2013_BLISS_v01_M_M5A
gen merge_2 = _merge 
drop _merge
sort HH_ID HHM_ID
save 2_WB_2013.dta, replace


*3)Unemployment Benenfits - 2607
clear
use BGR_2013_BLISS_v01_M_M5B
keep if m5b_q1==1
sort HH_ID HHM_ID
save sorted_BGR_2013_BLISS_v01_M_M5B, replace
clear
use 2_WB_2013.dta
merge m:m HH_ID HHM_ID using sorted_BGR_2013_BLISS_v01_M_M5B
gen merge_3 = _merge 
drop _merge
sort HH_ID HHM_ID
save 3_WB_2013, replace

*4)Active Labor Market Policies
clear
use BGR_2013_BLISS_v01_M_M5B2
sort HH_ID HHM_ID
count
save sorted_BGR_2013_BLISS_v01_M_M5B2, replace
clear
use 3_WB_2013.dta
merge m:m HH_ID HHM_ID using sorted_BGR_2013_BLISS_v01_M_M5B2
gen merge_4 = _merge 
drop _merge
sort HH_ID HHM_ID
save 4_WB_2013, replace

*5)Other Social Protection - 6880
clear
use BGR_2013_BLISS_v01_M_M5C
sort HH_ID HHM_ID
count
save sorted_BGR_2013_BLISS_v01_M_M5C, replace
clear
use 4_WB_2013.dta
merge m:m HH_ID HHM_ID using sorted_BGR_2013_BLISS_v01_M_M5C
gen merge_5 = _merge 
drop _merge
sort HH_ID HHM_ID
save 5_WB_2013, replace

*6)Other Income - 2524
clear
use BGR_2013_BLISS_v01_M_M7
sort HH_ID 
count
save sorted_BGR_2013_BLISS_v01_M_M7, replace
clear
use 5_WB_2013.dta
merge m:m HH_ID using sorted_BGR_2013_BLISS_v01_M_M7
gen merge_6 = _merge 
drop _merge
sort HH_ID HHM_ID
save 6_WB_2013, replace

*7)Intelligence Test, Ethnicity, Education
clear
use BGR_2013_BLISS_v03_M_Psyh
gen HH_ID = ID_household
gen HHM_ID = HHM_id
drop ID_household
drop HHM_id
sort HH_ID HHM_ID
count
save sorted_BGR_2013_BLISS_v03_M_Psyh, replace
clear
use 6_WB_2013.dta
merge m:m HH_ID using sorted_BGR_2013_BLISS_v03_M_Psyh
gen merge_7 = _merge 
drop _merge
sort HH_ID HHM_ID
save 7_WB_2013, replace

*8)Individual cross-sectional weights for the combined sample
clear
use wt_bliss_cs_cs_ind
rename hh_id HH_ID
rename pid HHM_ID
tostring HH_ID, replace
sort HH_ID HHM_ID
save sorted_wt_bliss_cs_cs_ind, replace
clear
use 7_WB_2013.dta
merge m:m HH_ID using sorted_wt_bliss_cs_cs_ind
gen merge_8 = _merge 
drop _merge
sort HH_ID HHM_ID
save 8_WB_2013, replace


*9)Household cross-sectional weights for the combined sample
clear
use wt_bliss_cs_cs_hh
rename hhid HH_ID
sort HH_ID 
save sorted_wt_bliss_cs_cs_hh, replace
clear
use 8_WB_2013.dta
merge m:m HH_ID using sorted_wt_bliss_cs_cs_hh
gen merge_9 = _merge 
drop _merge
sort HH_ID HHM_ID
save 9_WB_2013, replace
