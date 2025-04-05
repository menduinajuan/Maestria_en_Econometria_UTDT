clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/6. Microeconometría I/Trabajos Prácticos/Trabajo Práctico N° 6/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "mus16datav2", clear
describe

duplicates list
mdesc

local vars="age female educ blhisp totchr ins"

heckman lambexp `vars', select(dambexp = `vars' income)
estimates store est_heckman1

heckman lambexp `vars', select(dambexp = `vars' income) twostep
estimates store est_heckman2

tobit lambexp `vars', ll(0)
estimates store est_tobit

esttab est_heckman1 est_heckman2 est_tobit, se star(* 0.10 ** 0.05 *** 0.01) pr2 mtitles("Heckman (MLE)" "Heckman (Two Step)" "Tobit")


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


webuse "womenwk", clear
describe

local vars="age education married"

duplicates list
mdesc
summarize, separator(0)
summarize wage
summarize wage, detail
histogram wage

replace wage=0 if (wage==.)
generate dwage=(wage>0)

regress wage `vars'
estimates store est_ols

heckman wage `vars', select(dwage = `vars' children)
estimates store est_heckman1

heckman wage `vars', select(dwage = `vars' children) twostep
estimates store est_heckman2

esttab est_ols est_heckman1 est_heckman2, se star(* 0.10 ** 0.05 *** 0.01) r2 mtitles("OLS" "Heckman (MLE)" "Heckman (Two Step)")


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


use "mroz", clear
describe

local vars="kidsge6 age educ exper nwifeinc expersq"

summarize hours
summarize hours, detail
histogram hours

generate dhours=(hours>0)

regress hours `vars'
estimates store est_ols

heckman hours `vars', select(dhours = `vars' kidslt6) twostep
estimates store est_heckman

esttab est_ols est_heckman, se star(* 0.10 ** 0.05 *** 0.01) r2 mtitles("OLS" "Heckman (Two Step)")

margins, predict(ystar(0,.)) dydx(*)
margins, predict(e(0,.)) dydx(*)
margins, predict(ystar(0,.)) dydx(*) atmeans
margins, predict(e(0,.)) dydx(*) atmeans