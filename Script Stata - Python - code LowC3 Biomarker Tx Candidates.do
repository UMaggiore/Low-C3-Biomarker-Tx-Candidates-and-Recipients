********************************************************************************
**# START PREPARING DATASET FOR ANALYSES
********************************************************************************
clear
import excel "C:\Documenti\Micaela Gentile\Tesi Poggi\Tesi lista TX.xlsx", sheet("tesi lista tx ") firstrow
drop if missing(chbas_id)
mvdecode _all, mv(-99)
foreach var of varlist chbas_id chbas_name chbas_dob chbas_id dialysis_date {
	replace `var' = trim(`var')
	replace `var' = "" if `var' == "-99"
	}

foreach new of varlist chbas_dob dialysis_date {

	// add trailing zeros to sngle digits
	qui replace `new'  = "0" + `new'  if substr(`new', 2, 1) == "/"
	qui replace `new' = substr(`new',1,3) + "0" + substr(`new', 4, .) if substr(`new', 5, 1) == "/"
	// remove "/" by extracting date components
	qui gen _day = substr(`new',1,2)
    qui gen _month = substr(`new',4,2)
    qui gen _year = substr(`new',7,4)
    qui gen str1 space =" "
	qui replace `new' = _day + space + _month + space  + _year
    qui gen _`new' =date(`new', "MDY")
    format _`new' %td dD_M_CY
    qui drop _day _month _year  space
	qui drop `new'
	qui rename _`new' `new'
		}
		
replace lab_hb = 10.8 if lab_hb == 1.8
replace lab_hb = 8.9 if lab_hb== 81.9
replace lab_plt = lab_plt * 1000 if lab_plt < 1000
	
format diagn_date %td
label define yesno 0 "No" 1 "Yes"

gen AGE = (date("16 May 2024", "DMY") - chbas_dob) / 365.25
label var AGE "Age, years"

gen AGE40 = cond(AGE < 40, 1, 0)
replace AGE40 = . if missing(AGE)
label var AGE40 "Age < 40 years"
label values AGE40 yesno

gen DIALYSIS_VINTAGE = (date("16 May 2024", "DMY") - dialysis_date) / (365.25/12)
label var DIALYSIS_VINTAGE "Dialysis vintage, months"
replace DIALYSIS_VINTAGE = . if DIALYSIS_VINTAGE < 0

gen TIME_SINCE_DIAGNOSIS = (date("16 May 2024", "DMY") - diagn_date) / 365.25
label var TIME_SINCE_DIAGNOSIS  "Time since diagnosis, years"
replace TIME_SINCE_DIAGNOSIS  = . if TIME_SINCE_DIAGNOSIS < 0


// CARATTETISTICHE BASALI
label var chbas_dob "Date of birth"

label var chbas_sex "Recipient's sex"
label define chbas_sex  0 "M" 1 "F"
label values chbas_sex chbas_sex

label var chbas_ethnicity "Recipient's ethnicity"
label define chbas_ethnicity 0 "caucasian" 1 "afro american" 2 "others"
label values chbas_ethnicity chbas_ethnicity

label var chbas_genetics "Recipient's genetics"
label define chbas_genetics 0 "no genetic testing" 1 "genetic testing negative" 2 "genetic testing positive"
label values chbas_genetics chbas_genetics

label var chbas_mutation "Type of mutation"
label define chbas_mutation 0 "PKD1" 1 "susceptibility variants CFH + THBD" 2 "CFHRs" 3 "THBD" 4 "MCP" 5 "ADAMTS13" 6 "COL4A5" 7 "COL4A4" 8 "COL4A3" 9 "TRPC6" 10 "SGPL1" 11 "NUP107" 12 "LAMA5" 13 "TTC21B" 14 "FN1" 15 "CLCN5" 16 "MEFV" 17 "MMACHC" 18 "HNF1B" 19 "FGA"
label values chbas_mutation chbas_mutation

cap drop chbas_mutation2
gen chbas_mutation2 = chbas_mutation
label var chbas_mutation2 "Type of mutation"
replace chbas_mutation2 = chbas_mutation2 + 1
replace chbas_mutation2 = 0 if missing(chbas_mutation2)
label define chbas_mutation2 0 "None" 1 "PKD1" 2 "susceptibility variants CFH + THBD" 3 "CFHRs" 4 "THBD" 5 "MCP" 6 "ADAMTS13" 7 "COL4A5" 8 "COL4A4" 9 "COL4A3" 10 "TRPC6" 11 "SGPL1" 12 "NUP107" 13 "LAMA5" 14 "TTC21B" 15 "FN1" 16 "CLCN5" 17 "MEFV" 18 "MMACHC" 19 "HNF1B" 20 "FGA"
label values chbas_mutation2 chbas_mutation2

