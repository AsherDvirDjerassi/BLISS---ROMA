ssc install estout
ssc install oaxaca
ssc install univar
ssc install pshare
*spikeplot
ssc install eclplot

clear
cd "/OneDrive/Roma Paper/Data/World Bank Long 2013"

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

sort hh_id, stable

*Roma Dummy
gen Roma = 1 if ethnicity==2
replace Roma = 0 if ethnicity==1
label var Roma "Roma"

*HOURS WORKED LAST WEEK
rename m2_q23 hours_worked_last_week, replace
label var m2_q23 "Hours worked in the last 7 days"

*AGE
rename m1_q4a_age age, replace 
label var age "Age"

*MALE
gen male = 1 if m1_q5==1
replace male = 0 if m1_q5==2

*MARRIED or LIVING TOGETHER
gen married = 1 if m1_q5==2
replace married = 1 if m1_q5==3
replace married = 0 if m1_q5==1
replace married = 0 if m1_q5==4
replace married = 0 if m1_q5==5
replace married = 0 if m1_q5==6

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


*Cognitive Skills 
	*q4 - addition and subtraction questions
	replace q4_13=0 if q4_13==.
	replace q4_13=1 if q4_13==88
	*q5 - questions on semantics
	*q6 - reading comprehension
	*q7-q10 - applied mathematics questions
	*A1 - A4 - disabilities surveyed faced 


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

*INCOME 
*-------------------------------------------
*Total Net Income MEANING?????????
rename m2_q10A total_net_income, replace

*MEAN NET WA
rename m2_q16a Ave_Monthly_Net_Wages 
label var Ave_Monthly_Net_Wages "Average monthly net wages"
replace Ave_Monthly_Net_Wages = 0 if Ave_Monthly_Net_Wages == .

*EMPLOYMENT DUMMY
gen employed = 1 if Ave_Monthly_Net_Wages>0 
replace employed = 0 if Ave_Monthly_Net_Wages==0

replace Has_a = 0 if Has_a==.
reg Has_a_job Have_you_worked_in_past_4_weeks
*very similar

*ID
egen ID = concat( HH_ID HHM_ID)

*GENERATE MONTHLY GOV BENEFITS 
mvencode m5b_q6 m5a_q2_11 m5a_q3_11 m5a_q4_11 m5a_q5_11, mv(0)
gen monthly_gov_benefits = m5b_q6 + m5a_q2_11 + m5a_q3_11 + m5a_q4_11 + m5a_q5_11

*Net income when not working
gen NIWNE
label var NIWNE "Net income when not working"

*Net Income When Employed
gen NIWE
label var NIWE "Net income from all sources when employed" 

*GEN NET BEN FOR WORKING
*gen net_ben_working = 

*TEST WHETHER WEIGHTS WORK BY MULTIPLYING 
*How to know when I may use aweights or iweights?
*Is there a way to test the relevance of one or the other?
gen test_weight_mean_wage = Mean_Net_Wages * wta_comb
total test_weight_mean_wage
mean Mean_Net_Wages [iw= wta_comb]

*Distribution of Income
univar NIWE
univar Ave_Monthly_Net_Wages [aw= wta_comb] if employed==1, lst se box
univar Ave_Monthly_Net_Wages 
summarize Ave_Monthly_Net_Wages [aw= wta_comb] if employed==1, detail


*PLOTS AND GRAPHS
*-----------------------------------------------------------
*histogram of reservation wage by ethnicity
twoway (histogram reservation_wage if Roma==1 & q4_13==1 & age<65 & age>25, fraction width(50) color(edkblack)) ///
(histogram reservation_wage if Roma==0 & q4_13==1 & age<65 & age>25, fraction width(50) color(edkblue)), legend(order(1 "Roma" 2 "Non-Roma Bulgarian" ))

*reservation wages
*change the color of the bars
twoway (histogram reservation_wage if Roma==1 & q4_13==0 & age<65 & age>25, fraction width(50) color(edkblack)) ///
(histogram reservation_wage if Roma==0 & q4_13==0 & age<65 & age>25, fraction width(50) color(edkblue)), legend(order(1 "Roma" 2 "Non-Roma Bulgarian" ))

*willingness to commute
twoway (histogram dist_willing_commut if dist_willing_commut>0 & Roma==1 & q4_13==0 & age<65 & age>25, fraction width(50) color(edkblue)) ///
(histogram dist_willing_commut if dist_willing_commute>0 & Roma==0 & q4_13==0 & age<65 & age>25, fraction width(50) color(edkblack)), legend(order(1 "Roma" 2 "Non-Roma Bulgarian" ))

mean dist_willing_commut, over(ethnicity)
twoway kdensity dist_willing_commut  if  dist_willing_commut<500, color(*3) ||, by (ethnicity)


reservation_wage if Roma==1 & q4_13==0 & age<65 & age>25

fcolor(eltblue) lcolor(black)), legend(order(1 "Roma" 2 "Ethnic Bulgarian" ))



twoway lowess Ave_Monthly age if employed==1, by(ethnicity)


*Employment over age MUST LIMIT THE NUMBER OF TICKS AND RENAME Y AXIS

*Bar graph of employment rate over age and by whether answered three questions wrong consectutively
graph bar (mean) employed[aw=wta_adj_BLISS_cs], over(age) over(ethnicity) 
graph bar (mean) Ave_Monthly[aw=wta_adj_BLISS_cs], over(age) over(ethnicity) 




*
*Employment Rate by Age by Ethnicity
twoway line age employment 


*univar 
univar reservation_wage [aw=wta_adj_BLISS_cs] if q4_13==0 & age<65 & age>25, by (ethnicity)

