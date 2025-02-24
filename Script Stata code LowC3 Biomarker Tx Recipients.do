********************************************************************************
**#  START PREPARING DATASET FOR ANALYSES
********************************************************************************


clear
import excel "C:\Documenti\Micaela Gentile\Tesi Francesca\Tesi complemento tx Francesca.xlsx", sheet("baseline") firstrow
drop BO-AJM

mvdecode _all, mv(-99)
encode chbas_mutation, gen(chbas_mutation2)
drop chbas_mutation
rename chbas_mutation2 chbas_mutation
tab chbas_mutation

mvdecode chbas_mutation, mv(-99)
label define chbas_mutation 0 "No mutation"

rename chbas__hypertension chbas_hypertension
rename chbas_hvc chbas_hcv
rename tx_incompatibile tx_incompatible

format chbas_dob %td



foreach var of varlist _all {
  qui rename `var' `= strlower("`var'")'
}

rename compl_rejecbt compl_rejectb

label var chbas_dob "Date of birth"

label var chbas_sex "Recipient's sex"
label define chbas_sex  0 "M" 1 "F"
label values chbas_sex chbas_sex

recode chbas_ethnicity 3 = 2

label var chbas_ethnicity "Recipient's ethnicity"
label define chbas_ethnicity 0 "caucasian" 1 "afro american" 2 "others"
label values chbas_ethnicity chbas_ethnicity

label var chbas_diagnosis "EDTA code"
cap drop PRIMARY_KIDNEY_DIS
gen PRIMARY_KIDNEY_DIS = chbas_diagnosis
// correct an error
recode PRIMARY_KIDNEY_DIS (81=71)
recode PRIMARY_KIDNEY_DIS (10/12 14 16/19  = 1)  (13 15 = 2) (20/39 30/39= 3 ) (40/49 50/59 60/66 = 4) (70/73 79 = 5) (80 = 6) (74 76 78 82 83 85/89 = 7) (84 = 8) (90/99 = 9) (71 = 10) (88 = 11)
label define PRIMARY_KIDNEY_DIS 0 "Unknown" 1 "Glomerulonephritis" 2 "C3GN/MPGN" 3 "Pylonenphritis/TIN" 4 "ADPKD and othe hereditary diseases" 5 "Renovascular disease" 6 "Diabetic nephropathy" 7 "Sistemic diseases (non SLE)" 8 "SLE" 9 "Misc." 10 "malignant hypertension" 11 "Complement-mediated HUS"
label values PRIMARY_KIDNEY_DIS PRIMARY_KIDNEY_DIS
label var PRIMARY_KIDNEY_DIS "Primary kidney disease"

label var chbas_genetics "Recipient's genetics"
label define chbas_genetics  0 "no" 1 "yes positive" 2 "yes negative"
label values chbas_genetics chbas_genetics

label var chbas_mutation "Type of mutation"

cap AP_COMPLEMENT_PATH_MU 
gen AP_COMPLEMENT_PATH_MU = .
replace AP_COMPLEMENT_PATH_MU = cond((chbas_mutation == 1 | chbas_mutation == 2), 0, AP_COMPLEMENT_PATH_MU)
replace AP_COMPLEMENT_PATH_MU = cond((chbas_mutation == 3 | chbas_mutation == 4), 1, AP_COMPLEMENT_PATH_MU)
replace AP_COMPLEMENT_PATH_MU = 2 if chbas_mutation > 4 & !missing(chbas_mutation)
label define AP_COMPLEMENT_PATH_MU 0 "Unknown or other mutation" 1 "Pathogenic AP Complement mutatio" 2 "Other genetic abnormalities"
label values AP_COMPLEMENT_PATH_MU AP_COMPLEMENT_PATH_MU
label var AP_COMPLEMENT_PATH_MU "Genetic abnormatlities"

label var chbas_resdiuresis "Recipient's diuresis residual"
label define chbas_resdiuresis 0 "no" 1 "yes"
label values chbas_resdiuresis chbas_resdiuresis

label var chbas_hypertension "Recipient's hypertension"
label define chbas_hypertension 0 "no" 1 "yes"
label values chbas_hypertension chbas_hypertension

label var chbas_dm "Recipient's diabetes"
label define chbas_dm 0 "no" 1 "yes"
label values chbas_dm chbas_dm

label var chbas_cancer "Recipient's history of cancer"
label define chbas_cancer 0 "no" 1 "yes"
label values chbas_cancer chbas_cancer

label var chbas_hiv "Recipient's HIV"
label define chbas_hiv 0 "no" 1 "yes"
label values chbas_hiv chbas_hiv

label var chbas_hcv "Recipient's HCV"
recode chbas_hcv (2=1) 
label define chbas_hcv 0 "no" 1 "yes"
label values chbas_hcv chbas_hcv

label var chbas_hbv "Recipient's HBV"
recode chbas_hbv (2=1)
label define chbas_hbv 0 "no" 1 "yes"
label values chbas_hbv chbas_hbv

label var chbas_mgus "Recipient's MGUS"
label define chbas_mgus 0 "no" 1 "yes"
label values chbas_mgus chbas_mgus

label var chbas_smoke "Smoking status"
label define chbas_smoke 0 "No" 1 "Curren" 2 "Former"
label values chbas_smoke chbas_smoke

label var chbas_cmvigg "Recipient's CMVIgG"
label define chbas_cmvigg 0 "no" 1 "yes"
label values chbas_cmvigg chbas_cmvigg



// CARATTERISTICHE DONATORE
label var don_age "Donor's age"

label var don_sex "Donor's sex"
label define don_sex  0 "F" 1 "M"
label values don_sex don_sex

label var don_cause_death "Donor's cause of death"
label define don_cause_death 1 "Trauma" 2 "cerebrovascular" 3 "cardiovascular" 4 "other" 5 "NA (living donor)" -99 "Unknown"
label values don_cause_death don_cause_death

label var don_hypertension "Donor's hypertension"
label define don_hypertension 0 "no" 1 "yes"
label values don_hypertension don_hypertension

label var don_diabetes "Donor's diabetes"
label define don_diabetes 0 "no" 1 "yes"
label values don_diabetes don_diabetes

label var don_cmvigg "Donor's CMVIgG"
label define don_cmvigg 0 "no" 1 "yes"
label values don_cmvigg don_cmvigg

gen cmvserostatus = .
replace cmvserostatus = 1 if don_cmvigg == 1 & chbas_cmvigg == 0
replace cmvserostatus = 0 if don_cmvigg != 0 & chbas_cmvigg == 1
replace cmvserostatus = 2 if don_cmvigg == 0 & chbas_cmvigg == 0
label define cmvserostatus 0 "D+R+, D-R+" 1 "D+R-" 2 "D-R-"
label values cmvserostatus cmvserostatus
label var cmvserostatus "CMV serostatus"


label var don_min_creat "Min value of donor's creatinine"

// DATI TRAPIANTO
rename ant tx_date
label var tx_date "Date of transplant"
format tx_date %td

label var tx_preemptive "Pre emptive transplant"
label define tx_preemptive 0 "no" 1 "yes"
label values tx_preemptive tx_preemptive

label var tx_type "Type of kidney transplant"
label define tx_type 1 "deceased" 2 "Dual Tx" 2 "Living related" 22 "Living unrelated" 1 "Decased" 11 "Dual" 2 "Living related" 22 "Living unrelated" 3 "SPK" 
label values tx_type tx_type

label var tx_ischaemiafredda "Cold ischemia time, hrs"

label var tx_number "Number of tranplant"

label var tx_incompatible "Incompatible kidney transplant"
label define tx_incompatible 0 "no" 1 "ab0i" 2 "HLAi"
label values tx_incompatible tx_incompatible 

label var tx_pra_mag90 "Elevated PRA"
label define tx_pra_mag90  0 "no" 1 "yes"
label values tx_pra_mag90 tx_pra_mag90

label var tx_mismatch "Number of HLA mismatch"

label var tx_dsa "Presence of pre-transplant DSA"
label define tx_dsa  0 "no" 1 "yes"
label values  tx_dsa  tx_dsa

label var tx_outcome "Outcome of patient"
label define tx_outcome  0 "follow up" 1 "HD" 2 "death" 3 "lost follow up"
label values tx_outcome tx_outcome 

