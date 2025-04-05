clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/6. Microeconometría I/Trabajos Prácticos/Trabajo Práctico N° 4/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


*INCISO (a)*

use "NPS", clear
describe

duplicates list
mdesc
summarize
keep if (nps!=.)

local vars="i.gender_code edad i.segmento"

*INCISO (b)*

generate clasificacion=.
replace clasificacion=1 if (nps<=6)
replace clasificacion=2 if (nps>=7 & nps<=8)
replace clasificacion=3 if (nps>=9)

label define clasificacion 1 "Detractor" 2 "Neutral" 3 "Promotor"
label values clasificacion clasificacion

tabulate clasificacion

*INCISO (c)*

sort clasificacion espera
by clasificacion: summarize espera
graph box espera, over(clasificacion)

*INCISO (d)*

sample 10
xi: ologit clasificacion `vars' espera
xi: ologit clasificacion `vars' espera, or
estimates store ologit
predict pr_ologit1 pr_ologit2 pr_ologit3, pr

*INCISO (e)*

mfx, predict(pr outcome(1))
mfx, predict(pr outcome(2))
mfx, predict(pr outcome(3))

*INCISO (f)*

xi: oprobit clasificacion `vars' espera
estimates store oprobit
predict pr_oprobit1 pr_oprobit2 pr_oprobit3, pr

mfx, predict(pr outcome(1))
mfx, predict(pr outcome(2))
mfx, predict(pr outcome(3))

*INCISO (g)*

xi: ologit clasificacion `vars' espera
test _Igender_co_2 edad _Isegmento_2 _Isegmento_3 _Isegmento_4 _Isegmento_5 espera
test _Igender_co_2
test edad
test _Isegmento_2
test _Isegmento_3
test _Isegmento_4
test _Isegmento_5
test espera

xi: oprobit clasificacion `vars' espera
test _Igender_co_2 edad _Isegmento_2 _Isegmento_3 _Isegmento_4 _Isegmento_5 espera
test _Igender_co_2
test edad
test _Isegmento_2
test _Isegmento_3
test _Isegmento_4
test _Isegmento_5
test espera


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


*INCISO (a)*

use "nlsw88", clear
describe

local vars="i.race i.south"

generate educ_cat=cond(grade<12,1,cond(grade==12,2,cond(grade<16,3,4))) if (grade!=.)
label define educ_cat 1 "Less than High School" 2 "High School" 3 "Junior College" 4 "College"
label value educ_cat educ_cat

generate hs=(educ_cat>=2) if (educ_cat<.)
generate jc=(educ_cat>=3) if (educ_cat>=2 & educ_cat<.)
generate c =(educ_cat==4) if (educ_cat>=3 & educ_cat<.)

seqlogit educ_cat `vars', tree(1: 2 3 4, 2: 3 4, 3: 4)

logit hs `vars'
logit jc `vars'
logit c  `vars'

*INCISO (b)*

use "gss", clear
describe

local vars="south c.coh##c.coh"

label define degree 0 "Less than High School" 1 "High School" 2 "Junior College" 3 "College"
label value degree degree

seqlogit degree `vars'				, tree(0: 1 2 3, 1: 2 3, 2: 3) ofinterest(paeduc) over(c.coh##c.coh)
seqlogit degree `vars' if (black==0), tree(0: 1 2 3, 1: 2 3, 2: 3) ofinterest(paeduc) over(c.coh##c.coh)
seqlogit degree `vars' if (black==1), tree(0: 1 2 3, 1: 2 3, 2: 3) ofinterest(paeduc) over(c.coh##c.coh)