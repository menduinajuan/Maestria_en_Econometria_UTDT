clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/6. Microeconometría I/Trabajos Prácticos/Trabajo Práctico N° 5/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


*INCISO (a)*

webuse "auto", clear
describe

summarize
generate wgt=weight/1000

summarize mpg, detail
tabulate mpg if (mpg<17)
count if (mpg<17)
clonevar mpg_a=mpg
replace mpg_a=17 if (mpg_a<17)

regress mpg wgt
estimates store est_ols

regress mpg_a wgt
estimates store est_ols_a

tobit mpg_a wgt, ll
estimates store est_tobit_a1

tobit mpg_a wgt, ll(17)
estimates store est_tobit_a2

esttab est_ols est_ols_a est_tobit_a1 est_tobit_a2, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS" "OLS ll(17)" "Tobit ll()" "Tobit ll(17)")
esttab est_ols est_ols_a est_tobit_a2, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS" "OLS ll(17)" "Tobit ll(17)")

*INCISO (b)*

summarize mpg, detail
tabulate mpg if (mpg>24)
count if (mpg>24)
clonevar mpg_b=mpg
replace mpg_b=24 if (mpg_b>24)

regress mpg_b wgt
estimates store est_ols_b

tobit mpg_b wgt, ul
estimates store est_tobit_b1

tobit mpg_b wgt, ul(24)
estimates store est_tobit_b2

esttab est_ols est_ols_b est_tobit_b1 est_tobit_b2, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS" "OLS ul(24)" "Tobit ul()" "Tobit ul(24)")
esttab est_ols est_ols_b est_tobit_b2, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS" "OLS ul(24)" "Tobit ul(24)")

*INCISO (c)*

tobit mpg_a wgt, ll(17)
margins, predict(ystar(17,.)) dydx(wgt) at(wgt=(1 2 3 4))
margins, predict(e(17,.)) dydx(wgt) at(wgt=(1 2 3 4))

tobit mpg_b wgt, ul(24)
margins, predict(ystar(.,24)) dydx(wgt) at(wgt=(1 2 3 4))
margins, predict(e(.,24)) dydx(wgt) at(wgt=(1 2 3 4))


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


*INCISO (a)*

use "mus16datav2", clear
describe

local vars="age female educ blhisp totchr ins"

duplicates list
mdesc
summarize
summarize `vars', separator(0)
summarize ambexp
summarize ambexp, detail
histogram ambexp

tobit ambexp `vars', ll(0)
estimates store est_tobit

*INCISO (b)*

margins, predict(ystar(0,.)) dydx(*)
margins, predict(e(0,.)) dydx(*)
margins, predict(ystar(0,.)) dydx(*) atmeans
margins, predict(e(0,.)) dydx(*) atmeans

*INCISO (c)*

matrix define betas_tobit=e(b)
matrix list betas_tobit
scalar sigma=betas_tobit[1,e(df_m)+2]
matrix define betas_coef=betas_tobit[1,1..e(df_m)+1]
predict xb, xb
summarize xb
scalar mean_xb=r(mean)
scalar phi=normal(mean_xb/sigma)
matrix define em=phi*betas_coef
matrix list em

*INCISO (d)*

summarize lambexp, detail
scalar gamma=r(min)
replace lambexp=gamma-0.0000001 if (lambexp==.)

regress lambexp `vars'
estimates store est_ols

tobit lambexp `vars', ll(-0.0000001)
estimates store est_tobit

esttab est_ols est_tobit, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS (log)" "Tobit (log)")


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


use "mroz", clear
describe

local vars="kidslt6 kidsge6 age educ exper nwifeinc expersq"

summarize hours
summarize hours, detail
histogram hours

regress hours `vars'
estimates store est_ols

tobit hours `vars', ll(0)
estimates store est_tobit

esttab est_ols est_tobit, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS" "Tobit")

margins, predict(ystar(0,.)) dydx(*)
margins, predict(e(0,.)) dydx(*)
margins, predict(ystar(0,.)) dydx(*) atmeans
margins, predict(e(0,.)) dydx(*) atmeans