clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/6. Microeconometría I/Examen/Datos"


capture log close
log using "Examen Final", replace


*##############################################################################*
***************** PRIMERA PARTE: LOGIT, PROBIT, TOBIT Y HECKMAN ****************
*##############################################################################*


use "mroz", clear
describe


********************************************************************************
								* EJERCICIO 1 *
********************************************************************************


*INCISO (a)*

summarize, separator(0)

*INCISO (b)*

summarize if (lfp==1)
summarize if (lfp==0)

*INCISO (c)*

generate prin=faminc-whrs*ww
summarize prin

*INCISO (d)*

generate lww=ln(ww)
summarize lww

generate ax2=ax*ax
generate wa2=wa*wa

regres lww wa we cit ax ax2
predict flww, xb

summarize flww if (lfp==0), separator(0)
summarize lww if (lfp==1), separator(0)

generate lww1=.
replace lww1=lww if (lfp==1)
replace lww1=flww if (lfp==0)

summarize lww1


********************************************************************************
								* EJERCICIO 2 *
********************************************************************************


*INCISO (a)*

summarize whrs if (lfp==0)
regress whrs kl6 k618 wa we lww1 prin

*INCISO (b)*

display as text "La elasticidad de las horas trabajadas con respecto a los salarios es " as result _b[lww1]/1500
display as text "La elasticidad de las horas trabajadas con respecto a la renta de la propiedad es " as result _b[prin]*1000/1500
display as text "La respuesta implícita de las horas trabajadas ante un cambio de 1 dólar en el salario es " as result _b[lww1]/4.5
display as text "La respuesta implícita de las horas trabajadas ante un aumento de $1.000 en el ingreso de la propiedad es " as result _b[prin]*1000


********************************************************************************
								* EJERCICIO 3 *
********************************************************************************


local vars="lww1 kl6 k618 wa we un cit prin"

*INCISO (a)*

regress lfp `vars'
estimates store est_ols_lfp
predict lfp_ols, xb
summarize lfp_ols
matrix define betas_ols=e(b)

count if (lfp_ols<0)
local obs_menor_0=r(N)
display as text "Observaciones con valores ajustados negativos: " as result `obs_menor_0'

count if (lfp_ols>1)
local obs_mayor_1=r(N)
display as text "Observaciones con valores ajustados mayores que 1: " as result `obs_mayor_1'

*INCISO (b)*

logit lfp `vars'
estimates store est_logit_lfp
predict lfp_logit_pr, pr
summarize lfp_logit_pr
matrix define betas_logit=e(b)
estat classification

esttab est_ols_lfp est_logit_lfp, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS" "Logit")

*INCISO (c)*

probit lfp `vars'
estimates store est_probit_lfp
predict lfp_probit_pr, pr
summarize lfp_probit_pr
matrix define betas_probit=e(b)
estat classification

esttab est_logit_lfp est_probit_lfp, se star(* 0.10 ** 0.05 *** 0.01) pr2 mtitles("Logit" "Probit")

matrix define prueba_logit=(betas_ols',0.25*betas_logit')
matrix prueba_logit [9,2]=prueba_logit[9,2]+0.5
matrix colnames prueba_logit="Betas OLS" "Prueba Betas Logit"
matrix list prueba_logit

*INCISO (d)*

logit lfp `vars'
margins
display as text "La probabilidad log-likelihood maximizada de la muestra en el modelo Logit es " as result r(b)[1,1]