cap drop MUT_ANYTYPE
gen MUT_ANYTYPE = cond(chbas_mutation2 != 0, 1, 0)
replace MUT_ANYTYPE = . if missing(chbas_mutation2)
label var MUT_ANYTYPE "Genetic mutations, any type"
label values MUT_ANYTYPE yesno


label var chbas_resdiuresis "Recipient's diuresis residual"
label define chbas_resdiuresis 0 "no" 1 "yes"
label values chbas_resdiuresis chbas_resdiuresis

// DATI DIAGNOSI 
label var diagn_edta "EDTA CODE"

cap drop PRIMARY_KIDNEY_DIS
gen PRIMARY_KIDNEY_DIS = diagn_edta
label var PRIMARY_KIDNEY_DIS "Primary Kidney Disease"
recode PRIMARY_KIDNEY_DIS (10/12 14 16/19  = 1)  (13 15 = 2) (20/39 30/39= 3 ) (40/49 50/59 60/66 = 4) (70 72 73 79 = 5) (80 = 6) (74 76 78 82 83 85/89 = 7) (84 = 8) (90/99 = 9) (71 = 10) (88 = 11)
label define PRIMARY_KIDNEY_DIS 0 "Unknown" 1 "Glomerulonephritis" 2 "C3GN/MPGN" 3 "Pylonenphritis/TIN" 4 "ADPKD and othe hereditary diseases" 5 "Renovascular disease" 6 "Diabetic nephropathy" 7 "Sistemic diseases (non SLE)" 8 "SLE" 9 "Misc." 10 "malignant hypertension" 11 "Complement-mediated HUS"
label values PRIMARY_KIDNEY_DIS PRIMARY_KIDNEY_DIS


label var diagn_immcomplexgn "Immune complex GN"
label define diagn_immcomplexgn 0 "no" 1 "IgAN" 2 "LES" 3 "infection related GN" 4 "fibrillary"
label values diagn_immcomplexgn diagn_immcomplexgn

cap drop ICGN_ANYTYPE
gen ICGN_ANYTYPE = cond(diagn_immcomplexgn != 0, 1, 0)
replace ICGN_ANYTYPE = . if missing(diagn_immcomplexgn)
label var ICGN_ANYTYPE "Immune complex GN, any type"
label values ICGN_ANYTYPE yesno

label var diagn_anca "AAV vasculitis"
label define diagn_anca 0 "no" 1 "PR3" 2 "MPO"
label values diagn_anca diagn_anca

cap drop AAV_ANYTYPE
gen AAV_ANYTYPE = cond(diagn_anca != 0, 1, 0)
replace AAV_ANYTYPE = . if missing(diagn_anca)
label var AAV_ANYTYPE "AAV, any type"
label values AAV_ANYTYPE yesno

label var diagn_antigbm "Anti GBM"
label define diagn_antigbm 0 "no" 1 "yes"
label values diagn_antigbm diagn_gbm

label var diagn_monoclonal "Monoclonal Ig-GN"
label define diagn_monoclonal 0 "no" 1 "PGNMID" 2 "MIDD"
label values diagn_monoclonal diagn_monoclonal

cap drop MIG_ANYTYPE
gen MIG_ANYTYPE = cond(diagn_monoclonal != 0, 1, 0)
replace MIG_ANYTYPE = . if missing(diagn_monoclonal)
label var MIG_ANYTYPE "Monoclonal Ig-GN, any type"
label values MIG_ANYTYPE yesno

label var diagn_c3g "C3 glomerulopathy"
label define diagn_c3g 0 "no" 1 "C3G" 2 "DDD"
label values diagn_c3g diagn_c3g

cap drop C3G_ANYTYPE
gen C3G_ANYTYPE = cond(diagn_c3g != 0, 1, 0)
replace C3G_ANYTYPE = . if missing(diagn_c3g)
label var C3G_ANYTYPE "C3GN, any type"
label values C3G_ANYTYPE yesno