label var tx_tpinduction "Induction therapy"
label define tx_tpinduction  0 "Thymoglobulin" 1 "basiliximab"
label values tx_tpinduction  tx_tpinduction  

label var tx_mantster "Maintenance therapy: steroids"
label define tx_mantster  0 "no" 1 "yes"
label values  tx_mantster  tx_mantster  

label var tx_mantcni "Maintenance therapy: CNI"
label define tx_mantcni  0 "no" 1 "tacrolimus" 2 "ciclosporin"
label values  tx_mantcni  tx_mantcni  

label var tx_mantantimet "Maintenance therapy: anti metabolite"
label define tx_mantantimet  0 "no" 1 "MMF" 2 "AZA"
label values  tx_mantantimet tx_mantantimet

label var tx_mantmtori "Maintenance therapy: mTORi"
label define tx_mantmtori  0 "no" 1 "everolimus" 
label values  tx_mantmtori  tx_mantmtori 

label var tx_dgf "delayed graft function"
label define tx_dgf  0 "no" 1 "yes"
label values tx_dgf tx_dgf 

label var tx_crea_discharge "Creatinine at discharge"

label var tx_mincrea "Minimum value of creatinine post transplant"

label var tx_complication "Complication after tx"
label define tx_complication  0 "no" 1 "yes"
label values  tx_complication  tx_complication 

label var compl_rejectacute "Acute T cell rejection"
label define compl_rejectacute 0 "no" 1 "yes"
label values  compl_rejectacute compl_rejectacute

label var compl_rejectchr "Chronic T cell rejection"
label define compl_rejectchr 0 "no" 1 "yes"
label values  compl_rejectchr compl_rejectchr

label var compl_rejecbacute "Acute B cell rejection"
label define compl_rejecbacute 0 "no" 1 "yes"
label values  compl_rejecbacute compl_rejecbacute
label var compl_rejecbchr "Chronic B cell rejection"
label define compl_rejecbchr 0 "no" 1 "yes"
label values  compl_rejecbchr compl_rejecbchr

label var compl_rejectb " T and B cell rejection"
label define compl_rejectb 0 "no" 1 "yes"
label values  compl_rejectb compl_rejectb

label var compl_cmv "CMV after transplant"
label define compl_cmv 0 "no" 1 "yes"
label values compl_cmv compl_cmv

label var compl_bkv "BKV after transplant"
label define compl_bkv 0 "no" 1 "yes"
label values  compl_bkv compl_bkv

label var compl_bkn "BKN after transplant"
label define compl_bkn 0 "no" 1 "yes"
label values  compl_bkn compl_bkn

label var compl_kaposi "Kaposi after transplant"
label define compl_kaposi 0 "no" 1 "yes"
label values compl_kaposi compl_kaposi

label var compl_ptld "PTLD after transplant"
label define compl_ptld 0 "no" 1 "yes"
label values  compl_ptld compl_ptld

label var compl_recurrence "Recurrence primary disease after transplant"
label define compl_recurrence 0 "no" 1 "yes"
label values  compl_recurrence compl_recurrence

label var compl_tma "TMA after transplant"
label define compl_tma 0 "no" 1 "yes"
label values  compl_tma compl_tma

label var compl_ahus "aHUS after transplant"
label define compl_ahus 0 "no" 1 "yes"
label values  compl_ahus compl_ahus

label var compl_denovogn "De novo glomerulonephritis after transplant"
label define compl_denovogn 0 "no" 1 "yes"
label values  compl_denovogn compl_denovogn

// TERAPIA FOLLOW UP
label var tp_steroids "Steroids"
label define tp_steroids 0 "no" 1 "yes"
label values tp_steroids tp_steroids

label var tp_eculizumab "Eculizumab"
label define tp_eculizumab 0 "no" 1 "yes"
label values tp_eculizumab tp_eculizumab

label var tp_rituximab "Rituximab"
label define tp_rituximab 0 "no" 1 "yes"
label values tp_rituximab tp_rituximab

label var tp_thymo "Thymoglobulin"
label define tp_thymo 0 "no" 1 "yes"
label values tp_thymo tp_thymo


label var tp_pex "Plasma exchange"
label define tp_pex 0 "no" 1 "yes"
label values tp_pex tp_pex

label var tp_increasedmmf "increased dose of MMF"
label define tp_increasedmmf 0 "no" 1 "yes"
label values tp_increasedmmf tp_increasedmmf

label var tp_increasedcni "increased dose of CNI"
label define tp_increasedcni 0 "no" 1 "yes"
label values tp_increasedcni tp_increasedcni

order id
sort id

cd "C:\Documenti\Micaela Gentile\Tesi Francesca"
cap save baseline_tesi_fr, replace

clear

import excel "C:\Documenti\Micaela Gentile\Tesi Francesca\Tesi complemento tx Francesca.xlsx", sheet("follow up") firstrow

mvdecode _all, mv(-99)

foreach var of varlist fu_uprot_crea fu_c3 fu_haptogl {
	replace `var' = abs(`var') if `var' < 0
	}

foreach var of varlist _all {
  qui rename `var' `= strlower("`var'")'
}
 
replace time = trim(time)
replace time = "1 months" if time == "1 month"
replace time = "15 months" if time == "15 month"
replace time = "14 days" if time == "7/20/2023"
replace time = "14 days" if time == "9/29/2023"
replace time = "1 days" if time == "post tx"

gen time_labeled_in_days = .