*Scatter of 
twoway kdensity weekly_income, color(*3) ||, by (q4_13) 
twoway kdensity weekly_income, color(*3) ||, by (ethnicity) 

twoway kdensity reservation_wage, color(*3) ||, by (ethnicity) 



grmeanby employed [if age>18 & age<75]  [iw= wta_adj_BLISS_cs], summarize(age)

mean employed [iw= wta_adj_BLISS_cs] if ethnicity==1, over(age)
mean employed [iw= wta_adj_BLISS_cs] if ethnicity==2, over(age)

*Compare Income Declines in BLISS to EUROSTAT
univar 


*URBAN & RURAL
*------------------------------------------------------------
*One of the most salient and impacting sratification in Bulgaria is the urban/rural divide. 



*------------------------------------------------------------
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

*PROBIT
probit employed Roma married male IRT_Scores_Total_Cognitive_skill child_under_6 child_under_6_int child_6_to_17 child_6_to_17_int highest_education highest_education_int age_factor age_factor_int  [pweight= wta_comb], vce(robust)

*regression no constant
eststo:reg employed q4_13 Roma married male IRT_Scores_Total_Cognitive_skill child_under_6 child_under_6_int child_6_to_17 child_6_to_17_int highest_education highest_education_int age_factor age_factor_int  [pweight= wta_comb], vce(robust) noconstant
eststo:reg employed Roma married male IRT_Scores_Total_Cognitive_skill child_under_6 child_under_6_int child_6_to_17 child_6_to_17_int highest_education highest_education_int age_factor age_factor_int  [pweight= wta_comb], vce(robust) noconstant
eststo:reg employed Roma married male IRT_Scores_Total_Cognitive_skill child_under_6 child_under_6_int child_6_to_17 child_6_to_17_int highest_education age_factor age_factor_int  [pweight= wta_comb], vce(robust) noconstant
eststo:reg employed Roma married male IRT_Scores_Total_Cognitive_skill child_under_6 child_under_6_int child_6_to_17 child_6_to_17_int age_factor age_factor_int  [pweight= wta_comb], vce(robust) noconstant
*Create Regression Tables
esttab


REGRESSION OUTPUT TABLES FOR THE EXTENSIVE MARGIN
*-------------------------------------------------
eststo: quietly reg earned_income_dummy ROMA
estimates store m1, title(I)
eststo: quietly xtreg earned_income_dummy ROMA, i(m5a) fe
estimates store m2, title(II fe)
eststo: quietly reg earned_income_dummy ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE, nocon
estimates store m3, title(III)
eststo: quietly xtreg earned_income_dummy ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE, nocon, i(m5a) fe
estimates store m4, title(IV fe)
eststo: quietly reg earned_income_dummy ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE if working_age==1, nocon
estimates store m5, title(V)
eststo: quietly xtreg earned_income_dummy ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE if working_age==1, nocon,i(m5a) fe
estimates store m6, title(VI fe)

estout m1 m2 m3 m4 m5 m6, cells(b(star fmt(%9.3f)) se(par)) stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared)) legend label collabels(none) varlabels(_cons Constant)

*Effect on Employment
eststo: quietly reg earned_income_dummy ROMA
estimates store m1, title(I)
eststo: quietly xtreg earned_income_dummy ROMA, fe
estimates store m2, title(II)
eststo: quietly reg earned_income_dummy ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE
estimates store m3, title(III)
eststo: quietly xtreg earned_income_dummy ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE, fe
estimates store m4, title(IV)
eststo: quietly reg earned_income_dummy ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE if working_age==1
estimates store m5, title(V)
eststo: quietly xtreg earned_income_dummy ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE if working_age==1, fe
estimates store m6, title(VI)

estout m1 m2 m3 m4 m5 m6, cells(b(star fmt(%9.3f)) se(par)) stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared)) legend label collabels(none) varlabels(_cons Constant)

xtreg earned_income_dummy ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE if working_age==1, fe
xtreg earned_income_dummy ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE, fe

*Effect on Earned Income
eststo: quietly reg EARN_EMPLY ROMA
estimates store m1, title(I)
eststo: quietly xtreg EARN_EMPLY ROMA, fe
estimates store m2, title(II)
eststo: quietly reg EARN_EMPLY ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE
estimates store m3, title(III)
eststo: quietly xtreg EARN_EMPLY ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE, fe
estimates store m4, title(IV)
eststo: quietly reg EARN_EMPLY ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE if working_age==1
estimates store m5, title(V)
eststo: quietly xtreg EARN_EMPLY ROMA a2 b2 MARRIED MALE CHILD CHILD_OVER_6 m8 LITERATE if working_age==1, fe
estimates store m6, title(VI)

estout m1 m2 m3 m4 m5 m6 m7 m8, cells(b(star fmt(%9.3f)) se(par)) stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared)) legend label collabels(none) varlabels(_cons Constant)

*NET INCOME WHEN EMPLOYED AND PREDICTED INCOME
*Net income when employed
quietly reg NIWE betas (how to include multiple characteristics in var?) [iw=wta_adj_BLISS_cs] if Roma==0
predict predicted_NIWE_using_nonRoma

quietly reg NIWE betas [iw=wta_adj_BLISS_cs] if Roma==1
predict predicted_NIWE_using_Roma


*Relationship between predicted earned income of non-Roma and Roma if employed who have the same observable characterisitics 
lowess predicted_NIWE_using_nonRoma predicted_NIWE_using_Roma if Roma==1

lowess predicted_NIWE_using_nonRoma NIWE if Roma==1

lowess predicted_NIWE_using_Roma NIWE if Roma==1

twoway lowess NIWE Prob_Employed
twoway lowess predicted_NIWE_using_Roma Prob_Employed



save Data_For_R, replace
