clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/7. Econometría de Datos de Panel/Trabajos Prácticos/Trabajo Práctico N° 0/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*



use "mus03data", clear
describe

local vars="suppins phylim actlim totchr age female income"

*INCISO (a)*

summarize totexp ltotexp `vars'
keep if (totexp>0)

matrix accum XtX=`vars'
matrix list XtX
matrix vecaccum YtX=ltotexp `vars'
matrix list YtX

matrix define b=invsym(XtX)*(YtX)'
matrix colnames b="beta"
matrix list b

scalar K=rowsof(XtX)
scalar N=_N

matrix accum YtY=ltotexp, noconstant
matrix list YtY
matrix define ete=YtY-b'*XtX'*b
matrix list ete
matrix define s2=ete/(N-K)
matrix list s2
matrix define V=s2*invsym(XtX)
matrix list V

matrix define Vcoef=vecdiag(V)
matrix list Vcoef
matrix define Vdiag=diag(Vcoef)
matrix list Vdiag
matrix invVdiag=invsym(Vdiag)
matrix list invVdiag
matrix chol_invVdiag=cholesky(invVdiag)
matrix list chol_invVdiag
matrix define seinv=vecdiag(chol_invVdiag)'
matrix list seinv
matrix seinv=(vecdiag(cholesky(invsym(diag(vecdiag(V))))))'
matrix list seinv

matrix define se=vecdiag(invsym(chol_invVdiag))'
matrix colnames se="se"
matrix list se

matrix define t=hadamard(b,seinv)
matrix colnames t="t"
matrix list t

matrix define results=(b,se,t)
matrix colnames results="beta" "se" "t"
matrix list results

*INCISO (b)*

regress ltotexp `vars'

*INCISO (c)*

test totchr

*INCISO (d)*

test (suppins=0) (phylim=0) (actlim=0) (totchr=0) (age=0) (female=0) (income=0)


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


*INCISO (a)*


use "mus08psidextract", clear
describe

order id t, first
sort id t

xtset id t
xtdescribe

*INCISO (b)*

use "pigweights", clear
describe

reshape long weight, i(id) j(t)

order id t, first
sort id t

xtset id t
xtdescribe

*INCISO (c)*

clear all
set seed 12345

local NT=5000
local N=500
local T=10
set obs `NT'

egen id=seq(), from(1) to(`N') block(`T')
egen t=seq(), from(1) to(`T')

generate x=rnormal()
generate u=rnormal()
generate y=1+x+u

xtset id t
xtdescribe
xtsum

regress y x


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


clear all
global seed=12345
set seed $seed

global beta1=1
global beta2=1
global beta3=1
global reps=1000

*PROGRAMA*

program define simulation, rclass

	*Seteo*
	drop _all
	set obs $N

	*Variables*
	generate x2=rnormal(0,5)
	generate x3=rnormal(0,5)
	generate e=rnormal(0,5)
	generate u=sqrt(exp(-1+0.2*x2))*e
	generate y=${beta1}+${beta2}*x2+${beta3}*x3+u

	*OLS*
	regress y x2 x3
	test x3=${beta3}
	return scalar pvalue_ols=r(p)
	return scalar beta1_ols=e(b)[1,3]
	return scalar beta2_ols=e(b)[1,1]
	return scalar beta3_ols=e(b)[1,2]

	*GLS*
	generate w=exp(-1+0.2*x2)
	regress y x2 x3 [aweight=1/w]
	test x3=${beta3}
	return scalar pvalue_gls=r(p)
	return scalar beta1_gls=e(b)[1,3]
	return scalar beta2_gls=e(b)[1,1]
	return scalar beta3_gls=e(b)[1,2]

	*FGLS*
	regress y x2 x3
	predict r, residuals
	generate r2=r^2
	generate ln_r2=ln(r2)
	regress ln_r2 x2
	predict ln_r2_hat, xb
	generate r2_hat=exp(ln_r2_hat)
	regress y x2 x3 [aweight=1/r2_hat]
	test x3=${beta3}
	return scalar pvalue_fgls=r(p)
	return scalar beta1_fgls=e(b)[1,3]
	return scalar beta2_fgls=e(b)[1,1]
	return scalar beta3_fgls=e(b)[1,2]

end

*SIMULACIONES*

local models="ols gls fgls"
local samples="10 20 30 100 200 500"
local cols: word count `samples'

matrix define   results = J(30,`cols',.)
matrix rownames results = "tam_test_1_ols" "media_b1_ols" "mediana_b1_ols" "de_b1_ols" "media_b2_ols" "mediana_b2_ols" "de_b2_ols" "media_b3_ols" "mediana_b3_ols" "de_b3_ols" ///
						  "tam_test_1_gls" "media_b1_gls" "mediana_b1_gls" "de_b1_gls" "media_b2_gls" "mediana_b2_gls" "de_b2_gls" "media_b3_gls" "mediana_b3_gls" "de_b3_gls" ///
						  "tam_test_1_fgls" "media_b1_fgls" "mediana_b1_fgls" "de_b1_fgls" "media_b2_fgls" "mediana_b2_fgls" "de_b2_fgls" "media_b3_fgls" "mediana_b3_fgls" "de_b3_fgls"
matrix colnames results = "n_10" "n_20" "n_30" "n_100" "n_200" "n_500"

local i=1
quietly foreach N of local samples {

	noisily display as text "Simulaciones con tamaño de muestra N=" as result `N'

	*Simulación*
	global N=`N'
	simulate pvalue_ols_N`N'=r(pvalue_ols)		beta1_ols_N`N'=r(beta1_ols)		beta2_ols_N`N'=r(beta2_ols)		beta3_ols_N`N'=r(beta3_ols)		///
			 pvalue_gls_N`N'=r(pvalue_gls)		beta1_gls_N`N'=r(beta1_gls)		beta2_gls_N`N'=r(beta2_gls)		beta3_gls_N`N'=r(beta3_gls)		///
			 pvalue_fgls_N`N'=r(pvalue_fgls)	beta1_fgls_N`N'=r(beta1_fgls)	beta2_fgls_N`N'=r(beta2_fgls)	beta3_fgls_N`N'=r(beta3_fgls),	///
			 reps(${reps}) seed(${seed}): simulation

	*Base resultados*
	generate n=_n
	if (`N'!=10) {
		merge 1:1 n using "results_base"
		drop _merge
	}
	order _all, sequential
	order n, first
	save "results_base", replace

	*Matriz resultados*
	local j=1
	foreach model of local models {
		count if (pvalue_`model'_N`N'<0.01)
		matrix results [`j',`i']=r(N)/${reps}*100
		forvalues beta=1(1)3 {
			summarize beta`beta'_`model'_N`N', detail
			matrix results [`j'+1,`i']=r(mean)
			matrix results [`j'+2,`i']=r(p50)
			matrix results [`j'+3,`i']=r(sd)
			local j=`j'+3
		}
		local j=`j'+1
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