clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/10. Microeconometría II/Trabajos Prácticos/Trabajo Práctico N° 4/Datos"


/*
ssc install csdid, replace
ssc install jwdid, replace
ssc install reghdfe, replace
*/


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "organ_donations", clear
describe

egen state_id=group(state)
xtset state_id quarter_num

*INCISO (e)*

generate Treated=(state=="California")
generate Post=inlist(quarter,"Q32011","Q42011","Q12012")
generate D=Treated*Post

tabulate D 
tabulate state D
tabulate quarter_num D

reghdfe rate D, absorb(state quarter) vce(cluster state)
xtreg rate i.quarter_num D, fe


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


use "organ_donations", clear
describe

egen state_id=group(state)
xtset state_id quarter_num

*INCISO (b)*

generate California=(state=="California")
reghdfe rate California##ib3.quarter_num, absorb(state quarter_num) vce(cluster state)

*INCISO (c)*

preserve

generate coef=.
generate se=.
forvalues i=1(1)6 {
	replace coef=_b[1.California#`i'.quarter_num] if (quarter_num==`i')
	replace se=_se[1.California#`i'.quarter_num] if (quarter_num==`i')
}

generate ic_sup=coef+1.96*se
generate ic_inf=coef-1.96*se

keep quarter_num coef se ic_*
duplicates drop

graph twoway (sc coef quarter_num, connect(line)) (rcap ic_sup ic_inf quarter_num) (function y=0, range(1 6)), xtitle("Quarter")

restore

*INCISO (d)*

keep if (quarter_num<=3)

generate FakeTreat1=(state=="California" & inlist(quarter,"Q12011","Q22011"))
generate FakeTreat2=(state=="California" & quarter=="Q22011")

reghdfe rate FakeTreat1, absorb(state quarter) vce(cluster state)
reghdfe rate FakeTreat2, absorb(state quarter) vce(cluster state)


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


use "mpdta", clear
describe

*INCISO (a)*

csdid lemp, ivar(countyreal) time(year) gvar(first_treat) method(dripw)

*INCISO (b)*

estat pretrend

*INCISO (c)*

estat simple
estat group
estat calendar
estat event
estat all

*INCISO (d)*

csdid lemp lpop, ivar(countyreal) time(year) gvar(first_treat) method(dripw)
estat pretrend
estat simple
estat group
estat calendar
estat event
estat all

*INCISO (e)*

csdid lemp, ivar(countyreal) time(year) gvar(first_treat) method(dripw) notyet
estat pretrend
estat simple
estat group
estat calendar
estat event
estat all

csdid lemp lpop, ivar(countyreal) time(year) gvar(first_treat) method(dripw) notyet
estat pretrend
estat simple
estat group
estat calendar
estat event
estat all

*INCISO (f)*

generate D=(first_treat<=year & treat==1)

forvalues i=1(1)4 {
	generate Tm`i'=(year-first_treat==-`i') if (treat==1)
	replace Tm`i'=0 if (Tm`i'==.)
}

forvalues i=0(1)3 {
	generate Tp`i'=(year-first_treat==`i') if (treat==1)
	replace Tp`i'=0 if (Tp`i'==.)
}

order Tm4 Tm3 Tm2 Tm1 Tp0 Tp1 Tp2 Tp3, last

reghdfe lemp D, absorb(countyreal year) vce(cluster countyreal)
reghdfe lemp Tm4 Tm3 Tm2 Tm1 Tp1 Tp2 Tp3, absorb(countyreal year) vce(cluster countyreal)


*##############################################################################*
								* EJERCICIO 4 *
*##############################################################################*


use "mpdta", clear
describe

jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) never group
estat simple
estat group
estat calendar
estat event

jwdid lemp lpop, ivar(countyreal) tvar(year) gvar(first_treat) never group
estat simple
estat group
estat calendar
estat event

jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) group
estat simple
estat group
estat calendar
estat event

jwdid lemp lpop, ivar(countyreal) tvar(year) gvar(first_treat) group
estat simple
estat group
estat calendar
estat event