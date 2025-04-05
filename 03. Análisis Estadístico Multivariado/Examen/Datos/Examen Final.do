clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/3. Análisis Estadístico Multivariado/Examen/Datos"


capture log close
log using "Examen Final", replace


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


/*
*Abro la base*

import excel "Base", sheet("Data") firstrow clear
describe

*Reshape de la base*

drop indicator_name
reshape long yr, i(country indicator) j(year)
replace indicator=subinstr(indicator,".","_",.)
reshape wide yr, i(country year) j(indicator) string

save "Base_aux", replace														// Guardo una base auxiliar para seguir porque el segundo reshape es muy costoso
*/

*Selecciono un subconjunto de indicadores para un año de referencia*

use "Base_aux", clear

local year=2020
local indicators="yrEG_ELC_ACCS_ZS yrSP_POP_DPND yrEN_ATM_CO2E_PC yrBN_CAB_XOKA_GD_ZS yrNY_GDP_MKTP_KD yrNY_GDP_PCAP_KD yrNE_CON_GOVT_ZS yrNE_GDI_TOTL_ZS yrIT_NET_USER_ZS yrSP_DYN_LE00_IN"
keep country iso year `indicators'
keep if year==`year'

*Elimino observaciones missings*

foreach var of local indicators {
	keep if `var'!=.
}

*Renombro variables*

foreach var of local indicators {
	local name=subinstr("`var'","yr","",.)
	rename `var' `name'
}

*Etiqueto los indicadores*

label variable country				"Country"
label variable iso					"ISO-code"
label variable year					"Year"
label variable EG_ELC_ACCS_ZS		"Access to electricity (% of population)"
label variable SP_POP_DPND			"Age dependency ratio (% of working-age population)"
label variable EN_ATM_CO2E_PC		"CO2 emissions (metric tons per capita)"
label variable BN_CAB_XOKA_GD_ZS	"Current account balance (% of GDP)"
label variable NY_GDP_MKTP_KD		"GDP (constant 2015 US$)"
label variable NY_GDP_PCAP_KD		"GDP per capita (constant 2015 US$)"
label variable NE_CON_GOVT_ZS		"General government final consumption expenditure (% of GDP)"
label variable NE_GDI_TOTL_ZS		"Gross capital formation (% of GDP)"
label variable IT_NET_USER_ZS		"Individuals using the Internet (% of population)"
label variable SP_DYN_LE00_IN		"Life expectancy at birth, total (years)"

*Guardo la base*

order country iso year
sort country
save "Base", replace


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


*Abro la base*

use "Base", clear
describe

*Lista de variables*

local vars="BN_CAB_XOKA_GD_ZS EG_ELC_ACCS_ZS EN_ATM_CO2E_PC IT_NET_USER_ZS NE_CON_GOVT_ZS NE_GDI_TOTL_ZS NY_GDP_MKTP_KD NY_GDP_PCAP_KD SP_DYN_LE00_IN SP_POP_DPND"
local cols: word count `vars'

*Análisis descriptivo*

summarize `vars'
summarize `vars', detail
tabstat `vars', statistics(mean variance cv)

*Medidas de variabilidad global*

correlate `vars'
matrix define C=r(C)
correlate `vars', covariance
matrix define S=r(C)

foreach mat in C S {

	local var_tot_`mat'=trace(`mat')
	local var_media_`mat'=`var_tot_`mat''/`cols'
	local var_gen_`mat'=det(`mat')
	local var_efec_`mat'=det(`mat')^(1/`cols')

	display as text "Varianza total `mat' = "			as result `var_tot_`mat''
	display as text "Varianza media `mat' = "			as result `var_media_`mat''
	display as text "Varianza generalizada `mat' = "	as result `var_gen_`mat''
	display as text "Varianza efectiva `mat' = "		as result `var_efec_`mat''

}


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


correlate `vars'
correlate `vars', covariance


*##############################################################################*
								* EJERCICIO 4 *
*##############################################################################*


*PCA basado en matriz de varianzas y covarianzas*

pca `vars', covariance
matrix define eigenvalues_cov=e(Ev)
matrix define eigenvectors_cov=e(L)
matrix list eigenvalues_cov
matrix list eigenvectors_cov

screeplot, title("PCA" "(basado en matriz de varianzas y covarianzas)", color(black)) ytitle("Autovalor") xtitle("Componente")

matrix define	prop_cov = J(`cols',2,.)
matrix rownames prop_cov = "Comp1" "Comp2" "Comp3" "Comp4" "Comp5" "Comp6" "Comp7" "Comp8" "Comp9" "Comp10"
matrix colnames prop_cov = "comp" "prop"

local traza=0
forvalues i=1(1)`cols' {
	local traza=`traza'+eigenvalues_cov[1,`i']
}

forvalues i=1(1)`cols' {
	matrix prop_cov [`i',1]=`i'
	matrix prop_cov [`i',2]=eigenvalues_cov[1,`i']/`traza'
}

matrix list prop_cov