label var diagn_tma "Thrombotic microangiopathy"
label define diagn_tma 0 "no" 1 "TMA" 2 "aHUS" 3 "HUS"
label values diagn_tma diagn_tma

cap drop HUS_ANYTYPE
gen HUS_ANYTYPE = cond(diagn_tma != 0, 1, 0)
replace HUS_ANYTYPE = . if missing(diagn_tma)
label var HUS_ANYTYPE "HUS, any type"
label values HUS_ANYTYPE yesno

label var diagn_biopsy "Biopsy performed for diagnosis"
label define diagn_biopsy 0 "No" 1 "Yes"
label values diagn_biopsy diagn_biopsy

label var diagn_date "Date of biopsy"

// TERAPIA 
label var tp_is "Immune suppressive therapy"
label define tp_is  0 "no" 1 "yes"
label values tp_is tp_is

label var tp_steroid "Steroid"
label define tp_steroid  0 "no" 1 "MP/prednisone" 2 "budesonide"
label values tp_steroid tp_steroid

label var tp_cni "Calcineurin inhibitor"
label define tp_cni  0 "no" 1 "TAC" 2 "CSA"
label values tp_cni  tp_cni  

label var tp_antimetabolite "Antimetabolite"
label define tp_antimetabolite  0 "no" 1 "MMF/MPS" 2 "AZA"
label values tp_antimetabolite tp_antimetabolite

label var tp_belatacept "Belatacept"
label define tp_belatacept 0 "no" 1 "yes"
label values tp_belatacept tp_belatacept

label var tp_eculizumab "Eculizumab"
label define tp_eculizumab 0 "no" 1 "yes"
label values tp_eculizumab tp_eculizumab

label var tp_other "Other"
label define  tp_other 0 "no" 1 "yes"
label values tp_other tp_other


cap drop IS_THERAPY
egen IS_THERAPY = rownonmiss(tp_is tp_antimetabolite tp_belatacept tp_eculizumab tp_steroid tp_cni)
replace IS_THERAPY = cond(IS_THERAPY == 6, 1, 0)
label var IS_THERAPY "Any IS therapy on WL"
label values IS_THERAPY yesno


// DIALISI
label var dialysis_dialysis "Recepient's dialysis"
label define dialysis_dialysis  0 "no" 1 "yes"
label values dialysis_dialysis dialysis_dialysis

label var dialysis_date "Date of dialysis"

label var dialysis_type "Type of dialysis"
label define dialysis_type 0 "HD" 1 "Peritoneal"
label values dialysis_type dialysis_type

// LABORATORY
label var lab_c3 "C3 value, mg/dL"

label var lab_c4 "C4 value, mg/dL"

label var lab_hb "Hb value, g/dL"

label var lab_plt "PLT value, count/mm3"

label var lab_ldh "LDH value, IU/L"


cap drop LOWC3 
gen LOWC3 = cond(lab_c3 < 90, 1, 0)
replace LOWC3 = . if missing(lab_c3)
label var LOWC3 "C3 < 90 mg/dL"
label values LOWC3 yesno
cap drop LOWC4 
gen LOWC4= cond(lab_c4 < 10, 1, 0)
replace LOWC4 = . if missing(lab_c3)
label var LOWC4 "C4 < 10 mg/dL"
label values LOWC4 yesno


cd "C:\Documenti\Micaela Gentile\Tesi Poggi"
save c3_on_wl, replace
export delimited _all using c3_on_wl, replace
preserve
cap drop C3 C4 PLT LDH Hb
rename lab_c3  C3 
rename lab_c4 C4 
rename lab_plt PLT 
rename lab_ldh LDH 
rename lab_hb  Hb
order  C3 C4 PLT LDH Hb
keep C3 C4 PLT LDH Hb
egen nomiss = rownonmiss(C3 C4 PLT LDH Hb)
keep if nomiss == 5
drop nomiss
export delimited _all using c3_labs_on_wl, replace
restore
clear

cd "C:\Documenti\Micaela Gentile\Tesi Poggi"
use c3_on_wl, clear
preserve
cap drop C3 C4 PLT LDH Hb
rename lab_c3  C3 
rename lab_c4 C4 
rename lab_plt PLT 
rename lab_ldh LDH 
rename lab_hb  Hb
order  C3 C4 PLT LDH Hb
keep LOWC3 C3 C4 PLT LDH Hb
egen nomiss = rownonmiss(C3 C4 PLT LDH Hb)
keep if nomiss == 5
drop nomiss
cap save c3_grp_labs_on_wl, replace
restore
clear


