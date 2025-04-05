clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/7. Econometría de Datos de Panel/Trabajos Prácticos/Trabajo Práctico N° 1/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "cornwell", clear
describe

xtset county year
xtdescribe

local vars="lprbarr lprbconv lprbpris lavgsen lpolpc d82 d83 d84 d85 d86 d87"

*INCISO (a)*

regress lcrmrte `vars'
estimates store est_pols1

*INCISO (b)*

regress lcrmrte `vars', vce(cluster county)
estimates store est_pols2

esttab est_pols1 est_pols2, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("POLS" "POLS (robust)")

*INCISO (c)*

regress lcrmrte `vars'
predict resid, residuals
regress resid `vars' l.resid
local LM=e(N)*e(r2)

display as text "chi2(1) = " as result `LM'
display as text "El P-valor (LM) es " as result 1-chi2(1,`LM')

*INCISO (d)*

generate resid2=resid^2
regress resid2 lprbarr c.lprbarr#c.lprbarr lprbpris c.lprbpris#c.lprbpris c.lprbarr#c.lprbpris
local LM=e(N)*e(r2)

display as text "chi2(5) = " as result `LM'
display as text "El P-valor (LM) es " as result 1-chi2(5,`LM')

*INCISO (e)*

regress resid l.resid
local rho=_b[l.resid]

generate ones=1

foreach var of varlist lcrmrte ones `vars' {
	generate tilde_`var'=.
	replace tilde_`var'=sqrt(1-`rho'^2)*`var' if (year==81)
	replace tilde_`var'=`var'-`rho'*l.`var' if (year!=81)
}

regress tilde_lcrmrte tilde_lprbarr tilde_lprbconv tilde_lprbpris tilde_lavgsen tilde_lpolpc tilde_d82-tilde_d87 tilde_ones, noconstant
estimates store est_fgls1

prais lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc d82-d87
estimates store est_prais1
prais lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc d82-d87, twostep
estimates store est_prais2

esttab est_prais1 est_prais2, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("PRAIS" "PRAIS (Two Step)")

*INCISO (f)*

regress tilde_lcrmrte tilde_lprbarr tilde_lprbconv tilde_lprbpris tilde_lavgsen tilde_lpolpc tilde_d82-tilde_d87 tilde_ones, noconstant vce(cluster county)
estimates store est_fgls2

esttab est_fgls1 est_fgls2, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("FGLS" "FGLS (robust)")



*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


use "greene97", clear
describe

local vars="lq lf lpf i.id"

*INCISO (a)*

generate lc=ln(c)
generate lq=ln(q)
generate lpf=ln(pf)

regress lc `vars'
estimates store est_pols

*INCISO (b)*

*Opción 1*

regress lc `vars'
predict resid, residuals

summarize id
local ids=`r(max)'

summarize year
local years=`r(max)'-`r(min)'+1

generate w=.
local a1=1
local a2=`years'
forvalues i=1(1)`ids' {
	mkmat resid in `a1'/`a2', matrix(resid`i')
	matrix sigma`i'=resid`i''*resid`i'/`years'
	replace w=sigma`i'[1,1] in `a1'/`a2'
	local a1=`a1'+`years'
	local a2=`a2'+`years'
}

regress lc `vars' [aweight=1/w]

estimates store est_fgls1

*Opción 2*

generate resid2=resid^2
generate ln_resid2=ln(resid2)
regress ln_resid2 i.id
predict ln_resid2_hat, xb
generate resid2_hat=exp(ln_resid2_hat)

regress lc `vars' [aweight=1/resid2_hat]
estimates store est_fgls2

hetregress lc `vars', het(i.id) twostep
estimates store est_fgls3

esttab est_pols est_fgls1 est_fgls2 est_fgls3, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("POLS" "FGLS1" "FGLS2" "FGLS3")


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


clear all
global seed=12345
set seed $seed

global beta0=1
global beta1=1
global reps=1000
global T=2

matrix define omega=(1,0\0,4)

*PROGRAMA*

program define simulation, rclass

	*Seteo*
	drop _all
	local N=$N
	local T=$T
	local NT=`N'*`T'
	set obs `NT'
	egen id=seq(), from(1) to(`N') block(`T')
	egen t=seq(), from(1) to(`T')

	*Variables*
	generate x=runiform(1,20)
	generate u=.
	replace u=rnormal(0,omega[1,1]^(1/2)) if (t==1)
	replace u=rnormal(0,omega[2,2]^(1/2)) if (t==2)
	generate y=${beta1}+${beta2}*x+u

	*Estimación*
	regress y x
	predict resid, residuals
	generate w=.
	forvalues t=1(1)`T' {
		mkmat resid if (t==`t'), matrix(resid`t')
		matrix sigma`t'=resid`t''*resid`t'/`N'
		replace w=sigma`t'[1,1] if (t==`t')
	}
	regress y x [aweight=1/w]

	*Resultados*
	test x=${beta1}
	return scalar pvalue_b1_1=r(p)
	test x=0.8
	return scalar pvalue_b1_08=r(p)

end

*SIMULACIONES*

local samples="5 500"
local cols: word count `samples'

matrix define   results = J(2,`cols',.)
matrix rownames results = "tam_test_1" "poder_test_08"
matrix colnames results = "n_5" "n_500"

local i=1
quietly foreach N of local samples {

	noisily display as text "Simulaciones con tamaño de muestra N=" as result `N'

	*Simulación*
	global N=`N'
	simulate pvalue_b1_1_N`N'=r(pvalue_b1_1) pvalue_b1_08_N`N'=r(pvalue_b1_08), reps(${reps}) seed(${seed}): simulation

	*Base resultados*
	generate n=_n
	if (`N'!=5) {
		merge 1:1 n using "results_base"
		drop _merge
	}
	order _all, sequential
	order n, first
	save "results_base", replace

	*Matriz resultados*
	count if (pvalue_b1_1_N`N'<0.01)
	matrix results [1,`i']=r(N)/${reps}*100
	count if (pvalue_b1_08_N`N'<0.01)
	matrix results [2,`i']=r(N)/${reps}*100

	local i=`i'+1

}

*RESULTADOS FINALES*

drop _all
matrix list results
matrix define results_t=results'
svmat results_t, names(col)

local i=1
generate N=.
foreach N of local samples {
	replace N=`N' in `i'
	local i=`i'+1
}

order N, first
save "results_matriz", replace