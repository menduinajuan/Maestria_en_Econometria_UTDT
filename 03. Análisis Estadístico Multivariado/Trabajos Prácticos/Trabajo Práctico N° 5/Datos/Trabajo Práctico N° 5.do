clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/3. Análisis Estadístico Multivariado/Trabajos Prácticos/Trabajo Práctico N° 5/Datos"


quietly include "ftest"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "ind", clear
describe

local cols=17
local vars=""
forvalues i=1(1)`cols' {
	local vars="`vars' x`i'"
}

*INCISO (a)*

mvtest normality `vars', stats(all)

local vars_log=""
foreach var of local vars {
	generate `var'_log=log(`var')
	local vars_log="`vars_log' `var'_log"
}

mvtest normality `vars_log', stats(all)

*INCISO (b)*

factor `vars', pf

matrix define uniqueness=e(Psi)'
matrix define psi=diag(uniqueness)
matrix define lambda=e(L)
matrix define lambdat_lambda=lambda'*lambda
matrix define phi=e(Phi)
matrix define covariance_X=lambda*phi*lambda'+psi

matrix list uniqueness
matrix list psi
matrix list lambda
matrix list lambdat_lambda
matrix list phi
matrix list covariance_X
correlate `vars'

forvalues i=1(1)`cols' {
	display as text "Factors: " as result `i' 
	ftest `vars', f(`i') alpha(0.05)
}
local factors=6

*INCISO (c)*

factor `vars', pf factors(`factors')

matrix define uniqueness=e(Psi)'
matrix define psi=diag(uniqueness)
matrix define lambda=e(L)
matrix define lambdat_lambda=lambda'*lambda
matrix define phi=e(Phi)
matrix define covariance_X=lambda*phi*lambda'+psi

matrix list uniqueness
matrix list psi
matrix list lambda
matrix list lambdat_lambda
matrix list phi
matrix list covariance_X
correlate `vars', covariance

*INCISO (d)*

matrix define ones=J(rowsof(uniqueness),1,1)
matrix define commonality=ones-uniqueness
matrix colnames commonality="commonality"
matrix list commonality

matrix define lambda_lambdat=lambda*lambda'
matrix list lambda_lambdat


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


use "ipc2dig", clear
describe

local cols=26
local vars=""
forvalues i=1(1)`cols' {
	local vars="`vars' div`i'"
}

*INCISO (a)*

mvtest normality `vars', stats(all)

forvalues i=1(1)`cols' {
	display as text "Factors: " as result `i'
	ftest `vars', f(`i') alpha(0.05)
}
local factors=4

factor `vars', pf factors(`factors')

matrix define uniqueness=e(Psi)'
matrix define psi=diag(uniqueness)
matrix define lambda=e(L)
matrix define lambdat_lambda=lambda'*lambda
matrix define phi=e(Phi)
matrix define covariance_X=lambda*phi*lambda'+psi
matrix define sigma=e(C)

matrix list uniqueness
matrix list psi
matrix list lambda
matrix list lambdat_lambda
matrix list phi
matrix list covariance_X
correlate `vars'
matrix list sigma

*INCISO (b)*

predict f1-f`factors'
mkmat f1-f`factors', matrix(factors)
matrix list factors

*INCISO (c)*

matrix define means_X=e(means)'
matrix define ones=J(_N,1,1)
matrix define D=ones*means_X'
mkmat `vars', matrix(X)
matrix define X_centered=X-D

matrix list means_X
matrix list ones
matrix list D
matrix list X
matrix list X_centered

matrix define resids=X_centered'-lambda*factors'
matrix define resids=resids'
matrix list resids

preserve
drop _all
svmat resids
mvtest normality resids*, stats(all) 
mvtest covariances resids*, diagonal
restore

*INCISO (d)*

forvalues i=1(1)`cols' {
    local rho2_`i'=1-uniqueness[`i',1]^2/1
    display as text "rho2_`i' = " as result `rho2_`i''
}

local r2=1-(det(psi)/det(sigma))^(1/`cols')
display as text "r2 = " as result `r2'