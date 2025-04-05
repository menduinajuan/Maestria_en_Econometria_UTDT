clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/3. Análisis Estadístico Multivariado/Trabajos Prácticos/Trabajo Práctico N° 2/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "ine", clear
describe

local vars="alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
local cols: word count `vars'

*INCISO (a)*

summarize `vars'
summarize `vars', detail
tabstat `vars', statistics(mean variance cv)
correlate `vars'
correlate `vars', covariance
pcorr `vars'

*INCISO (b)*

pca `vars', covariance
matrix define eigenvalues_cov=e(Ev)
matrix define eigenvectors_cov=e(L)
matrix list eigenvalues_cov
matrix list eigenvectors_cov

pca `vars', correlation
matrix define eigenvalues_cor=e(Ev)
matrix define eigenvectors_cor=e(L)
matrix list eigenvalues_cor
matrix list eigenvectors_cor

*INCISO (c)*

*(i)*

screeplot, title("PCA" "(basado en matriz de correlaciones)", color(black)) ytitle("Autovalor") xtitle("Componente") yline(1, lcolor(red))

*(ii)*

matrix define	prop = J(`cols',2,.)
matrix rownames prop = "Comp1" "Comp2" "Comp3" "Comp4" "Comp5" "Comp6" "Comp7" "Comp8" "Comp9" "Comp10" "Comp11"
matrix colnames prop = "comp" "prop"

local traza=0
forvalues i=1(1)`cols' {
	local traza=`traza'+eigenvalues_cor[1,`i']
}

forvalues i=1(1)`cols' {
	matrix prop [`i',1]=`i'
	matrix prop [`i',2]=eigenvalues_cor[1,`i']/`traza'
}

matrix list prop

preserve
drop _all
svmat prop, names(col)
generate prop_acum=sum(prop)
graph bar prop, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
				ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%") ///
				title("Porcentaje de varianza explicada por cada componente" "(basado en matriz de correlaciones)", color(black)) ytitle("")

graph bar prop_acum, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
					 ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 1.0 "100%") ///
					 title("Porcentaje acumulado de varianza explicada por cada componente" "(basado en matriz de correlaciones)", color(black)) ytitle("") yline(0.8, lcolor(red))
restore

*(iii)*

local varianza_media=0
forvalues i=1(1)`cols' {
	local varianza_media=`varianza_media'+eigenvalues_cor[1,`i']
}
local varianza_media=`varianza_media'/`cols'
display as text "Varianza media = " as result `varianza_media'

*INCISO (d)*

pca `vars', components(3) correlation


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


biplot `vars',	dim(2 1) std alpha(0.5) xnegate autoaspect table ///
				rowopts(msize(tiny) mlabel(comunidad) mlabsize(tiny)) ///
				colopts(mcolor(green) lcolor(green) mlabsize(tiny) mlabcolor(green)) ///
				title("Biplot (c = 0.5)" "(basado en matriz de correlaciones)", color(black)) ytitle("Dimensión 2") xtitle("Dimensión 1") ///
				yline(0, lcolor(red)) xline(0, lcolor(red))


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


biplot `vars',	dim(2 1) std alpha(0) xnegate table ///
				rowopts(msize(tiny) mlabel(comunidad) mlabsize(tiny)) ///
				colopts(mcolor(green) lcolor(green) mlabsize(tiny) mlabcolor(green)) ///
				title("Biplot (c = 0)" "(basado en matriz de correlaciones)", color(black)) ytitle("Dimensión 2") xtitle("Dimensión 1") ///
				yline(0, lcolor(red)) xline(0, lcolor(red))

biplot `vars',	dim(3 1) std alpha(0) xnegate autoaspect table ///
				rowopts(msize(tiny) mlabel(comunidad) mlabsize(tiny)) ///
				colopts(mcolor(green) lcolor(green) mlabsize(tiny) mlabcolor(green)) ///
				title("Biplot (c = 0)" "(basado en matriz de correlaciones)", color(black)) ytitle("Dimensión 3") xtitle("Dimensión 1") ///
				yline(0, lcolor(red)) xline(0, lcolor(red))


*##############################################################################*
								* EJERCICIO 4 *
*##############################################################################*


use "wb", clear
describe

local vars=""
forvalues i=4(1)12 {
	local vars="`vars' var`i'"
}
local cols: word count `vars'

*INCISO (a)*

summarize `vars'
summarize `vars', detail
tabstat `vars', statistics(mean variance cv)
correlate `vars'
correlate `vars', covariance
pcorr `vars'

pca `vars', covariance
matrix define eigenvalues_cov=e(Ev)
matrix define eigenvectors_cov=e(L)
matrix list eigenvalues_cov
matrix list eigenvectors_cov