preserve
svmat prop_cov, names(col)
generate prop_acum=sum(prop)
graph bar prop, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
				ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 1.0 "100%") ///
				title("Porcentaje de varianza explicada por cada componente" "(basado en matriz de varianzas y covarianzas)", color(black)) ytitle("")
graph bar prop_acum, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
					 ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 1.0 "100%") ///
					 title("Porcentaje acumulado de varianza explicada por cada componente" "(basado en matriz de varianzas y covarianzas)", color(black)) ytitle("")
restore

*PCA basado en matriz de correlaciones*

pca `vars', correlation
matrix define eigenvalues_cor=e(Ev)
matrix define eigenvectors_cor=e(L)
matrix list eigenvalues_cor
matrix list eigenvectors_cor

screeplot, title("PCA" "(basado en matriz de correlaciones)", color(black)) ytitle("Autovalor") xtitle("Componente") yline(1, lcolor(red))

matrix define	prop_cor = J(`cols',2,.)
matrix rownames prop_cor = "Comp1" "Comp2" "Comp3" "Comp4" "Comp5" "Comp6" "Comp7" "Comp8" "Comp9" "Comp10"
matrix colnames prop_cor = "comp" "prop"

local traza=0
forvalues i=1(1)`cols' {
	local traza=`traza'+eigenvalues_cor[1,`i']
}

forvalues i=1(1)`cols' {
	matrix prop_cor [`i',1]=`i'
	matrix prop_cor [`i',2]=eigenvalues_cor[1,`i']/`traza'
}

matrix list prop_cor

preserve
drop _all
svmat prop_cor, names(col)
generate prop_acum=sum(prop)
graph bar prop, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
				ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%") ///
				title("Porcentaje de varianza explicada por cada componente" "(basado en matriz de correlaciones)", color(black)) ytitle("")
graph bar prop_acum, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
					 ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 1.0 "100%") ///
					 title("Porcentaje acumulado de varianza explicada por cada componente" "(basado en matriz de correlaciones)", color(black)) ytitle("")
restore


*##############################################################################*
								* EJERCICIO 5 *
*##############################################################################*


local components=2
pca `vars', components(`components') correlation
predict u1-u`components'
correlate `vars' u1-u`components'


*##############################################################################*
								* EJERCICIO 6 *
*##############################################################################*


summarize u1-u`components'
summarize u1-u`components', detail
tabstat u1-u`components', statistics(mean variance cv)


*##############################################################################*
								* EJERCICIO 7 *
*##############################################################################*


biplot `vars',	dim(2 1) std alpha(0.5) ynegate autoaspect table ///
				rowopts(msize(tiny) mlabel(country) mlabsize(tiny)) ///
				colopts(mcolor(green) lcolor(green) mlabsize(tiny) mlabcolor(green)) ///
				title("Biplot sobre matriz de datos (c = 0.5)" "(basado en matriz de correlaciones)", color(black)) ytitle("Dimensión 2") xtitle("Dimensión 1") ///
				yline(0, lcolor(red)) xline(0, lcolor(red))


*##############################################################################*
								* EJERCICIO 8 *
*##############################################################################*


preserve

drop _all

svmat C, names(col)

generate variable=""
forvalues i=1(1)`cols' {
	local name: word `i' of `vars'
	replace variable="`name'" in `i'
}

order variable

pca `vars', components(`components') correlation
predict u1-u`components'

biplot `vars',	dim(2 1) std alpha(0.5) xnegate autoaspect table ///
				rowopts(msize(tiny) mlabel(variable) mlabsize(tiny)) ///
				colopts(mcolor(green) lcolor(green) mlabsize(tiny) mlabcolor(green)) ///
				title("Biplot sobre matriz de correlaciones (c = 0.5)", color(black)) ytitle("Dimensión 2") xtitle("Dimensión 1") ///
				yline(0, lcolor(red)) xline(0, lcolor(red))

restore


*##############################################################################*
							* EJERCICIOS 9, 10, 11 y 12 *
*##############################################################################*


quietly include "kmedtest"

local vars_clusters="u2 u1"

forvalues i=1(1)5 {
	kmedtest `vars_clusters', k(`i')
}
local groups=2

set seed 10
cluster kmeans `vars_clusters', k(`groups') generate(group)
graph twoway (scatter `vars_clusters' if (group==1)) (scatter `vars_clusters' if (group==2)), ///
													 title("Análisis de clusters con algoritmo k-medias", color(black)) ytitle("Componente 2") xtitle("Componente 1") ///
													 legend(label(1 "Grupo 1") label(2 "Grupo 2"))

local metodos="singlelinkage averagelinkage"
foreach met of local metodos {
	cluster `met' `vars_clusters', name(cluster_`met')
	cluster stop cluster_`met'
	cluster generate cluster_`met'=group(`groups'), name(cluster_`met')
	cluster dendrogram cluster_`met', title("Dendrograma para análisis de clusters con método jerárquico `met'", color(black))
}


*##############################################################################*
								* EJERCICIO 13 *
*##############################################################################*


local factors=1

*Tests de normalidad multivariada*

