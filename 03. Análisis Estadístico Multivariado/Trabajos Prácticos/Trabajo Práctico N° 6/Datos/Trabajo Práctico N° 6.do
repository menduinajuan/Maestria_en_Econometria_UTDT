clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/3. Análisis Estadístico Multivariado/Trabajos Prácticos/Trabajo Práctico N° 6/Datos"


quietly include "ftest"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "eurosec", clear
describe

local cols=9
local vars=""
forvalues i=1(1)`cols' {
	local vars="`vars' s`i'"
}

forvalues i=1(1)`cols' {
	display as text "Factors: " as result `i'
	ftest `vars', f(`i') c(0.05)
}
local factors=5

mvtest normality `vars', stats(all)

factor `vars', ml factors(`factors')
loadingplot, factors(`factors')
rotate, orthogonal varimax
loadingplot, factors(`factors')

matrix define uniqueness=e(Psi)'
matrix define psi=diag(uniqueness)
matrix define ones=J(rowsof(uniqueness),1,1)
matrix define commonality=ones-uniqueness
matrix colnames commonality="commonality"

matrix list uniqueness
matrix list psi
matrix list ones
matrix list commonality

predict f1-f`factors', norotated

matrix define lambda=e(L)
matrix define sigma=e(C)
matrix define inv_sigma=inv(sigma)
matrix define inv_psi=inv(psi)
matrix define I=I(`factors')

matrix list sigma
matrix list inv_sigma
matrix list inv_psi
matrix list I

local vars_std=""
foreach var of local vars {
	egen `var'_std=std(`var')
	local vars_std="`vars_std' `var'_std"
}

mkmat `vars_std', matrix(X)
matrix list X

matrix define f1=inv(I+lambda'*inv_psi*lambda)*lambda'*inv_psi*X'
matrix define f2=lambda'*inv_sigma*X'

matlist f1'
matlist f2'


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


*EJERCICIO 1*

use "ind", clear
describe

local cols=17
local vars=""
forvalues i=1(1)`cols' {
	local vars="`vars' x`i'"
}

forvalues i=1(1)`cols' {
	display as text "Factors: " as result `i'
	ftest `vars', f(`i') c(0.05)
}
local factors=4

mvtest normality `vars', stats(all)

factor `vars', factors(`factors')
loadingplot, factors(`factors')
rotate, orthogonal varimax
loadingplot, factors(`factors')

matrix define uniqueness=e(Psi)'
matrix define psi=diag(uniqueness)
matrix define ones=J(rowsof(uniqueness),1,1)
matrix define commonality=ones-uniqueness
matrix colnames commonality="commonality"

matrix list uniqueness
matrix list psi
matrix list ones
matrix list commonality

predict f1-f`factors'

*EJERCICIO 2*

use "ipc2dig", clear
describe

local cols=26
local vars=""
forvalues i=1(1)`cols' {
	local vars="`vars' div`i'"
}

forvalues i=1(1)`cols' {
	display as text "Factors: " as result `i'
	ftest `vars', f(`i') c(0.05)
}
local factors=4

mvtest normality `vars', stats(all)

factor `vars', factors(`factors')
loadingplot, factors(`factors')
rotate, orthogonal varimax
loadingplot, factors(`factors')

matrix define uniqueness=e(Psi)'
matrix define psi=diag(uniqueness)
matrix define ones=J(rowsof(uniqueness),1,1)
matrix define commonality=ones-uniqueness
matrix colnames commonality="commonality"

matrix list uniqueness
matrix list psi
matrix list ones
matrix list commonality

predict f1-f`factors'


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


use "sachs", clear
describe

local vars="gdp95 lnd100km pop100km lnd100cr pop100cr dens95c dens95i airdist ciffob95 landarea open6590 urbpop95 pop95"
local cols: word count `vars'

forvalues i=1(1)`cols' {
	display as text "Factors: " as result `i'
	ftest `vars', f(`i') c(0.05)
}
local factors=4

mvtest normality `vars', stats(all)

factor `vars', factors(`factors')
loadingplot, factors(`factors')
rotate, orthogonal varimax
loadingplot, factors(`factors')

matrix define uniqueness=e(Psi)'
matrix define psi=diag(uniqueness)
matrix define ones=J(rowsof(uniqueness),1,1)
matrix define commonality=ones-uniqueness
matrix colnames commonality="commonality"

matrix list uniqueness
matrix list psi
matrix list ones
matrix list commonality

predict f1-f`factors'


*##############################################################################*
								* EJERCICIO 4 *
*##############################################################################*


use "heritage", clear
describe

local vars="propertyrights judicaleffectiveness governmentintegrity taxburden govtspending fiscalhealth businessfreedom laborfreedom monetaryfreedom tradefreedom investmentfreedom financialfreedom"
local cols: word count `vars'

forvalues i=1(1)`cols' {
	display as text "Factors: " as result `i'
	ftest `vars', f(`i') c(0.05)
}
local factors=3

mvtest normality `vars', stats(all)

factor `vars', factors(`factors')
loadingplot, factors(`factors')
rotate, orthogonal varimax
loadingplot, factors(`factors')

matrix define uniqueness=e(Psi)'
matrix define psi=diag(uniqueness)
matrix define ones=J(rowsof(uniqueness),1,1)
matrix define commonality=ones-uniqueness
matrix colnames commonality="commonality"

matrix list uniqueness
matrix list psi
matrix list ones
matrix list commonality

predict f1-f`factors'