pca `vars', correlation
matrix define eigenvalues_cor=e(Ev)
matrix define eigenvectors_cor=e(L)
matrix list eigenvalues_cor
matrix list eigenvectors_cor

*INCISO (b)*

screeplot, title("PCA" "(basado en matriz de correlaciones)", color(black)) ytitle("Autovalor") xtitle("Componente") yline(1, lcolor(red))

matrix define	prop = J(`cols',2,.)
matrix rownames prop = "Comp1" "Comp2" "Comp3" "Comp4" "Comp5" "Comp6" "Comp7" "Comp8"
matrix colnames prop = "comp" "prop"

local traza=0
forvalues i=1(1)`cols' {
	local traza=`traza'+eigenvalues_cor[1,`i']
}

forvalues i=1(1)`cols' {
	matrix prop [`i',1]=`i'
	matrix prop [`i',2]=eigenvalues_cor[1,`i']/`traza'
}

matrix list prop

preserve
drop _all
svmat prop, names(col)
generate prop_acum=sum(prop)
graph bar prop, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
				ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%") ///
				title("Porcentaje de varianza explicada por cada componente" "(basado en matriz de correlaciones)", color(black)) ytitle("")
graph bar prop_acum, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
					 ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 1.0 "100%") ///
					 title("Porcentaje acumulado de varianza explicada por cada componente" "(basado en matriz de correlaciones)", color(black)) ytitle("") yline(0.8, lcolor(red))
restore


*INCISO (e)*

pca `vars', components(3) correlation
predict u1-u3

scatter u2 u1, title("Scatterplot" "(basado en matriz de correlaciones)", color(black)) ytitle("Componente 2") xtitle("Componente 1") ///
				 yline(0, lcolor(red)) xline(0, lcolor(red)) mlabel(var1)

*INCISO (f)*

biplot `vars',	dim(2 1) std alpha(0.5) xnegate autoaspect table ///
				rowopts(msize(tiny) mlabel(var1) mlabsize(tiny)) ///
				colopts(mcolor(green) lcolor(green) mlabsize(tiny) mlabcolor(green)) ///
				title("Biplot (c = 0.5)" "(basado en matriz de correlaciones)", color(black)) ytitle("Dimensión 2") xtitle("Dimensión 1") ///
				yline(0, lcolor(red)) xline(0, lcolor(red))


*##############################################################################*
								* EJERCICIO 5 *
*##############################################################################*


import delimited "hspendusa2009", clear
describe

local cols=12
local vars=""
forvalues i=1(1)`cols' {
	local vars="`vars' s`i'"
}

summarize `vars'
summarize `vars', detail
tabstat `vars', statistics(mean variance cv)
correlate `vars'
correlate `vars', covariance
pcorr `vars'

pca `vars', covariance
matrix define eigenvalues_cov=e(Ev)
matrix define eigenvectors_cov=e(L)
matrix list eigenvalues_cov
matrix list eigenvectors_cov

pca `vars', correlation
matrix define eigenvalues_cor=e(Ev)
matrix define eigenvectors_cor=e(L)
matrix list eigenvalues_cor
matrix list eigenvectors_cor

screeplot, title("PCA" "(basado en matriz de correlaciones)", color(black)) ytitle("Autovalor") xtitle("Componente") yline(1, lcolor(red))

matrix define	prop = J(`cols',2,.)
matrix rownames prop = "Comp1" "Comp2" "Comp3" "Comp4" "Comp5" "Comp6" "Comp7" "Comp8" "Comp9" "Comp10" "Comp11" "Comp12"
matrix colnames prop = "comp" "prop"

local traza=0
forvalues i=1(1)`cols' {
	local traza=`traza'+eigenvalues_cor[1,`i']
}

forvalues i=1(1)`cols' {
	matrix prop [`i',1]=`i'
	matrix prop [`i',2]=eigenvalues_cor[1,`i']/`traza'
}

matrix list prop

preserve
drop _all
svmat prop, names(col)
generate prop_acum=sum(prop)
graph bar prop, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
				ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%") ///
				title("Porcentaje de varianza explicada por cada componente" "(basado en matriz de correlaciones)", color(black)) ytitle("")
graph bar prop_acum, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
					 ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 1.0 "100%") ///
					 title("Porcentaje acumulado de varianza explicada por cada componente" "(basado en matriz de correlaciones)", color(black)) ytitle("") yline(0.8, lcolor(red))
restore

pca `vars', components(4) correlation
predict u1-u4

scatter u2 u1,	title("Scatterplot" "(basado en matriz de correlaciones)", color(black)) ytitle("Componente 2") xtitle("Componente 1") ///
				yline(0, lcolor(red)) xline(0, lcolor(red)) mlabel(meta)

biplot `vars',	dim(2 1) std alpha(0.5) ynegate xnegate autoaspect table ///
				rowopts(msize(tiny) mlabel(meta) mlabsize(tiny)) ///
				colopts(mcolor(green) lcolor(green) mlabsize(tiny) mlabcolor(green)) ///
				title("Biplot (c = 0.5)" "(basado en matriz de correlaciones)", color(black)) ytitle("Dimensión 2") xtitle("Dimensión 1") ///
				yline(0, lcolor(red)) xline(0, lcolor(red))