probit lfp `vars'
margins
display as text "La probabilidad log-likelihood maximizada de la muestra en el modelo Probit es " as result r(b)[1,1]

local p1=428/753
local z1=invnormal(`p1')
local fz1=normalden(`z1')
display as text "p1: " as result `p1'
display as text "z1: " as result `z1'
display as text "fz1: " as result `fz1'
matrix define dp1_logit=`p1'*(1-`p1')*betas_logit
matrix define dp1_probit=`fz1'*betas_probit
matrix define cociente1=J(1,9,.)
forvalues i=1(1)9 {
	matrix cociente1 [1,`i']=dp1_logit[1,`i']/dp1_probit[1,`i']
}
matrix define dp1=(dp1_logit',dp1_probit',cociente1')
matrix colnames dp1="dP1 Logit" "dP1 Probit" "L/P"
matrix list dp1

local p2=0.9
local z2=invnormal(`p2')
local fz2=normalden(`z2')
display as text "p2: " as result `p2'
display as text "z2: " as result `z2'
display as text "fz2: " as result `fz2'
matrix define dp2_logit=`p2'*(1-`p2')*betas_logit
matrix define dp2_probit=`fz2'*betas_probit
matrix define cociente2=J(1,9,.)
forvalues i=1(1)9 {
	matrix cociente2 [1,`i']=dp2_logit[1,`i']/dp2_probit[1,`i']
}
matrix define dp2=(dp2_logit',dp2_probit',cociente2')
matrix colnames dp2="dP2 Logit" "dP2 Probit" "L/P"
matrix list dp2

*INCISO (e)*

matrix define betas_logit_prueba1=3^(1/2)/3.14159*betas_logit
matrix define cociente1=J(1,9,.)
forvalues i=1(1)9 {
	matrix cociente1 [1,`i']=betas_probit[1,`i']/betas_logit_prueba1[1,`i']
}
matrix define prueba1=(betas_probit',betas_logit_prueba1',cociente1')
matrix colnames prueba1="Betas Probit" "Betas Logit Prueba 1" "P/L"
matrix list prueba1

matrix define betas_logit_prueba2=0.625*betas_logit
matrix define cociente2=J(1,9,.)
forvalues i=1(1)9 {
	matrix cociente2 [1,`i']=betas_probit[1,`i']/betas_logit_prueba2[1,`i']
}
matrix define prueba2=(betas_probit',betas_logit_prueba2',cociente2')
matrix colnames prueba2="Betas Probit" "Betas Logit Prueba 2" "P/L"
matrix list prueba2



********************************************************************************
								* EJERCICIO 4 *
********************************************************************************


local vars="kl6 k618 wa we prin lww1"

*INCISO (a)*

regress whrs `vars' if (lfp==1)
regress whrs `vars' if (lfp==1), robust
estimates store est_ols_whrs
matrix define betas_ols_whrs=e(b)

*INCISO (b)*

local p=428/753
matrix define betas_ols_whrs_trans=betas_ols_whrs/`p'
matlist betas_ols_whrs_trans'

*INCISO (c)*

tobit whrs `vars', ll(0)
predict whrs_tobit1, xb
estimates store est_tobit_whrs1

*INCISO (d)*

local p=428/753
local z=invnormal(`p')
local fz=normalden(`z')
display as text "p: " as result `p'
display as text "z: " as result `z'
display as text "fz: " as result `fz'

local beta=_b[lww1]
local A=1-`z'*`fz'/`p'-(`fz'/`p')^2

summarize whrs_tobit if (lfp==1)
local EH=r(mean)
local sigma=e(b)[1,8]^(1/2)

margins, dydx(lww1)
display as text "Del cambio total en las horas trabajadas debido a un cambio de $1 en el salario, la cantidad que resulta de los cambios en las horas trabajadas de aquellos que ya están trabajando es " as result `p'*`beta'*`A'
display as text "Del cambio total en las horas trabajadas debido a un cambio de $1 en el salario, la cantidad que proviene de los nuevos ingresantes a la fuerza laboral es " as result `EH'*`fz'*`beta'/`sigma'
display as text "La proporción del efecto total sobre las horas trabajadas de un cambio en cualquiera de las variables que se deriva de aquellas mujeres que ya están trabajando es " as result `A'

*INCISO (e)*

tobit whrs `vars' if (lfp==1), ll(0)
predict whrs_tobit2, xb
estimates store est_tobit_whrs2

esttab est_ols_whrs est_tobit_whrs2, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS Condicional" "Tobit Condicional")


********************************************************************************
								* EJERCICIO 5 *
********************************************************************************


local vars="wa wa2 we cit ax"

*INCISO (a)*

regress lww1 `vars' if (lfp==1)
predict lww_ols, xb
matrix define betas_ols_lww=e(b)'
matrix list betas_ols_lww

*INCISO (c)*

matrix define   parametros_a = J(10,2,.)
matrix rownames parametros_a = "d" "a0" "a1" "a2" "a3" "a4" "a5" "a6" "a7" "a8"
matrix colnames parametros_a = "Indirecto" "Directo"

regress whrs `vars' kl6 k618 prin un
matrix define betas_ols_whrs=e(b)'

matrix parametros_a [1,1]=betas_ols_whrs[5,1]/betas_ols_lww[5,1]						/*d*/
matrix parametros_a [2,1]=betas_ols_lww[6,1]-betas_ols_whrs[10,1]/parametros_a[1,1]		/*a0*/
matrix parametros_a [3,1]=betas_ols_lww[1,1]-betas_ols_whrs[1,1]/parametros_a[1,1]		/*a1*/
matrix parametros_a [4,1]=betas_ols_lww[2,1]-betas_ols_whrs[2,1]/parametros_a[1,1]		/*a2*/
matrix parametros_a [5,1]=betas_ols_lww[3,1]-betas_ols_whrs[3,1]/parametros_a[1,1]		/*a3*/
matrix parametros_a [6,1]=betas_ols_lww[4,1]-betas_ols_whrs[4,1]/parametros_a[1,1]		/*a4*/
matrix parametros_a [7,1]=-betas_ols_whrs[6,1]/parametros_a[1,1]						/*a5*/
matrix parametros_a [8,1]=-betas_ols_whrs[7,1]/parametros_a[1,1]						/*a6*/
matrix parametros_a [9,1]=-betas_ols_whrs[8,1]/parametros_a[1,1]						/*a7*/
matrix parametros_a [10,1]=-betas_ols_whrs[9,1]/parametros_a[1,1]						/*a8*/

generate wa_t=wa*betas_ols_lww[1,1]
generate wa2_t=wa2*betas_ols_lww[2,1]
generate we_t=we*betas_ols_lww[3,1]
generate cit_t=cit*betas_ols_lww[4,1]
generate ax_t=ax*betas_ols_lww[5,1]

regress whrs wa_t wa2_t we_t cit_t ax_t kl6 k618 prin un
matrix define betas_ols_whrs_t=e(b)'

matrix parametros_a [1,2]=betas_ols_whrs_t[5,1]/betas_ols_lww[5,1]						/*d*/
matrix parametros_a [2,2]=betas_ols_lww[6,1]-betas_ols_whrs_t[10,1]/parametros_a[1,2]	/*a0*/
matrix parametros_a [3,2]=betas_ols_lww[1,1]-betas_ols_whrs_t[1,1]/parametros_a[1,2]	/*a1*/
matrix parametros_a [4,2]=betas_ols_lww[2,1]-betas_ols_whrs_t[2,1]/parametros_a[1,2]	/*a2*/
matrix parametros_a [5,2]=betas_ols_lww[3,1]-betas_ols_whrs_t[3,1]/parametros_a[1,2]	/*a3*/
matrix parametros_a [6,2]=betas_ols_lww[4,1]-betas_ols_whrs_t[4,1]/parametros_a[1,2]	/*a4*/
matrix parametros_a [7,2]=-betas_ols_whrs_t[6,1]/parametros_a[1,2]						/*a5*/
matrix parametros_a [8,2]=-betas_ols_whrs_t[7,1]/parametros_a[1,2]						/*a6*/
matrix parametros_a [9,2]=-betas_ols_whrs_t[8,1]/parametros_a[1,2]						/*a7*/
matrix parametros_a [10,2]=-betas_ols_whrs_t[9,1]/parametros_a[1,2]						/*a8*/

matrix list parametros_a

*INCISO (d)*

matrix define   parametros_b = J(9,1,.)
matrix rownames parametros_b = "d" "b0" "b1" "b2" "b3" "b4" "b5" "b6" "b7"
matrix colnames parametros_b = "Indirecto"

matrix parametros_b [1,1]=betas_ols_whrs[5,1]/betas_ols_lww[5,1]						/*d*/
matrix parametros_b [2,1]=betas_ols_lww[6,1]-betas_ols_whrs[10,1]/parametros_b[1,1]		/*b0*/
matrix parametros_b [3,1]=betas_ols_lww[1,1]-betas_ols_whrs[1,1]/parametros_b[1,1]		/*b1*/
matrix parametros_b [4,1]=betas_ols_lww[2,1]-betas_ols_whrs[2,1]/parametros_b[1,1]		/*b2*/
matrix parametros_b [5,1]=betas_ols_lww[3,1]-betas_ols_whrs[3,1]/parametros_b[1,1]		/*b3*/
matrix parametros_b [6,1]=-betas_ols_whrs[6,1]/parametros_b[1,1]						/*b4*/
matrix parametros_b [7,1]=-betas_ols_whrs[7,1]/parametros_b[1,1]						/*b5*/
matrix parametros_b [8,1]=-betas_ols_whrs[8,1]/parametros_b[1,1]						/*b6*/
matrix parametros_b [9,1]=-betas_ols_whrs[9,1]/parametros_b[1,1]						/*b7*/

matrix list parametros_b

*INCISO (e)*




********************************************************************************
								* EJERCICIO 6 *
********************************************************************************


local varsA="kl6 k618 wa we wa2 we2 wawe wa3 we3 wa2we wawe2 wfed wmed un cit prin"
local varsB="kl6 k618 wa we prin"

*INCISO (a)*

*generate ax2=ax*ax
*generate wa2=wa*wa
generate we2=we*we
generate wa3=wa2*wa
generate we3=we2*we
generate wawe=wa*we
generate wa2we=wa2*we
generate wawe2=wa*we2

probit lfp `varsA'
predict lfp_probit1, xb
generate invr1=normalden(lfp_probit1)/(1-normal(lfp_probit1))

probit lfp `varsA' ax ax2
predict lfp_probit2, xb
generate invr2=normalden(lfp_probit2)/(1-normal(lfp_probit2))

*INCISO (b)*

regress lww `varsA' if (lfp==1), robust
predict lww_hat1, xb
regress lww `varsA' ax ax2 if (lfp==1), robust
predict lww_hat2, xb

regress lww `varsA' invr1 if (lfp==1), robust
predict lww_hat3, xb
regress lww `varsA' ax ax2 invr2 if (lfp==1), robust
predict lww_hat4, xb

*INCISO (c)*

regress whrs `varsB' lww_hat1 if (lfp==1), robust
regress whrs `varsB' lww_hat3 invr1 if (lfp==1), robust

regress whrs `varsB' lww_hat2 if (lfp==1), robust
regress whrs `varsB' lww_hat4 invr2 if (lfp==1), robust

*INCISO (e)*

regress lfp `varsA'
predict lfp_ols1, xb
replace lfp_ols1=lfp_ols1-1

regress lfp `varsA' ax ax2
predict lfp_ols2, xb
replace lfp_ols2=lfp_ols2-1

regress lww `varsA' lfp_ols1 if (lfp==1), robust
predict lww_hat5, xb
regress lww `varsA' lfp_ols2 if (lfp==1), robust
predict lww_hat6, xb

regress whrs `varsB' lww_hat5 lfp_ols1 if (lfp==1), robust
regress whrs `varsB' lww_hat6 lfp_ols2 if (lfp==1), robust



********************************************************************************
								* EJERCICIO 7 *
********************************************************************************


local vars="kl6 k618 wa we wa2 we2 wawe wa3 we3 wa2we wawe2 wfed wmed un cit prin"

*INCISO (a)*

generate vprin=(1-mtr)*prin
generate ltax=ln(1-mtr)
generate ltww=ltax+lww1

*INCISO (b)*

/*
generate ax2=ax*ax
generate wa2=wa*wa
generate we2=we*we
generate wa3=wa2*wa
generate we3=we2*we
generate wawe=wa*we
generate wa2we=wa2*we
generate wawe2=wa*we2
*/

probit lfp `vars'
predict lfp_probit3, xb
generate invr=normalden(lfp_probit3)/(1-normal(lfp_probit3))

*INCISO (c)*

*ivregress 2sls whrs ltax kl6 k618 wa we prin vprin invr (ltww = `vars' invr), robust

regress ltww `vars' invr, robust
predict ltww_hat1, xb
regress whrs ltww_hat1 ltax kl6 k618 wa we prin vprin invr, robust

test ltax prin
test (_b[ltax]=-_b[ltww_hat1]) (_b[vprin]=0)
testnl (_b[ltax]=-_b[ltww_hat1]) (_b[vprin]=0)

*INCISO (d)*

probit lfp `vars' ax ax2
predict lfp_probit4, xb
generate invr_new=normalden(lfp_probit4)/(1-normal(lfp_probit4))

regress ltww `vars' invr_new, robust
predict ltww_hat2, xb
regress whrs ltww_hat2 ltax kl6 k618 wa we prin vprin ax ax2 invr_new, robust

test ltax prin
test (_b[ltax]=-_b[ltww_hat2]) (_b[vprin]=0)
testnl (_b[ltax]=-_b[ltww_hat2]) (_b[vprin]=0)


********************************************************************************
								* EJERCICIO 8 *
********************************************************************************


*INCISO (c)*



*INCISO (d)*




*##############################################################################*
******************* SEGUNDA PARTE: ANÁLISIS DE SUPERVIVENCIA *******************
*##############################################################################*


use "linfosarcoma", clear
describe


********************************************************************************
				* INTRODUCIÓN AL ANÁLISIS DE SUPERVIVENCIA *
********************************************************************************


*EJERCICIO 1*

stset months, fail(died=1)
stdescribe
stsum

sts list, survival
sts graph, survival ci

*EJERCICIO 2*

sts list, cumhaz
sts graph, cumhaz ci
sts graph, hazard ci

*EJERCICIO 3*

sts graph if (rad==1), survival ci
sts graph if (rad==0), survival ci

sts graph if (chemo==1), survival ci
sts graph if (chemo==0), survival ci

*EJERCICIO 4*

generate terapy=.
replace terapy=1 if (rad==0 & chemo==0)
replace terapy=2 if (rad==0 & chemo==1)
replace terapy=3 if (rad==1 & chemo==0)
replace terapy=4 if (rad==1 & chemo==1)

sts graph if (terapy==1), survival ci
sts graph if (terapy==2), survival ci
sts graph if (terapy==3), survival ci
sts graph if (terapy==4), survival ci

*EJERCICIO 5*

sts generate surv=s
*ranksum s, by(terapy)
ranksum s, by(rad)
ranksum s, by(chemo)


********************************************************************************
		* ESTIMANDO UN MODELO DE COX (COX PROPORTIONAL HAZARD MODEL) *
********************************************************************************


local vars="age rad chemo"

*EJERCICIO 1*

stset days, fail(died=1)
stdescribe
stsum

stcox `vars', nohr
stcox `vars'
estimates store est_cox1

*EJERCICIO 2*

xi: stcox `vars' i.clinic, nohr
xi: stcox `vars' i.clinic
estimates store est_cox2

*EJERCICIO 3*

test _Iclinic_2 _Iclinic_3 _Iclinic_4 _Iclinic_5 _Iclinic_6 _Iclinic_7
lrtest est_cox1 est_cox2

stcox `vars', nohr
estat ic
local aic_s=r(S)[1,5]
xi: stcox `vars' i.clinic, nohr
estat ic
local aic_c=r(S)[1,5]

display as text "El AIC del modelo más simple (sin clinic) es " as result `aic_s'
display as text "El AIC del modelo más completo (con clinic) es " as result `aic_c'

*EJERCICIO 4*

xi: stcox age rad#chemo i.clinic, nohr
xi: stcox age rad#chemo i.clinic
estimates store est_cox3

*EJERCICIO 5*

stcurve, hazard

*EJERCICIO 6*

stcox age rad#chemo, strata(clinic) nohr
stcox age rad#chemo, strata(clinic)
estimates store est_cox4

stcox age rad#chemo chemo#clinic, nohr
stcox age rad#chemo chemo#clinic
estimates store est_cox5

*EJERCICIO 7*

xi: stcox age i.terapy i.clinic, nohr
xi: stcox age i.terapy i.clinic
estimate store est_cox6

sts graph, cumhaz by(terapy)

*EJERCICIO 8*

stphplot, by(terapy)
estat phtest


********************************************************************************
							* MODELOS PARAMÉTRICOS *
********************************************************************************


local vars="age age2 rad chemo rad_chemo"

generate age2=age*age
generate rad_chemo=rad*chemo

*EJERCICIO 1*

stset days, fail(died=1)
stdescribe
stsum

streg `vars', distribution(exponential) robust nohr
estimates store est_param_expo
streg `vars', distribution(weibull) robust nohr
estimates store est_param_weib
streg `vars', distribution(lognormal) robust
estimates store est_param_logn

esttab est_param_expo est_param_weib est_param_logn, se mtitles("Exponencial" "Weibull" "Lognormal")

*EJERCICIO 3*

streg `vars', distribution(exponential) robust nohr
estat ic
local aic_e=r(S)[1,5]
local bic_e=r(S)[1,6]
streg `vars', distribution(weibull) robust nohr
estat ic
local aic_w=r(S)[1,5]
local bic_w=r(S)[1,6]
streg `vars', distribution(lognormal) robust
estat ic
local aic_l=r(S)[1,5]
local bic_l=r(S)[1,6]

display as text "El AIC del modelo con distribución exponencial es " as result `aic_e'
display as text "El AIC del modelo con distribución Weibull es " as result `aic_w'
display as text "El AIC del modelo con distribución lognormal es " as result `aic_l'

display as text "El BIC del modelo con distribución exponencial es " as result `bic_e'
display as text "El BIC del modelo con distribución Weibull es " as result `bic_w'
display as text "El BIC del modelo con distribución lognormal es " as result `bic_l'

*EJERCICIO 4*

streg `vars', distribution(weibull) robust nohr
stcurve, survival at(chemo==1)
stcurve, survival at(chemo==0)

streg `vars', distribution(lognormal) robust
stcurve, survival at(chemo==1)
stcurve, survival at(chemo==0)

*EJERCICIO 5*

streg `vars', distribution(weibull) robust nohr
stcurve, hazard at(rad==1)
stcurve, hazard at(rad==0)

streg `vars', distribution(lognormal) robust
stcurve, hazard at(rad==1)
stcurve, hazard at(rad==0)

*EJERCICIO 6*

streg `vars', distribution(weibull) robust nohr
stcurve, survival
estat ic

streg `vars', distribution(lognormal) robust
stcurve, survival
estat ic

sts graph, survival


log close