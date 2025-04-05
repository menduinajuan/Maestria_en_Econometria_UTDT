clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/7. Econometría de Datos de Panel/Trabajos Prácticos/Trabajo Práctico N° 2/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "cornwell", clear
describe

xtset county year
xtdescribe

local vars="lprbarr lprbconv lprbpris lavgsen lpolpc d82 d83 d84 d85 d86 d87"

*INCISO (a)*

regress lcrmrte `vars', vce(cluster county)
estimates store est_pols

foreach var of varlist lcrmrte `vars' {
	by county: egen mean_`var'=mean(`var')
}

*INCISO (b)*

foreach var of varlist lcrmrte `vars' {
	generate within_`var'=`var'-mean_`var'
}

regress within_lcrmrte within_lprbarr within_lprbconv within_lprbpris within_lavgsen within_lpolpc within_d82-within_d87, noconstant
estimates store est_within

*INCISO (d)*

xtreg lcrmrte `vars', fe
estimates store est_fe

esttab est_within est_fe,	se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("WITHIN" "FE") ///
							rename(within_lprbarr lprbarr within_lprbconv lprbconv within_lprbpris lprbpris within_lavgsen lavgsen within_lpolpc lpolpc within_d82 d82 within_d83 d83 within_d84 d84 within_d85 d85 within_d86 d86 within_d87 d87)

*INCISO (e)*

regress D.lcrmrte D.lprbarr D.lprbconv D.lprbpris D.lavgsen D.lpolpc D.d82 D.d83 D.d84 D.d85 D.d86 D.d87, noconstant
estimates store est_fd

esttab est_pols est_fe est_fd,	se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("POLS" "FE" "FD") ///
								rename(D.lprbarr lprbarr D.lprbconv lprbconv D.lprbpris lprbpris D.lavgsen lavgsen D.lpolpc lpolpc D.d82 d82 D.d83 d83 D.d84 d84 D.d85 d85 D.d86 d86 D.d87 d87)


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


use "murder", clear
describe

xtset id year
xtdescribe

local vars="exec unem d90 d93"

*INCISO (a)*

regress mrdrt `vars'
estimates store est_pols

*INCISO (c)*

regress mrdrte `vars' i.id
estimates store est_lsdv

xtreg mrdrt `vars', fe
estimates store est_fe

esttab est_lsdv est_fe,	se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("LSDV" "FE") drop(*.id)

matrix define b_fe=e(b)
matrix define V_fe=e(V)

*INCISO (d)*

generate cd90=.
replace cd90=1 if (year==90)
replace cd90=-1 if (year==93)

generate cd93=.
replace cd93=0 if (year==90)
replace cd93=1 if (year==93)

regress cmrdrte cexec cunem cd90 cd93, noconstant
estimates store est_fd

esttab est_lsdv est_fe est_fd, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("LSDV" "FE" "FD") rename(cexec exec cunem unem cd90 d90 cd93 d93) drop(*.id)

*INCISO (f)*

mkmat mrdrte, matrix(Y)
mkmat exec unem d90 d93, matrix(X)
matrix define D=[-1,1,0\0,-1,1]
matrix list D

matrix define DtD=D'*D
matrix define aux=I(51)#DtD
matrix define XtX=X'*aux*X
matrix define XtY=X'*aux*Y
matrix define bfd=invsym(XtX)*XtY
matrix list bfd

matrix define DtD=D'*inv(D*D')*D
matrix define IkronDtD=I(51)#DtD
matrix define XtX=X'*IkronDtD*X
matrix define XtY=X'*IkronDtD*Y
matrix define bfdgls=invsym(XtX)*XtY
matrix list bfdgls

*INCISO (g)*

xtreg mrdrt `vars', re
estimates store est_re

esttab est_lsdv est_fe est_fd est_re, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("LSDV" "FE" "FD" "RE") drop(*.id) rename(cexec exec cunem unem cd90 d90 cd93 d93)

matrix define b_re=e(b)
matrix define V_re=e(V)

hausman est_fe est_re