********************************************************************************
**# END PREPARING DATASET FOR ANALYSES
********************************************************************************


********************************************************************************
**# Start Table 1
********************************************************************************
clear
cd "C:\Documenti\Micaela Gentile\Tesi Poggi"
use c3_on_wl

dtable AGE  i.AGE40 i.chbas_sex i.chbas_ethnicity i.dialysis_dialysis ///
	i.dialysis_type DIALYSIS_VINTAGE i.diagn_biopsy ///
	i.chbas_genetics i.chbas_mutation i.MUT_ANYTYPE chbas_resdiuresis ///
	i.PRIMARY_KIDNEY_DIS i.diagn_immcomplexgn i.ICGN_ANYTYPE i.diagn_anca ///
	i.AAV_ANYTYPE i.diagn_monoclonal i.MIG_ANYTYPE i.diagn_c3g 	i.C3G_ANYTYPE ///
	i.diagn_tma  i.HUS_ANYTYPE i.IS_THERAPY ///
	lab_c3 lab_c4 lab_hb lab_plt lab_ldh ///
	, ///	
	by(LOWC3, tests) ///
	factor(AGE40 chbas_sex chbas_ethnicity dialysis_dialysis ///
	dialysis_type diagn_biopsy ///
	chbas_genetics chbas_mutation MUT_ANYTYPE  ///
	PRIMARY_KIDNEY_DIS diagn_immcomplexgn ICGN_ANYTYPE diagn_anca ///
	AAV_ANYTYPE diagn_monoclonal MIG_ANYTYPE diagn_c3g C3G_ANYTYPE ///
	diagn_tma  HUS_ANYTYPE IS_THERAPY , test(fisher)) ///
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
    continuous(AGE lab_hb, stat(meansd) test(kwallis)) ///   
	continuous(DIALYSIS_VINTAGE chbas_resdiuresis, stat(median myiqr) test(kwallis)) ///   
	continuous(lab_c3 lab_c4 lab_hb lab_plt lab_ldh,  stat(median myrange) test(kwallis)) ///	
	column(by(hide) test(p-value)) ///
	title(Table 1. "Patient's characteristcs by Low C3 (< 90mg/dL)" ) ///
	note(Mann-Whitney test for continuous variables (reported as mean ± standard deviation), median (iqr) or medain [range].) ///
    note(Fisher's exact test for categorical variables (reported as number (percentage)).) ///
	note(AAV, ANCA-associated vasculitis; ADPKD, Adult Dominant  Polycistic Kidney Disease; aHUS, atypical HUS; C3GN, C3 glomerulopathy; GN, glomerulonephritis; HUS, hemolytic uremic synrome; Ig, immunoglobulin; IS, immunosuppressive therapy; MIDD, monoclonal immune deposition disease; MPGN, membranoprolipherative glomerulonephritis; SLE, Systemic Lupus Erythematosus;TIN, tipulointerstitial nephritis; TMA; Thrombotic Micronagiopathy; WL, waiting list) ///
	note(Cross-sectional characteristics on patients on the waiting list for kidney transplantation) 
	

// chenge title to bold font size 14
collect style title,  font(, bold size(14))
// change the column headers to bodl font seze 12 and underlines
collect style cell cell_type[column-header],  font(, bold  size(12))
// change the row header to bold fonf
collect style cell cell_type[row-header],  font(, bold)
// change the cell result to font arial size 11 and italic
collect style cell result, font(arial , size(11) color(navy) italic)

// change the row-header
collect style cell cell_type[row-header],  font(, bold noitalic color(maroon))


// change font, set size, and make bold or italic
collect style cell,  font(Arial)
collect style title, font(Arial, bold size(18))
collect style notes, font(Arial, italic size(14))

collect layout
collect export Table1.docx, replace
collect export Table1.html, replace

	

********************************************************************************
**# End Table 1
********************************************************************************


********************************************************************************
**# START biplot with Stata
********************************************************************************

clear
cd "C:\Documenti\Micaela Gentile\Tesi Poggi"
use c3_on_wl
qui biplot lab_c3 lab_c4 lab_plt lab_ldh lab_hb, ///
    dim(1 2) std rowover(LOWC3)
local rho1  = `r(rho1)' * 100      //    explained variance by component 1
local rho2  = `r(rho2)' * 100     //     explained variance by component 2
local prho1  = string(`rho1', "%3.1f")        
local prho2  = string(`rho2', "%3.1f")

preserve
cap drop C3 C4 PLT LDH Hb
rename lab_c3  C3 
rename lab_c4 C4 
rename lab_plt PLT 
rename lab_ldh LDH 
rename lab_hb  Hb

biplot C3 C4 PLT LDH Hb, ///
    dim(1 2) std  rowover(LOWC3) ///
	xsc(range(-2.5 2.5)) xlab(-6.0(2)4, labsize(*0.8) grid) ///
	ysc(range(-2.5 2.5)) ylab(-6.0(2)4, labsize(*0.8) grid) ///
	row1opts(msymbol(o) mfcolor(stc2) mlcolor(white) msize(*2) mlabsize(zero)) ///
	row2opts(msymbol(o) mfcolor(stc3) mlcolor(white) msize(*2) mlabsize(zero)) ///
    stretch(2) ///
	xtitle("Component 2 (`prho2'%)") ytitle("Component 1 (`prho1'%)") ///
	legend(order(1 "Variables" 2 "C3 < 90 mg/dL" 3 "Others"))
restore
********************************************************************************
**# END biplot with Stata
********************************************************************************



********************************************************************************
**# START matrix of correlation/p values and heatmap with Stata
********************************************************************************

**# compute matrix of Spearman's rak correlation and P values

preserve
cap drop C3 C4 PLT LDH Hb
rename lab_c3  C3 
rename lab_c4 C4 
rename lab_plt PLT 
rename lab_ldh LDH 
rename lab_hb  Hb
order  C3 C4 PLT LDH Hb
local vars " C3 C4 PLT LDH Hb"
cap drop nmiss
egen nmiss = rowmiss(`vars')
local n_vars: word count `vars'
matrix rho = J(`n_vars',`n_vars',-99)
matrix pval = J(`n_vars',`n_vars',-99)
matrix npts = J(`n_vars',`n_vars',-99)
local i=0
foreach v in `vars' {
           local i= `i' +1
           local j=0
           foreach w in `vars'  {
                   local j= `j'+1
           qui spearman `v' `w' if nmiss==0
           matrix rho[`i',`j'] = r(rho)
		   matrix pval[`i',`j'] = r(p)
		   matrix npts[`i',`j'] = r(N)	   
		   matrix rho[`i',`i'] = .
		   matrix pval[`i',`i'] = .
		   matrix npts[`i',`i'] = .
           }
   }

unab vars : `vars'
matrix rownames rho= `vars'
matrix colnames rho= `vars'
matrix rownames pval= `vars'
matrix colnames pval= `vars'
matrix rownames npts= `vars'
matrix colnames npts= `vars'
matrix list rho,  format(%3.2f)
matrix list pval, format(%4.3f)


**# Heatmap rho in Stata
* hcl lch jmh hsv hsl
heatplot rho, values(format(%4.3f) mlabsize(*0.7)) color(lch, intensity(.6)) ///
	aspectratio(1) cuts(-1(0.25)+1)    ///
	plotregion(fcolor(white)) graphregion(fcolor(white)) ///
	ylabel(1 "C3" 2 "C4" 3 "PLT" 4 "LDH" 5 "Hb" ) ///
	xlabel(1 "C3" 2 "C4" 3 "PLT" 4 "LDH" 5 "Hb" , angle(45)) ///
	note("Spearman's rho correlation coefficient")

	
**# Heatmap P values in Stata
heatplot pval, values(format(%4.3f) mlabsize(*0.7)) color(hsl, intensity(0.4)) ///
	aspectratio(1) cuts(0 0.001 0.01 0.05 0.10 1.0)  keylabels(1(1)5, interval subtitle("P value")) ///
	plotregion(fcolor(white)) graphregion(fcolor(white)) ///
	ylabel(1 "C3" 2 "C4" 3 "PLT" 4 "LDH" 5 "Hb" ) ///
	xlabel(1 "C3" 2 "C4" 3 "PLT" 4 "LDH" 5 "Hb" , angle(45)) ///
	note("Spearman's p values from correlation coefficient")

restore

********************************************************************************
**# END matrix of correlation/p values and heatmap with Stata
********************************************************************************

********************************************************************************
**# START heatmap with Python
********************************************************************************

**# HEATMAP rho in Python heatmap using seaborn
cd "C:\Documenti\Micaela Gentile\Tesi Poggi"
python
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
X = pd.read_csv("c3_labs_on_wl.csv")
X.head(6)

//import os
//os.chdir('C:\\Documenti\\Micaela Gentile\\Tesi Poggi')

plt.figure(figsize=(12, 10))
X.corr(method='spearman')
heatmap = sns.heatmap(X.corr(method='spearman'), vmin=-1, vmax=1, annot=True, cmap='vlag', fmt=".2f")
heatmap.set_title('Correlation Heatmap', fontdict={'fontsize':12}, pad=12) 
plt.yticks(fontsize=12)
plt.xticks(fontsize=12)
plt.savefig('pyheatmap.png', dpi=600, bbox_inches='tight')
plt.show()
end


********************************************************************************
**# End heatmap with Python
********************************************************************************

********************************************************************************
**# Start biplots with ellipse and heatmap (half) with R
********************************************************************************

capture program drop start_r_stata
program define start_r_stata
version 14.0
syntax
	*-----------------------------------------------------------------------
	* rsource
	*------------------------------------------------------------------------
	global Rterm_path `"C:/Program Files/R/R-4.2.3/bin/x64/Rterm.exe"'
	** This records Stata's present working directory in R-compatible format
	local r_pwd = subinstr("`c(pwd)'","","/",.)
	** Start R via rsource, pass your present working directory to it
	rsource, terminator("end_r_stata") roptions(`" --vanilla --args "`r_pwd'" "')
end



start_r_stata
# clear objects in memory
rm( list=ls() )
## set working directory
setwd("C:\\Documenti\\Micaela Gentile\\Tesi Poggi")
## load required packages
rm( list=ls() )
## set working directory
setwd("C:\\Documenti\\Micaela Gentile\\Tesi Poggi")
## load required packages
## devtools::install_github("r-lib/conflicted")
library(tidyverse)
library(ggrepel)
library(FactoMineR)
library(factoextra)
library(corrplot)
library(reshape2)
library(pROC)
library(reshape2)
library(haven)
## import dataset
unito <- read_dta("C:/Documenti/Micaela Gentile/Tesi Poggi/c3_grp_labs_on_wl.dta")


unito.0 <- unito
unito.0$ID <- 1:nrow(unito.0)
unito.0 <- column_to_rownames(unito.0, var = "ID")
unito.0$LOWC3 <- 
    factor(unito.0$LOWC3, levels = c(0,1),
           labels = c("No", "Yes"))

unito.0 <- unito.0 %>%
  rename("PLT count" = PLT,
         "C4"  = C4,
         "C3" = C3,
         "Hb" = Hb)

## performa PCA calulations 
X <- unito.0
X[c("LOWC3")] <- NULL
PCA(X, scale.unit = TRUE, ncp = 5, graph = FALSE)
res.pca <- PCA(X, graph = FALSE)
print(res.pca)
eig.val <- get_eigenvalue(res.pca)
fviz_eig(res.pca, addlabels = TRUE, ylim = c(0,100))
var <- get_pca_var(res.pca)
head(var$coord)
head(var$cos2)
head(var$contrib)
fviz_pca_var(res.pca, col.var = "black")

## plot correlation with variables extracted by PCA
library(corrplot)
corrplot(var$cos2, is.corr = TRUE, cl.ratio = 0.4, mar=c(0,0,2,0)) 

pdf(file = "mv.corr.pca.pdf")
corrplot(var$cos2, is.corr = TRUE, cl.ratio = 0.4, mar=c(0,0,2,0)) 
dev.off()

file_path= "mv.corr.pca.png"
png(file=file_path, type = "cairo")
# Your function to plot image goes here
corrplot(var$cos2, is.corr = TRUE, cl.ratio = 0.4, mar=c(0,0,2,0)) 
# Then
dev.off()

tiff("mv.corr.tiff", units="in", width=6, height=5, res=1200)
corrplot(var$cos2, is.corr = TRUE, cl.ratio = 0.4, mar=c(0,0,2,0)) 
# Then
dev.off()



## biplot from PCA with groups via fviz_pca_biplot (Dim.1 Dim.2)
fviz_pca_biplot(res.pca, 
                geom.ind = "point",
                pointshape = 21,
                pointsize = 3,
                fill.ind = unito.0$LOWC3,
                col.ind = "black",
                palette = c(rgb(72,108,140, maxColorValue = 255), 
                            rgb(144,53,59, maxColorValue = 255)),
                addEllipse = TRUE,
                repel = TRUE, 
                col.var = "contrib",
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                legend.title = list(fill = "Low C3", color = "Contribution"),
                title = NULL) 
tiff("mv.pca.1.2.tiff", units="in", width=8, height=6, res=1200)
options(ggrepel.max.overlaps = Inf)
fviz_pca_biplot(res.pca, axes = c(1,2),
                geom.ind = "point",
                pointshape = 21,
                pointsize = 3,
                fill.ind = unito.0$LOWC3,
                col.ind = "black",
                palette = c(rgb(72,108,140, maxColorValue = 255), 
                            rgb(144,53,59, maxColorValue = 255)),
                addEllipse = TRUE,
                repel = TRUE,
                col.var = "contrib",
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                legend.title = list(fill = "Low C3", color = "Contribution"),
                label = "all", 
                title = NULL)
dev.off()
ggsave("mv.pca.1.2.png",  width = 8, height = 6, dpi = 1200)
ggsave("mv.pca.1.2.pdf",  width = 8, height = 6, dpi = 1200)


tiff("mv.pca.2.3.tiff", units="in", width=8, height=6, res=1200)
options(ggrepel.max.overlaps = Inf)
fviz_pca_biplot(res.pca, axes = c(2,3),
                geom.ind = "point",
                pointshape = 21,
                pointsize = 3,
                fill.ind = unito.0$LOWC3,
                col.ind = "black",
                palette = c(rgb(72,108,140, maxColorValue = 255), 
                            rgb(144,53,59, maxColorValue = 255)),
                addEllipse = TRUE,
                repel = TRUE,
                col.var = "contrib",
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                legend.title = list(fill = "Low C3", color = "Contribution"),
                label = "all", 
                title = NULL)
dev.off()
ggsave("mv.pca.2.3.png",  width = 8, height = 6, dpi = 1200)
ggsave("mv.pca.2.3.pdf",  width = 8, height = 6, dpi = 1200)



## calculate correlation matrix based on Spearman's rank correlation coeff.
X <- unito.0
X[c("LOWC3")] <- NULL
cormat <- round(cor(X, method = c("spearman")), 2)

## prepare dataset for heatmap
melted_cormat <- melt(cormat)
head(melted_cormat)

## plot heatmap
ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile() +
  labs(x= NULL, y = NULL) +
  theme(axis.text.x = element_text(angle=30)) 

# Get lower triangle of the correlation matrix
get_lower_tri<-function(cormat){
  cormat[upper.tri(cormat)] <- NA
  return(cormat)
}
# Get upper triangle of the correlation matrix
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}
upper_tri <- get_upper_tri(cormat)
upper_tri
melted_cormat <- melt(upper_tri, na.rm = TRUE)
# Melt the correlation matrix

melted_cormat <- melt(upper_tri, na.rm = TRUE)
## Heatmap lower triangulat
ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Spearman\nCorrelation") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 9, hjust = 1)) + 
  labs(x= NULL, y = NULL) +
  coord_fixed()


tiff("matrixhalf.corr.sorted_creat_ratio.tiff", units="in", width=8, height=6, res=1200)
## sort the matrix
reorder_cormat <- function(cormat){
  # Use correlation between variables as distance
  dd <- as.dist((1-cormat)/2)
  hc <- hclust(dd)
  cormat <-cormat[hc$order, hc$order]
}
# Reorder the correlation matrix
cormat <- reorder_cormat(cormat)
upper_tri <- get_upper_tri(cormat)
# Melt the correlation matrix
melted_cormat.2 <- melt(upper_tri, na.rm = TRUE)
# Create a ggheatmap with sorted datae

ggheatmap <- ggplot(melted_cormat.2, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Spearman\nCorrelation") +
  theme_minimal()+ # minimal theme
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 9, hjust = 1)) +
  labs(x= NULL, y = NULL) +
  coord_fixed()
print(ggheatmap)
dev.off()
ggsave("matrixhalf.corr.sorted.png", plot =ggheatmap,  units="in", width=8, height =6, dpi = 1200)
ggsave("matrixhalf.corr.sorted.pdf", plot =ggheatmap, units="in", width=8, height =6, dpi = 1200)
# convert pdf in tiff to get the sorted matrix
# 

********************************************************************************
**# End biplots with ellipse and heatmap (half) with R
********************************************************************************
