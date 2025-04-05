clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/3. Análisis Estadístico Multivariado/Trabajos Prácticos/Trabajo Práctico N° 1/Datos"


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

label variable pais "País" 
label variable s1 "Agricultura" 
label variable s2 "Minería"
label variable s3 "Industria"
label variable s4 "Energía"
label variable s5 "Construcción"
label variable s6 "Servicios Industriales"
label variable s7 "Finanzas"
label variable s8 "Servicios"
label variable s9 "Transporte y Telecomunicaciones"

*INCISO (a)*

summarize `vars'
summarize `vars', detail
tabstat `vars', statistics(mean variance cv)

*INCISO (b)*

correlate `vars', covariance
matrix define S=r(C)
matrix list S

*INCISO (c)*

mkmat `vars', matrix(X)
matrix list X
local fils=rowsof(X)
local cols=colsof(X)

local var_tot=trace(S)
local var_media=`var_tot'/`cols'
local var_gen=det(S)
local var_efec=det(S)^(1/`cols')

display as text "Varianza total = " as result `var_tot'
display as text "Varianza media = " as result `var_media'
display as text "Varianza generalizada = " as result `var_gen'
display as text "Varianza efectiva = " as result `var_efec'

*INCISO (d)*

correlate `vars'

*INCISO (e)*

regress s2 s1 s3-s9
local r2_reg=e(r2)
predict resid, residuals
summarize resid, detail
local var_resid_reg=r(Var)

display as text "Varianza de los residuos = " as result `var_resid_reg'
display as text "Coeficiente de determinación = " as result `r2_reg'

matrix define S_inv=inv(S)
matrix list S_inv
local S_inv_22=S_inv[2,2]
local var_resid_S=1/`S_inv_22'
display as text "Varianza de los residuos mediante matriz de precisión = " as result `var_resid_S'
display as text "Varianza de los residuos mediante regresión = " as result `var_resid_reg'

local r2_S=1-1/(S[2,2]*S_inv[2,2])
display as text "Coeficiente de determinación mediante matriz de precisión = " as result `r2_S'
display as text "Coeficiente de determinación mediante regresión = " as result `r2_reg'

*INCISO (f)*

pcorr `vars'

regress s1 s3-s9
predict resid_s1, residuals

regress s2 s3-s9
predict resid_s2, residuals

correlate resid_s1 resid_s2
local coef_corr_part_com=r(rho)
display as text "Coeficiente de correlación parcial = " as result `coef_corr_part_com'

local coef_corr_part_S=-S_inv[1,2]/sqrt(S_inv[1,1]*S_inv[2,2])
display as text "Coeficiente de correlación parcial = " as result `coef_corr_part_S'

*INCISO (g)*

correlate `vars'
matrix define C=r(C)

matrix symeigen Avec Aval=C
matrix list Aval

local p=0
forvalues i=1(1)`cols' {
	local p=`p'+Aval[1,`i']
}
display as text "Número de variables = " as result `p'

*INCISO (h)*

local coef_dep_efec=1-(det(C))^(1/(`cols'-1))
display as text "Coeficiente de dependencia efectiva = " as result `coef_dep_efec'


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


use "individual_t410", clear
describe
keep if (estado==1 & (ch06>15 & ch06!=.))

generate sector_empleo=substr(pp04b_cod,1,2)
destring sector_empleo, replace
replace sector_empleo=1 if (sector_empleo>=1 & sector_empleo<=5)
replace sector_empleo=2 if (sector_empleo>=10 & sector_empleo<=14)
replace sector_empleo=3 if (sector_empleo>=15 & sector_empleo<=37)
replace sector_empleo=4 if (sector_empleo==40)
replace sector_empleo=5 if (sector_empleo==45)
replace sector_empleo=6 if (sector_empleo>=50 & sector_empleo<=53)
replace sector_empleo=7 if (sector_empleo==64)
replace sector_empleo=8 if (sector_empleo>=65 & sector_empleo<=67)
replace sector_empleo=9 if (sector_empleo==41 | sector_empleo==55 | (sector_empleo>=60 & sector_empleo<=63) | (sector_empleo>=70 & sector_empleo<=74) | sector_empleo==80 | sector_empleo==85 | (sector_empleo>=90 & sector_empleo<=99))
replace sector_empleo=10 if (sector_empleo==75)

label define sector_empleo 1 "Agricultura, Ganadería, Caza y Pesca" 2 "Minería" 3 "Industria" 4 "Energía" 5 "Construcción" 6 "Comercio" 7 "Correo y Telecomunicaciones" 8 "Ss. Financieros" 9 "Otros Ss." 10 "Administración Pública" 
label values sector_empleo sector_empleo

tabulate sector_empleo, missing

order sector_empleo, after(pp04b_cod)
sort aglomerado sector_empleo

*INCISO (a)*

tabulate aglomerado sector_empleo, matcell(tabmat)

matrix define X=(tabmat/_N)*100
matrix list X
local fils=rowsof(X)
local cols=colsof(X)

drop _all
svmat X

local matrices="vector_media vector_var vector_cv"
foreach mat of local matrices {
	matrix define	`mat' = J(`cols',1,.)
	matrix rownames `mat' = "Agricultura_Ganadería_Caza_Pesca" "Minería" "Industria" "Energía" "Construcción" "Comercio" "Correo_Telecomunicaciones" "Ss._Financieros" "Otros Ss." "Administración_Pública"
	loc colname=subinstr("`mat'","vector_","",.)
	matrix colnames `mat' = "`colname'"
}