matrix define V=V_fe-V_re
matrix list V
matrix eigenvalues r c=V
matrix list r
matrix list c
matrix define det_V=det(V)
matrix list det_V

matrix define VV=V[1..2,1..2]
matrix list VV
matrix eigenvalues r c=VV
matrix list r
matrix list c
matrix define det_VV=det(VV)
matrix list det_VV
matrix define V_inv=invsym(VV)
matrix list V_inv
matrix define b=b_fe-b_re
matrix list b
matrix define bb=b[1,1..2]
matrix list bb

matrix define chi2=bb*V_inv*bb'
matrix list chi2
display as text "El P-valor es" as result 1-chi2(2,chi2[1,1])


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


clear all
global seed=12345
set seed $seed

global beta=1
global sigma_mu=1
global sigma_nu=1
global reps=1000
global T=10

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
	xtset id t

	*Variables*
	generate x=rnormal()
	generate mu=.
	forvalues id=1(1)`N' {
		local aux=rnormal(0,${sigma_mu}^(1/2))
		replace mu=`aux' if (id==`id')
	}
	generate nu=rnormal(0,${sigma_nu}^(1/2))
	generate y=${beta}*x+mu+nu

	*POLS*
	regress y x
	return scalar beta_pols=e(b)[1,1]

	*FE*
	xtreg y x, fe
	return scalar beta_fe=e(b)[1,1]

	*RE*
	xtreg y x, re
	return scalar beta_re=e(b)[1,1]	

end

*SIMULACIONES*

local models="pols fe re"
local samples="5 10 30 50 100 500"
local cols: word count `samples'

matrix define   results = J(9,`cols',.)
matrix rownames results = "media_beta_pols" "de_beta_pols" "rmse_beta_pols"	///
						  "media_beta_fe"	"de_beta_fe"   "rmse_beta_fe"	///
						  "media_beta_re"	"de_beta_re"   "rmse_beta_re"
matrix colnames results = "N_5" "N_10" "N_30" "N_50" "N_100" "N_500"

local i=1
quietly foreach N of local samples {

	noisily display as text "Simulaciones con tamaño de muestra N=" as result `N'

	*Simulación*
	global N=`N'
	simulate beta_pols_N`N'=r(beta_pols) beta_fe_N`N'=r(beta_fe) beta_re_N`N'=r(beta_re), reps(${reps}) seed(${seed}): simulation

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
	local j=0
	foreach model of local models {	
		summarize beta_`model'_N`N'
		matrix results [`j'+1,`i']=r(mean)
		matrix results [`j'+2,`i']=r(sd)
		generate rmse_`model'=(beta_`model'_N`N'-${beta})^2
		summarize rmse_`model'
		matrix results [`j'+3,`i']=sqrt(r(mean))
		local j=`j'+3
	}

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


*##############################################################################*
								* EJERCICIO 4 *
*##############################################################################*


use "wagepan", clear
describe

xtset nr year
xtdescribe

*INCISO (a)*

local vars="d81-d87"

regress lwage `vars'
estimates store est_pols

xtreg lwage `vars', re
estimates store est_re

xtreg lwage `vars', fe
estimates store est_fe

regress D.lwage D.(`vars'), noconstant
estimates store est_fd

esttab est_pols est_re est_fe est_fd, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("POLS" "RE" "FE" "FD") ///
									  rename(D.d81 d81 D.d82 d82 D.d83 d83 D.d84 d84 D.d85 d85 D.d86 d86 D.d87 d87)

*INCISO (b)*

local vars="d81-d87 educ black hisp"

regress lwage `vars'
estimates store est_pols

xtreg lwage `vars', re
estimates store est_re

xtreg lwage `vars', fe
estimates store est_fe

esttab est_pols est_re est_fe, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("POLS" "RE" "FE")

*INCISO (d)*

regress lwage `vars', vce(cluster nr)
estimates store est_pols

*INCISO (e)*

xtreg lwage `vars', re robust
estimates store est_re

esttab est_pols est_re, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("POLS (robust)" "RE (robust)")