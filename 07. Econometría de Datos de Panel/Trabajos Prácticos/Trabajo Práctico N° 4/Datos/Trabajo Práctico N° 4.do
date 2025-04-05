clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/7. Econometría de Datos de Panel/Trabajos Prácticos/Trabajo Práctico N° 4/Datos"


use "keane", clear
describe

xtset id year
xtdescribe


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


local vars="exper educ"

*INCISO (a)*

xtreg lwage `vars', fe
estimates store est_fe

*INCISO (b)*

egen mean_exper=mean(exper), by(id)
egen mean_educ=mean(educ), by(id)

probit obswage `vars' mean_exper mean_educ
predict xb_mundlak, xb

generate lambda_mundlak=normalden(xb_mundlak)/normal(xb_mundlak)
xtreg lwage `vars' lambda_mundlak, fe vce(cluster id)

*INCISO (c)*

summarize id
local ids=r(max)

forvalues t=81(1)83 {
	foreach var of varlist `vars' {
		generate `var'`t'=.
	}
	quietly forvalues id=1(1)`ids' {
		foreach var of varlist `vars' {
			summarize `var' if (id==`id' & year==`t')
			replace `var'`t'=r(mean) if (id==`id')	
		}
	}
}

probit obswage `vars' exper81-educ83
predict xb_chamberlain, xb

generate lambda_chamberlain=normalden(xb_chamberlain)/normal(xb_chamberlain)
xtreg lwage `vars' lambda_chamberlain, fe vce(cluster id)


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


*INCISO (a)*

regress lwage `vars' exper81-educ83 i.year#c.lambda_chamberlain
estimates store est_pols_chamberlain

*INCISO (b)*

regress lwage `vars' mean_exper mean_educ i.year#c.lambda_mundlak
estimates store est_pols_mundlak

esttab est_fe est_pols_chamberlain est_pols_mundlak, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("FE" "POLS (Chamberlain)" "POLS (Mundlak)") keep(exper educ)

*INCISO (d)*



*INCISO (e)*

