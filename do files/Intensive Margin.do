cd "C:\Users\Asher\OneDrive\Roma Paper\Data\World Bank Long 2013"
use 9_WB_2013, replace

sort hh_id, stable

*Roma
gen Roma = 1 if ethnicity==2
replace Roma = 0 if ethnicity==1
label var Roma "Roma"

*HOURS WORKED LAST WEEK
rename m2_q23 hours_worked_last_week, replace
label var m2_q23 "Hours worked in the last 7 days"

*AGE
rename m1_q4a_age age, replace 
label var age "Age"

*EDUCATION
rename m1_q14a highest_education, replace
label var highest_education "Highest level of education"
replace highest_education=0 if highest_education==.

*AGE FACTOR VARIABLE
gen age_factor = 1 if age<18
label var age_factor "Age catergories (2-5 being 18 to 65)"
replace age_factor = 2 if age<25 & age>17
replace age_factor = 3 if age<35 & age>24
replace age_factor = 4 if age<45 & age>34
replace age_factor = 5 if age<65 & age>44
replace age_factor = 6 if age>=65

*CHILDREN
by hh_id: egen child_under_6=max(age<6)
label var child_under_6 "Household with one child or more under 6"
by hh_id: egen child_6_to_17=max(age<18 & age>5)
label var child_6_to_17 "Household with one child or more between 6 and 18"

*INTERACTION VARIBALES
gen age_factor_int = age_factor*Roma
label var age_factor "Age catergories interaction"

gen highest_education_int = highest_education*Roma
label var highest_education "Highest level of education interaction"

gen child_under_6_int = child_under_6*Roma
label var child_under_6 "Household with one child or more under 6 interaction"

gen child_6_to_17_int = child_6_to_17*Roma
label var child_6_to_17 "Household with one child or more between 6 and 18 interaction"

*Data on Reservation Wage, Commuting, Willingness to Move
rename m2_q7d reservation_wage, replace
rename m2_q7e dist_willing_commute, replace
rename m2_q7f willing_move, replace 
replace willing_move = 0 if willing_move==2
rename m2_q10A total_net_income, replace

*INCOME VARIABLES
gen weekly_income = total_net_income/52
label var weekly_income "Average Weekly Net Income"

rename m2_q16a Mean_Net_Wages 
label var Mean_Net_Wages "Average monthly net wages"

univar reservation_wage dist_willing_commute willing_move total_net_income if hours==., by(Roma)

*REGRESSIONS
reg hours_worked_last_week child_under_6 child_6_to_17 highest_education i.age_factor if hours_worked_last_week>1
reg hours_worked_last_week child_under_6 child_6_to_17 highest_education i.age_factor if hours_worked_last_week>1 [pweight= wta_comb], vce(robust)
reg hours_worked_last_week child_under_6 child_6_to_17 highest_education i.age_factor if hours_worked_last_week>1 [aweight= wta_comb], vce(robust)
reg hours_worked_last_week child_under_6 child_6_to_17 i.highest_education i.age_factor if hours_worked_last_week>1 [iw= wta_comb], vce(robust)
reg hours_worked_last_week child_under_6 child_6_to_17 i.highest_education i.age_factor if hours_worked_last_week>1 [iw= wta_comb], vce(robust)
mfpigen : reg hours_worked_last_week Roma child_under_6 child_6_to_17 i.highest_education i.age_factor if hours_worked_last_week>1 [iw= wta_comb], vce(robust)

reg Mean_Net_Wages Roma child_under_6 child_6_to_17 highest_education i.age_factor age_factor_int highest_education_int child_under_6_int child_6_to_17_int if Mean_Net_Wages>1
reg Mean_Net_Wages Roma child_under_6 child_under_6_int child_6_to_17 child_6_to_17_int highest_education highest_education_int age_factor age_factor_int if Mean_Net_Wages>1 [iw= wta_comb], vce(robust)
reg Mean_Net_Wages Roma child_under_6 child_under_6_int child_6_to_17 child_6_to_17_int highest_education highest_education_int age_factor age_factor_int if Mean_Net_Wages>1 [pw= wta_comb], vce(robust)
reg Mean_Net_Wages Roma child_under_6 child_6_to_17 highest_education age_factor if hours_worked_last_week>1 [iw= wta_comb], vce(robust)

save Data_For_R
