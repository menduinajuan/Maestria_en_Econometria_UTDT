clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/3. Análisis Estadístico Multivariado/Trabajos Prácticos/Trabajo Práctico N° 4/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "ine", clear
describe
local vars="alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"

mvtest normality `vars', stats(all)
mvtest means `vars', zero


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


clear all
set seed 12345

local vars=""
forvalues i=1(1)8 {
	local vars="`vars' x`i'"
}

matrix define vector_means_1=(2,0.45,0.23,0.54,0.12,0.63,0.66,0.32)
matrix define vector_sds_1=(0.67,0.89,0.56,0.90,0.56,0.34,0.76,0.13)
drawnorm `vars', n(100) sds(vector_sds_1) means(vector_means_1)
save "ejercicio_2", replace

summarize `vars'

*INCISO (a)*

mvtest normality `vars', stats(all)

*INCISO (b)*

mvtest means `vars', zero

*INCISO (c)*

mvtest means `vars', equal

*INCISO (d)*

mvtest covariances `vars', spherical

*INCISO (e)*

mvtest covariances `vars', diagonal


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


drop _all
set seed 12345

local cols=8
local vars=""
forvalues i=1(1)`cols' {
	local vars="`vars' x`i'"
}

forvalues i=2(1)3 {
	preserve
	matrix define aux=J(1,8,`i'-1)
	matrix define vector_means_`i'=vector_means_1+aux
	matrix define vector_sds_`i'=vector_sds_1+aux
	if `i'==2 local n=50
	if `i'==3 local n=10
	drawnorm `vars', n(`n') sds(vector_sds_`i') means(vector_means_`i')
	generate id=`i'
	order id, first
	tempfile data_`i'
	save "`data_`i''", replace
	restore
}

drawnorm `vars', n(40) sds(vector_sds_1) means(vector_means_1)
generate id=1
order id, first
append using "`data_2'"
append using "`data_3'"
save "ejercicio_3", replace

summarize `vars'

*INCISO (a)*

mvtest normality `vars', stats(all)
mvtest means `vars', zero
mvtest means `vars', equal
mvtest covariances `vars', spherical
mvtest covariances `vars', diagonal

*INCISO (b)*

forvalues i=1(1)3 {
	display as text in red "PARTICIÓN `i': "
	mvtest normality `vars' if (id==`i'), stats(all)
	mvtest means `vars' if (id==`i'), zero
	mvtest means `vars' if (id==`i'), equal
	mvtest covariances `vars' if (id==`i'), spherical
	mvtest covariances `vars' if (id==`i'), diagonal
	display _n
}

*INCISO (c)*

*Opción 1*

local vars_log=""
foreach var of local vars {
	generate `var'_log=log(`var')
	local vars_log="`vars_log' `var'_log"
}

mvtest normality `vars_log', stats(all)
mvtest means `vars_log', zero
mvtest means `vars_log', equal
mvtest covariances `vars_log', spherical
mvtest covariances `vars_log', diagonal

*Opción 2*

matrix define means=(vector_means_1\vector_means_2\vector_means_3)'
matrix define weights=(0.4\0.5\0.1)
matrix aggregated_mean=means*weights
matrix list means
matrix list weights
matrix list aggregated_mean

forvalues i=1(1)3 {
	mkmat `vars' if (id==`i'), matrix(X)
	local fils=rowsof(X)
	matrix define ones=J(`fils',1,1)
	matrix mean_dif=vector_means_`i''-aggregated_mean
	matrix define var_b_`i'=mean_dif*mean_dif'	
	matrix define I=I(`fils') 
	matrix define P=I-(1/`fils')*ones*ones'
	matrix define S_`i'=1/(`fils'-1)*X'*P*X
}

matrix define var_b=0.4*var_b_1+0.5*var_b_2+0.1*var_b_3
matrix define var_w=0.4*S_1+0.5*S_2 + 0.1*S_3

matrix covariance_matrix=var_b+var_w
matrix list covariance_matrix

drop _all
capture drawnorm `vars', n(100) cov(covariance_matrix) means(aggregated_mean)
if (_rc!=0) {
	mata
		covariance_matrix=st_matrix("covariance_matrix")
		issymmetric(covariance_matrix)
		covariance_matrix=makesymmetric(covariance_matrix)
		issymmetric(covariance_matrix)
		st_matrix("covariance_matrix",covariance_matrix)
	end
}
matrix list covariance_matrix

drawnorm `vars', n(100) cov(covariance_matrix) means(aggregated_mean)

mvtest normality `vars', stats(all)
mvtest means `vars', zero
mvtest means `vars', equal
mvtest covariances `vars', spherical
mvtest covariances `vars', diagonal