mvtest normality `vars', stats(all)

*Análisis factorial*

factor `vars', factors(`factors')
predict f`factors'
mkmat f`factors', matrix(factors`factors')

matrix define uniqueness`factors'=e(Psi)'
matrix define psi`factors'=diag(uniqueness`factors')
matrix define lambda`factors'=e(L)
matrix define phi`factors'=e(Phi)
matrix define sigma`factors'=e(C)

*Comunalidad de las variables*

matrix define ones`factors'=J(rowsof(uniqueness`factors'),1,1)
matrix define commonality`factors'=ones`factors'-uniqueness`factors'
matrix colnames commonality`factors'="commonality`factors'"
matrix list uniqueness`factors'
matrix list commonality`factors'

*Análisis de los residuos*

matrix define means`factors'=e(means)'
matrix define ones=J(_N,1,1)
matrix define D`factors'=ones*means`factors''
mkmat `vars', matrix(X)
matrix define X_centered`factors'=X-D`factors'
matrix define resids`factors'=X_centered`factors''-lambda`factors'*factors`factors''
matrix define resids`factors'=resids`factors''
matrix list resids`factors'

preserve
drop _all
svmat resids`factors'
mvtest normality resids`factors'*, stats(all) 
mvtest covariances resids`factors'*, diagonal
restore

*Estadísticos de bondad del ajuste*

forvalues i=1(1)`cols' {
    local rho2_`i'=1-uniqueness`factors'[`i',1]^2/1
    display as text "rho2_`i' = " as result `rho2_`i''
}

local r2=1-(det(psi`factors')/det(sigma`factors'))^(1/`cols')
display as text "r2 = " as result `r2'


*##############################################################################*
								* EJERCICIO 14 *
*##############################################################################*


matrix define covariance`factors'_aux=lambda`factors'*phi`factors'*lambda`factors''+psi`factors'
local row=rowsof(covariance`factors'_aux)
local col=colsof(covariance`factors'_aux)
matrix define covariance`factors'=covariance`factors'_aux

forvalues i=1(1)`row' {

	forvalues j=1(1)`col' {
		matrix covariance`factors' [`i',`j']=round(covariance`factors'_aux[`i',`j'],0.0001)
	}

}

matrix list covariance`factors'
correlate `vars'


*##############################################################################*
								* EJERCICIOS 15 *
*##############################################################################*


*EJERCICIO 13 (con dos factores)*

local factors=2

*Tests de normalidad multivariada*

mvtest normality `vars', stats(all)

*Análisis factorial*

factor `vars', factors(`factors')
predict f1_new f`factors'_new
mkmat f1_new f`factors'_new, matrix(factors`factors')

matrix define uniqueness`factors'=e(Psi)'
matrix define psi`factors'=diag(uniqueness`factors')
matrix define lambda`factors'=e(L)
matrix define phi`factors'=e(Phi)
matrix define sigma`factors'=e(C)

*Comunalidad de las variables*

matrix define ones`factors'=J(rowsof(uniqueness`factors'),1,1)
matrix define commonality`factors'=ones`factors'-uniqueness`factors'
matrix colnames commonality`factors'="commonality`factors'"
matrix list uniqueness`factors'
matrix list commonality`factors'

*Análisis de los residuos*

matrix define means`factors'=e(means)'
matrix define ones=J(_N,1,1)
matrix define D`factors'=ones*means`factors''
mkmat `vars', matrix(X)
matrix define X_centered`factors'=X-D`factors'
matrix define resids`factors'=X_centered`factors''-lambda`factors'*factors`factors''
matrix define resids`factors'=resids`factors''
matrix list resids`factors'
matrix list resids1

preserve
drop _all
svmat resids`factors'
mvtest normality resids`factors'*, stats(all) 
mvtest covariances resids`factors'*, diagonal
restore

*Estadísticos de bondad del ajuste*

forvalues i=1(1)`cols' {
    local rho2_`i'=1-uniqueness`factors'[`i',1]^2/1	
    display as text "rho2_`i' = " as result `rho2_`i''
}

local r2=1-(det(psi`factors')/det(sigma`factors'))^(1/`cols')
display as text "r2 = " as result `r2'

*EJERCICIO 14 (con dos factores)*

matrix define covariance`factors'_aux=lambda`factors'*phi`factors'*lambda`factors''+psi`factors'
local row=rowsof(covariance`factors'_aux)
local col=colsof(covariance`factors'_aux)
matrix define covariance`factors'=covariance`factors'_aux

forvalues i=1(1)`row' {

	forvalues j=1(1)`col' {
		matrix covariance`factors' [`i',`j']=round(covariance`factors'_aux[`i',`j'],0.0001)
	}

}

matrix list covariance`factors'
correlate `vars'

*FTEST*

quietly include "ftest"

forvalues i=1(1)`cols' {
	display as text "Factors: " as result `i'
	ftest `vars', f(`i') c(0.05)
}


*##############################################################################*
								* EJERCICIOS 16 *
*##############################################################################*


pca `vars', components(`components') correlation
factor `vars', factors(`factors')

save "Base_resultados", replace


log close