forvalues i=1(1)`cols' {
    summarize X`i'
	matrix vector_media [`i',1]=r(mean)
    matrix vector_var [`i',1]=r(Var)
    matrix vector_cv [`i',1]=r(sd)/r(mean)
}

foreach mat of local matrices {
	matrix list `mat'
}

*INCISO (b)*

correlate X*, covariance
matrix define S=r(C)

local var_tot=trace(S)
local var_media=`var_tot'/`cols'
local var_gen=det(S)
local var_efec=(det(S))^(1/`cols')

display as text "Varianza total = " as result `var_tot'
display as text "Varianza media = " as result `var_media'
display as text "Varianza generalizada = " as result  `var_gen'
display as text "Varianza efectiva = " as result `var_efec'

*INCISO (c)*

regress X9 X1-X8 X10
local r2_reg=e(r2)
predict resid, residuals
summarize resid, detail
local var_resid_reg=r(Var)

display as text "Varianza de los residuos = " as result `var_resid_reg'
display as text "Coeficiente de determinación = " as result `r2_reg'

matrix define S_inv=inv(S)
matrix list S_inv
local S_inv_99=S_inv[9,9]
local var_resid_S=1/`S_inv_99'
display as text "Varianza de los residuos mediante matriz de precisión = " as result `var_resid_S'
display as text "Varianza de los residuos mediante regresión = " as result `var_resid_reg'

local r2_S=1-1/(S[9,9]*S_inv[9,9])
display as text "Coeficiente de determinación mediante matriz de precisión = " as result `r2_S'
display as text "Coeficiente de determinación mediante regresión = " as result `r2_reg'

*INCISO (d)*

pcorr X9 X1-X8 X10

regress X6 X1-X5 X7 X8 X10
predict resid_s6, residuals

regress X9 X1-X5 X7 X8 X10
predict resid_s9, residuals

correlate resid_s6 resid_s9
local coef_corr_part_com=r(rho)
display as text "Coeficiente de correlación parcial = " as result `coef_corr_part_com'

local coef_corr_part_S=-S_inv[6,9]/sqrt(S_inv[6,6]*S_inv[9,9])
display as text "Coeficiente de correlación parcial = " as result `coef_corr_part_S'

*INCISO (e)*

correlate X*
matrix define C=r(C)

matrix symeigen Avec Aval=C
matrix list Aval

*INCISO (f)*

local coef_dep_efec=1-(det(C))^(1/(`cols'-1))
display as text "Coeficiente de dependencia efectiva = " as result `coef_dep_efec'


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


use "records", clear
describe

local vars="m_100 m_200 m_400 m_800 m_1500 km_5 km_10 maraton"
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
				ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 1.0 "100%") ///
				title("Porcentaje de varianza explicada por cada componente" "(basado en matriz de correlaciones)", color(black)) ytitle("")
graph bar prop_acum, over(comp) bargap(100) blabel(bar, format(%5.3g)) ///
					 ylabel(0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 1.0 "100%") ///
					 title("Porcentaje acumulado de varianza explicada por cada componente" "(basado en matriz de correlaciones)", color(black)) ytitle("")
restore

*INCISO (d)*

predict u_1 u_2
scatter u_2 u_1, title("Scatterplot" "(basado en matriz de correlaciones)", color(black)) ytitle("Componente 2") xtitle("Componente 1") ///
				 yline(0, lcolor(red)) xline(0, lcolor(red)) mlabel(pais)