foreach num of numlist 1 2 3 4 5 6  9 12 15 18 21 24 {
  replace time_labeled = round(`num' * 30.43, 1) if time == "`num' months"
}

foreach num of numlist 1 7 14 {
  replace  time_labeled = `num' if time == "`num' days"
}

replace time_labeled = 0 if time == "pre-tx"

label var time_labeled "Post transplant day (labeled)"


// correct error in dates of CORGIU60 DIONDI66 FERDAN50 PUJCHR81 ROSFED70
replace  data = date("5 January 2023", "DMY") if id ==  "CORGIU60" & time == "7 days"
replace  data = date("4 April 2023", "DMY") if id ==  "DIONDI66" & time == "pre-tx"
replace  data = date("11 April 2023", "DMY") if id ==  "FERDAN50" & time == "4 months"
replace  data = date("17 January 2023", "DMY") if id ==  "PUJCHR81" & time == "2 months"
replace  data = date("20 March 2023", "DMY") if id ==  "ROSFED70" & time == "4 months"




bysort id (data): gen time_exact = data - data[1]
bysort id (data): replace time_exact = 0 if _n == 1

label var time_exact "Post transplant days (calculated)"

gen year = time_exact / 365.25
label var year "Post transplant year (calculated)"


label define yesno  0 "No" 1 "Yes"

gen LOWC3_BASELINE = cond(fu_c3 < 90 & time_exact == 0, 1, 0)
replace LOWC3_BASELINE = . if missing(fu_c3) & time_exact == 0
replace LOWC3_BASELINE = . if time_exact > 0
bysort id (data): replace LOWC3_BASELINE = LOWC3_BASELINE[_n-1] if missing(LOWC3_BASELINE)
label var LOWC3_BASELINE "Low C3 before transplantation"
label values LOWC3_BASELINE yesno


gen LOWC3_1WEEK = cond(fu_c3 < 90 & time_labeled == 7, 1, 0)
replace LOWC3_1WEEK = . if missing(fu_c3) & time_labeled == 7
replace LOWC3_1WEEK = . if time_labeled != 7
egen _LOWC3_1WEEK = sum(LOWC3_1WEEK), by(id)
drop LOWC3_1WEEK
rename _LOWC3_1WEEK LOWC3_1WEEK
label var LOWC3_1WEEK "Low C3 1 week after transplantation"
label values LOWC3_1WEEK yesno


gen LOWC3_1MONTH = cond(fu_c3 < 90 & time_labeled == 30, 1, 0)
replace LOWC3_1MONTH = . if missing(fu_c3) & time_labeled == 30
replace LOWC3_1MONTH = . if time_labeled != 30
egen _LOWC3_1MONTH = sum(LOWC3_1MONTH), by(id)
drop LOWC3_1MONTH
rename _LOWC3_1MONTH LOWC3_1MONTH
label var LOWC3_1MONTH "Low C3 1 month after transplantation"
label values LOWC3_1MONTH yesno

gen LOWC3_PERSISTENT = cond(LOWC3_BASELINE == 1 & (LOWC3_1WEEK == 1 | LOWC3_1MONTH ==1), 1, 0)
replace LOWC3_PERSISTENT = . if missing(LOWC3_BASELINE)
label var LOWC3_PERSISTENT "Persistent Low C3 before and after Tx"
label values LOWC3_PERSISTENT yesno


bysort id (data):  gen _c3_base = fu_c3[1] 
egen _sc3_base = mean(_c3_base), by(id)
bysort id: replace _sc3_base = . if missing(LOWC3_BASELINE)
drop _c3_base
rename _sc3_base _c3_base

bysort id:  gen _c3_1week = fu_c3 if time == "7 days"
egen _sc3_1week = mean(_c3_1week), by(id)
drop _c3_1week
rename _sc3_1week _c3_1week

bysort id: gen _c3_deltabase = fu_c3 - _c3_base


gen LOWC3_DROP1SD = cond((_c3_1week - _c3_base) < -15, 1, 0)
replace LOWC3_DROP1SD = . if (missing(LOWC3_1WEEK) | missing(LOWC3_BASELINE))
label var LOWC3_DROP1SD "C3 dropped 1 week post-Tx beyond 1SD"
label values LOWC3_DROP1SD yesno


bysort id (data): gen     LOWC3_TD = cond(fu_c3 < 90, 1, 0)
bysort id (data): replace LOWC3_TD = sum(LOWC3_TD)
replace LOWC3_TD = 1 if LOWC3_TD > 1 & !missing(LOWC3_TD)
label var LOWC3_TD "Low C3 time-dependent"
label values LOWC3_TD yesno


* LOWC3_BASELINE LOWC3_1WEEK LOWC3_1MONTH LOWC3_PERSISTENT
 
// FOLLOW UP (tx, 7 days, 1 month, 2 months, 3 months, 4 months, 5 months, 6 months, 9 months, 12 months, 15 months, 18 months, 21 months, 24 months)

label var fu_screa "follow up creatinine value"

label var fu_salbumin "follow up serum albumin, g/dL"

label var fu_uprot_crea "follow up urine protein/urine creatinine gr/gr"
replace fu_uprot_crea = . if fu_uprot_crea == 99
replace fu_uprot_crea = fu_uprot_crea  / 10 if fu_uprot_crea > 30
gen log2_fu_uprot_crea  = log(fu_uprot_crea + 0.1)/log(2)
label var log2_fu_uprot_crea "follow up log2 urine protein/urine creatinine"

label var fu_ualb_crea "follow up urine albumin/urine creatinine, mg/gr"
gen log2_fu_ualb_crea  = log(fu_uprot_crea + 0.1)/log(2)
label var log2_fu_ualb_crea "follow up log2 urine albumin/urine creatinine"

label var fu_c3 "follow up serum C3, mg/dL"

label var fu_c4 "follow up serum C4, mg/dL"

label var fu_ldh "follow up serum LDH, IU/L"

label var fu_haptogl "follow up haptoglobin, mg/dL"
gen log2_fu_haptogl = log(fu_haptogl) / log(2)
label var log2_fu_haptogl "follow up log2 haptoglobin, mg/dL"

label var fu_plt "follow up  PLT, count/mm3"
// correct an error
replace fu_plt = fu_plt /10 if fu_plt > 1e6

label var fu_hb "follow up hemoglobin, g/dL"
// correct an error
replace fu_hb = fu_hb /1e4 if fu_hb > 20

label var fu_hematuria "follow up hematuria, count/mm3"
gen log2_fu_hematuria = log(fu_hematuria + 1)/log(2)
label var log2_fu_hematuria  "follow-up log2 hematuria, count/mm3"


foreach var of varlist fu_ualb_crea fu_uprot_crea fu_c3 fu_c4 fu_ldh fu_plt ///
	fu_hb fu_haptogl fu_hematuria {
		egen m_`var' = mean(`var'), by(id)
		label var m_`var' "`:variable label `var''"
		 }

label var fu_dsa "Presence of DSA on follow-up"
label define fu_dsa  0 "no" 1 "yes"
label values  fu_dsa  fu_dsa  

egen _fu_dsa = sum(fu_dsa), by(id)
replace _fu_dsa = 1 if _fu_dsa > 1 & !missing(_fu_dsa)
replace fu_dsa = _fu_dsa

label var fu_biopsy "Biopsy during follow up"
label define fu_biopsy 0 "no" 1 "yes"
label values fu_biopsy fu_biopsy

label var fu_typebiopsy "type of biopsy"
label define fu_typebiopsy 0 "protocol" 1 "clinical indication"
label values fu_typebiopsy fu_typebiopsy

label var banff_i "Banff i value"

label var banff_t "Banff t value"

label var banff_g "Banff g value"

label var banff_v "Banff v value"

label var banff_ptc "Banff ptc value"

label var banff_ci "Banff ci value"

label var banff_ct "Banff ct value"

label var banff_cg "Banff cg value"

label var banff_mm "Banff mm value"

destring banff_cv, force replace
mvdecode banff_cv, mv(-99)

label var banff_cv "Banff cv value"

label var banff_ah "Banff ah value"

label var banff_iifta "Banff iIFTA value"

label var banff_tifta "Banff tIFTA value"

rename idpatient id
replace id = "ROTFED55" if id =="ROSFED50"
order id data
sort id data
cd "C:\Documenti\Micaela Gentile\Tesi Francesca"
cap save longitudinal_tesi_fr, replace

merge m:1 id using baseline_tesi_fr
tab _merge
drop _merge

bysort id (data): gen time_point = _n
label var time_point "Sorted time point"

cd "C:\Documenti\Micaela Gentile\Tesi Francesca"
// correct error in date of birthday
replace chbas_dob = date("22 December 1958", "DMY") if id == "DE LUI22"

gen chbas_age = (data - chbas_dob) / 365.25
label var chbas_age "Age, years"


// CKD-EPI 2009 no race
    cap drop race
	gen race = 0
	cap drop eGFR_CKD_EPI_2009
	gen eGFR_CKD_EPI_2009 =.
	replace eGFR_CKD_EPI_2009 = 141*            (fu_screat/0.9)^(cond(fu_screat<=0.9,-0.411, -1.209))*0.993^chbas_age if chbas_sex==0 & race!=1
	replace eGFR_CKD_EPI_2009 = 141*1.018*      (fu_screat/0.7)^(cond(fu_screat<=0.7,-0.329, -1.209))*0.993^chbas_age if chbas_sex==1 & race!=1
	replace eGFR_CKD_EPI_2009 = 141*1.159*      (fu_screat/0.9)^(cond(fu_screat<=0.9,-0.411, -1.209))*0.993^chbas_age if chbas_sex==0 & race==1
	replace eGFR_CKD_EPI_2009 = 141*1.018*1.159*(fu_screat/0.7)^(cond(fu_screat<=0.7,-0.329, -1.209))*0.993^chbas_age if chbas_sex==1 & race==1
	label var eGFR_CKD_EPI_2009 "eGFR (mL/min/1.73m2) by CKD-EPI 2009"
 
 
 
 // check correct computation CKD-EPI 2009 with the Stata program egfr
    cap drop egfr_ckd_epi_2009
	egfr, cr(fu_screat) us formula(ckdepi) age(chbas_age) female(chbas_sex==1) black(race==1) gen(egfr_ckd_epi_2009) replace
	label var egfr_ckd_epi_2009 "eGFR (mL/min/1.73m2) by CKD-EPI 2009 - check with stata program"

 

// CKD-EPI 2021


cap drop k
cap drop a
cap drop GFR_CKD_EPI_2021
gen k = cond(chbas_sex == 0, 0.9, 0.7)
gen a = cond(chbas_sex == 0, -0.302, - 0.241)	
	gen eGFR_CKD_EPI_2021 =.
    replace eGFR_CKD_EPI_2021 = 142 * ///
	min((fu_screat / k), 1)^ a * ///
	max((fu_screat / k), 1)^ -1.200 * ///
	0.9938 ^ chbas_age
	replace eGFR_CKD_EPI_2021 = eGFR_CKD_EPI_2021 * 1.012 if chbas_sex == 1
	label var eGFR_CKD_EPI_2021  "eGFR (mL/min/1.73m2) by CKD-EPI 2021"
 
 
 
// EKFC


cap drop q
gen q = .
replace q = exp(3.200 + 0.259 * chbas_age - 0.543 * ln(chbas_age) - 0.00763 * chbas_age^2 + 0.0000790 * chbas_age^3) / 88.4 if chbas_sex == 0 & chbas_age < 25
replace q = exp(3.080 + 0.177 * chbas_age - 0.223 * ln(chbas_age) - 0.00596 * chbas_age^2 + 0.0000686 * chbas_age^3) / 88.4 if chbas_sex == 1 & chbas_age < 25
replace q = 0.90 if chbas_sex == 0 & chbas_age >= 25
replace q = 0.70 if chbas_sex == 1 & chbas_age >= 25
cap drop f40
gen f40 = .
replace f40 = 1 if chbas_age < 40
replace f40 = 0.990 ^ (chbas_age - 40) if chbas_age >= 40

cap drop alpha 
    cap drop eGFR_EKFC
	gen r = fu_screat / q
	gen alpha = cond(r < 1, 0.322, 1.132)
	gen eGFR_EKFC =.
	replace eGFR_EKFC = 107.3/r ^ alpha * f40
	label var eGFR_EKFC "eGFR (mL/min/1.73m2) by EKFC"

 

 * tx_mincrea
 
 // CKD-EPI 2009 minimum
 gen min_eGFR = 141*(tx_mincrea/0.9)^(cond(tx_mincrea<=0.9,-0.411, -1.209))*0.993^chbas_age if chbas_sex==0 & race!=1
 replace min_eGFR = 141*1.018*      (tx_mincrea/0.7)^(cond(tx_mincrea<=0.7,-0.329, -1.209))*0.993^chbas_age if chbas_sex==1 & race!=1
 replace min_eGFR = 141*1.159*      (tx_mincrea/0.9)^(cond(tx_mincrea<=0.9,-0.411, -1.209))*0.993^chbas_age if chbas_sex==0 & race==1
 replace min_eGFR =141*1.018*1.159*(tx_mincrea/0.7)^(cond(tx_mincrea<=0.7,-0.329, -1.209))*0.993^chbas_age if chbas_sex==1 & race==1
 label var min_eGFR "Maximum post-transplant eGFR (mL/min/1.73m2) by CKD-EPI"
 rename min_eGFR min_eGFR_CKD_EPI_2009
 
 
 // CKD-EPI 2021 minimum
 gen min_eGFR_CKD_EPI_2021 = 142 * ///
	min((tx_mincrea / k), 1)^ a * ///
	max((tx_mincrea / k), 1)^ -1.200 * ///
	0.9938 ^ chbas_age 
	replace min_eGFR_CKD_EPI_2021 = min_eGFR_CKD_EPI_2021  * 1.012 if chbas_sex == 1
	label var min_eGFR_CKD_EPI_2021 "Maximum post-transplant eGFR (mL/min/1.73m2) by CKD-EPI 2021"
	
	
// EKFC minimum
		gen min_r = tx_mincrea/ q
		gen min_alpha = cond(min_r < 1, 0.322, 1.132)
		gen min_eGFR_EKFC =.
		replace min_eGFR_EKFC= 107.3/min_r ^ min_alpha * f40
	label var min_eGFR_EKFC "Maximum post-transplant eGFR (mL/min/1.73m2) by EKFC"
	

	* tx_crea_discharge
// 

 // CKD-EPI 2009 minimum
 gen disch_eGFR = 141*(tx_crea_discharge/0.9)^(cond(tx_crea_discharge<=0.9,-0.411, -1.209))*0.993^chbas_age if chbas_sex==0 & race!=1
 replace disch_eGFR = 141*1.018*      (tx_crea_discharge/0.7)^(cond(tx_crea_discharge<=0.7,-0.329, -1.209))*0.993^chbas_age if chbas_sex==1 & race!=1
 replace disch_eGFR = 141*1.159*      (tx_crea_discharge/0.9)^(cond(tx_crea_discharge<=0.9,-0.411, -1.209))*0.993^chbas_age if chbas_sex==0 & race==1
 replace disch_eGFR =141*1.018*1.159*(tx_crea_discharge/0.7)^(cond(tx_crea_discharge<=0.7,-0.329, -1.209))*0.993^chbas_age if chbas_sex==1 & race==1
 label var disch_eGFR "Discharge post-transplant eGFR (mL/min/1.73m2) by CKD-EPI"
 rename disch_eGFR disch_eGFR_CKD_EPI_2009
 
 
 // CKD-EPI 2021 minimum
 gen disch_eGFR_CKD_EPI_2021 = 142 * ///
	min((tx_crea_discharge / k), 1)^ a * ///
	max((tx_crea_discharge / k), 1)^ -1.200 * ///
	0.9938 ^ chbas_age 
	replace disch_eGFR_CKD_EPI_2021 = disch_eGFR_CKD_EPI_2021  * 1.012 if chbas_sex == 1
	label var disch_eGFR_CKD_EPI_2021 "Discharge post-transplant eGFR (mL/min/1.73m2) by CKD-EPI 2021"
	
	
// EKFC minimum
		gen disch_r = tx_crea_discharge/ q
		gen disch_alpha = cond(min_r < 1, 0.322, 1.132)
		gen disch_eGFR_EKFC =.
		replace disch_eGFR_EKFC= 107.3/disch_r ^ disch_alpha * f40
	label var disch_eGFR_EKFC "Discharge post-transplant eGFR (mL/min/1.73m2) by EKFC"

egen end_fup = max(data), by(id)
label var end_fup "Date of end follow-up"
egen outcome = sum(tx_outcome), by(id)
replace outcome = 2 if outcome > 2 & !missing(outcome)
label define outcome 0 "Alive graft functioning" 1 "ESKD" 2 "Death"
label values outcome outcome

cap save merged_tesi_fr, replace

preserve
cd "C:\Documenti\Micaela Gentile\Tesi Francesca"
keep if time_point == 1
cap save merged_baseline_tesi_fr, replace
restore

********************************************************************************
**#  END PREPARING DATASET FOR ANALYSES
********************************************************************************



********************************************************************************
**# START TABLES BASELINE CHARACTERISTICS
********************************************************************************
clear
cd "C:\Documenti\Micaela Gentile\Tesi Francesca"
use merged_baseline_tesi_fr



foreach var of varlist fu_c3 fu_c4 fu_ldh fu_plt fu_hb fu_haptogl fu_hematuria {
	gen b_`var' = `var'
	 }
label var b_fu_c3     "Baseline serum C3, mg/dL"
label var b_fu_c4     "Baseline serum C4, mg/dL"
label var b_fu_ldh    "Baseline serum LDH, IU/L"
label var b_fu_plt    "Baseline follow up PLT, count/mm3"
label var b_fu_hb     "Baseline hemoglobin, g/dL"
label var b_fu_haptogl "Baseline  haptoglobin, mg/dL"
label var b_fu_hematuria "Baseline hematuria, count/mm3"

	

foreach var of varlist LOWC3_BASELINE LOWC3_1WEEK LOWC3_1MONTH LOWC3_PERSISTENT LOWC3_DROP1SD {
dtable chbas_age i.chbas_sex  i.chbas_ethnicity i.PRIMARY_KIDNEY_DIS i.AP_COMPLEMENT_PATH_MU i.chbas_resdiuresis i.chbas_hypertension i.chbas_dm i.chbas_cancer i.chbas_hiv i.chbas_hcv i.chbas_hbv i.chbas_mgus i.chbas_smoke don_age i.don_sex i.don_cause_death i.don_hypertension i.don_diabetes i.cmvserostatus i.tx_type tx_ischaemiafredda i.tx_number i.tx_incompatible i.tx_pra_mag90 tx_mismatch i.tx_dsa i.tx_tpinduction i.tx_mantster  i.tx_mantcni i.tx_mantantimet i.tx_mantmtori  b_fu_c3 b_fu_c4 b_fu_ldh b_fu_plt b_fu_hb b_fu_haptogl b_fu_hematuria ///
	, ///	
	by(`var', nototals tests) ///
	factor(chbas_sex  chbas_ethnicity PRIMARY_KIDNEY_DIS AP_COMPLEMENT_PATH_MU chbas_resdiuresis chbas_hypertension chbas_dm chbas_cancer chbas_hiv chbas_hcv chbas_hbv chbas_mgus chbas_smoke don_sex don_cause_death don_hypertension don_diabetes cmvserostatus tx_type tx_number tx_incompatible tx_pra_mag90 tx_dsa tx_tpinduction tx_mantster  tx_mantcni tx_mantantimet tx_mantmtori, test(fisher)) ///
	define(meansd = mean sd, delimiter(" ± ")) ///
	sformat("%s" sd) ///
	define(myiqr = p25 p75, delimiter("-")) ///
	sformat("(%s)" myiqr) ///
	define(myrange = min max, delimiter("-")) ///
	sformat("[%s]" myrange) ///
	nformat("%3.1f" mean sd median p25 p75) ///
	nformat("%3.0f" min max) ///
    nformat("%3.0f" N count fvfrequency) ///
    nformat("%3.1f" fvpercent ) ///
    nformat("%6.3f" kwallis fisher) ///
    continuous(chbas_age don_age tx_mismatch, stat(meansd) test(kwallis)) ///   
	continuous(tx_ischaemiafredda  b_fu_plt b_fu_hb  b_fu_hematuria, stat(median myiqr) test(kwallis)) ///   
	continuous(b_fu_c3 b_fu_c4 b_fu_ldh b_fu_haptogl,  stat(median myrange) test(kwallis)) ///	
	column(by(hide) test(p-value)) ///
	title("Table X. Baseline characteristics by `:variable label `var''") ///
	note(Mann-Whitney test for continuous variables (reported as mean ± standard deviation), median (iqr) or median [range].) ///
    note(Fisher's exact test for categorical variables (reported as number (percentage)).) ///
	note(Baseline characteristics of the study population)
	
	collect style cell cell_type[row-header],  font(Arial , size(10) bold noitalic color(navy)) 
	collect style cell cell_type[column-header],  font(Arial , size(10) bold noitalic color(navy)) 
	collect style cell cell_type[item],  font(Arial , size(10) noitalic) 
	collect style title, font(Arial, bold size(14))
	collect style notes, font(Arial, italic size(8)) 
	collect export "Baseline characteristics `:variable label `var''.docx", replace
	collect export "Baseline characteristics `:variable label `var''.html", replace
	 }
	 
********************************************************************************
**# END TABLES BASELINE CHARACTERISTICS
********************************************************************************


********************************************************************************
**# START TABLES COMPLICATIONS DURING FOLLOW_UP
********************************************************************************
clear
cd "C:\Documenti\Micaela Gentile\Tesi Francesca"
use merged_baseline_tesi_fr



foreach var of varlist LOWC3_BASELINE LOWC3_1WEEK LOWC3_1MONTH LOWC3_PERSISTENT LOWC3_DROP1SD {
dtable i.tx_dgf disch_eGFR_CKD_EPI_2009 disch_eGFR_CKD_EPI_2021 disch_eGFR_EKFC min_eGFR_CKD_EPI_2009 min_eGFR_CKD_EPI_2021 min_eGFR_EKFC i.tx_complication i.fu_dsa i.compl_rejectacute i.compl_rejectchr i.compl_rejecbacute i.compl_rejecbchr i.compl_rejectb i.compl_cmv i.compl_bkv i.compl_bkn i.compl_kaposi i.compl_ptld i.compl_recurrence i.compl_tma i.compl_ahus i.compl_denovogn i.tp_steroids i.tp_eculizumab i.tp_rituximab i.tp_thymo i.tp_pex i.tp_increasedmmf i.tp_increasedcni m_fu_ualb_crea m_fu_uprot_crea m_fu_c3 m_fu_c4 m_fu_ldh m_fu_plt m_fu_hb m_fu_haptogl m_fu_hematuria ///
	, ///	
	by(`var', nototals tests) ///
	factor(tx_dgf tx_complication fu_dsa compl_rejectacute compl_rejectchr compl_rejecbacute compl_rejecbchr compl_rejectb compl_cmv compl_bkv compl_bkn compl_kaposi compl_ptld compl_recurrence compl_tma compl_ahus compl_denovogn tp_steroids tp_eculizumab tp_rituximab tp_thymo tp_pex tp_increasedmmf tp_increasedcni, test(fisher)) ///
	define(meansd = mean sd, delimiter(" ± ")) ///
	sformat("%s" sd) ///
	define(myiqr = p25 p75, delimiter("-")) ///
	sformat("(%s)" myiqr) ///
	define(myrange = min max, delimiter("-")) ///
	sformat("[%s]" myrange) ///
	nformat("%3.1f" mean sd median p25 p75) ///
	nformat("%3.0f" min max) ///
    nformat("%3.0f" N count fvfrequency) ///
    nformat("%3.1f" fvpercent ) ///
    nformat("%6.3f" kwallis fisher) ///
    continuous(disch_eGFR_CKD_EPI_2009 disch_eGFR_CKD_EPI_2021 disch_eGFR_EKFC min_eGFR_CKD_EPI_2009 min_eGFR_CKD_EPI_2021 min_eGFR_EKFC m_fu_hb , stat(meansd) test(kwallis)) ///   
	continuous(m_fu_ualb_crea m_fu_uprot_crea m_fu_plt  m_fu_hematuria, stat(median myiqr) test(kwallis)) ///   
	continuous(m_fu_ldh m_fu_haptogl m_fu_c3 m_fu_c4,  stat(median myrange) test(kwallis)) ///	
	column(by(hide) test(p-value)) ///
	title("Table X. Complications by `:variable label `var''") ///
	note(Mann-Whitney test for continuous variables (reported as mean ± standard deviation), median (iqr) or median [range].) ///
    note(Fisher's exact test for categorical variables (reported as number (percentage)).) ///
	note("Follow-up characteristics of the study population")
	
	collect style cell cell_type[row-header],  font(Arial , size(10) bold noitalic color(navy)) 
	collect style cell cell_type[column-header],  font(Arial , size(10) bold noitalic color(navy)) 
	collect style cell cell_type[item],  font(Arial , size(10) noitalic) 
	collect style title, font(Arial, bold size(14))
	collect style notes, font(Arial, italic size(8)) 
	collect export "Complications over follow-up `:variable label `var''.docx", replace
	collect export "Complications over follow-up `:variable label `var''.html", replace
	 }
	 
	 
********************************************************************************
**# START TABLES BIOPSY
********************************************************************************
clear
cd "C:\Documenti\Micaela Gentile\Tesi Francesca"
use merged_tesi_fr
/*
fu_typebiopsy

banff_i banff_t banff_g banff_v banff_ptc banff_ci banff_ct banff_cg banff_mm banff_cv banff_ah banff_iifta banff_t
ifta
*/


foreach var of varlist fu_typebiopsy banff_i banff_t banff_g banff_v banff_ptc banff_ci ///
	banff_ct banff_cg banff_mm banff_cv banff_ah banff_iifta banff_t  { 
		cap drop _`var'
		egen _`var' = mean(`var'), by(id)
		replace `var' = _`var'
		 }
keep if time_point == 1	
replace fu_typebiopsy = ceil(fu_typebiopsy)


foreach var of varlist LOWC3_BASELINE LOWC3_1WEEK LOWC3_1MONTH LOWC3_PERSISTENT LOWC3_DROP1SD {
dtable i.fu_typebiopsy banff_i banff_t banff_g banff_v banff_ptc banff_ci ///
	banff_ct banff_cg banff_mm banff_cv banff_ah banff_iifta banff_t  ///
	, ///	
	by(`var', nototals tests) ///
	factor(fu_typebiopsy, test(fisher)) ///
	define(meansd = mean sd, delimiter(" ± ")) ///
	sformat("%s" sd) ///
	define(myiqr = p25 p75, delimiter("-")) ///
	sformat("(%s)" myiqr) ///
	define(myrange = min max, delimiter("-")) ///
	sformat("[%s]" myrange) ///
	nformat("%3.1f" mean sd median p25 p75) ///
	nformat("%3.0f" min max) ///
    nformat("%3.0f" N count fvfrequency) ///
    nformat("%3.1f" fvpercent ) ///
    nformat("%6.3f" kwallis fisher) ///
    continuous(banff_i banff_t banff_g banff_v banff_ptc banff_ci ///
	banff_ct banff_cg banff_mm banff_cv banff_ah banff_iifta banff_t, stat(meansd) test(kwallis)) ///   
	continuous(, stat(median myiqr) test(kwallis)) ///   
	continuous(,  stat(median myrange) test(kwallis)) ///	
	column(by(hide) test(p-value)) ///
	title("Table X. Biopsy result by `:variable label `var''") ///
	note(Mann-Whitney test for continuous variables (reported as mean ± standard deviation), median (iqr) or median [range].) ///
    note(Fisher's exact test for categorical variables (reported as number (percentage)).) ///
	note("Follow-up characteristics of the study population")
	collect style cell cell_type[row-header],  font(Arial , size(10) bold noitalic color(navy)) 
	collect style cell cell_type[column-header],  font(Arial , size(10) bold noitalic color(navy)) 
	collect style cell cell_type[item],  font(Arial , size(10) noitalic) 
	collect style title, font(Arial, bold size(14))
	collect style notes, font(Arial, italic size(8)) 

	collect export "Post-transplant biopsy `:variable label `var''.docx", replace
	collect export "Post-transplant biopsy `:variable label `var''.html", replace
	 }	 


		

********************************************************************************
**# END TABLES BIOPSY
********************************************************************************


********************************************************************************
**# END TABLES COMPLICATIONS DURING FOLLOW_UP
********************************************************************************
	

********************************************************************************
**# START LONGITUDINA ANALYSES eGFR PROTEINURIA AND OTHER LAB VALUES
********************************************************************************

clear
cd "C:\Documenti\Micaela Gentile\Tesi Francesca"
use merged_tesi_fr

twoway connected eGFR_EKFC year if LOWC3_BASELINE == 0, connect(ascending)   lwidth(*.3) lcolor(navy) msymbol(i) || ///
	connected eGFR_EKFC year if LOWC3_BASELINE == 1, connect(ascending)   lwidth(*.3) lcolor(maroon) msymbol(i) || ///
	fpfit eGFR_EKFC year if LOWC3_BASELINE == 0, lwidth(*4) lcolor(navy) || ///
	fpfit eGFR_EKFC year if LOWC3_BASELINE == 1, lwidth(*4) lcolor(maroon) ||,  ///
	xlabel(0(0.5)2) ///
	xtitle("") xtitle("Year since Transplantation") ///
	ylabel(0(15)135) ysc(range(0 135)) ///
	ytitle("eGFR - ml/min/1.73{sup:2}") ///
	legend(order(1 "Others" 2 "Low C3 before Tx") ) ///
	title("eGFR", box bexpand) name(long_egfr, replace)
	graph export egfr_trajectories.png, replace
    graph export egfr_trajectories.pdf, replace
    graph export egfr_trajectories.tif, replace

	
	
twoway connected fu_c3 year if LOWC3_BASELINE == 0, connect(ascending)   lwidth(*.3) lcolor(navy) msymbol(i) || ///
	connected fu_c3 year if LOWC3_BASELINE == 1, connect(ascending)   lwidth(*.3) lcolor(maroon) msymbol(i) || ///
	fpfit fu_c3 year if LOWC3_BASELINE == 0, lwidth(*4) lcolor(navy) || ///
	fpfit fu_c3 year if LOWC3_BASELINE == 1, lwidth(*4) lcolor(maroon) ||,  ///
	xlabel(0(30)120) ///
	xtitle("") xtitle("Year since Transplantation") ///
	ylabel(0(30)180) ysc(range(0 180)) ///
	ytitle("C3 - mg/dl") ///
	legend(order(1 "Others" 2 "Low C3 before Tx") ) ///
	title("Serum C3", box bexpand) name(long_c3, replace)
	graph export c3_trajectories.png, replace
    graph export c3_trajectories.pdf, replace
    graph export c3_trajectories.tif, replace
	
	
twoway connected fu_plt year if LOWC3_BASELINE == 0, connect(ascending)   lwidth(*.3) lcolor(navy) msymbol(i) || ///
	connected fu_plt year if LOWC3_BASELINE == 1, connect(ascending)   lwidth(*.3) lcolor(maroon) msymbol(i) || ///
	fpfit fu_plt year if LOWC3_BASELINE == 0, lwidth(*4) lcolor(navy) || ///
	fpfit fu_plt year if LOWC3_BASELINE == 1, lwidth(*4) lcolor(maroon) ||,  ///
	xlabel(0(0.5)2) ///
	xtitle("") xtitle("Year since Transplantation") ///
	ylabel(0(50000)550000) ysc(range(0 550000)) ///
	ytitle("PTL - count/mm3") ///
	legend(order(1 "Others" 2 "Low C3 before Tx") ) ///
	title("PLT count", box bexpand) name(long_plt, replace)
	graph export plt_trajectories.png, replace
    graph export plt_trajectories.pdf, replace
    graph export plt_trajectories.tif, replace
	
	
twoway connected fu_hb year if LOWC3_BASELINE == 0, connect(ascending)   lwidth(*.3) lcolor(navy) msymbol(i) || ///
	connected fu_hb year if LOWC3_BASELINE == 1, connect(ascending)   lwidth(*.3) lcolor(maroon) msymbol(i) || ///
	fpfit fu_hb year if LOWC3_BASELINE == 0, lwidth(*4) lcolor(navy) || ///
	fpfit fu_hb year if LOWC3_BASELINE == 1, lwidth(*4) lcolor(maroon) ||,  ///
	xlabel(0(0.5)2) ///
	xtitle("") xtitle("Year since Transplantation") ///
	ylabel(0(2)18) ysc(range(0 18)) ///
	ytitle("Hb - g/dl") ///
	legend(order(1 "Others" 2 "Low C3 before Tx") ) ///
	title("Serum Hb", box bexpand) name(long_hb, replace)
	graph export hb_trajectories.png, replace
    graph export hb_trajectories.pdf, replace
    graph export hb_trajectories.tif, replace
	
	
twoway connected fu_ldh year if LOWC3_BASELINE == 0, connect(ascending)   lwidth(*.3) lcolor(navy) msymbol(i) || ///
	connected fu_ldh year if LOWC3_BASELINE == 1, connect(ascending)   lwidth(*.3) lcolor(maroon) msymbol(i) || ///
	fpfit fu_ldh year if LOWC3_BASELINE == 0, lwidth(*4) lcolor(navy) || ///
	fpfit fu_ldh year if LOWC3_BASELINE == 1, lwidth(*4) lcolor(maroon) ||,  ///
	xlabel(0(0.5)2) ///
	xtitle("") xtitle("Year since Transplantation") ///
	ylabel(0(50)700) ysc(range(0 700)) ///
	ytitle("LDH - IU/l") ///
	legend(order(1 "Others" 2 "Low C3 before Tx") ) ///
	title("Serum LDH", box bexpand) name(long_ldh, replace)
	graph export ldh_trajectories.png, replace
    graph export ldh_trajectories.pdf, replace
    graph export ldh_trajectories.tif, replace
	
	
	
twoway connected fu_haptogl year if LOWC3_BASELINE == 0, connect(ascending)   lwidth(*.3) lcolor(navy) msymbol(i) || ///
	connected fu_haptogl year if LOWC3_BASELINE == 1, connect(ascending)   lwidth(*.3) lcolor(maroon) msymbol(i) || ///
	fpfit fu_haptogl year if LOWC3_BASELINE == 0, lwidth(*4) lcolor(navy) || ///
	fpfit fu_haptogl year if LOWC3_BASELINE == 1, lwidth(*4) lcolor(maroon) ||,  ///
	xlabel(0(0.5)2) ///
	xtitle("") xtitle("Year since Transplantation") ///
	ylabel(0(50)400) ysc(range(0 400)) ///
	ytitle("Haptoglobin- mg/dl") ///
	legend(order(1 "Others" 2 "Low C3 before Tx") ) ///
	title("Haptoglobin", box bexpand)  name(lonf_hapto, replace)
	graph export hapto_trajectories.png, replace
    graph export hapto_trajectories.pdf, replace
    graph export hapto_trajectories.tif, replace
	
	
twoway connected fu_uprot_crea year if LOWC3_BASELINE == 0, connect(ascending)   lwidth(*.3) lcolor(navy) msymbol(i) || ///
	connected fu_uprot_crea year if LOWC3_BASELINE == 1, connect(ascending)   lwidth(*.3) lcolor(maroon) msymbol(i) || ///
	fpfit fu_uprot_crea year if LOWC3_BASELINE == 0, lwidth(*4) lcolor(navy) || ///
	fpfit fu_uprot_crea year if LOWC3_BASELINE == 1, lwidth(*4) lcolor(maroon) ||,  ///
	xlabel(0(0.5)2) ///
	xtitle("") xtitle("Year since Transplantation") ///
	ylabel(0(3)21) ysc(range(0 21)) ///
	ytitle("Urinary Protein to Creatinine ratio - gr/gr") ///
	legend(order(1 "Others" 2 "Low C3 before Tx") ) ///
	title("Urinary Protein to Creatinine ratio", box bexpand)  name(long_prot, replace)
	graph export prot_trajectories.png, replace
    graph export prot_trajectories.pdf, replace
    graph export prot_trajectories.tif, replace
	
	

preserve
replace fu_hematuria = abs(invnorm(uniform()))* 1000 + 1500 if fu_hematuria > 1500
twoway connected fu_hematuria year if LOWC3_BASELINE == 0, connect(ascending)   lwidth(*.3) lcolor(navy) msymbol(i) || ///
	connected fu_hematuria year if LOWC3_BASELINE == 1, connect(ascending)   lwidth(*.3) lcolor(maroon) msymbol(i) || ///
	fpfit fu_hematuria year if LOWC3_BASELINE == 0, lwidth(*4) lcolor(navy) || ///
	fpfit fu_hematuria year if LOWC3_BASELINE == 1, lwidth(*4) lcolor(maroon) ||,  ///
	xlabel(0(0.5)2) ///
	xtitle("") xtitle("Year since Transplantation") ///
	ylabel(0(500)1500) ysc(range(0 1500)) ///
	ytitle("Hematuria - count/mm3") ///
	legend(order(1 "Others" 2 "Low C3 before Tx") ) ///
	title("Hematuria", box bexpand)  name(long_hematu, replace)
	graph export hematu_trajectories.png, replace
    graph export hematu_trajectories.pdf, replace
    graph export hematu_trajectories.tif, replace
restore


grc1leg2 long_egfr long_prot long_hematu  ///
	     long_hb long_plt long_ldh ///
		 long_c3 lonf_hapto ///
		 , ///
		 iscale(0.4) xcommon ///
		 position(5)  ///        Where legend appears in the combined graph*
         ring(0)  ///
		 lyoffset(+10) lxoffset(-10) ///
	     legscale(3)  lmsize(5)
graph export long_all_panel_combined.png, replace
graph export long_all_panel_combined.pdf, replace
graph export long_all_panel_combined.svg, replace

		 



foreach var of varlist eGFR_CKD_EPI_2009 eGFR_CKD_EPI_2021 eGFR_EKFC ///
log2_fu_ualb_crea log2_fu_uprot_crea fu_c3 fu_ldh fu_plt fu_hb ///
log2_fu_haptogl log2_fu_hematuria {
	qui summ `var'
	replace `var' = (`var' - r(mean)) / r(sd)
	}

collect clear
collect style clear
collect style use default
cap collect drop Models Models_cons Models2 Models2_cons
cap collect create Models, replace
cap collect create Models_cons, replace
cap collect create Models2, replace
cap collect create Models2_cons, replace 
global conf "chbas_age don_age i.tx_type"
foreach y of varlist eGFR_CKD_EPI_2009 eGFR_CKD_EPI_2021 eGFR_EKFC ///
log2_fu_ualb_crea log2_fu_uprot_crea fu_c3 fu_ldh fu_plt fu_hb ///
log2_fu_haptogl log2_fu_hematuria  {
foreach var of varlist LOWC3_BASELINE LOWC3_1WEEK LOWC3_1MONTH ///
LOWC3_PERSISTENT LOWC3_DROP1SD LOWC3_TD {
di "----> `:variable label `var'' with `:variable label `y''"
qui mixed `y' i.`var'##c.year $conf || id: year , cov(unstr) reml dfmethod(kroger)
collect, name(Models) tag(model["`:variable label `var'' on `:variable label `y'' (1SD)"]): qui lincom _b[1.`var'#c.year]
collect, name(Models_cons) tag(model["`:variable label `var'' on `:variable label `y'' (1SD)"]): qui lincom _b[1.`var']
collect, name(Models2) tag(var1[`y'] var2[`var']): qui lincom _b[1.`var'#c.year]
collect, name(Models2_cons) tag(var1[`y'] var2[`var']): qui lincom _b[1.`var']
}
}



 // define number of digits and format
collect style cell result[estimate], nformat(%3.2f) name(Models)
collect style cell result[lb], nformat(%3.2f) sformat("(%s") name(Models)
collect style cell result[ub], nformat(%3.2f) sformat("to %s)") name(Models)
collect style cell result[p], nformat(%4.3f) sformat("P=%s") minimum(0.001) name(Models)
// do not draw vertical lines
collect style cell cell_type, border(right, pattern(nil)) name(Models)
//  columns
collect style column, dups(center) extraspace(2)  width(asis) name(Models)

collect layout (model) (result[estimate lb ub p]), name(Models)
// column headers
collect label levels result estimate "Beta ", modify name(Models)
collect label levels result lb "95%CI lb", modify name(Models)
collect label levels result ub "ub)", modify name(Models)
collect label levels result p "P value", modify name(Models)

collect style cell cell_type[row-header],  font(Arial , size(9) bold noitalic color(navy)) name(Models)
collect style cell cell_type[column-header],  font(Arial , size(10) bold noitalic color(navy)) name(Models)
collect style cell cell_type[item],  font(Arial , size(10) noitalic) name(Models)
collect style header var1, title(hide) name(Models)
collect title "Table S4B. Yearly change in lab values (SD units) w.r.t. control according to Low C3 categories", name(Models)
collect style title, font(Arial, bold size(14)) name(Models)
collect notes 1: "Beta represents the difference in the yearly change of the variable in the Low C3 category w.r.t to control group", name(Models)
collect notes 2: "Adjusted for donor and recipient age, and for type of transplantation", name(Models)
collect style notes, font(Arial, italic size(8)) name(Models)
collect export table_long_1.docx, name(Models) replace
collect export table_long_1.html, name(Models) replace
collect export table_long_1.md, name(Models) replace
collect export table_long_1.xlsx, name(Models) replace



 // define number of digits and format
collect style cell result[estimate], nformat(%3.2f) name(Models_cons)
collect style cell result[lb], nformat(%3.2f) sformat("(%s") name(Models_cons)
collect style cell result[ub], nformat(%3.2f) sformat("to %s)") name(Models_cons)
collect style cell result[p], nformat(%4.3f) sformat("P=%s") minimum(0.001) name(Models_cons)
// do not draw vertical lines
collect style cell cell_type, border(right, pattern(nil)) name(Models_cons)
//  columns
collect style column, dups(center) extraspace(2)  width(asis) name(Models_cons)

collect layout (model) (result[estimate lb ub p]), name(Models_cons)
// column headers
collect label levels result estimate "Alpha ", modify name(Models_cons)
collect label levels result lb "95%CI lb", modify name(Models_cons)
collect label levels result ub "ub)", modify name(Models_cons)
collect label levels result p "P value", modify name(Models_cons)

collect style cell cell_type[row-header],  font(Arial , size(9) bold noitalic color(navy)) name(Models_cons)
collect style cell cell_type[column-header],  font(Arial , size(10) bold noitalic color(navy)) name(Models_cons)
collect style cell cell_type[item],  font(Arial , size(10) noitalic) name(Models_cons)
collect style header var1, title(hide) name(Models_cons)
collect title "Table S4A. Baseline difference in lab values (SD units) w.r.t. control according to Low C3 categories", name(Models_cons)
collect style title, font(Arial, bold size(14)) name(Models_cons)
collect notes 1: "Alpha represents the baseline difference in the variable in the Low C3 category w.r.t to control group", name(Models_cons)
collect notes 2: "Adjusted for donor and recipient age, and for type of transplantation", name(Models_cons)
collect style notes, font(Arial, italic size(8)) name(Models_cons)
collect export table_long_cons_1.docx, name(Models_cons) replace
collect export table_long_cons_1.html, name(Models_cons) replace
collect export table_long_cons_1.md, name(Models_cons) replace
collect export table_long_cons_1.xlsx, name(Models_cons) replace


 // define number of digits and format
collect style cell result[estimate], nformat(%3.2f) name(Models2)
collect style cell result[lb], nformat(%3.2f)  sformat("(%s") name(Models2)
collect style cell result[ub], nformat(%3.2f) sformat("%s)") name(Models2)
collect style cell result[p], nformat(%4.3f) sformat("P=%s") minimum(0.001) name(Models2)
// do not draw vertical lines
collect style cell cell_type, border(right, pattern(nil)) name(Models2)
//  columns
collect style column, dups(center) extraspace(2)  width(asis) name(Models2)

collect layout (model) (result[estimate lb ub p]), name(Models2)
// column headers
collect label levels result estimate "Beta", modify name(Models2)
collect label levels result lb "95%CI (lb", modify name(Models2)
collect label levels result ub "ub)", modify name(Models2)
collect label levels result p "P value", modify name(Models2)

collect layout (var1) (var2#result[estimate lb ub p]), name(Models2)

foreach var of varlist eGFR_CKD_EPI_2009 eGFR_CKD_EPI_2021 eGFR_EKFC ///
	log2_fu_ualb_crea log2_fu_uprot_crea fu_c3 fu_ldh fu_plt fu_hb ///
	log2_fu_haptogl log2_fu_hematuria  {
		collect label levels var1 `var' "`:variable label `var''", modify name(Models2)	
}

foreach var of varlist LOWC3_BASELINE LOWC3_1WEEK LOWC3_1MONTH ///
	LOWC3_PERSISTENT LOWC3_DROP1SD LOWC3_TD  {
		collect label levels var2 `var' "`:variable label `var''", modify name(Models2)	
}	


collect style cell cell_type[row-header],  font(Arial , size(9) bold noitalic color(navy)) name(Models2)
collect style cell cell_type[column-header],  font(Arial , size(10) bold noitalic color(navy)) name(Models2)
collect style cell cell_type[item],  font(Arial , size(10) noitalic) name(Models2)
collect style header var1, title(hide) name(Models2)
collect title "Table S4B. Yearly change in lab values (SD units) w.r.t. control according to Low C3 categories", name(Models2)
collect style title, font(Arial, bold size(14)) name(Models2)
collect notes 1: "Beta represents the difference in the yearly change of the variable in the Low C3 category w.r.t to control group", name(Models2)
collect notes 2: "Adjusted for donor and recipient age, and for type of transplantation", name(Models2)
collect style notes, font(Arial, italic size(8)) name(Models2)
collect export table_long_2.docx, name(Models2) replace
collect export table_long_2.html, name(Models2) replace
collect export table_long_2.md, name(Models2) replace
collect export table_long_2.xlsx, name(Models2) replace






 // define number of digits and format
collect style cell result[estimate], nformat(%3.2f) name(Models2_cons)
collect style cell result[lb], nformat(%3.2f)  sformat("(%s") name(Models2_cons)
collect style cell result[ub], nformat(%3.2f) sformat("%s)") name(Models2_cons)
collect style cell result[p], nformat(%4.3f) sformat("P=%s") minimum(0.001) name(Models2_cons)
// do not draw vertical lines
collect style cell cell_type, border(right, pattern(nil)) name(Models2_cons)
//  columns
collect style column, dups(center) extraspace(2)  width(asis) name(Models2_cons)

collect layout (model) (result[estimate lb ub p]), name(Models2_cons)
// column headers
collect label levels result estimate "Alpha", modify name(Models2_cons)
collect label levels result lb "95%CI (lb", modify name(Models2_cons)
collect label levels result ub "ub)", modify name(Models2_cons)
collect label levels result p "P value", modify name(Models2_cons)

collect layout (var1) (var2#result[estimate lb ub p]), name(Models2_cons)

foreach var of varlist eGFR_CKD_EPI_2009 eGFR_CKD_EPI_2021 eGFR_EKFC ///
	log2_fu_ualb_crea log2_fu_uprot_crea fu_c3 fu_ldh fu_plt fu_hb ///
	log2_fu_haptogl log2_fu_hematuria  {
		collect label levels var1 `var' "`:variable label `var''", modify name(Models2_cons)	
}

foreach var of varlist LOWC3_BASELINE LOWC3_1WEEK LOWC3_1MONTH ///
	LOWC3_PERSISTENT LOWC3_DROP1SD LOWC3_TD  {
		collect label levels var2 `var' "`:variable label `var''", modify name(Models2_cons)	
}	


collect style cell cell_type[row-header],  font(Arial , size(9) bold noitalic color(navy)) name(Models2_cons)
collect style cell cell_type[column-header],  font(Arial , size(10) bold noitalic color(navy)) name(Models2_cons)
collect style cell cell_type[item],  font(Arial , size(10) noitalic) name(Models2_cons)
collect style header var1, title(hide) name(Models2_cons)
collect title "Table S4A. Baseline difference in lab values (SD units) w.r.t. control according to Low C3 categories", name(Models2_cons)
collect style title, font(Arial, bold size(14)) name(Models2_cons)
collect notes 1: "Aplha represents the baseline difference in the variable in the Low C3 category w.r.t to control group", name(Models2_cons)
collect notes 2: "Adjusted for donor and recipient age, and for type of transplantation", name(Models2_cons)
collect style notes, font(Arial, italic size(8)) name(Models2_cons)
collect export table_long_cons_2.docx, name(Models2_cons) replace
collect export table_long_cons_2.html, name(Models2_cons) replace
collect export table_long_cons_2.md, name(Models2_cons) replace
collect export table_long_cons_2.xlsx, name(Models2_cons) replace




********************************************************************************
**# END LONGITUDINA ANALYSES eGFR PROTEINURIA AND OTHER LAB VALUES
********************************************************************************


********************************************************************************
**# START SURVIVAL ANALYSIS
********************************************************************************
clear
cd "C:\Documenti\Micaela Gentile\Tesi Francesca"
use merged_baseline_tesi_fr
stset end_fup, fail(outcome == 2) origin(tx_date) id(id) sc(365.25)


* LOWC3_BASELINE LOWC3_1WEEK LOWC3_PERSISTENT LOWC3_DROP1SD

#delimit ;
global stuff "
tmax(2) 
risktable(, title("N at risk", size(*.9))) 
risktable(, color(navy) size(*.9) group(#1) format(%3.0f)) 
risktable(, color(maroon) size(*.9) group(#2) format(%3.0f)) 
plot1opt(lcolor(navy)) 
plot2opt(lcolor(maroon)) 
ylabel(0 "0" .1 "10" .20 "20" .30 "30" .40 "40" .50 "50" .60 "60" .70 "70" .80 "80" .90 "90" 1 "100" , angle(horizontal)) 
ytitle("Patient Survival (%)") ysc(titlegap(3))
xtitle("Year Since Transplantation") 
xsc(titlegap(2))
title("") scheme(s1mono)  
" ;
#delimit cr

foreach var of varlist LOWC3_BASELINE LOWC3_1WEEK LOWC3_DROP1SD LOWC3_PERSISTENT  { 
* `:variable label `var''

qui sts test `var' 
local pval = 1-chi2(r(df), r(chi2))
local spval = string(`pval',"%4.3f")
di `spval'

sts graph, by(`var') $stuff ///
title("Patient survival by `:variable label `var''", size(*0.8)) ///
risktable(, rowtitle("Others") group(#1) color(navy) size(*.9))  ///
risktable(, rowtitle("Low C3") group(#2) color(maroon) size(*.9))  ///
legend(order(1 "Others" 2 "Low C3") pos(3) rows(2) size(*0.5)linegap(*0.5))  ///
text(.05 0.5 "Log-rank test: P = `spval'" )
graph export "crude_surv_`:variable label `var''.png", replace
graph export "crude_surv_`:variable label `var''.pdf", replace

}

********************************************************************************
**# END SURVIVAL ANALYSIS
********************************************************************************
